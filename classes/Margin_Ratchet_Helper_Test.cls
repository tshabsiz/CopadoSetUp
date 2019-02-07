/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Margin_Ratchet_Helper_Test 
{
    public static testMethod void testAgreementLevel()
	{
        Date todaysDate = System.today();
        List<Margin_Ratchet__c> marginRatchetList = new List<Margin_Ratchet__c>();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        marginRatchetList.add(testDataClass.testEventMarginRatchet);
        
        test.startTest();
        
        testDataClass.testEventMarginRatchet.Frequency__c = 'Once Off';
        testDataClass.testEventMarginRatchet.Due_Date__c = todaysDate.addDays(100);
        
        update testDataClass.testEventMarginRatchet;
        
        testDataClass.testEventMarginRatchet.Frequency__c = 'Monthly';
        testDataClass.testEventMarginRatchet.Relative_Date__c = 'Other';
        testDataClass.testEventMarginRatchet.Number_Of_Days__c = 5;
        testDataClass.testEventMarginRatchet.Days__c = 'Days After';
        testDataClass.testEventMarginRatchet.Other_Relative_Date__c = todaysDate.addDays(50);
        testDataClass.testEventMarginRatchet.Due_Date__c = null;
        
        update testDataClass.testEventMarginRatchet;
        
        testDataClass.TestAgreement.Termination_Date__c = todaysDate.addYears(5) ;       
        update testDataClass.TestAgreement;
        
        Margin_Ratchet_Helper.insertWatcherOccurence(marginRatchetList);
        
        test.stopTest();
        
    }
    
     public static testMethod void testFacilityLevel()
	{
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
        
        test.stopTest();
    }

}