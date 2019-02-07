/**
*** CHANGE LOG ***

04/10/2017 - PG    - Created Class.
16/11/2017 - TdB   - Populate lookup fields based on parent records
				   - Call methods to insert Margin Ratchet, Notification Participants and Notification Groups (Used Wrappers)

**/ 
public with sharing class Margin_Ratchet_Override 
{
    private static final Map <String, Schema.RecordTypeInfo> recordTypes = Margin_Ratchet__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    private static final String objectPrefix = Margin_Ratchet__c.sObjectType.getDescribe().getKeyPrefix();
    public Margin_Ratchet__c objectRecord { get; set; }
    public sObject_Scheduling_Occurences sObjectSchedulingOccurencesClass = new sObject_Scheduling_Occurences();
    public List<sObject_Scheduling_Occurences.ParticipantWrapper> participantsWrapper { get; set; }
    public List<sObject_Scheduling_Occurences.DistroGroupWrapper> distroGroupsWrapper { get; set; }
    public List<sObject_Scheduling_Occurences.FinancialCovenantsWrapper> financialCovenantsWrapper { get; set; }
    public List<sObject_Scheduling_Occurences.RelationshipPartiesWrapper> relationshipPartiesWrapper { get; set; }
    
    //Constructor
    public Margin_Ratchet_Override(ApexPages.StandardController stdController) 
    {
        //Empty wrappers
        participantsWrapper = new List<sObject_Scheduling_Occurences.ParticipantWrapper>();
        distroGroupsWrapper = new List<sObject_Scheduling_Occurences.DistroGroupWrapper>();
        financialCovenantsWrapper = new List<sObject_Scheduling_Occurences.FinancialCovenantsWrapper>();
        relationshipPartiesWrapper = new List<sObject_Scheduling_Occurences.RelationshipPartiesWrapper> ();
        
        List<Agreement__c> agreementRecord = new List<Agreement__c>();
        
        //List for additional field on record
        List<String> fields = new List<String>{
            'Agreement__c', 
                'Agreement__r.Matter_Deal__c',     
                'Facility__c',
                'Facility_Tranche__c'
                };
                    
         //Query fields.
         if(!Test.isRunningTest())
         {
         	stdController.addFields(fields); 
         }
        
        //Fetch object record.
        this.objectRecord = (Margin_Ratchet__c)stdController.getRecord();
                
        //New record.
        if(objectRecord.Id == null)
        {
            //Populate all lookups.
            populateLookups();
        }
        
        //Get Matter/Deal Id
        agreementRecord = [SELECT Id, Matter_Deal__c FROM Agreement__c WHERE Id = :objectRecord.Agreement__c];
        
        //Call class with method to get list of Participants
        if(agreementRecord.size() > 0)
        {
            participantsWrapper = sObject_Scheduling_Occurences.getParticipantsList(agreementRecord[0].Matter_Deal__c);
        }
        
        //Call class with method to get list of Groups
        distroGroupsWrapper = sObject_Scheduling_Occurences.getDistributionGroupList();
        financialCovenantsWrapper = sObject_Scheduling_Occurences.getFinancialCovenants(objectRecord.Agreement__c);
    }

    public PageReference actionRouteEdit()
    {
        System.debug('### Margin_Ratchet_Override : actionRouteEdit');
        
        //Stay put if this is a Covenant.
        if(objectRecord.RecordTypeId == recordTypes.get('Covenant').getRecordTypeId())
        {
            return null;
        }
        else
        {
            //Get current page parameters
            Map<String, String> currentParams = ApexPages.CurrentPage().getParameters();
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+objectPrefix+'/e?'); 
            standardPage.setRedirect(true);
            
            //Add passed params.
            standardPage.getParameters().putAll(currentParams);
            
            //Remove some unwanted params.
            standardPage.getParameters().remove('save_new');
            standardPage.getParameters().remove('save');
            
            //Prevent infinite loop. Force override.
            standardPage.getParameters().put('nooverride','1'); 
            
            //Redirect.
            return standardPage;
        }
    }
    
    public void populateLookups()
    {
        //Facility Tranche
        if(objectRecord.Facility_Tranche__c != null)
        {
            //Query the parents.
            Facility_Tranche__c facilityTranche = [
                SELECT 
                Id, 
                Facility__r.Id,
                Facility__r.Agreement__r.Id ,
                Facility__r.Agreement__r.Matter_Deal__r.Id 
                FROM Facility_Tranche__c
                WHERE
                Id = :objectRecord.Facility_Tranche__c
            ];
            
            //Set values
            objectRecord.Facility__c = facilityTranche.Facility__r.Id;
            objectRecord.Agreement__c = facilityTranche.Facility__r.Agreement__r.Id;
            objectRecord.Matter_Deal__c = facilityTranche.Facility__r.Agreement__r.Matter_Deal__r.Id ;
            relationshipPartiesWrapper = sObject_Scheduling_Occurences.getRelationshipPartiesList(objectRecord.Facility_Tranche__c, 'Tranche');
        }
        
        //Facility
        else if(objectRecord.Facility__c != null)
        {
            //Query the parents.
            Facility__c facility = [
                SELECT 
                Id, 
                Agreement__r.Id,
                Agreement__r.Matter_Deal__r.Id 
                FROM Facility__c
                WHERE
                Id = :objectRecord.Facility__c
            ];
            
            //Set values
            objectRecord.Agreement__c = facility.Agreement__r.Id; 
            objectRecord.Matter_Deal__c = facility.Agreement__r.Matter_Deal__r.Id ;
            relationshipPartiesWrapper = sObject_Scheduling_Occurences.getRelationshipPartiesList(objectRecord.Facility__c, 'Facility');
        }
        else if(objectRecord.Agreement__c != null)
        {
            
            //Query the parents.
            Agreement__c agreement = [
                SELECT 
                Id, 
                Matter_Deal__r.Id 
                FROM Agreement__c
                WHERE
                Id = :objectRecord.Agreement__c
            ];
            
            //Set values
            objectRecord.Matter_Deal__c = agreement.Matter_Deal__r.Id ;
            relationshipPartiesWrapper = sObject_Scheduling_Occurences.getRelationshipPartiesList(objectRecord.Agreement__c, 'Agreement');
        }
    }
    
    public PageReference saveRecord()
    {
        try
        {
            //Insert Margin Ratchet
            Margin_Ratchet__c newMarginRatchetRecord = new Margin_Ratchet__c();
            newMarginRatchetRecord = (Margin_Ratchet__c)sObject_Scheduling_Occurences.insertSObject(objectRecord);
            
            if(objectRecord.id != null)
            {
                //Insert Noticifaction Participants 
                sObject_Scheduling_Occurences.insertNotificationParticipants(participantsWrapper, objectRecord.id , 'Margin Ratchet');
                
                //Insert Noticifaction Groups 
                sObject_Scheduling_Occurences.insertNotificationGroups(distroGroupsWrapper, objectRecord.id , 'Margin Ratchet');
                
                //Insert Financial Covenants
                sObject_Scheduling_Occurences.insertMarginRatchetConditions(financialCovenantsWrapper,objectRecord.id);
                
                //Insert Financial Covenants
                sObject_Scheduling_Occurences.insertRelationshipParties(relationshipPartiesWrapper,objectRecord.id);
            }
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessages(e);
            
            return null;
        }
        
        //New Page Setup
        PageReference standardPage = new PageReference('/'+objectRecord.Id); 
        standardPage.setRedirect(true);
        
        //Redirect.
        return standardPage; 
    }
}