/**
*** CHANGE LOG ***

08/12/2017 - TdB   - Created Class.
				   - Call methods to insert Trigger record, Notification Participants and Groups (Wrappers)
				   - DealParticipants() - Get Notification Participants based on Deal selected

**/ 
public with sharing class Trigger_Override 
{
    public Trigger__c triggerRecord { get; set; }
    public sObject_Scheduling_Occurences sObjectSchedulingOccurencesClass = new sObject_Scheduling_Occurences();
    public List<sObject_Scheduling_Occurences.ParticipantWrapper> participantsWrapper { get; set; }
    public List<sObject_Scheduling_Occurences.DistroGroupWrapper> distroGroupsWrapper { get; set; }
    
    //Constructor
    public Trigger_Override(ApexPages.StandardController stdController) 
    {
        //Empty wrappers
        participantsWrapper = new List<sObject_Scheduling_Occurences.ParticipantWrapper>();
        distroGroupsWrapper = new List<sObject_Scheduling_Occurences.DistroGroupWrapper>();
        
        List<Agreement__c> agreementRecord = new List<Agreement__c>();
        
        //Add additional fields for record
        List<String> fields = new List<String>{
            'Agreement__c', 
                'Agreement__r.Matter_Deal__c'
                };
                    
                    //Query fields.
                    if(!Test.isRunningTest())
                {
                    stdController.addFields(fields); 
                }
        
        //Fetch object record.
        this.triggerRecord = (Trigger__c)stdController.getRecord();
        
        //New record.
        if(triggerRecord.Id == null)
        {
            //Populate all lookups.
            populateLookups();
        }

        //Get Matter/Deal Id
        agreementRecord = [SELECT Id, Matter_Deal__c FROM Agreement__c WHERE Id = :triggerRecord.Agreement__c];
        
        //Call class with method to get list of Participants
        if(agreementRecord.size() > 0)
        {
            participantsWrapper = sObject_Scheduling_Occurences.getParticipantsList(agreementRecord[0].Matter_Deal__c);
        }
        
        //Call class with method to get list of Groups
        distroGroupsWrapper = sObject_Scheduling_Occurences.getDistributionGroupList();   
    }
    
    public void populateLookups()
    {
        if(triggerRecord.Agreement__c != null)
        {
            //Query the parents.
            Agreement__c agreement = [
                SELECT 
                Id, 
                Matter_Deal__r.Id 
                FROM Agreement__c
                WHERE
                Id = :triggerRecord.Agreement__c
            ];
            
            //Set values
            triggerRecord.Deal__c = agreement.Matter_Deal__r.Id ;
        }
    }
    
    public PageReference saveRecord()
    {
        try
        {
            Trigger__c newTriggerRecord = new Trigger__c();
            newTriggerRecord = (Trigger__c)sObject_Scheduling_Occurences.insertSObject(triggerRecord);

            if(triggerRecord.id != null)
            {
                //Insert Noticifaction Participants 
                sObject_Scheduling_Occurences.insertNotificationParticipants(participantsWrapper, triggerRecord.id , 'Trigger');
                
                //Insert Noticifaction Groups 
                sObject_Scheduling_Occurences.insertNotificationGroups(distroGroupsWrapper, triggerRecord.id , 'Trigger');
            }
        }
        catch(Exception e)
        {
        	ApexPages.addMessages(e);
            return null;
        }
        
        //New Page Setup
        PageReference standardPage = new PageReference('/'+triggerRecord.Id); 
        standardPage.setRedirect(true);
        
        //Redirect.
        return standardPage;
    }    
    
    public void DealParticipants()
    {
        //Get all Notification Participants related to the Deal selected on the VF Page
        //Call method upon fields change on VF Page
        if(triggerRecord.Deal__c != null)
        {
            participantsWrapper = new List<sObject_Scheduling_Occurences.ParticipantWrapper>();
            participantsWrapper = sObject_Scheduling_Occurences.getParticipantsList(triggerRecord.Deal__c);
        }
    }

}