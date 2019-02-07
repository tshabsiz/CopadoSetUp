@isTest 
public class Drawdown_Override_Test {
    
    public static Map <String, Schema.RecordTypeInfo> mapDrawdownRecordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName();
  
    public static testMethod void testController_insertDrawDown() 
    {   
        Set<Id> drawdownId = new Set<Id>();
        //Setup data data
       // BXDtesclassdata.setupFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        drawdownId.add(testDataClass.TestDrawdown.Id);
        //testDataClass.TestDrawdown.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown').getRecordTypeId();

        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdown);
        Drawdown_Override ec = new Drawdown_Override(sc);
        ec.drawdownObject = testDataClass.TestDrawdown; 
        Drawdown_Override.approvalStatuses(drawdownId);
        
        Test.startTest();
        
        testDataClass.TestDrawdown.Facility_Tranche__c = testDataClass.TestFacilityTranche.id;
        testDataClass.TestDrawdown.Facility__c = testDataClass.TestFacility.id;
        
        try {
        testDataClass.TestDrawdown.Facility_Tranche__c = testDataClass.TestFacilityTranche.id;
        testDataClass.TestDrawdown.Facility__c = testDataClass.TestFacility.id;
        testDataClass.TestDrawdown.Facility_Limit__c = 50;
        update testDataClass.TestDrawdown;
        
         } catch(Exception error) {

    }
        
         ec.saveRecord();

