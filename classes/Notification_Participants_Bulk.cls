/**
*** CHANGE LOG ***
 
 16/11/2017 - TdB    - Created Class.
 22/02/2018 - TdB    - Add DrawDown and Fit to Lend functionality

**/ 

public class Notification_Participants_Bulk {
    
    public List<sObject_Scheduling_Occurences.ParticipantWrapper> participantsWrapper { get; set; }
    public List<Notification_Participant__c> existingNotificationParticipants { get; set; }
    public List<advpm__Participant__c> existingParticipants { get; set; }
    public List<sObject> objectParentRecord { get; set; }
    public Set<Id> existingParticipantsSet { get; set; }
    public Map<Id, Id> participantNotificationParticipants { get; set; }
    public Boolean showError { get; set; }
    public Id currentObjectId;
    public String currentObjectName; 
    public Id parentObjectId;
    
    public Notification_Participants_Bulk()
    {
        //Empty wrappers
        participantsWrapper = new  List<sObject_Scheduling_Occurences.ParticipantWrapper>();
        existingNotificationParticipants = new List<Notification_Participant__c>();
        existingParticipants = new  List<advpm__Participant__c>();
        objectParentRecord = new List<sObject>();
        existingParticipantsSet = new Set<Id>();
        participantNotificationParticipants = new Map<Id, Id>();
        
        //Get Record Id from URL
        if(ApexPages.currentPage().getParameters().get('sObjectId') != null)
        {
            currentObjectId = Id.valueOf(ApexPages.currentPage().getParameters().get('sObjectId'));
        }
        
        //Get Object API Name based on Id
        currentObjectName = currentObjectId.getSObjectType().getDescribe().getName();
        
        //Margin Ratchet
        if(currentObjectName  == 'Margin_Ratchet__c')
        {
            //Get Margin Ratchet Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Margin_Ratchet__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification Participants
            existingNotificationParticipants = [SELECT Id, Margin_Ratchet__c,Participant__c FROM Notification_Participant__c WHERE Margin_Ratchet__c = : currentObjectId];
        }
        //Collateral Vaulation
        else if(currentObjectName  == 'Collateral_Valuation__c')
        {
            //Get Collateral Valuation Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Collateral_Valuation__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification Participants
            existingNotificationParticipants = [SELECT Id, Collateral_Valuation__c,Participant__c FROM Notification_Participant__c WHERE Collateral_Valuation__c = : currentObjectId];
        }   
        //Collateral Monitoring
        else if(currentObjectName  == 'Collateral_Monitoring__c')
        {
            //Get Margin Collateral Monitoring (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Collateral_Monitoring__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification Participants
            existingNotificationParticipants = [SELECT Id, Collateral_Monitoring__c,Participant__c FROM Notification_Participant__c WHERE Collateral_Monitoring__c = : currentObjectId];
        }
        //Trigger
        else if(currentObjectName  == 'Trigger__c')
        {
            //Get Trigger Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Trigger__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification Participants
            existingNotificationParticipants = [SELECT Id, Trigger__c,Participant__c FROM Notification_Participant__c WHERE Trigger__c = : currentObjectId];
        }
        //DrawDown
        else if(currentObjectName  == 'Drawdown__c')
        {
            //Get Trigger Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Drawdown__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification Participants
            existingNotificationParticipants = [SELECT Id, Trigger__c,Participant__c FROM Notification_Participant__c WHERE Drawdown__c = : currentObjectId];
        }
        //Fit to Lend
        else if(currentObjectName  == 'Fit_To_Lend_Checklist__c')
        {
            //Get Trigger Record (sObject)
            objectParentRecord = [SELECT Id, Deal__c  FROM Fit_To_Lend_Checklist__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification Participants
            existingNotificationParticipants = [SELECT Id, Trigger__c,Participant__c FROM Notification_Participant__c WHERE Fit_To_Lend_Checklist__c = : currentObjectId];
        }
                
        if(currentObjectName  != 'Fit_To_Lend_Checklist__c' && objectParentRecord.size() > 0 && (Id)objectParentRecord[0].get('Agreement__c') != null )
        {
            //Call class with method to get list of Participants
            sObject_Scheduling_Occurences.getParticipantsList((Id)objectParentRecord[0].getSObject('Agreement__r').get('Matter_Deal__c'));
            //Get Participants linked to Agreement
            existingParticipants = sObject_Scheduling_Occurences.participants;
        }
        else if(currentObjectName  == 'Fit_To_Lend_Checklist__c' && objectParentRecord.size() > 0 && (Id)objectParentRecord[0].get('Deal__c') != null )
        {
            //Call class with method to get list of Participants
            sObject_Scheduling_Occurences.getParticipantsList((Id)objectParentRecord[0].get('Deal__c'));
            //Get Participants linked to Agreement
            existingParticipants = sObject_Scheduling_Occurences.participants;
        }
        
        if(!existingNotificationParticipants.isEmpty())
        {
            //Build a set of existing Notification Participants
            for(Notification_Participant__c eachNotificationParticipant : existingNotificationParticipants)
            {
                if(!existingParticipantsSet.contains(eachNotificationParticipant.Participant__c))
                {
                    existingParticipantsSet.add(eachNotificationParticipant.Participant__c);  
                } 
                
                //Add to map for use later to track deselected.
                participantNotificationParticipants.put(eachNotificationParticipant.Participant__c, eachNotificationParticipant.Id);
            } 
        }
        
        initialiseWrapperList();
    }
    
    public void initialiseWrapperList()
    {
        System.debug('### initialiseWrapperList : ' + existingParticipants);
        //Loop through Participants Wrapper, check if Participant already created as a Notification Participant and flag as True
        for(advpm__Participant__c eachParticipant : existingParticipants)
        {
            sObject_Scheduling_Occurences.participantWrapper wrapperItem = new sObject_Scheduling_Occurences.participantWrapper();
            wrapperItem.participant = eachParticipant;
            
            if(existingParticipantsSet.contains(eachParticipant.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            participantsWrapper.add(wrapperItem);
        }
    }
    
    public PageReference saveRecord() 
    {
     	System.debug('### saveRecord : ' + existingParticipants);   
        List<Notification_Participant__c> notificationParticipantInsert = new List<Notification_Participant__c>();
        List<Notification_Participant__c> notificationParticipantDelete = new List<Notification_Participant__c>();
        Map <String, Schema.RecordTypeInfo> NOTI_PARTICIPANT_TYPES = Notification_Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        
        //Reset error message.
        showError = true;
        
        //Loop through wrapper list.
        for(sObject_Scheduling_Occurences.participantWrapper eachWrapper : participantsWrapper)
        {
            //If selected
            if(eachWrapper.selected)
            {
                //One is selected at least.
                showError = false;
                
                if(!existingParticipantsSet.contains(eachWrapper.participant.Id))
                {
                    //New Notification participant
                    Notification_Participant__c notificationParticipantItem = new Notification_Participant__c();
                    
                    //Set Record Type and sObject
                    //Margin Ratchet
                    if(currentObjectName  == 'Margin_Ratchet__c')
                    {
                        notificationParticipantItem.Margin_Ratchet__c = currentObjectId;
                        notificationParticipantItem.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Margin Ratchet').getRecordTypeId();
                    }
                    //Collateral Valuation
                    else if (currentObjectName  == 'Collateral_Valuation__c')
                    {
                        notificationParticipantItem.Collateral_Valuation__c = currentObjectId;
                        notificationParticipantItem.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Collateral Valuation').getRecordTypeId();
                    }
                    //Collateral Monitoring
                    else if (currentObjectName  == 'Collateral_Monitoring__c')
                    {
                        notificationParticipantItem.Collateral_Monitoring__c = currentObjectId;
                        notificationParticipantItem.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Collateral Monitoring').getRecordTypeId();
                    }
                    //Trigger
                    else if (currentObjectName  == 'Trigger__c')
                    {
                        notificationParticipantItem.Trigger__c = currentObjectId;
                        notificationParticipantItem.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Trigger').getRecordTypeId();
                    }
                    //DrawDown
                    else if (currentObjectName  == 'Drawdown__c')
                    {
                        notificationParticipantItem.Drawdown__c = currentObjectId;
                        notificationParticipantItem.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Drawdown').getRecordTypeId();
                    }
                    //Fit to Lend
                    else if (currentObjectName  == 'Fit_To_Lend_Checklist__c')
                    {
                        notificationParticipantItem.Fit_To_Lend_Checklist__c = currentObjectId;
                        notificationParticipantItem.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Fit To Lend Checklist').getRecordTypeId();
                    }
                    
                    notificationParticipantItem.Participant__c = eachWrapper.participant.Id;
                    
                    //Add to list.
                    notificationParticipantInsert.add(notificationParticipantItem);
                }
            }
            //If deselected
            else
            {
                if(existingParticipantsSet.contains(eachWrapper.participant.Id))
                {
                    //Id of participant to delete.
                    Id participantNotificationId = (Id)participantNotificationParticipants.get(eachWrapper.participant.Id);
                    
                    //Notification participant to delete.
                    Notification_Participant__c notificationParticipantToDelete = new Notification_Participant__c(Id = participantNotificationId); 
                    
                    //Add to delete list.
                    notificationParticipantDelete.add(notificationParticipantToDelete);
                }
            }
        }
        
        //Execute changes.
        try 
        {
            //Insert new records.
            if(!notificationParticipantInsert.isEmpty())
            {
                insert notificationParticipantInsert;
            }
            
            //Delete deselected records.
            if(!notificationParticipantDelete.isEmpty())
            {
                delete notificationParticipantDelete;
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+ currentObjectId); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        return null;
    }
}