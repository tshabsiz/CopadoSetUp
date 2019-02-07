/**
*** CHANGE LOG ***

20/11/2017 - TdB   - Created Class.
01/08/2018 - TdB  - Remove commeneted code
**/ 

public with sharing class Collateral_Monitoring_Override {
    
    public Collateral_Monitoring__c collateralMonitoringRecord { get; set; }
    public sObject_Scheduling_Occurences sObjectSchedulingOccurencesClass = new sObject_Scheduling_Occurences();
    public List<sObject_Scheduling_Occurences.ParticipantWrapper> participantsWrapper { get; set; }
    public List<sObject_Scheduling_Occurences.DistroGroupWrapper> distroGroupsWrapper { get; set; }
    
    private String errorMessage {get ; set; }
     private ApexPages.StandardController sController;
    private Collateral__c collateral;
    
    public Collateral_Monitoring_Override(ApexPages.StandardController stdController) 
  {
        sController = stdController;
        //Empty wrappers
        participantsWrapper = new List<sObject_Scheduling_Occurences.ParticipantWrapper>();
        distroGroupsWrapper = new List<sObject_Scheduling_Occurences.DistroGroupWrapper>();
        
        
        List<Agreement__c> agreementRecord = new List<Agreement__c>();
        
    List<String> fields = new List<String>{
            'Id',
      'Name',
            'Deal__c',
            'Person_Responsible__c',
            'Agreement__c',
            'Description__c',
            'Collateral__c',
            'Collateral_Type__c',
            'Specify_Other__c',
            'Item_to_Monitor__c',
            'Account_Number__c',
            'Account_Type__c',
            'Frequency__c',
            'Due_Date__c',
            'Relative_Date__c',
            'Other_Relative_Date__c',
            'Number_of_Days__c',
            'Days__c',
            'Agreement__c', 
            'Agreement__r.Matter_Deal__c',
            'Effective_Date__c',
            'Schedule_Start_Date__c',
            'Signature_Date__c',
            'Schedule_End_Date__c',
            'Financial_Year_End__c',
            'CreatedById',
            'LastModifiedById',
            'CreatedDate',
            'LastModifiedDate'
    };

    //Query fields.
    if(!Test.isRunningTest())
    {
      stdController.addFields(fields); 
    }

        
    //Fetch object record.
    this.collateralMonitoringRecord = (Collateral_Monitoring__c)stdController.getRecord();
        collateral = AcmMitigantCRUDService.getCollateralFromId(collateralMonitoringRecord.Collateral__c);
        
        //Get Matter/Deal Id
        agreementRecord = [SELECT Id, Matter_Deal__c FROM Agreement__c WHERE Id = :collateralMonitoringRecord.Agreement__c];
        
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
            Collateral_Monitoring__c newcollateralMonitoringRecord = new Collateral_Monitoring__c();
            newcollateralMonitoringRecord = (Collateral_Monitoring__c)sObject_Scheduling_Occurences.insertSObject(collateralMonitoringRecord);
            System.debug('###newcollateralMonitoringRecord : ' +  newcollateralMonitoringRecord);
            
            if(collateralMonitoringRecord.id != null)
            {
                //Insert Noticifaction Participants 
                sObject_Scheduling_Occurences.insertNotificationParticipants(participantsWrapper, collateralMonitoringRecord.id , 'Collateral Monitoring');
                
                //Insert Noticifaction Groups 
                sObject_Scheduling_Occurences.insertNotificationGroups(distroGroupsWrapper, collateralMonitoringRecord.id , 'Collateral Monitoring');
            }
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessages(e);
            
            return null;
        }
        
        //New Page Setup
        PageReference standardPage = new PageReference('/'+collateralMonitoringRecord.Id); 
        standardPage.setRedirect(true);
        
        //Redirect.
        return null;
    }
    
     public void DealParticipants()
    {
        System.debug('##### collateralMonitoringRecord.Deal__c : ' + collateralMonitoringRecord.Deal__c);
        
        if(collateralMonitoringRecord.Deal__c != null)
        {
             participantsWrapper = new List<sObject_Scheduling_Occurences.ParticipantWrapper>();
             participantsWrapper = sObject_Scheduling_Occurences.getParticipantsList(collateralMonitoringRecord.Deal__c);
        }
    }
    public PageReference CallWebService() {
        PageReference redirectSuccess = null;
        System.debug('Web service Call' +errorMessage);
        PageReferenceMessage pageReferenceMessage = new PageReferenceMessage();
        if(String.isBlank(errorMessage)) {
            System.debug('Save to ACM');
            pageReferenceMessage = AcmControllerLogic.saveToACM(sController, collateral, false, errorMessage);
            if(pageReferenceMessage.message == 'Mitigant successfully created/update') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else if(pageReferenceMessage.message == 'Not Saving to ACM') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else {
                System.debug('My messages are here : ' + pageReferenceMessage.message);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageReferenceMessage.message));
                return null; 
            }
        }
        redirectSuccess = new ApexPages.StandardController(sController.getRecord()).view();
        return redirectSuccess; 
    }
    public PageReference createBoxPermission()
    {
        System.debug('### Collateral_Monitoring_Override : createBoxPermission : ' + collateralMonitoringRecord.Id);
        BxdCollateralMonitoringService.createBoxPermission(collateralMonitoringRecord.Id);
        return null;
    }

}