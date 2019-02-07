/**
* Author : Rudolf Niehaus
* Date   : 2017-08-05
* Desc   : 

2017-08-24	DH	Initiliase the new Host__c field on new Delegates
2017-08-26	DH	Clear the allExistingDelMap each time the list are loaded
2017-08-28	RN	Add logic to use event bookings only for Complex event registration proces types
2017-10-12	DF  Removing logic the creates the Event_Team_Members_Delegates__c against the delegate record as the evDelegate_trigger now handles it
**/
public class evAddContactsToEventExt 
{
    
    public String recordCount {set;get;}
    public String eventId {get;set;}
    public String selectedEvent{get;set;}
    public String selectedHost {get;set;}
    public list<SelectOption> eventOptions {get;set;}
    public list<SelectOption> hostOptions {get;set;}
    public list<listAWrapper> lstAWrapper {get;set;}
    public list<Delegate__c> existingDelegates {get;set;}
    public Boolean isNumbersOk {get;set;}  
    public Decimal existingNumbers {get;set;}
    public Decimal selectedNumbers {get;set;}
    public Decimal allowedNumbers {get;set;}
    
    private set<String> contactIds = new set<String>();
    private set<String> delegateIds = new set<String>();
    private map<Id,Delegate__c> allExistingDelMap = new map<Id, Delegate__c>();
    private map<String, String> eventProcessType = new map<String,String>();
    private map<String, Decimal> maxNumberPerHost = new map<String, Decimal>();
    public static Map <String, Schema.RecordTypeInfo> mapDelegateRecordTypes = Delegate__c.sObjectType.getDescribe().getRecordTypeInfosByName();  
    
    public evAddContactsToEventExt(ApexPages.StandardSetController setController){}
    
    public PageReference showEvent()
    {
        profile UserProfile =  
            [
                SELECT
                id,
                name
                from
                profile
                where
                id = :system.UserInfo.getProfileId()
            ];
        
        
        
        contactIds.addAll(ApexPages.currentPage().getParameters().get('recs').split(',',-2));
        
        recordCount = String.valueOf(contactIds.size());
        eventOptions = new list<SelectOption>();
        hostOptions = new list<SelectOption>();
        existingDelegates = new list<Delegate__c>(); 
        isNumbersOk = true;
        existingNumbers = 0;
        selectedNumbers = 0;
        allowedNumbers = 0;
        
        for
            (
                Event__c e :
                [
                    Select
                    Id, 
                    Name, 
                    City__c, 
                    Start_Date__c, 
                    Registration_Process__c,    
                    ( 
                        Select
                        Team_Member__c
                        From
                        Event_Teams__r
                        Where
                        Team_Member__c = :UserInfo.getUserId()
                    ) 
                    From 
                    Event__c
                    Where 
                    Active__c = true 
                    ORDER BY Start_Date__c ASC
                ]
            )
        {
            
            eventProcessType.put(e.Id,e.Registration_Process__c);
            
            if(e.Event_Teams__r.size() > 0 || ( UserProfile.name == 'System Administrator' || UserProfile.name == 'Barclays Administrator'))
            {
                //add first listed event ID and member details
                if(String.isBlank(selectedEvent))
                {
                    selectedEvent = e.Id; 
                }
                
                Date dateOnly = e.Start_Date__c;
                eventOptions.add(new SelectOption(e.Id, dateOnly.format() + ' - ' + e.Name + ' - ' + e.City__c));
                
            }          
        }
        
        //populate dynamic host and existing delegates lists
        fillLists(selectedEvent);
        system.debug('lstAWrapper :' + lstAWrapper);       
        return null;
    }
    
