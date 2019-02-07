/**
* Author : Daniel Field
* Date   : 2017-12-17
* Desc   : Controller class that handles the creation of delegate__c records via two visual force pages evDelegateCreation_Import 
and evDelegateCreation_AddContacts | Uses a custom controller and a Standard Contact Controller
* 2018-01-17 - RN - CloudSmiths - Clean-up existing code
* 2018-05-20 - DP - Update delegate information fields with contact information. 
					Updated evDelegateCreation_Controller method to use standard set and add loop to update contact id set, to make this lightning compatible.
**/
public class evDelegateCreation_Controller 
{
    //Shared Varibles
    public Id EventId {get;set;}
    public string selectedEvent {get;set;}
    //add contacts page Varibles------------------------------------------------------------
    public String recordCount {get;set;}
    public Boolean isNumbersOk {get;set;}  
    public Decimal existingNumbers {get;set;}
    public Decimal selectedNumbers {get;set;}
    public Decimal allowedNumbers {get;set;}
    
    public list<Delegate__c> existingDelegates {get;set;}
    public list<SelectOption> eventOptions {get;set;}
    public list<SelectOption> hostOptions {get;set;}
    public list<DelegateWrapper> lstAWrapper {get;set;}
    
    public List<Contact> contactList {get;set;}
    private ApexPages.StandardSetController setController;
    private set<String> contactIds = new set<String>();
    private set<String> delegateIds = new set<String>();
    private map<Id,Delegate__c> allExistingDelMap = new map<Id, Delegate__c>();
    private map<String, String> eventProcessType = new map<String,String>();
    private map<String, Decimal> maxNumberPerHost = new map<String, Decimal>();
    
    public static Map <String, Schema.RecordTypeInfo> mapDelegateRecordTypes = Delegate__c.sObjectType.getDescribe().getRecordTypeInfosByName();  
    
    //importDelegate Varibles---------------------------------    
    public List<DelegateWrapper> DelegateWrappers {get;set;}
    public List<Pending_Delegate__c> items {get;set;}
    public List<Event__c> Events {get;set;}
    public List<SelectOption> EventsList {get;set;}
    Public set<string> ContactUpsertErrorList {get;set;}
    public List<Event_Team_Member__c> members {get;set;}
    public set<id> FailedUpdateContactIdSet {get;set;}
    public List<SelectOption> TeamMembersList {get;set;}
    
    public string defaultListValue {get;set;}
    public string dataImportWizardURL {get;set;}
    public string importFileTemplateURL {get;set;}
    public string selectedTeamMember {get;set;}
    public string numberOfInvites {get;set;}
    public boolean hasItems {get;set;}
    public integer numberOfInvitesUsed;
    
        //ImportDelegates Controller START--------------------------------------------------------------------------------------------------------------------------------------------
    public evDelegateCreation_Controller()
    {
        
        system.debug('>>>>> Entering Constructor');
        numberOfInvites = '0';    
        numberOfInvitesUsed = 0;

        selectedEvent = ApexPages.currentPage().getParameters().get('eventid');        
        selectedTeamMember = ApexPages.currentPage().getParameters().get('host');
        
        
        defaultListValue = 'New';
        
        ContactUpsertErrorList =  new set<string>();
        FailedUpdateContactIdSet =  new set<id>();
        
        Events = getEventRecordList(null);
        
        if (Events != null && Events.size() > 0)
        {
            EventsList = new List<SelectOption>();
            EventsList.Add(new SelectOption('', '(Select Event)'));
            
            for(Event__c event: Events)
            {
                EventsList.Add(new SelectOption(event.Id, event.Name));
            }
            
        }
        else
        {
            EventsList = new List<SelectOption>();
            EventsList.Add(new SelectOption('', '(No Events Found)'));
        }
        
        system.debug('>>>>> EventId = ' + EventId);
        
        getDelegateWrapperItems();        
        
        system.debug('DelegateWrappers = ' + DelegateWrappers);
        
        if (string.isNotBlank(selectedTeamMember))
        {
            getNumberOfInvitesUsed();
            getNumberOfInvites();
        }
  
    }
    
    //addcontact Methods START-------------------------------------------------------------------------------------------------------------------------------------------------
    public evDelegateCreation_Controller(ApexPages.StandardSetController setController)
    {
        //DP
        this.setController = setController;
        contactList = setController.getSelected();
        
        numberOfInvites = '0';    
        numberOfInvitesUsed = 0;
        showEvents();
    }
    
    //Shared Methods START------------------------------------
    public List<String> addSingleQuote(List<String> collection)
    {
        List<String> updateList = new List<String>();
        
        for(String currentElement : collection)
        {
            currentElement = '\''+currentElement+'\'';
            updateList.add(currentElement);
        } 
        
        return updateList;
    }
    
    
    public event__C getEventRecord(id eventRecId)
    {
        event__c event =     
            [
                SELECT
                    Id,
                    Name,
                    Registration_Process__c, 
                    Venue__c, 
                    Private_Delegate_Account_Name__c
                FROM 
                	Event__c
                WHERE 
                	id = : eventRecId
            ];
        
        return event;
    }
    
    public List<Event__C> getEventRecordList(list<id> eventRecIdList)
    {
        List<Event__C> eventList;
        
        if(eventRecIdList !=  null )
        {
            eventList = 
                [
                    SELECT
                        Id, 
                        Name, 
                        Registration_Process__c, 
                        Venue__c, 
                        Private_Delegate_Account_Name__c
                    FROM 
                    	Event__c 
                    WHERE
                    	Id IN :eventRecIdList
                ];
        }
        else
        {
            
            eventList = 
                [
                    SELECT 
                        Id,
                        Name,Registration_Process__c,
                        Venue__c, 
                        Private_Delegate_Account_Name__c,
                        City__c,
                        Start_Date__c,
                        ( 
                            SELECT
                            	Team_Member__c 
                            FROM 
                            	Event_Teams__r
                            WHERE 
                                Team_Member__c = :UserInfo.getUserId()
                        ) 
                    FROM 
                    	Event__c 
                    WHERE
                    	Active__c = true 
                    ORDER BY 
                    	Start_Date__c
                    ASC
                ];
        }
        
        return eventList;
    }
    
