/*
* 17-08-08	DH:	Changed from using Status__c to Invitation_Status__c
* 17-08-22 	DP: Update Custom Setting to Custom Metadata evSetting__mdt which will be used going forward to store all Custom Event Settings
* 17-08-22	DH:	Set Delegate.Host when new record created
* 17-09-14  DF: Updating to allow partial inserts of contacts and the logic to handle them
* COmments
* 08-09 DH->Gen:  You have DML operations in a loop - "update contact" - which will fail if the volumes get too high
* 08-10 DH->Gen:  I cannot think of anything else.  Go with the limit of records to review and process on each page.... and keep the loop as is
*/


public class evImportDelegates_Controller {
    public List<PendingDelegate> PendingDelegates {get; set;}
    public Id EventId { get; set;}
    public List<Pending_Delegate__c> items {get; set;}
    public string defaultListValue {get; set;}
    public List<Event__c> Events {get; set;}
    public List<SelectOption> EventsList {get; set;}
    public string selectedEvent {get; set;}
    public boolean hasItems {get; set;}
    public string dataImportWizardURL {get;set;}
    public string importFileTemplateURL {get;set;}
    public List<SelectOption> TeamMembersList {get;set;}
    public string selectedTeamMember {get;set;}
    public string numberOfInvites {get;set;}
    public integer numberOfInvitesUsed;
    Public set<string> ContactUpsertErrorList  {get;set;}
    public List<Event_Team_Member__c> members {get;set;}
    public set<id> FailedUpdateContactIdSet {get;set;}
    
    public evImportDelegates_Controller()
    {
        system.debug('>>>>> Entering Constructor');
        
        selectedEvent = ApexPages.currentPage().getParameters().get('eventid');        
        selectedTeamMember = ApexPages.currentPage().getParameters().get('host');
        numberOfInvites = '0';    
        numberOfInvitesUsed = 0;
        defaultListValue = 'New';
        ContactUpsertErrorList =  new set<string>();
        FailedUpdateContactIdSet =  new set<id>();
        Events = [select Id,Name from Event__c where Active__c =true];// and Team_Member__c = '00524000000xuH1'];
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
        
        getPendingDelegateItems();        
        
        system.debug('PendingDelegates = ' + PendingDelegates);
        
        if (string.isNotBlank(selectedTeamMember))
        {
            GetTeamMembersList();
            getNumberOfInvitesUsed();
            getNumberOfInvites();
        }
    }   
    
    public void getPendingDelegateItems()
    {
        system.debug('>>>>> Entering getPendingDelegateItems');
        List<Pending_Delegate__c> pditems = [select Id, Name, First_Name__c, Last_Name__c, Email__c, Company_Name__c, Event__c,Job_Title__c,Mobile_Phone__c
                                             from Pending_Delegate__c where OwnerId=:UserInfo.getUserId() 
                                             order by First_Name__c, Last_Name__c, Company_Name__c, Job_Title__c limit 30];
        PendingDelegates = new List<PendingDelegate>();
        if (pditems != null && pditems.size() > 0)
        {          
            system.debug('retrieved pending delegates where OwnerId=' + UserInfo.getUserId() );
            hasItems = true;
            
            for(Pending_Delegate__c item: pditems)
            {
                system.debug('item:' + item);
                PendingDelegate newD = new PendingDelegate();
                newD.PDId = item.Id;
                newD.FirstName = item.First_Name__c;
                newD.LastName = item.Last_Name__c;
                newD.JobTitle = item.Job_Title__c;
                newD.CompanyName = item.Company_Name__c;
                newD.Email = item.Email__c;
                newD.MobilePhone = item.Mobile_Phone__c;                 
                newD.EventId = item.Event__c;
                newD.PossibleMatches = new List<SelectOption>();
                
                //Check for matching contacts for this item
                string fnFilter = '%' + item.First_Name__c + '%';
                string lnFilter = '%' + item.Last_Name__c + '%';
                List<Contact> matches = null;
                try{
                    matches = 
                        [
                            select 
                            Id, Name,FirstName,LastName, Title, MobilePhone, Email, Company_Name__c 
                            from 
                            Contact 
                            where 
                            (FirstName like :fnFilter or LastName like :lnFilter) and 
                            (MobilePhone = :item.Mobile_Phone__c or Email = :item.Email__c)
                            order by FirstName,LastName,Company_Name__c,Title,Email
                            limit 30
                        ];
                } catch (Exception ex){}
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
                PendingDelegates.Add(newD);
            }            
        }
        else 
        {
            evSetting__mdt settings = [select Data_Import_Wizard_URL__c,Template_File_Path__c from evSetting__mdt where QualifiedApiName = 'Bhalisa_Default' limit 1] ;
            if (settings != null)
            {
                dataImportWizardURL = settings.Data_Import_Wizard_URL__c;
                importFileTemplateURL = settings.Template_File_Path__c;
            }
        }
        
        //return PendingDelegates;
        
        
    }
    