    public void fillLists(String eventId)
    {
        
        //populate hosts picklist
        Id currentUser = UserInfo.getUserId();
        list<SelectOption> holdLoginHost = new list<SelectOption>();
        hostOptions.clear();
        maxNumberPerHost.clear();
        isNumbersOk = true;
        
        for
            (
                Event_Team_Member__c tm :
                [
                    Select
                    Id, 
                    Team_Member__c, 
                    Team_Member__r.Name, 
                    Event_Team_Member_Role__c, 
                    Maximum_Number_of_Actual_Invitees__c,
                    Maximum_Number_of_Proposed_Invitees__c  
                    From 
                    Event_Team_Member__c 
                    Where 
                    Event__c = :eventId
                ]
            )
        {
            system.debug('tm.Maximum_Number_of_Proposed_Invitees__c :' + tm.Maximum_Number_of_Proposed_Invitees__c); 
            maxNumberPerHost.put(tm.Id, tm.Maximum_Number_of_Proposed_Invitees__c);                              
            system.debug('maxNumberPerHost :' + maxNumberPerHost);                        
            if(tm.Team_Member__c == currentUser)
            {
                selectedHost = tm.Id;
                //hold the login users listing so we can add the rest at the bottom of the list and this is the default
                hostOptions.add(new SelectOption(tm.Id, tm.Team_Member__r.Name + ' - ' + tm.Event_Team_Member_Role__c ));
            }
            else
            {
                holdLoginHost.add(new SelectOption(tm.Id, tm.Team_Member__r.Name + ' - ' + tm.Event_Team_Member_Role__c ));
            }
            
            if(String.isBlank(selectedHost)){
                
                selectedHost = tm.Id;
            } 
        }
        
        //add the rest of the list
        hostOptions.addAll(holdLoginHost);
        
        //populate existing delegates 
        existingDelegates.clear();
        delegateIds.clear();
        
        //get correct delegates for selected host
        set<Id> delIds = new set<Id>(); 
        for(Event_Team_Members_Delegates__c etm :[Select Delegate__c From Event_Team_Members_Delegates__c 
                                                  Where Event_Team_Member__c = :selectedHost])
        {
            delIds.add(etm.Delegate__c);                                      
        }
        
        existingNumbers = 0;
        
        for(Delegate__c del :[Select Id, Invitation_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName  
                              From Delegate__c Where Event__c = :eventId and id IN :delIds])
        {
            existingNumbers++;
            delegateIds.add(del.Contact__c);
            existingDelegates.add(del);
        }
        
        //get all existing delegates regardless of host in order not to add duplicates
        allExistingDelMap = new map<Id, Delegate__c>();
        for(Delegate__c xDel :[Select Id, Contact__c From Delegate__c Where Event__c = :eventId])
        {
            allExistingDelMap.put(xDel.Contact__c, xDel);
        }
        selectedNumbers = 0;
        //populate wrapper class
        lstAWrapper = new list<listAWrapper>();
        system.debug('contactIds +' + contactIds); 
        for(Contact c :[Select Id, FirstName, LastName From Contact Where Id IN :contactIds])
        {
            system.debug('c' + c);
            system.debug('contactIds' + contactIds);
            system.debug('delegateIds' + delegateIds);
            listAWrapper AW = new listAWrapper(c, true);
            
            if(!delegateIds.contains(c.Id))
            {
                AW.isChecked = true;
                lstAWrapper.add(AW);
                selectedNumbers++;
            }
        }
        system.debug('(existingNumbers + selectedNumbers) >  maxNumberPerHost.get(selectedHost) :' + ((existingNumbers + selectedNumbers) >  maxNumberPerHost.get(selectedHost)));       
        if( (existingNumbers + selectedNumbers) >  maxNumberPerHost.get(selectedHost))
        {
            isNumbersOk=false;
            allowedNumbers = maxNumberPerHost.get(selectedHost);
        }
        system.debug('lstAWrapper :' + lstAWrapper);       
        system.debug('existingNumbers :' + existingNumbers);       
        system.debug('selectedNumbers :' + selectedNumbers);      
        system.debug('maxNumberPerHost.get(selectedHost) :' + maxNumberPerHost.get(selectedHost));      
        system.debug('allowedNumbers :' + allowedNumbers);     
        system.debug('isNumbersOk :' + isNumbersOk);      
    }
    