    public delegate__c getDelegateRecord(id delegateID, id ContactID, Id eventRecId)
    {
        string queryString =  ' SELECT Id, Name,Contact__c  FROM delegate__c  WHERE Name !=  null ';
        
        if(delegateID != null)
        {
            queryString += ' AND id = \'' + delegateID + '\' ';
        }
        if(ContactID != null)
        {
            queryString += ' AND contact__c = \'' + ContactID + '\' ';
        }
        if(eventRecId != null)
        {
            queryString += ' AND event__c = \'' + eventRecId + '\' ';
        }
        
        queryString += ' LIMIT 1';
        
        delegate__c Delegate    = database.Query(queryString);
        return Delegate;
    }
    
    
    public List<delegate__c> getDelegateRecordList(  Id eventRecId, list<string> delegateIdList)
    {
        string queryString =  ' SELECT Id, Name, Invitation_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName FROM delegate__c WHERE name != null';
        
        if(delegateIdList != null && delegateIdList.size() > 0)
        {
            string delegateIdString = '';
            
            queryString += ' AND Id IN (';
            
            for(id DelId : delegateIdList)
            {
                queryString +=  '\''+ DelId + '\'' + ',';
            }
            
            queryString = queryString.left(queryString.length() -1);
            
            queryString += ' )';
        }
        
        if(eventRecId != null)
        {
            queryString +=  ' AND event__c =  \'' + eventRecId + '\'';
        }
        
        system.debug(' getDelegateRecordList : queryString :'+queryString); 
        
        List<delegate__c> DelegateList    = database.Query(queryString);
        
        return DelegateList;
    }
    
  @testVisible  private Event_Booking__c createEventBooking(Id eventId)//Possible shared logic
    {
        //Create EventBooking
        Event_Booking__c EventBooking = new Event_Booking__c();
        EventBooking.Event__c = eventId;
        insert EventBooking;
        return EventBooking;
    }
   
    //ImportDelegates Methods START--------------------------------------------------------------------------------------------------------------------------------------------
    public void getDelegateWrapperItems()//no shared logic
    {
        system.debug('>>>>> Entering getDelegateWrapperItems');
        List<Pending_Delegate__c> pditems = 
            [
                SELECT
                    Id, 
                    Name,
                    First_Name__c, 
                    Last_Name__c,
                    Email__c,
                    Company_Name__c,
                    Event__c,
                    Job_Title__c,
                    Mobile_Phone__c
                FROM
                	Pending_Delegate__c 
                WHERE
                	OwnerId=:UserInfo.getUserId() 
                ORDER BY
                	First_Name__c, Last_Name__c, Company_Name__c, Job_Title__c 
                LIMIT 500
            ];
        
        DelegateWrappers  = new List<DelegateWrapper>();
        
        List<string> SearchStringNameList = new   List<string>();
        List<string> SearchStringMobileList = new   List<string>();
        List<string> SearchStringEmailList = new   List<string>();
        List<Contact> allMatches = null;
        
        map<string,list<contact>> MapOfContactListsToString= new map<string,list<contact>>();
        
        for(Pending_Delegate__c item: pditems)
        {
            string fnFilter = '%' + item.First_Name__c + '%';
            string lnFilter = '%' + item.Last_Name__c + '%';
            
            
            SearchStringNameList.add(fnFilter);
            SearchStringNameList.add(lnFilter);
            SearchStringMobileList.add(item.Mobile_Phone__c);
            SearchStringEmailList.add(item.Email__c);
            
        }
        
        allMatches = 
            [
                SELECT 
                    Id, 
                    Name,
                    FirstName,
                    LastName, 
                    Title,
                    MobilePhone,
                    Email,
                    Company_Name__c 
                FROM 
                	Contact 
                WHERE 
                (
                    FirstName like :SearchStringNameList 
                    OR
                    LastName like :SearchStringNameList
                ) 
                AND 
                (
                    MobilePhone IN :SearchStringMobileList
                    OR 
                    Email IN :SearchStringEmailList
                )
                order by FirstName,LastName,Company_Name__c,Title,Email
            ];
        
        for(Contact con: allMatches)
        { 
            List<Contact> TempMatchList;      
            
            if(con.MobilePhone != null)
            {
                TempMatchList =  MapOfContactListsToString.get(con.MobilePhone);
            }
            
            if(TempMatchList == null && con.email != null)
            {
                TempMatchList =  MapOfContactListsToString.get(con.email);
            }
            
            if(TempMatchList == null)
            {
                TempMatchList =  new list<Contact>();
            }
            
            TempMatchList.add(con);
            
            if(con.MobilePhone != null)
            {
                MapOfContactListsToString.put(con.MobilePhone, TempMatchList);
            }
            else if(con.email !=null) 
            {
                MapOfContactListsToString.put(con.email, TempMatchList);
            }
            
        }
        
        if (pditems != null && pditems.size() > 0)
        {          
            system.debug('retrieved pending delegates where OwnerId=' + UserInfo.getUserId() );
            hasItems = true;
            
            for(Pending_Delegate__c item: pditems)
            {
                system.debug('item:' + item);
                
                List<Contact> Matches;
                
                if(item.Mobile_Phone__c != null)
                {
                    Matches = MapOfContactListsToString.get(item.Mobile_Phone__c);
                    
                }                  
                if(Matches == null && item.Email__c != null)
                {
                    Matches = MapOfContactListsToString.get(item.Email__c);
                    
                }
                
                DelegateWrapper newD = new DelegateWrapper();
                
                newD.PDId = item.Id;
                newD.FirstName = item.First_Name__c;
                newD.LastName = item.Last_Name__c;
                newD.JobTitle = item.Job_Title__c;
                newD.CompanyName = item.Company_Name__c;
                newD.Email = item.Email__c;
                newD.MobilePhone = item.Mobile_Phone__c;                 
                newD.EventId = item.Event__c;
                newD.PossibleMatches = new List<SelectOption>();
               
                system.debug('matches:' + matches);
                
                if (matches != null && matches.size() > 0)
                {                   
                    if (matches.size() >= 1) 
                    {
                        newD.PossibleMatches.Add(new SelectOption('Select','(Select An Action)'));
                        newD.PossibleMatches.Add(new SelectOption('New','Create New Contact'));
                    }                    
                    for(Contact c: matches)
                    {                                               
                        newD.PossibleMatches.Add(new SelectOption(string.valueOf(c.Id),c.FirstName + ' ' + c.LastName + '(' + c.Company_Name__c + ' - ' + c.Title + ') (' + c.MobilePhone + ') (' + c.Email + ')' ));                        
                    }                    
                }                
                
                if (newD != null && newD.PossibleMatches != null && newD.PossibleMatches.size() > 0) 
                {
                    newD.hasPossibleMatches = true;
                }
                else 
                {
                    newD.ActualMatch = 'New';
                }
                DelegateWrappers.Add(newD);
            }            
        }
        else 
        {
            evSetting__mdt settings = 
                [
                    SELECT 
                        Data_Import_Wizard_URL__c,
                        Template_File_Path__c 
                    FROM
                    	evSetting__mdt
                    WHERE
                    	QualifiedApiName = 'Bhalisa_Default'
                    LIMIT 1
                ];
            
            if (settings != null)
            {
                dataImportWizardURL = settings.Data_Import_Wizard_URL__c;
                importFileTemplateURL = settings.Template_File_Path__c;
            }
        }
    }
    
