public with sharing class evScheduleExtension_Controller {
   
    public Event__c event {get;set;}
    public Account acc {get;set;}
    public Id accId {get;set;}
    public List<Event_Session_Booking__c> sessionSpeakerList {get;set;}
    public Set<String> sessionSpeakerSet {get;set;}
    public List<dayGroupWrapper> groups {get; set;}
    public Event_Configuration__c agendaConfig {get;set;}
    
    //Delegate Fields
    public String delFirstName {get;set;}
    public String delLastName {get;set;}
    public String delCompany {get;set;}
    public String delTitle {get;set;}
    public String delMobile {get;set;}
    public String delEmail {get;set;}
    
    //Holds Temp Id for Session to book delegate on
    public String delAgendaItem {get;set;}
    
    public evScheduleExtension_Controller(ApexPages.StandardController stdController) {
        
        if (!Test.isRunningTest()) 
        { 
            stdController.addFields(new List<String>{'Event_Agenda__c', 'Theme__r.Template__c'});
        }
        
        event = (Event__c)stdController.getRecord();
        accId = ApexPages.currentPage().getParameters().get('accId'); 
        
        String eventId = event.Id;
        
        if (accId != null) 
        {
            acc = 
                [
                    SELECT
                    Id,
                    Name
                    FROM
                    Account
                    WHERE
                    Id =: accId
                    LIMIT 1
                ];
        }
        
        if(event.Event_Agenda__c != null)
        {
            agendaConfig = 
                [
                    SELECT
                    Id,
                    Disclaimer__c,
                    Agenda_Logo__c 
                    FROM
                    Event_Configuration__c 
                    WHERE
                    Id =: event.Event_Agenda__c
                ];
        }
        
        sessionSpeakerList = 
            [
                SELECT
                Id,
                Delegate__r.Full_Name__c
                FROM
                Event_Session_Booking__c 
                WHERE
                Session__r.Event_Function__c =: event.Id
                AND
                isSpeaker__c = true
                AND
                Invitation_Status__c = 'Confirmed'
            ];
        
        //Add speakers to Set to dedup
        sessionSpeakerSet = new Set<String>();
        
        for(Event_Session_Booking__c sb : sessionSpeakerList)
        {
            sessionSpeakerSet.add(sb.Delegate__r.Full_Name__c);
        }
        
        List<Event_Session__c> sessionList = new List<Event_Session__c>();
        
        String queryString = 
            'SELECT Id, Name, Date__c, Start_Time__c, Start_Time_Text__c, End_Time__c, End_Time_Text__c, Type__c, ' +
            'Scheduled_Delegates_Confirmed__c, Session_Bookings_Walk_Ins__c, Room__r.Name, Participating_Company__r.Name, ' +
            '(SELECT Id, Session__c, Event_Id__c, Session__r.Date__c, Session__r.Start_Time__c, ' +
            'Session__r.Start_Time_Text__c, Session__r.End_Time_Text__c, Session__r.End_Time__c, Session__r.Type__c, ' +
            'Session__r.Room__r.Name, Session__r.Participating_Company__r.Name, Delegate__r.Full_Name__c, ' +
            'Delegate__r.Company__c, Delegate__r.Contact__r.Name, Delegate__r.Account__r.Name, Invitation_Status__c, ' +
            'Attendance_Status__c ' +
            'FROM Session_Bookings__r ' +
            'WHERE (Invitation_Status__c = \'Confirmed\' OR Invitation_Status__c = \'Walk In\') AND isSpeaker__c != true) ' +
            'FROM Event_Session__c WHERE Event_Function__c =: eventId AND Scheduled_Delegates_Confirmed__c > 0';
        
        if (accid != null)
        {
            queryString += ' AND Participating_Company__c =: accId';
        }
        
        queryString += ' ORDER BY Date__c, Start_Time__c';
        
        sessionList = Database.query(queryString);
        
        Map<String, List<Event_Session__c>> groupedMap = new Map<String, List<Event_Session__c>>();
        for (Event_Session__c session : sessionList)
        {
            Date d = session.Date__c;
            String key = DateTime.newInstance(d.year(),d.month(),d.day()).format('EEEE, MMM d, YYYY');
            
            List<Event_Session__c> groupedSessions = groupedMap.get(key);
            if (null==groupedSessions)
            {
                groupedSessions=new List<Event_Session__c>();
                groupedMap.put(key, groupedSessions);
            }
            
            groupedSessions.add(session);
        }
        
        groups = new List<dayGroupWrapper>();
        
        for (String key : groupedMap.keySet())
        {
            dayGroupWrapper gr = new dayGroupWrapper();
            groups.add(gr);
            gr.sessions = groupedMap.get(key);
            gr.groupedVal = key;
        }

    }
    
    @RemoteAction
    public static pageReference updateAttendance(String sdId, String attStatus)
    {
        
        Event_Session_Booking__c sbToUpdate =
            [
                SELECT
                Id,
                Attendance_Status__c
                FROM
                Event_Session_Booking__c
                WHERE
                Id =: sdId
            ];
        
        sbToUpdate.Attendance_Status__c = attStatus;
        
        update sbToUpdate;
        
        return null;
        
    }
    
    public pageReference addWalkIn() 
    {
        Delegate__c del = new Delegate__c();
        del.Event__c = event.Id;
        del.First_Name__c = delFirstName;
        del.Last_Name__c = delLastName;
        del.Company__c = delCompany;
        del.Mobile__c = delMobile;
        del.Title__c = delTitle;
        del.Email__c = delEmail;
        del.Registration_Status__c = 'Walk In';
        del.Registered_Date__c = DateTime.now();
        del.Walk_In__c = true;
        del.Status__c = 'Attended';
        del.CheckIn_Date__c = DateTime.now();      
        
        insert del;
        
        system.debug('delAgendaItem: ' + delAgendaItem);
        
        Event_Session_Booking__c sb = new Event_Session_Booking__c();
        sb.Delegate__c = del.Id;
        sb.Invitation_Status__c = 'Walk In';
        sb.Attendance_Status__c = 'Attended';
        sb.Session__c = delAgendaItem;
        
        insert sb;
        
        pageReference pg = new PageReference('/apex/evAttendanceRegister?id=' + event.Id);
        pg.setRedirect(true);
        return pg;
    }

    public class dayGroupWrapper
    {
        public List<Event_Session__c> sessions {get; set;}
        public String groupedVal {get; set;}
    }

}