        Test.stopTest();
    }
     
    public static testMethod void test_DrawDown() 
    {   
        //Setup data data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

        Test.startTest(); 

        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('clone', '1');

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);

        //Select notficiaiton groups and paritcipants.
        ec.participantsWrapper[0].selected = true;
        ec.distroGroupsWrapper[0].selected = true;
        
        ec.actionUpdateLenders();
        ec.actionUpdateLenderParties();
        ec.actionUpdateBankDetails();

        //Main method
        ec.exceedingLimit = True;
        ec.saveRecord();  

        Test.stopTest();
    }
    
     public static testMethod void test_DrawDownAgency() 
    {   
        //Setup data data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        testDataClass.TestDrawdown.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown - Agency').getRecordTypeId();
        update testDataClass.TestDrawdown;

        Test.startTest(); 

        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdown);
        Drawdown_Override ec = new Drawdown_Override(sc);
        ec.drawdownObject = testDataClass.TestDrawdown;
        
        ec.actionUpdateLenders();
        ec.actionChangeLenderPortions();
        ec.actionUpdateLenderParties();
        ec.actionUpdateBankDetails();

        //Main method
        ec.saveAndSubmitRecord();
        ec.saveRecord();  

        Test.stopTest();
    }
    
    public static testMethod void test_DrawDown_Agreement() 
    {   
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        testDataClass.TestDrawdownNotInserted.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown').getRecordTypeId();
        delete testDataClass.TestFacility;
        delete testDataClass.TestDrawdown;
        
         testDataClass.TestDrawdownNotInserted.Facility_Limit__c = null;
        testDataClass.TestDrawdownNotInserted.Facility__c = null;
        testDataClass.TestDrawdownNotInserted.Facility_Tranche__c = null;
        testDataClass.TestAgreement.limit__c = 2000;
        testDataClass.TestDrawdownNotInserted.Agreement__c = testDataClass.TestAgreement.id;
        //update testDataClass.TestAgreement;
        
        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);
        
        ec.exceedingLimit = True;
        Test.startTest(); 
        
        //Select notficiaiton groups and paritcipants.
        ec.participantsWrapper[0].selected = true;
        ec.distroGroupsWrapper[0].selected = true;
		
        ec.drawDownLimitCheck();
        ec.saveRecord();
        
        testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 0;
        
        //upsert testDataClass.TestDrawdownNotInserted;
        
        sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        
         try {
            testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 99999;
            update testDataClass.TestDrawdownNotInserted;
            
        } catch(Exception error) {
            
        }
        
        ec.actionUpdateLenders();
        ec.saveRecord();
        
        Test.stopTest();
    }   
    public static testMethod void test_DrawDown_Facility() 
    {   
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        testDataClass.TestDrawdownNotInserted.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown').getRecordTypeId();
        delete testDataClass.TestFacilityTranche;
        
        testDataClass.TestDrawdownNotInserted.Facility__c = testDataClass.TestFacility.id;

        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);
        
        
        
        //Select notficiaiton groups and paritcipants.
        ec.participantsWrapper[0].selected = true;
        ec.distroGroupsWrapper[0].selected = true;
		ec.exceedingLimit = True;
        
        //ec.actionUpdateLenders();
        //ec.saveRecord();
        
        testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 50;

        //sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        
        try {
            //testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 10;
            //update testDataClass.TestDrawdownNotInserted;
            
        } catch(Exception error) {
            
       }
        Test.startTest(); 
        
        //ec.actionUpdateLenders();
        //ec.saveRecord();
        
        Test.stopTest();
    }   
    
    public static testMethod void test_DrawDown_Tranche() 
    {   
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
         testDataClass.TestDrawdownNotInserted.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown').getRecordTypeId();
        testDataClass.TestDrawdownNotInserted.Facility__c = testDataClass.TestFacility.id;
        testDataClass.TestDrawdownNotInserted.Facility_Tranche__c = testDataClass.TestFacilityTranche.id;
        
        
        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);
        
        Test.startTest(); 
        
        //Select notficiaiton groups and paritcipants.
        ec.participantsWrapper[0].selected = true;
        ec.distroGroupsWrapper[0].selected = true;
		ec.exceedingLimit = True;
        ec.drawDownLimitCheck();
        ec.saveRecord();
        
        testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 50;
        
        sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        
        try {
            testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 10;
            update testDataClass.TestDrawdownNotInserted;
            
        } catch(Exception error) {
            //System.assert(error.getMessage().contains('The Total Drawdown Limit cannot exceed the Agreement Limit'));
        }
        
        ec.actionUpdateLenders();
        ec.saveRecord();
        
        Test.stopTest();
    }   
    
     public static testMethod void test_DrawDownAgency_Agreement() 
    {   
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        testDataClass.TestDrawdownNotInserted.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown - Agency').getRecordTypeId();
        delete testDataClass.TestFacility;
        delete testDataClass.TestDrawdown;
        
         testDataClass.TestDrawdownNotInserted.Facility_Limit__c = null;
        testDataClass.TestDrawdownNotInserted.Facility__c = null;
        testDataClass.TestDrawdownNotInserted.Facility_Tranche__c = null;
        testDataClass.TestAgreement.limit__c = 2000;
        testDataClass.TestDrawdownNotInserted.Agreement__c = testDataClass.TestAgreement.id;
        //update testDataClass.TestAgreement;
        
        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);
        
        Test.startTest(); 
		
        ec.actionUpdateLenders();
        //ec.saveAndSubmitRecord();
        ec.saveRecord();
        
        testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 0;
        
        //upsert testDataClass.TestDrawdownNotInserted;
        
        sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        
         try {
            testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 99999;
            update testDataClass.TestDrawdownNotInserted;
            
        } catch(Exception error) {
            
        }
        
        //ec.actionUpdateLenders();
        //ec.saveRecord();
        
        Test.stopTest();
    }   
    public static testMethod void test_DrawDownAgency_Facility() 
    {   
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        testDataClass.TestDrawdownNotInserted.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown - Agency').getRecordTypeId();
        delete testDataClass.TestFacilityTranche;
        
        testDataClass.TestDrawdownNotInserted.Facility__c = testDataClass.TestFacility.id;

        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);
        
        Test.startTest(); 
		
        ec.saveAndSubmitRecord();
        ec.saveRecord();
        
        testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 50;

        sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        
        try {
            testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 10;
            update testDataClass.TestDrawdownNotInserted;
            
        } catch(Exception error) {
            
       }
        
        ec.actionUpdateLenders();
        ec.saveRecord();
        
        Test.stopTest();
    }   
    
    public static testMethod void test_DrawDownAgency_Tranche() 
    {   
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
         testDataClass.TestDrawdownNotInserted.RecordTypeId = mapDrawdownRecordTypes.get('Drawdown - Agency').getRecordTypeId();
        testDataClass.TestDrawdownNotInserted.Facility__c = testDataClass.TestFacility.id;
        testDataClass.TestDrawdownNotInserted.Facility_Tranche__c = testDataClass.TestFacilityTranche.id;

        //VF page
        PageReference pageRef = Page.Drawdown_Override;
        Test.setCurrentPage(pageRef);

        //Standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        Drawdown_Override ec = new Drawdown_Override(sc);
        
        Test.startTest(); 
        ec.actionChangeLenderPortions();
		ec.saveAndSubmitRecord();
        ec.saveRecord();
        
        testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 50;
        
        sc = new ApexPages.StandardController(testDataClass.TestDrawdownNotInserted);
        
        try {
            testDataClass.TestDrawdownNotInserted.Facility_Limit__c = 10;
            update testDataClass.TestDrawdownNotInserted;
            
        } catch(Exception error) {
            //System.assert(error.getMessage().contains('The Total Drawdown Limit cannot exceed the Agreement Limit'));
        }
        
        ec.actionUpdateLenders();
        ec.saveRecord();
        
        Test.stopTest();
    }   
}