    public integer getNumberOfInvitesUsed()// Possible shared logic
    {
        system.debug('>>>>> Entering getNumberOfInvitesUsed, selectedTeamMember = ' + selectedTeamMember);
        numberOfInvitesUsed = 0;
        system.debug('selectedTeamMember : '+ selectedTeamMember); 
        getNumberOfInvites(); 
        if (string.isNotBlank(selectedTeamMember) && string.isNotBlank(selectedEvent))
        {
            Id tm = Id.valueOf(selectedTeamMember);           
            system.debug('SOQL:'+ 'select count() from Event_Team_Members_Delegates__c where Event_Team_Member__c = \'' + tm + '\' and Event_Team_Member__r.Event__r.Id = \'' + selectedEvent + '\'');
            
            try
            {
                numberOfInvitesUsed = database.countQuery('select count() from Event_Team_Members_Delegates__c where Event_Team_Member__c = \'' + tm + '\' and Event_Team_Member__r.Event__r.Id = \'' + selectedEvent + '\'');
                system.debug('numberOfInvitesUsed : '+ numberOfInvitesUsed);
            } 
            catch (Exception ex)
            {
                system.debug('ERROR:' + ex.getMessage());
                numberOfInvitesUsed = 0;
            }
        } 
        else 
        {
            return -1;
        }
        system.debug('numberOfInvitesUsed : '+ numberOfInvitesUsed);

        return numberOfInvitesUsed;
    }
    
    public void setNumberOfInvitesUsed(integer v)//no shared logic
    {
        numberOfInvitesUsed = v;
    }
    
    public string getDefaultListValue()//no shared logic
    {
        if (string.isNotBlank(defaultListValue))
        {
            defaultListValue = 'New';
        }
        
        return defaultListValue;
    }
    
    public void setDefaultListValue(string v)//no shared logic
    {
        defaultListValue = v;
    }
    
    public string getSelectedEvent()
    {        
        system.debug('>>>>> Entering getSelectedEvent, value=' + selectedEvent);
        return selectedEvent;
    }
    
    public void setSelectedEvent(string v)
    {
        selectedEvent = v;
    }
    
    public string getSelectedTeamMember()
    {        
        return selectedTeamMember;
    }
    
    public void setSelectedTeamMember(string v)
    {
        selectedTeamMember = v;
    }
    
    public PageReference removeDelegates()//no shared logic
    {
        system.debug('>>>>> Entering removeDelegates');
        List<Pending_Delegate__c> del = new List<Pending_Delegate__c>();
        Pending_Delegate__c dd = null;
        // system.debug('PendingDelegates:' + PendingDelegates);
        
        set<id> PendingDelegateIdSet = new set<id>();
        
        for(DelegateWrapper Pd: DelegateWrappers)
        {
            PendingDelegateIdSet.add(Pd.PDId);
        }
        
        map<id,Pending_Delegate__c> PendingDelegateMap = new map<id,Pending_Delegate__c>
            ([
                select 
                Id
                from
                Pending_Delegate__c
                where
                ID in : PendingDelegateIdSet
            ]);
        
        for(DelegateWrapper d: DelegateWrappers)
        {
            system.debug('Handling PendingDelegate:' + d);
            if (d.doImport == true)
            {
                try
                {
                    system.debug('select Id from Pending_Delegate__c where ID=:' + d.PDId + ' limit 1');
                    dd = PendingDelegateMap.get(d.PDId);
                } 
                catch (Exception ex) 
                {
                    system.debug('error retrieving pending delegate for deletion:' + ex.getMessage());
                }
                if (dd != null) 
                {
                    del.add(dd);
                }
            }
        }
        
        system.debug('del = ' + del);
        if (del != null && del.size() > 0)
        {
            delete del;
        }
        
        system.debug('selectedEvent=' + selectedEvent + ', selectedTeamMember = ' + selectedTeamMember);
        
        getDelegateWrapperItems();
        
        if (DelegateWrappers.size() == 0)
        {
            PageReference pr = new PageReference('/apex/evDelegateCreation_Import');
            pr.getParameters().put('eventid', selectedEvent);
            pr.getParameters().put('host', selectedTeamMember);
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Selected delegates successfully deleted!'));
            return null;
        }        
    }
    