    public integer getNumberOfInvitesUsed()
    {
        system.debug('>>>>> Entering getNumberOfInvitesUsed, selectedTeamMember = ' + selectedTeamMember);
        numberOfInvitesUsed = 0;
        if (string.isNotBlank(selectedTeamMember) && string.isNotBlank(selectedEvent))
        {
            Id tm = Id.valueOf(selectedTeamMember);           
            system.debug('SOQL:'+ 'select count() from Event_Team_Members_Delegates__c where Event_Team_Member__c = \'' + tm + '\' and Event_Team_Member__r.Event__r.Id = \'' + selectedEvent + '\'');
            try{
                numberOfInvitesUsed = database.countQuery('select count() from Event_Team_Members_Delegates__c where Event_Team_Member__c = \'' + tm + '\' and Event_Team_Member__r.Event__r.Id = \'' + selectedEvent + '\'');
            } 
            catch (Exception ex)
            {
                system.debug('ERROR:' + ex.getMessage());
                numberOfInvitesUsed = 0;
            }
        } else 
        {
            return -1;
        }
        return numberOfInvitesUsed;
    }
    public void setNumberOfInvitesUsed(integer v)
    {
        numberOfInvitesUsed = v;
    }
    public string getDefaultListValue()
    {
        if (string.isNotBlank(defaultListValue)) defaultListValue = 'New';
        return defaultListValue;
    }
    public void setDefaultListValue(string v)
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
    
