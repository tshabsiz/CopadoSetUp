public with sharing class evDelegateScheduleExtension_Controller {
    
    public Delegate__c delegate {get;set;}
    public Event__c event {get;set;}
    public List<dayGroupWrapper> groups {get; set;}
    public Event_Configuration__c agendaConfig {get;set;}
    public Boolean hasBooking {get;set;}
        
    public evDelegateScheduleExtension_Controller(ApexPages.StandardController stdController) {
        
        if (!Test.isRunningTest()) 
        { 
            stdController.addFields(new List<String>{'Event__c'});
        }
        
        delegate = (Delegate__c)stdController.getRecord();
                
        List<Event_Session__c> sessionList = new List<Event_Session__c>();
        sessionList = 
            [
            	SELECT
                Id,
                Name,
                Date__c,
                Start_Time__c,
                End_Time__c,
                Type__c,
                Room__r.Name,
                Participating_Company__r.Name,
                (
                    SELECT
                    Id,
                    Session__c,
                    Event_Id__c,
                    Session__r.Date__c,
                    Session__r.Start_Time__c,
                    Session__r.Start_Time_Text__c,
                    Session__r.End_Time_Text__c,
                    Session__r.End_Time__c,
                    Session__r.Type__c,
                    Session__r.Room__r.Name,
                    Session__r.Participating_Company__r.Name,
                    Delegate__r.Full_Name__c,
                    Delegate__r.Contact__r.Name
                    FROM
                    Session_Bookings__r
                    WHERE
                    Delegate__c =: delegate.Id
                )
                FROM
                Event_Session__c
                WHERE
                Event_Function__c =: delegate.Event__c
                AND
                Id IN (
                    SELECT 
                    Session__c 
                    FROM 
                    Event_Session_Booking__c 
                    WHERE 
                    Delegate__c =: delegate.Id 
                    AND 
                    Invitation_Status__c =: 'Confirmed' 
                    )
                ORDER BY 
                Date__c, Start_Time__c
            ];
        
        system.debug('sessionList: ' + sessionList);
        
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

        event = 
            [
                SELECT
                Id,
                Name,
                Start_Date__c,
                End_Date__c,
                Venue__r.Name,
                Venue__r.Address__c,
                Event_Agenda__c
                FROM
                Event__c
                WHERE
                Id =: delegate.Event__c
            ];
        
        List<Event_Session_Booking__c> delSc = new List<Event_Session_Booking__c>();
        
        delSc = 
            [
                SELECT
                Id
                FROM
                Event_Session_Booking__c
                WHERE
                Delegate__c =: delegate.Id
            ];


        if(delSc.isEmpty())
        {
        	hasBooking = false;  
        }
        else
        {
           hasBooking = true; 
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

    }
    
    public class dayGroupWrapper
    {
        public List<Event_Session__c> sessions {get; set;}
        public String groupedVal {get; set;}
    }

}