    public PageReference addToEvent()
    {
        system.debug('lstAWrapper :' + lstAWrapper);       
        SavePoint sp = Database.setSavepoint();
        
        //create new Event Booking record
        Event_Booking__c eventBooking = new Event_Booking__c();
        
        if(eventProcessType.get(selectedEvent) == 'Complex')
        {
            eventBooking.Event__c = selectedEvent;
            try
            {
                insert eventBooking;
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
        
        for(listAWrapper w :lstAWrapper)
        {
            system.debug('w '+w );
            if(w.IsChecked)
            {
                
                Delegate__c del = new Delegate__c();
                del.Contact__c = w.wContact.Id;
                del.Event__c = selectedEvent;
                
                if(String.isNotBlank(eventBooking.Id))
                {
                    del.Event_Booking__c = eventBooking.Id;
                }
                
                del.Invitation_Status__c = 'Proposed';
                del.Host__c = selectedHost;
                del.recordtypeid = mapDelegateRecordTypes.get('Invitee').getRecordTypeId();
                if(allExistingDelMap.containsKey(w.wContact.Id))
                {
                    existingDelList.add(allExistingDelMap.get(w.wContact.Id));
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
        delList.addAll(existingDelList);
        
        /*for (Delegate__c d :delList)
        {  
            
            Event_Team_Members_Delegates__c evtd = new Event_Team_Members_Delegates__c();                    
            evtd.Event_Team_Member__c = selectedHost;
            evtd.Delegate__c = d.Id;
            
            delegateHostLinks.add(evtd);
        }
        
        try
        {
            insert delegateHostLinks;
        }
        catch(DMLException ex)
        {
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error when inserting the selected delegates for this event'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug(ex.getMessage());
            
            Database.rollback(sp);
            
            return null;
        }*/        
        
        PageReference eventPage = new PageReference('/' + selectedEvent);
        
        return eventPage;
    }
    
    public PageReference cancel()
    {
        PageReference contactViewPage = new PageReference('/003/o');
        
        return contactViewPage;
        
    }
    public PageReference refreshLists()
    {
        
        //populate dynamic host and existing delegates lists
        fillLists(selectedEvent);
        
        return null;
        
    }
    
    public PageReference newHostList()
    {
        isNumbersOk = true;
        //populate existing delegates 
        existingDelegates.clear();
        delegateIds.clear();
        
        //get correct delegates for selected host
        set<Id> delIds = new set<Id>(); 
        for(Event_Team_Members_Delegates__c etm :[Select Delegate__c From Event_Team_Members_Delegates__c 
                                                  Where Event_Team_Member__c = :selectedHost])
        {
            delIds.add(etm.Delegate__c);                                      
        }
        existingNumbers = 0;
        for(Delegate__c del :[Select Id, Invitation_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName 
                              From Delegate__c Where Event__c = :selectedEvent and id IN :delIds])
        {
            
            existingNumbers++;
            delegateIds.add(del.Contact__c);
            existingDelegates.add(del);
        }
        
        selectedNumbers = 0;
        //populate wrapper class
        lstAWrapper = new list<listAWrapper>();
        for(Contact c :[Select Id, FirstName, LastName From Contact Where Id IN :contactIds])
        {
            
            listAWrapper AW = new listAWrapper(c, true);
            
            if(!delegateIds.contains(c.Id))
            {
                AW.ischecked = true;
                lstAWrapper.add(AW);
                selectedNumbers++;
            }
        }
        
        
        if( (existingNumbers + selectedNumbers) >  maxNumberPerHost.get(selectedHost))
        {
            isNumbersOk=false;
            allowedNumbers = maxNumberPerHost.get(selectedHost);
        } 
        return null;
        
    }
    
    public class listAWrapper
    {
        
        public Contact wContact {get;set;}
        public Boolean IsChecked {get;set;}
        
        public listAWrapper(Contact rec, Boolean chk)
        {
            this.wContact = rec;
            this.IsChecked = chk;
        }
    } 
}