    public PageReference removeDelegates()
    {
        system.debug('>>>>> Entering removeDelegates');
        List<Pending_Delegate__c> del = new List<Pending_Delegate__c>();
        Pending_Delegate__c dd = null;
        // system.debug('PendingDelegates:' + PendingDelegates);
        for(PendingDelegate d: PendingDelegates)
        {
            system.debug('Handling PendingDelegate:' + d);
            if (d.doImport == true)
            {
                try
                {
                    system.debug('select Id from Pending_Delegate__c where ID=:' + d.PDId + ' limit 1');
                    dd = [select Id from Pending_Delegate__c where ID=:d.PDId limit 1];
                } 
                catch (Exception ex) {system.debug('error retrieving pending delegate for deletion:' + ex.getMessage());}
                if (dd != null) del.add(dd);
            }
        }
        system.debug('del = ' + del);
        if (del != null && del.size() > 0) delete del;
        system.debug('selectedEvent=' + selectedEvent + ', selectedTeamMember = ' + selectedTeamMember);
        
        getPendingDelegateItems();
        if (PendingDelegates.size() == 0)
        {
            PageReference pr = new PageReference('/apex/evImportDelegates');
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
    
    public PageReference GetTeamMembersList()
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
                event = [select Id,Name,Registration_Process__c, Venue__c, Private_Delegate_Account_Name__c from Event__c where ID=:eventId limit 1];
            } catch (exception Ex){}
            
            if (event == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This event\'s details cannot be found!'));                
                TeamMembersList.Add(new SelectOption('', '(No Event Team Members Found)'));
                return null;
            }
            if (string.isBlank(event.Private_Delegate_Account_Name__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There is no Private Delegate Account specified for this event. Please assign one in order to import delegates.'));                
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please assign a value for Private Delegate Account in order to import delegates.'));                
                //TeamMembersList.Add(new SelectOption('', '(No Event Team Members Found)'));
                TeamMembersList = null;
                return null;
            }
            try
            {
                members = [select ID,Team_Member__r.Name,Maximum_Number_of_Proposed_Invitees__c from Event_Team_Member__c where Event__c =: eventId];
            } catch (exception ex)
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
        if (string.isNotBlank(selectedTeamMember) && members != null)
        {
            for(Event_Team_Member__c m: members)
            {
                if (m.Id == Id.valueOf(selectedTeamMember))
                {
                    numberOfInvites = string.valueOf(integer.valueOf(m.Maximum_Number_of_Proposed_Invitees__c));
                    return numberOfInvites;                    
                }
            }
        }
        return numberOfInvites;
    }
    
    public PageReference TeamMemberSelected()
    {
        getNumberOfInvites();
        return null;
    }
    
    public void setNumberOfInvites(string val)
    {
        numberOfInvites= val;
        system.debug('end of setNumberOfInvites');
    }
    
    public List<Pending_Delegate__c> getPendingDelegatesList()
    {
        return items;
    }
    
    public PageReference goBack()
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
    
    private Event_Booking__c createEventBooking(Id eventId)
    {
        //Create EventBooking
        Event_Booking__c EventBooking = new Event_Booking__c();
        EventBooking.Event__c = eventId;
        insert EventBooking;
        return EventBooking;
    }
    
    public PageReference createDelegates()
    {        
        ApexPages.getMessages().clear();
        //update items;
        system.debug('>>>>> Entering createDelegates, selectedEvent:' + selectedEvent);//a0G9E000000395DUAQ
        // Perform some validation
        for(PendingDelegate d: PendingDelegates)
        {
            if (d.doImport == true && (string.isBlank(d.ActualMatch) || d.ActualMatch=='Select'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure you have selected an action/possible match for every delegate selected'));
                return null;
            }
        }
        
        if (string.isNotBlank(selectedEvent) && string.isNotBlank(selectedTeamMember))
        {
            Id eventId = Id.valueOf(selectedEvent);
            Set<PendingDelegate> deleteDelegates = new Set<PendingDelegate>();
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
                event = [select Id,Name,Registration_Process__c, Venue__c, Private_Delegate_Account_Name__c from Event__c where ID=:eventId limit 1];
            } catch (exception Ex){}
            
            if (event == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This events details cannot be found!'));                
                return null;
            }
            integer dc = 0;
            for(PendingDelegate d: PendingDelegates)
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
                            existingContact = [select Id,Name,FirstName,LastName,MobilePhone,Title,Email,Company_Name__c from Contact where Id=:Id.valueOf(d.ActualMatch) limit 1];
                        } 
                        catch (Exception ex) {}
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
                    if (!deleteDelegates.contains(d)) deleteDelegates.add(d);
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
                        system.debug('ContactUpsertErrorList : ' +ContactUpsertErrorList);
                        ListIndex++;//increase list index to keep aligned
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
                    
                    List<Id> contactIds = new List<Id>();
                    for(Contact uc: upsertContacts)
                    {                           
                        contactIds.Add(uc.Id);
                        
                       for(PendingDelegate d: PendingDelegates)//DF for contacts that have an id, add to pending delegates based on email and first and last name so we can use the id later to match the pending delegate and actual delegate records
                       {
                           if(d.email == uc.Email && d.firstname == uc.FirstName && d.lastname == uc.LastName)//
                           {
                               d.Contactid =  uc.id;
                           }
                           
                       }
                        
                        if ((event.Registration_Process__c == null || event.Registration_Process__c == 'Simple'))
                        {                                
                            //Check if there is an existing event booking to add to
                            try
                            {
                                if (EventBooking == null) 
                                {
                                    system.debug('DML: Select Event_Booking__c');
                                    EventBooking = [select Id, Name from Event_Booking__c where Event__c=:event.Id limit 1];
                                }
                            } 
                            catch (Exception ex) {}
                            if (EventBooking == null)
                            {
                                //Create booking for each delegate  
                                //system.debug('about to add new Event booking');
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
                                //system.debug('Using existing eventBooking.');
                            }
                        }  
                        else 
                        {
                            //Create booking for each delegate    
                            EventBooking = null;
                            //system.debug('About to add new Event booking');
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
                        //system.debug('EventBooking:' + EventBooking);
                        if (EventBooking != null)
                        {                                    
                            Delegate__c Delegate = null;
                            if(uc.Id != null)//DF added only create delegates for contacts that were sucessfully inserted/have an id
                            {
                                ID cID = id.valueOf(uc.Id);
                                try
                                {
                                    system.debug('DML: Select Delegate for contact ' + cID);
                                    Delegate = [select Id, Name,contact__c from Delegate__c where Contact__c =:cID and Event__c =:eventId];
                                } 
                                catch (Exception ex) {}
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
            if (existingDelegates != null && existingDelegates.size() > 0) jointDelegateList.addAll(existingDelegates);
            if (jointDelegateList != null && jointDelegateList.size() > 0)
            {
                for (Delegate__c del: jointDelegateList)
                {                    
                    Event_Team_Members_Delegates__c evtd = new Event_Team_Members_Delegates__c();                    
                    evtd.Event_Team_Member__c = Id.valueOf(selectedTeamMember);
                    evtd.Delegate__c = del.Id;
                    try
                    {
                        evtd.Id = [select ID from Event_Team_Members_Delegates__c where Event_Team_Member__c =: stm and Delegate__c =:del.Id].Id;
                    } catch (exception ex){}
                    Hosts.Add(evtd);                    
                }       
            }
            if (Hosts.size() > 0) upsert Hosts;
            for(PendingDelegate pd: deleteDelegates)
            {
                for (Delegate__c delRec: jointDelegateList)//DF only set DelegateOrHostCreated to true if a contact, delegate__c and host/Event_Team_Members_Delegates__c have been created for this pending delegate
                {  
                    for(Event_Team_Members_Delegates__c  HostRec : Hosts)
                    {
                        if(pd.contactid == delRec.contact__c && delRec.id != null && delRec.id == HostRec.Delegate__c && HostRec.id != null ) 
                        {
                            pd.DelegateOrHostCreated = true;
                        }
                       
                    }
                }      
            }          
            
            
            // Now we can remove the proposed delegates from the pending_delegates__c object so that the next 30 can be picked up and processed.
            if (deleteDelegates.size() > 0) 
            {
                List<Pending_Delegate__c> del = new List<Pending_Delegate__c>();
                Pending_Delegate__c dd = null;
                for(PendingDelegate pd: deleteDelegates)
                {
                    system.debug('delete loop pd :' + pd);
                    system.debug('delete loop FailedUpdateContactIdSet :' + FailedUpdateContactIdSet);
                        
                    if(pd.DelegateOrHostCreated == true && FailedUpdateContactIdSet.Contains(pd.contactID) == false )//DF Only delete if host has been created, hosts can only be created if the contact and delegate record have succesfully inserted or updated
                    {
                        dd = null;
                        try
                        {
                            dd = [select Id from Pending_Delegate__c where ID=:pd.PDId limit 1];
                        } 
                        catch (Exception ex) {}
                        if (dd != null) del.add(dd);
                    }
                }
                if (del != null && del.size() > 0) delete del;
            }
            //return new PageReference('/' + eventId);
            
            getPendingDelegateItems();
            if ( ContactUpsertErrorList.size() > 0)//DF ensure there are no errors that must be addressed
            {
                 ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please note there are errors uploading contact data'));
                return null;
            }
            if (PendingDelegates.size() == 0 )//DF ensure there are no errors that must be addressed
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
    
    public class PendingDelegate
    {
        public PendingDelegate()
        {
            PossibleMatches = new List<SelectOption>();
            FirstName = '';
            LastName = '';
            JobTitle = '';
            CompanyName = '';
            Email = '';
            MobilePhone = '';                       
        }
        public Id PDId {get; set;}
        public Id ContactId {get; set;}//DF used for matching Pending delgates with actual Delegate records
        Public Boolean DelegateOrHostCreated{get; set;}//DF used to prevent the deletion of pending delegates that have do not have a host or delegate record
        public string FirstName { get; set;}
        public string LastName {get; set;}
        public string JobTitle {get;  set;}
        public string CompanyName {get; set;}
        public string Email { get; set;}
        public string MobilePhone { get; set;} 
        public List<SelectOption> PossibleMatches {get; set;}
        public Id EventId {get; set;}
        public string ActualMatch { get; set;}
        public boolean hasPossibleMatches { get; set;}
        public boolean doImport {get; set;}
    }
}