    public PageReference GetTeamMembersList()//no shared logic
    {
        system.debug('>>>>> Entering GetTeamMembersList');
        
        TeamMembersList = new List<SelectOption>();
        if (string.isNotBlank(selectedEvent))
        {            
            Id eventId = Id.valueOf(selectedEvent);
            
            Event__c event = null;
            try
            {
                system.debug('DML: Select Event');
                event = getEventRecord(eventid);
            }
            catch (exception Ex)
            {
                
            }
            
            if (event == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This event\'s details cannot be found!'));                
                TeamMembersList.Add(new SelectOption('', '(No Event Team Members Found)'));
                return null;
            }
            if (string.isBlank(event.Private_Delegate_Account_Name__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There is no Private Delegate Account specified for this event. Please assign one in order to import delegates.'));                
                TeamMembersList = null;
                return null;
            }
            try
            {
                members = 
                    [
                        SELECT 
                        ID,
                        Team_Member__r.Name,
                        Maximum_Number_of_Proposed_Invitees__c
                        FROM
                        Event_Team_Member__c
                        WHERE 
                        Event__c =: eventId
                    ];
            } 
            catch (exception ex)
            {
                system.debug('ERROR:' + ex.getMessage());
            }
            if (members != null && members.size() > 0)
            {
                TeamMembersList.Add(new SelectOption('', '(Select Host)'));
                for(Event_Team_Member__c m: members)
                {
                    TeamMembersList.Add(new SelectOption(m.Id, m.Team_Member__r.Name));
                }
            }
            else 
            {
                TeamMembersList.Add(new SelectOption('', '(No Event Team Members Found)'));
            }
        }
        else 
        {
            TeamMembersList.Add(new SelectOption('', '(No Event Team Members Found)'));
        }
        system.debug('>>>>> TeamMembersList = ' + TeamMembersList);
        return null;
    }
    
    public string getNumberOfInvites()
    {
        system.debug('getNumberOfInvites() members : ' + members);
        
        if (string.isNotBlank(selectedTeamMember) && members != null)
        {
            for(Event_Team_Member__c m: members)
            {
                if (m.Id == Id.valueOf(selectedTeamMember))
                {
                    numberOfInvites = string.valueOf(integer.valueOf(m.Maximum_Number_of_Proposed_Invitees__c));
                    return numberOfInvites;    
                    system.debug('getNumberOfInvites() numberOfInvites in for loop : '+numberOfInvites);
                }
            }
        }
        if (numberOfInvites ==  null)
        {
            numberOfInvites = '0';
        }
        system.debug('getNumberOfInvites() numberOfInvites : '+numberOfInvites);
        return numberOfInvites;
    }
    
    public PageReference TeamMemberSelected()//no shared logic
    {
        getNumberOfInvites();
        return null;
    }
    
    public void setNumberOfInvites(string val)//no shared logic
    {
        numberOfInvites= val;
        system.debug('end of setNumberOfInvites');
    }
    
    public List<Pending_Delegate__c> getDelegateWrappersList()//no shared logic
    {
        return items;
    }
    
    public PageReference goBack()//Possible shared logic
    {
        if (EventId != null)
        {
            return new PageReference('/' + EventId);
        }
        else 
        {
            return new PageReference('/');
        }        
    }
    
    public PageReference createDelegates()//no shared logic
    {        
        ApexPages.getMessages().clear();
        set<id> ContactIdSet = new Set<id>();
        
        system.debug('>>>>> Entering createDelegates, selectedEvent:' + selectedEvent);
        
        // Perform some validation
        for(DelegateWrapper d: DelegateWrappers)
        {
            if (d.doImport == true && (string.isBlank(d.ActualMatch) || d.ActualMatch=='Select'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure you have selected an action/possible match for every delegate selected'));
                return null;
            }
            else if (d.ActualMatch != 'New' && d.ActualMatch !='Select' && string.isNotBlank(selectedEvent) && string.isNotBlank(selectedTeamMember))
            {
                ContactIdSet.add(Id.valueOf(d.ActualMatch));
            }
        }
        
        if (string.isNotBlank(selectedEvent) && string.isNotBlank(selectedTeamMember))
        {
            Id eventId = Id.valueOf(selectedEvent);
            Set<DelegateWrapper> deleteDelegates = new Set<DelegateWrapper>();
            List<Contact> upsertContacts = new List<Contact>();
            List<Delegate__c> insertDelegates = new List<Delegate__c>();
            List<Delegate__c> existingDelegates = new List<Delegate__c>();
            Event_Booking__c EventBooking = null;
            
            system.debug('eventId:' + eventId);
            
            Event__c event = null;
            //First Check if we are creating an event booking for each delegate or one for all delegates                    
            try
            {
                system.debug('DML: Select Event');
                event = getEventRecord(eventid);
            } 
            catch (exception Ex)
            {
                
            }
            
            if (event == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This events details cannot be found!'));                
                return null;
            }
            
            
            map<id,contact> ExistingContactMap =  new map<id,contact>
                ([
                    SELECT
                    	Id,
                        Name,
                        FirstName,
                        LastName,
                        MobilePhone,
                        Title,
                        Email,
                        Company_Name__c 
                    FROM 
                    	Contact 
                    WHERE
                    	Id in : ContactIdSet
                 ]);
            
            integer dc = 0;
            for(DelegateWrapper d: DelegateWrappers)
            {
                system.debug('Handling PendingDelegate:' + d);
                if (d.doImport == true)
                {
                    dc++;
                    system.debug('IMPORT=TRUE');
                    Id ContactId;
                    if (d.ActualMatch == 'New')
                    {
                        // Add new contact
                        Contact newContact = new Contact();
                        newContact.FirstName = d.FirstName;
                        newContact.LastName = d.LastName;                        
                        newContact.MobilePhone = d.MobilePhone;
                        newContact.Email = d.Email;
                        newContact.Title = d.JobTitle;                        
                        newContact.AccountId = event.Private_Delegate_Account_Name__c;
                        upsertContacts.Add(newContact);
                    }
                    else 
                    {
                        Contact existingContact = null;
                        try
                        {
                            system.debug('DML: Select existingContact');
                            existingContact = ExistingContactMap.get(Id.valueOf(d.ActualMatch));
                        } 
                        catch (Exception ex) 
                        {
                            
                        }
                        
                        if (existingContact != null)
                        {
                            existingContact.FirstName = d.FirstName;
                            existingContact.LastName = d.LastName;                           
                            existingContact.MobilePhone = d.MobilePhone;
                            existingContact.Email = d.Email;
                            existingContact.Title = d.JobTitle;                          
                            
                            upsertContacts.Add(existingContact);
                        }
                    }
                    //Now to remove the pending delegate record
                    if (!deleteDelegates.contains(d))
                    {
                        deleteDelegates.add(d);
                    }
                }
            }
            
            if (upsertContacts != null && upsertContacts.size() > 0)//allow partial upsert of contacts 
            {
                Database.UpsertResult[] upsertResultList;
                ContactUpsertErrorList = new set<string>();
                FailedUpdateContactIdSet = new set<id>();
                
                try
                {
                    Integer ListIndex =  0;
                    system.debug('upsertContacts : ' + upsertContacts);
                    
                    upsertResultList =  database.upsert(upsertContacts, false);// upsert upsertContacts; use database.upsert method to allow partial upsert and then get result list back for error handling
                    
                    for(Database.UpsertResult Res : upsertResultList)// Run through result list and catch any errors thrown
                    {
                        contact ConRec = upsertContacts[ListIndex];//get contact related to Database.UpsertResult based on the list index as Database.UpsertResult list is always in the same order as upsertContacts list
                        string errormsg;
                        
                        if(Res.isSuccess() == false )// if record failed to update, get error message.
                        {
                            for(Database.Error error : Res.getErrors())
                            {
                                system.debug('error.getMessage() : '+error.getMessage());
                                errormsg =  error.getMessage();                                     
                            }
                        }
                        
                        if(ConRec.id == null && errormsg != null  &&  errormsg != '')//if insert failed through insert error message
                        {
                            ContactUpsertErrorList.add('A Contact for ' + ConRec.FirstName + ' ' + ConRec.LastName +  ' failed to create with error : ' + errormsg);
                        }
                        
                        if(ConRec.id != null && errormsg != null  &&  errormsg != '')//if Update failed through Update error message
                        {
                            ContactUpsertErrorList.add('A  Contact for ' + ConRec.FirstName + ' ' + ConRec.LastName +  ' failed to update with error : ' + errormsg);
                            FailedUpdateContactIdSet.add(ConRec.id); 
                        }
                        ListIndex++;//increase list index to keep aligned
                        system.debug('ContactUpsertErrorList : '+ ContactUpsertErrorList);
                    } 
                } 
                catch (Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error updating/inserting Contacts:' + ex.getMessage()));
                    return null;
                }
                
                if (event != null)
                {          
                    system.debug('add delegate for event:' + event.Name + '(' + event.Id + ')');
                    
                    if ((event.Registration_Process__c == null || event.Registration_Process__c == 'Simple'))
                        {                                
                            //Check if there is an existing event booking to add to
                            try
                            {
                                if (EventBooking == null) 
                                {
                                    system.debug('DML: Select Event_Booking__c');
                                    EventBooking = 
                                        [
                                            SELECT
                                            Id, 
                                            Name
                                            FROM 
                                            Event_Booking__c 
                                            WHERE 
                                            Event__c=:event.Id 
                                            LIMIT 1
                                        ];
                                }
                            } 
                            catch (Exception ex) 
                            {
                                
                            }
                            
                            if (EventBooking == null)
                            {
                                //Create booking for each delegate  
                                try
                                {                                            
                                    EventBooking = createEventBooking(event.Id); 
                                } 
                                catch (Exception ex)
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error creating event booking:' + ex.getMessage()));   
                                    return null;
                                }
                            } 
                            else 
                            {
                                
                            }
                        }  
                        else 
                        {
                            //Create booking for each delegate   // DF event bookimg issue 
                            EventBooking = null;
                            
                            try
                            {
                                EventBooking = createEventBooking(event.Id);   
                                
                            } 
                            catch (Exception ex)
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error creating event booking:' + ex.getMessage()));   
                                return null;
                            }
                        }  
                    
                   
                     List<Id> contactIds = new List<Id>();
                    for(Contact uc: upsertContacts)
                    {                           
                        contactIds.Add(uc.Id);
                    }
                    
                    map<id,delegate__c> DelegateMap =  new map<id,delegate__c>();
                    
                    list<delegate__c> TempDelegateList =  
                        [
                            SELECT 
                                Id,
                                Name,
                                contact__c
                            FROM 
                            	Delegate__c
                            WHERE 
                            	Contact__c In : contactIds
                            AND
                            	Event__c =:eventId
                        ];
                    
                    for(Delegate__c DelRec: TempDelegateList)
                    { 
                        DelegateMap.put(DelRec.Contact__c,DelRec);
                    }
                    
                    
                    for(Contact uc: upsertContacts)
                    {       
                        for(DelegateWrapper d: DelegateWrappers)//DF for contacts that have an id, add to pending delegates based on email and first and last name so we can use the id later to match the pending delegate and actual delegate records
                        {
                            if(d.email == uc.Email && d.firstname == uc.FirstName && d.lastname == uc.LastName)//
                            {
                                d.Contactid =  uc.id;
                                Continue;
                            }
                        } 
                        
                        if (EventBooking != null)
                        {                                    
                            Delegate__c Delegate = null;
                            
                            if(uc.Id != null)//DF added only create delegates for contacts that were sucessfully inserted/have an id
                            {
                                ID cID = id.valueOf(uc.Id);
                                try
                                {
                                    system.debug('DML: Select Delegate for contact ' + cID);
                                    Delegate = DelegateMap.get(cID);
                                    
                                } 
                                catch (Exception ex)
                                {
                                    
                                }
                                
                                if (Delegate == null)
                                {                                
                                    Delegate = new Delegate__c();
                                    Delegate.Event__c = eventId;
                                    Delegate.Contact__c = cID;
                                    Delegate.Invitation_Status__c = 'Proposed';
                                    Delegate.Company__c = uc.Company_Name__c;
                                    Delegate.Event_Booking__c = EventBooking.Id;
                                    Delegate.Host__c = Id.valueOf(selectedTeamMember);                                                                
                                    insertDelegates.Add(Delegate);                                    
                                } 
                                else 
                                {
                                    existingDelegates.Add(Delegate);
                                }
                            }
                        }
                        else 
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Event Booking Available for Use.'));                            
                        }
                    }                       
                }
            }
            else 
            {
                if (dc > 0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Contact Available for Use.'));                            
                }
                else 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Delegates Selected For Import.'));                            
                }
                return null;
            }
            
            //Joint List
            List<Delegate__c> jointDelegateList = new List<Delegate__c>();
            List<Event_Team_Members_Delegates__c> Hosts = new List<Event_Team_Members_Delegates__c>();
            
            Id stm = Id.valueOf(selectedTeamMember);
            Id eid = Id.valueOf(eventId);
            
            if (insertDelegates.size() > 0)
            {
                try
                {
                    insert insertDelegates;
                } 
                catch (Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error inserting delegates:' + ex.getMessage())); 
                    return null;
                }
                
                jointDelegateList.addAll(insertDelegates);                         
            }
            
            if (existingDelegates != null && existingDelegates.size() > 0) 
            {
                jointDelegateList.addAll(existingDelegates);
            }
            
            if (jointDelegateList != null && jointDelegateList.size() > 0)
            {
                set<id> teamMemberIdSet = new set<id>(); 
                set<id> DelegateIdSet = new set<id>(); 
                
                map<string,Event_Team_Members_Delegates__c> eventTeamMemberDelegatesToId = new map<string,Event_Team_Members_Delegates__c>();
                
                for (Delegate__c del: jointDelegateList)
                { 
                    teamMemberIdSet.add(stm);
                    DelegateIdSet.add(del.Id);
                }
                
                list<Event_Team_Members_Delegates__c> tempEventTeamMemberDelegateList =   
                    [
                        SELECT
                          ID,
                        	Event_Team_Member__c,
                        	Delegate__c
                        FROM
                          Event_Team_Members_Delegates__c 
                        WHERE 
                          Event_Team_Member__c in: teamMemberIdSet 
                        AND
                          Delegate__c in: DelegateIdSet
                    ];
                
                for (Event_Team_Members_Delegates__c delTeamMember: tempEventTeamMemberDelegateList)
                {
                    eventTeamMemberDelegatesToId.put(string.ValueOf(delTeamMember.Event_Team_Member__c) + string.ValueOf(delTeamMember.Delegate__c), delTeamMember);
                }
                 
                for (Delegate__c del: jointDelegateList)
                {                    
                    Event_Team_Members_Delegates__c evtd = new Event_Team_Members_Delegates__c();                    
                    evtd.Event_Team_Member__c = Id.valueOf(selectedTeamMember);
                    evtd.Delegate__c = del.Id;
                    try
                    {
                        Event_Team_Members_Delegates__c Temp =  eventTeamMemberDelegatesToId.get(string.ValueOf(stm) + string.ValueOf(del.id));
                        evtd.Id =Temp.Id;
                    } 
                    catch (exception ex)
                    {
                        
                    }
                    Hosts.Add(evtd);                    
                }       
            }
            
            if (Hosts.size() > 0) 
            {
                upsert Hosts;
            }
            
            map<id, Event_Team_Members_Delegates__c> HostMap = new map<id, Event_Team_Members_Delegates__c>();
            
            for(Event_Team_Members_Delegates__c  HostRec : Hosts)
            {
                HostMap.put(HostRec.Delegate__c, HostRec);
            }
            
            for(DelegateWrapper pd: deleteDelegates)
            {
                for (Delegate__c delRec: jointDelegateList)//DF only set DelegateOrHostCreated to true if a contact, delegate__c and host/Event_Team_Members_Delegates__c have been created for this pending delegate
                {  
                    Event_Team_Members_Delegates__c HostRec =    HostMap.get(delRec.id);
                    if(pd.contactid == delRec.contact__c && delRec.id != null && delRec.id == HostRec.Delegate__c && HostRec.id != null ) 
                    {
                        pd.DelegateOrHostCreated = true;
                    }
                }      
            }          
            
            
            // Now we can remove the proposed delegates from the pending_delegates__c object so that the next 30 can be picked up and processed.
            if (deleteDelegates.size() > 0) 
            {
                List<Pending_Delegate__c> del = new List<Pending_Delegate__c>();
                Pending_Delegate__c dd = null;
                //DF CHANGE
                set<id> pdIdSet =  new set<id>();
                
                for(DelegateWrapper pd: DelegateWrappers)
                {
                    pdIdSet.add(pd.PDId);
                }
                
                map<id,Pending_Delegate__c> PendingDelegateMap = new map<id,Pending_Delegate__c>
                    ([
                        SELECT
                        id,
                        name
                        FROM
                        Pending_Delegate__c
                        WHERE
                        id In : pdIdSet
                    ]);
                
                for(DelegateWrapper pd: DelegateWrappers)
                {
                    system.debug('delete loop pd :' + pd);
                    system.debug('delete loop FailedUpdateContactIdSet :' + FailedUpdateContactIdSet);
                    
                    if(pd.DelegateOrHostCreated == true && FailedUpdateContactIdSet.Contains(pd.contactID) == false )//DF Only delete if host has been created, hosts can only be created if the contact and delegate record have succesfully inserted or updated
                    {
                        dd = null;
                        try
                        {
                            dd =  PendingDelegateMap.get(pd.PDId);// dd = [select Id from Pending_Delegate__c where ID=:pd.PDId limit 1]; //DF CHANGE
                        } 
                        catch (Exception ex) 
                        {
                            
                        }
                        if (dd != null)
                        {
                            del.add(dd);
                        }
                    }
                }
                if (del != null && del.size() > 0) 
                {
                    delete del;
                }
            }
            //return new PageReference('/' + eventId);
            
            getDelegateWrapperItems();
            
            if ( ContactUpsertErrorList.size() > 0)//DF ensure there are no errors that must be addressed
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please note there are errors uploading contact data'));
                return null;
            }
            
            if (DelegateWrappers.size() == 0 )//DF ensure there are no errors that must be addressed
            {
                PageReference pr = new PageReference('/' + eventId);               
                pr.setRedirect(true);
                return pr;
            }
            else 
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Selected delegates successfully added to event!'));
            }
        }
        else 
        {
            ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify an Event and the Team Member hosting the delegates.'));
        }
        return null;
    }
    
    //ImportDelegates Methods END----------------------------------------------------------------------------------------------------------------------------------------------
    
    //addcontact Methods START-------------------------------------------------------------------------------------------------------------------------------------------------    
    public void showEvents(){
        
        Profile UserProfile =  [SELECT Id, Name From Profile Where Id = :system.UserInfo.getProfileId()];
        
        system.debug('contactList: ' + contactList);
        
        try{
            //DP
            for(Contact c : contactList)
            {
                contactIds.add(c.Id);
            }
            if (contactList.isEmpty())
            {
            	contactIds.addAll(ApexPages.currentPage().getParameters().get('recs').split(',',-2));   
            }
            
        }catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error when retrieving the contacts to be added '));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        
        eventOptions = new list<SelectOption>();
        hostOptions = new list<SelectOption>();
        existingDelegates = new list<Delegate__c>();
        
        for(Event__c e :getEventRecordlist(null)){
            
            eventProcessType.put(e.Id,e.Registration_Process__c);
            
            if(e.Event_Teams__r.size() > 0 || ( UserProfile.Name == 'System Administrator' || UserProfile.Name == 'Barclays Administrator')){
                //add first listed event ID and member details
                if(String.isBlank(selectedEvent)){
                    selectedEvent = e.Id; 
                }
                
                Date dateOnly = e.Start_Date__c;
                String city = 'No City Specified';
                
                if(String.isNotBlank(e.City__c)){
                    city = e.City__c;
                }
                
                eventOptions.add(new SelectOption(e.Id, dateOnly.format() + ' - ' + e.Name + ' - ' + city));
            }          
        }
        
        //populate dynamic host and existing delegates lists
        fillLists(selectedEvent);
        
        //numberOfInvites = '0';    
        //numberOfInvitesUsed = 0;
        
        //if (string.isNotBlank(selectedTeamMember)){
            //GetTeamMembersList();
            //getNumberOfInvitesUsed();
          //  getNumberOfInvites();
            
        //}
    }
    
    public void fillLists(String eventId){
        system.debug('filllists : '+ selectedTeamMember);
        //populate hosts picklist
        Id currentUser = UserInfo.getUserId();
        list<SelectOption> holdLoginHost = new list<SelectOption>();
        
        hostOptions.clear();
        maxNumberPerHost.clear();
        numberOfInvites = '0';
        numberOfInvitesUsed = 0;
        selectedTeamMember = null;
        
        for( Event_Team_Member__c tm :[ SELECT Id, Team_Member__c, Team_Member__r.Name, 
                    Event_Team_Member_Role__c, Maximum_Number_of_Actual_Invitees__c, Maximum_Number_of_Proposed_Invitees__c  
                    FROM Event_Team_Member__c 
                    WHERE Event__c = :eventId ]){
            
            maxNumberPerHost.put(tm.Id, tm.Maximum_Number_of_Proposed_Invitees__c);     
            
            if(tm.Team_Member__c == currentUser){
                selectedTeamMember = tm.Id;
                //hold the login users listing so we can add the rest at the bottom of the list and this is the default
                hostOptions.add(new SelectOption(tm.Id, tm.Team_Member__r.Name + ' - ' + tm.Event_Team_Member_Role__c ));
            }else{
                holdLoginHost.add(new SelectOption(tm.Id, tm.Team_Member__r.Name + ' - ' + tm.Event_Team_Member_Role__c ));
            }
            
            if(String.isBlank(selectedTeamMember)){     
                selectedTeamMember = tm.Id;
            } 
        }
        
        //add the rest of the list
        hostOptions.addAll(holdLoginHost);
        numberOfInvites = String.valueOf(maxNumberPerHost.get(selectedTeamMember));
        
        //populate existing delegates 
        existingDelegates.clear();
        delegateIds.clear();
        
        //get correct delegates for selected host
        set<Id> delIds = new set<Id>(); 

        for( Event_Team_Members_Delegates__c etm :[ Select Delegate__c From Event_Team_Members_Delegates__c 
                                                    Where Event_Team_Member__c = :selectedTeamMember]){
            delIds.add(etm.Delegate__c);
            numberOfInvitesUsed++;                                            
        }

        List<Id> DelIdList = new List<Id>();
        DelIdList.addAll(delIds);
        
        if(DelIdList.size() > 0){
            for(Delegate__c del : getDelegateRecordList(eventId, DelIdList)){
               
                delegateIds.add(del.Contact__c);
                existingDelegates.add(del);
            }
        }
        //get all existing delegates regardless of host in order not to add duplicates
        allExistingDelMap = new map<Id, Delegate__c>();
        for(Delegate__c xDel : getDelegateRecordList(eventId, null)){
            allExistingDelMap.put(xDel.Contact__c, xDel);
        }
        
        //populate wrapper class
        lstAWrapper = new list<DelegateWrapper>();
        
        for( Contact c :[SELECT Id, FirstName, LastName, Salutation, Phone, Email, Job_Title__c, MobilePhone, Account.Name FROM Contact WHERE Id IN :contactIds]){

            DelegateWrapper AW = new DelegateWrapper(c, true);
            
            if(!delegateIds.contains(c.Id)){
                AW.isChecked = false;
                lstAWrapper.add(AW);
            }
        }  
    }
    
    public PageReference addToEvent()//no shared Logic
    {
        system.debug('lstAWrapper :' + lstAWrapper);       
        SavePoint sp = Database.setSavepoint();
        
        //create new Event Booking record
        Event_Booking__c eventBooking = new Event_Booking__c();
        
        if(eventProcessType.get(selectedEvent) == 'Complex')
        {
            try
            {
                eventBooking =  createEventBooking(selectedEvent);
            }
            catch(DMLException ex)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error when inserting a event booking record for the selected delegates'));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                System.debug(ex.getMessage());
                
                return null;
            }
        }
        
        list<Delegate__c> delList = new list<Delegate__c>();
        list<Delegate__c> existingDelList = new list<Delegate__c>();
        
        for(DelegateWrapper w :lstAWrapper)
        {
            system.debug('w '+w );
            if(w.IsChecked)
            {
                Delegate__c del = new Delegate__c();
                del.Contact__c = w.ContactRec.Id;
                del.Event__c = selectedEvent;
                del.Salutation__c = w.ContactRec.Salutation;
                del.First_Name__c = w.ContactRec.FirstName;
                del.Last_Name__c = w.ContactRec.LastName;
                del.Mobile__c = w.ContactRec.MobilePhone;
                del.Phone__c = w.ContactRec.Phone;
                del.Email__c = w.ContactRec.Email;
                del.Title__c = w.ContactRec.Job_Title__c;
                del.Company__c = w.ContactRec.Account.Name;
                
                if(String.isNotBlank(eventBooking.Id))
                {
                    del.Event_Booking__c = eventBooking.Id;
                }
                
                del.Invitation_Status__c = 'Proposed';
                del.Host__c = selectedTeamMember;
                del.recordtypeid = mapDelegateRecordTypes.get('Invitee').getRecordTypeId();
                
                if(allExistingDelMap.containsKey(w.ContactRec.Id))
                {
                    existingDelList.add(allExistingDelMap.get(w.ContactRec.Id));
                }
                else
                {
                    delList.add(del);
                }  
            }
        }
        
        try
        {
            system.debug('delList '+delList );
            insert delList; 
        }
        catch(DMLException ex)
        {
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error when inserting the selected delegates for this event'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug(ex.getMessage());
            
            Database.rollback(sp);
            
            return null;
        }         
        
        //link delegate and host with the a junction object
        List<Event_Team_Members_Delegates__c> delegateHostLinks = new List<Event_Team_Members_Delegates__c>();
        for(delegate__c delRec : existingDelList)
        {
            Event_Team_Members_Delegates__c ETMD = new Event_Team_Members_Delegates__c();
            ETMD.Delegate__c = delRec.id;
            ETMD.Event_Team_Member__c = selectedTeamMember;
            
            delegateHostLinks.add(ETMD);
        }
      
        try
        {
            system.debug('delegateHostLinks '+delegateHostLinks );
            insert delegateHostLinks; 
        } 
        catch(DMLException ex)
        {
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error when inserting the selected delegates hosts for this event'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug(ex.getMessage());
            
            Database.rollback(sp);
            
            return null;
        }  
        
        PageReference eventPage = new PageReference('/' + selectedEvent);
        
        return eventPage;
    }
    
    public PageReference cancel()
    {
        PageReference contactViewPage = new PageReference('/003/o');
        return contactViewPage;
    }
    
    public PageReference refreshLists(){
        //populate dynamic host and existing delegates lists
        fillLists(selectedEvent);
        return null;
    }
    
    public PageReference newHostList(){
       
        //populate existing delegates 
        existingDelegates.clear();
        delegateIds.clear();
        numberOfInvites = String.valueOf(maxNumberPerHost.get(selectedTeamMember));
        numberOfInvitesUsed = 0;
        
        //get correct delegates for selected host
        set<Id> delIds = new set<Id>(); 
        for(Event_Team_Members_Delegates__c etm :[SELECT Delegate__c FROM Event_Team_Members_Delegates__c 
                                                  WHERE Event_Team_Member__c = :selectedTeamMember]){
            delIds.add(etm.Delegate__c); 
            numberOfInvitesUsed++;                                          
        }
        
        list<id> delidList = new list<id>();
        delidList.addAll(delIds);
        
        if(delidList.size() > 0){
            for( Delegate__c del :getDelegateRecordList(selectedEvent, delidList)){
               
                delegateIds.add(del.Contact__c);
                existingDelegates.add(del);
            }
        }
        //populate wrapper class
        lstAWrapper = new list<DelegateWrapper>();
        
        for( Contact c :[Select Id,FirstName, LastName, Salutation, MobilePhone, Email, Job_Title__c, Phone, Account.Name From Contact Where Id IN :contactIds]){
            
            DelegateWrapper AW = new DelegateWrapper(c, true);
            
            if(!delegateIds.contains(c.Id)){
                AW.ischecked = false;
                lstAWrapper.add(AW);
            }
        }
        
        return null;
    }
    //-----------------------------------------------------------------------------------
    //                                          NESTED CLASSES
    //----------------------------------------------------------------------------------
      public class DelegateWrapper{ 
        
        public Id PDId {get;set;}
        public Id ContactId {get;set;}//used for matching Pending delgates with actual Delegate records
        public Id EventId {get;set;}
        public string Salutation {get;set;}
        public string FirstName {get;set;}
        public string LastName {get;set;}
        public string JobTitle {get;set;}
        public string CompanyName {get;set;}
        public string Email {get;set;}
        public string MobilePhone {get;set;} 
        public string ActualMatch  {get;set;}
        public boolean hasPossibleMatches {get;set;}
        public boolean doImport {get;set;}
        Public Boolean DelegateOrHostCreated {get;set;}//used to prevent the deletion of pending delegates that have do not have a host or delegate record
        public Boolean IsChecked {get;set;}
        public Contact ContactRec {get;set;}
        
        public List<SelectOption> PossibleMatches {get;set;}
        
        public DelegateWrapper(){
            Salutation = '';
            FirstName = '';
            LastName = '';
            JobTitle = '';
            CompanyName = '';
            Email = '';
            MobilePhone = '';  
            PossibleMatches = new List<SelectOption>();
        }
        
        public DelegateWrapper(Contact con, Boolean chk){
            this.ContactRec = con;
            this.IsChecked = chk;
        }
    }  
    
     public List<SelectOption> getDelegateTypes() 
    {
        List<SelectOption> CitySelectOptions = new List<SelectOption>();
        CitySelectOptions.add(new SelectOption('','New'));
        CitySelectOptions.add(new SelectOption('Partner','Partner'));
        CitySelectOptions.add(new SelectOption('Visitor','Visitor'));
        CitySelectOptions.add(new SelectOption('Employee','Employee'));    
        CitySelectOptions.add(new SelectOption('Media','Media'));
        CitySelectOptions.add(new SelectOption('Registration','Registration'));
        CitySelectOptions.add(new SelectOption('Organiser','Organiser'));
        CitySelectOptions.add(new SelectOption('VIP Visitor	','VIP Visitor	'));
        CitySelectOptions.add(new SelectOption('VIP','VIP'));
        CitySelectOptions.add(new SelectOption('Other','Other'));
        return CitySelectOptions;
    }
    
    public List<SelectOption> getPartnerTypes() 
    {
        List<SelectOption> CitySelectOptions = new List<SelectOption>();
        CitySelectOptions.add(new SelectOption('','New'));
        CitySelectOptions.add(new SelectOption('Partner','Partner'));
        CitySelectOptions.add(new SelectOption('Spouse','Spouse'));
        CitySelectOptions.add(new SelectOption('Child','Child'));
        CitySelectOptions.add(new SelectOption('Other','Other'));
        
        return CitySelectOptions;
    }
    
}