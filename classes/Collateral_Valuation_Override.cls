/**
*** CHANGE LOG ***

20/11/2017 - TdB   - Created Class.
				   - Call methods to insert Collateral Valuation record, Notification Participants and Groups (Wrappers)
				   - DealParticipants() - Get Notification Participants based on Deal selected

**/ 
public with sharing class Collateral_Valuation_Override {
    
    public Collateral_Valuation__c collateralValuationRecord { get; set; }
    public sObject_Scheduling_Occurences sObjectSchedulingOccurencesClass = new sObject_Scheduling_Occurences();
    public List<sObject_Scheduling_Occurences.ParticipantWrapper> participantsWrapper { get; set; }
    public List<sObject_Scheduling_Occurences.DistroGroupWrapper> distroGroupsWrapper { get; set; }
    
    //Constructor
    public Collateral_Valuation_Override(ApexPages.StandardController stdController) 
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
        this.collateralValuationRecord = (Collateral_Valuation__c)stdController.getRecord();

        //Get Matter/Deal Id
        agreementRecord = [SELECT Id, Matter_Deal__c FROM Agreement__c WHERE Id = :collateralValuationRecord.Agreement__c];
        
        //Call class with method to get list of Participants
        if(agreementRecord.size() > 0)
        {
            participantsWrapper = sObject_Scheduling_Occurences.getParticipantsList(agreementRecord[0].Matter_Deal__c);
        }
        
        //Call class with method to get list of Groups
        distroGroupsWrapper = sObject_Scheduling_Occurences.getDistributionGroupList();   
    }
    
    public PageReference saveRecord()
    {
        try
        {
            Collateral_Valuation__c newCollateralValuationRecord = new Collateral_Valuation__c();
            newCollateralValuationRecord = (Collateral_Valuation__c)sObject_Scheduling_Occurences.insertSObject(collateralValuationRecord);

            if(collateralValuationRecord.id != null)
            {
                //Insert Noticifaction Participants 
                sObject_Scheduling_Occurences.insertNotificationParticipants(participantsWrapper, collateralValuationRecord.id , 'Collateral Valuation');
                
                //Insert Noticifaction Groups 
                sObject_Scheduling_Occurences.insertNotificationGroups(distroGroupsWrapper, collateralValuationRecord.id , 'Collateral Valuation');
            }
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessages(e);
            
            return null;
        }
        
        //New Page Setup
        PageReference standardPage = new PageReference('/'+collateralValuationRecord.Id); 
        standardPage.setRedirect(true);
        
        //Redirect.
        return standardPage;
    }
    
    public void DealParticipants()
    {
        //Get all Notification Participants related to the Deal selected on the VF Page
        //Call method upon fields change on VF Page
        if(collateralValuationRecord.Deal__c != null)
        {
            participantsWrapper = new List<sObject_Scheduling_Occurences.ParticipantWrapper>();
            participantsWrapper = sObject_Scheduling_Occurences.getParticipantsList(collateralValuationRecord.Deal__c);
        }
    }
}