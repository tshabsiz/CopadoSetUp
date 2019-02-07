/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Margin_Ratchet_Override_Test {
    
    public static testMethod void testAgreementLevel()
	{
         Date todaysDate = System.today();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		//VF page
        PageReference pageRef = Page.Margin_Ratchet_Override;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.testEventMarginRatchet);
		Margin_Ratchet_Override ec = new Margin_Ratchet_Override(sc);
        
        test.startTest();

		ec.participantsWrapper[0].selected = true;
		ec.distroGroupsWrapper[0].selected = true; 

		//Methods
        ec.actionRouteEdit();
        ec.populateLookups();
        ec.saveRecord();
        
        testDataClass.testEventMarginRatchet.Due_Date__c = todaysDate.addDays(-60);
        
        ec.saveRecord();
        
        test.stopTest();

    }
    
     public static testMethod void testFacilityLevel()
	{
        Date todaysDate = System.today();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        Margin_Ratchet__c testCovenantMarginRatchet_Facility = new Margin_Ratchet__c 
        (
            Name = 'Test Facility Tranche',
            Type__c = 'Covenant',
            Agreement__c = testDataClass.TestAgreement.id,
            Matter_Deal__c = testDataClass.TestMatter.id,
            facility__c = testDataClass.TestFacility.id
        );
        insert testCovenantMarginRatchet_Facility;

        //VF page
        PageReference pageRef = Page.Margin_Ratchet_Override;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(testCovenantMarginRatchet_Facility);
		Margin_Ratchet_Override ec = new Margin_Ratchet_Override(sc);
        
        test.startTest();

		//Methods
        ec.actionRouteEdit();
        ec.populateLookups();
        ec.saveRecord();  
        
        testDataClass.testEventMarginRatchet.Other_Relative_Date__c = todaysDate.addDays(-60);
        testDataClass.testEventMarginRatchet.frequency__c = 'Once Off';
        
        ec.saveRecord();  
        
        test.stopTest();

    }
    
     public static testMethod void testFacilityTrancheLevel()
	{
        Date todaysDate = System.today();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        Margin_Ratchet__c testCovenantMarginRatchet_FacilityTranche = new Margin_Ratchet__c 
        (
            Name = 'Test Facility Tranche',
            Type__c = 'Covenant',
            //Agreement__c = testDataClass.TestAgreement.id,
            Matter_Deal__c = testDataClass.TestMatter.id,
            facility_tranche__c = testDataClass.TestFacilityTranche.id,
            frequency__c = 'Once Off',
            Due_Date__c = todaysDate.addDays(-10)
        );
        insert testCovenantMarginRatchet_FacilityTranche;
        
        //VF page
        PageReference pageRef = Page.Margin_Ratchet_Override;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(testCovenantMarginRatchet_FacilityTranche);
		Margin_Ratchet_Override ec = new Margin_Ratchet_Override(sc);
        
        test.startTest();
        
		//Methods
        ec.actionRouteEdit();
        ec.populateLookups();
        ec.saveRecord();     
        
        testDataClass.testEventMarginRatchet.Relative_Date__c = 'Effective Date';
        testDataClass.testEventMarginRatchet.frequency__c = 'Monthly';
        
        
        ec.saveRecord(); 
        
        test.stopTest();
    }

}