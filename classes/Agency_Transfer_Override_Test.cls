/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 31/10/2017 - PG    - Created Class. 

**/ 
@isTest
public class Agency_Transfer_Override_Test
{
    @isTest
	public static void testOverride()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();

		//Add 2 Lenders
		testData.TestDealParty.Party_Type__c = 'Lender';
		update testData.TestDealParty;

		//testData.TestDealParty2.Party_Type__c = 'Lender';  
		//update testData.TestDealParty2; 

		testData.TestAgreementParty.Lender_Amount__c = 500;
		update testData.TestAgreementParty;

		testData.TestAgreementParty2.Lender_Amount__c = 400;
		//update testData.TestAgreementParty2;

		Test.startTest();

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestAgencyTransfer);
		Agency_Transfer_Override ec = new Agency_Transfer_Override(sc);

		//Methods
		ec.getTransferorOptions();  
		ec.getTransfereeOptions();  

		//Select Parties
		ec.selectedTransferor = testData.TestAgreementParty.Id;
		ec.selectedTransferee = testData.TestAgreementParty2.Id;

		ec.getDisabled();
		ec.actionUpdateTransferDetails();
		ec.actionUpdateTransferee();

		//Set Amount
		ec.transferAmount = 100;

		//Select Parties
		ec.selectedTransferor = testData.TestAgreementParty.Id;
		ec.selectedTransferee = testData.TestAgreementParty2.Id;

		ec.updateTransferDetails();

		System.debug(ec.transferDetails);

		ec.actionSave();

		Test.stopTest();
	}
    
    @isTest
    public static void testOverride_FacilityTrancheLevel()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();
        
        Facility__c TestFacility2 = new Facility__c 
        (
            Name = 'Test Agreement Facility',
            Facility_Type__C = 'Term Loan',
            Facility_Limit__c = 50,
            Agreement__c = testData.TestAgreement.Id,
            Availability_Start_Date__c = System.today(),
            Expiry_Date__c = System.today()
            
        );
       // insert TestFacility2;
        
        Facility_Party__c TestFacilityParty2 = new Facility_Party__c
        (
            Facility__c = TestFacility2.id,
            Agreement_Party__c  = testData.TestAgreementParty2.id,
            Facility_Amount__c = null               
        );
        //insert TestFacilityParty2;
        
        Facility_Party__c TestFacilityParty3 = new Facility_Party__c
        (
            Facility__c = TestFacility2.id,
            Agreement_Party__c  = testData.TestAgreementParty3.id,
            Facility_Amount__c = null               
        );
        //insert TestFacilityParty3;
        
        Facility_Tranche__c TestFacilityTranche2 = new Facility_Tranche__c 
        (
            Name = 'Test Facility Tranche',
            Tranche_Type__C = 'Term Loan',
            Tranche_Limit__C = 50,
            Facility__c = TestFacility2.Id
        );
        //insert TestFacilityTranche2;
        
        
         Tranche_Party__c TestTrancheParty2 = new Tranche_Party__c
        (
            Facility_Tranche__c = TestFacilityTranche2.id,
            Facility_Party__c  = TestFacilityParty2.id,
            Facility_Amount__c = 5                   
        );
       // insert TestTrancheParty2;
        
         Tranche_Party__c TestTrancheParty3 = new Tranche_Party__c
        (
            Facility_Tranche__c = TestFacilityTranche2.id,
            Facility_Party__c  = TestFacilityParty3.id,
            Facility_Amount__c = 5                   
        );
       //insert TestTrancheParty3;
        
        Agency_Transfer__c TestAgencyTransfer_TrancheLevel = new Agency_Transfer__c
        (
            Agreement__c = testData.TestAgreement.Id,
            Facility__c = TestFacility2.Id,
            Facility_Tranche__c = TestFacilityTranche2.Id,
            Transfer_Amount__c = 2,
            Transfer_Fee__c = true,
            Transferor_Tranche__c = TestTrancheParty2.id,
            Transferee_Tranche__c = TestTrancheParty3.id
        );
        insert TestAgencyTransfer_TrancheLevel;
        
        Agency_Transfer_Detail__c	testAgencyTranserDetals = new Agency_Transfer_Detail__c	
            (
                Agency_Transfer__c = TestAgencyTransfer_TrancheLevel.id
            );
        insert testAgencyTranserDetals;

		Test.startTest();

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(TestAgencyTransfer_TrancheLevel); 
		Agency_Transfer_Override ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = TestTrancheParty3.id;
        ec.selectedTransferor = TestTrancheParty2.id;
        ec.transferDetails.add(TestAgencyTranserDetals);
        ec.transferAmount = 2;

		//Methods
		ec.getTransferorOptions();  
		ec.getTransfereeOptions();  
        
        ec.updateTransferDetails();

		ec.getDisabled();
		ec.actionUpdateTransferDetails();
		ec.actionUpdateTransferee();

		//Set Amount
		ec.transferAmount = 100;

		//Select Parties
		ec.selectedTransferee = TestTrancheParty3.id;

		ec.updateTransferDetails();

		System.debug(ec.transferDetails);
        
        ec.selectedTransferee = TestTrancheParty3.id;
        ec.selectedTransferor = TestTrancheParty2.id;

		ec.actionSave();
        
        ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = TestTrancheParty3.id;
        ec.selectedTransferor = TestTrancheParty2.id;
        ec.transferAmount = 999999999;
        ec.actionSave();

		Test.stopTest();
	}
    
     @isTest
    public static void testOverride_FacilityLevel()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();
        delete testData.TestFacilityTranche;
		testData.TestAgencyTransfer.Facility__c = testData.testFacility.id;
        testData.TestAgencyTransfer.Facility_Tranche__c = null;
        testData.TestFacilityParty.Facility_Amount__c = 50;
        testData.TestFacilityParty2.Facility_Amount__c = 50;
        testData.TestAgreementParty2.Lender_Amount__c = 50;
        testData.TestAgreementParty3.Lender_Amount__c = 50;
        testData.TestAgreement.Limit__c = 100; 
        upsert testData.TestAgencyTransfer;
        List<Agreement_Party__c> agreementPartyUpdateList = new List<Agreement_Party__c>();
        agreementPartyUpdateList.add(testData.TestAgreementParty2);
        agreementPartyUpdateList.add(testData.TestAgreementParty3);
        upsert agreementPartyUpdateList;

		List<Facility_Party__c> facilityPartyUpdateList = new List<Facility_Party__c>();
        facilityPartyUpdateList.add(testData.TestFacilityParty);
        facilityPartyUpdateList.add(testData.TestFacilityParty2);
        upsert facilityPartyUpdateList;


		Test.startTest();

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestAgencyTransfer); 
		Agency_Transfer_Override ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = testData.TestFacilityParty.id;
        ec.selectedTransferor = testData.TestFacilityParty2.id;
        ec.transferAmount = 2;

		//Methods
		ec.getTransferorOptions();  
		ec.getTransfereeOptions();  
        
        ec.updateTransferDetails();

		ec.getDisabled();
		ec.actionUpdateTransferDetails();
		ec.actionUpdateTransferee();

		//Set Amount
		ec.transferAmount = 100;

		//Select Parties
		ec.selectedTransferee = testData.TestFacilityParty.id;

		ec.updateTransferDetails();

		System.debug(ec.transferDetails);
        
         ec.selectedTransferee = testData.TestFacilityParty.id;
        ec.selectedTransferor = testData.TestFacilityParty2.id;

		ec.actionSave();
        
        ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = testData.TestFacilityParty.id;
        ec.selectedTransferor = testData.TestFacilityParty2.id;
        ec.transferAmount = 999999999;
        ec.actionSave();

		Test.stopTest();
	}
    
    @isTest
    public static void testOverride_FacilityTranche2Level()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();Test.startTest();
		testData.TestAgencyTransfer.Facility__c = testData.testFacility.id;
        testData.TestAgencyTransfer.Facility_Tranche__c = testData.TestFacilityTranche.id;
        testData.TestFacilityParty.Facility_Amount__c = 50;
        testData.TestFacilityParty2.Facility_Amount__c = 50;
        testData.TestAgreementParty2.Lender_Amount__c = 50;
        testData.TestAgreementParty3.Lender_Amount__c = 50;
        testData.TestTrancheParty.Facility_Amount__c = 50;
        testData.TestTrancheParty2.Facility_Amount__c = 50;
        testData.TestAgreement.Limit__c = 100; 
		upsert testData.TestAgencyTransfer;
        List<Agreement_Party__c> agreementPartyUpdateList = new List<Agreement_Party__c>();
        agreementPartyUpdateList.add(testData.TestAgreementParty2);
        agreementPartyUpdateList.add(testData.TestAgreementParty3);
        upsert agreementPartyUpdateList;

		List<Facility_Party__c> facilityPartyUpdateList = new List<Facility_Party__c>();
        facilityPartyUpdateList.add(testData.TestFacilityParty);
        facilityPartyUpdateList.add(testData.TestFacilityParty2);
        upsert facilityPartyUpdateList;
        
        List<Tranche_Party__c> tranchePartyUpdateList = new List<Tranche_Party__c>();
        tranchePartyUpdateList.add(testData.TestTrancheParty);
        tranchePartyUpdateList.add(testData.TestTrancheParty2);
        upsert tranchePartyUpdateList;

		

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestAgencyTransfer); 
		Agency_Transfer_Override ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = testData.TestTrancheParty.id;
        ec.selectedTransferor = testData.TestTrancheParty2.id;
        ec.transferAmount = 2;

		//Methods
		ec.getTransferorOptions();  
		ec.getTransfereeOptions();  
        
        ec.updateTransferDetails();

		ec.getDisabled();
		ec.actionUpdateTransferDetails();
		ec.actionUpdateTransferee();

		//Set Amount
		ec.transferAmount = 100;

		//Select Parties
		ec.selectedTransferee = testData.TestTrancheParty.id;

		ec.updateTransferDetails();

		System.debug(ec.transferDetails);
        
         ec.selectedTransferee = testData.TestTrancheParty.id;
        ec.selectedTransferor = testData.TestTrancheParty2.id;

		ec.actionSave();
        
        ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = testData.TestTrancheParty.id;
        ec.selectedTransferor = testData.TestTrancheParty2.id;
        ec.transferAmount = 999999999;
        ec.actionSave();

		Test.stopTest();
	}
    
     @isTest
    public static void testOverride_AgreementLevel()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();
        delete testData.TestFacility;
		testData.TestAgencyTransfer.Facility__c = null;
        testData.TestAgencyTransfer.Facility_Tranche__c = null;
        testData.TestAgreementParty3.Lender_Amount__c = 50;
        testData.TestAgreementParty2.Lender_Amount__c = 50;
        testData.TestAgreement.Limit__c = 100;
        //upsert testData.TestAgencyTransfer;
        upsert testData.TestAgreementParty3;
		upsert testData.TestAgreementParty2;
		Test.startTest(); 

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestAgencyTransfer); 
		Agency_Transfer_Override ec = new Agency_Transfer_Override(sc);
        ec.selectedTransferee = testData.TestAgreementParty3.Id;
        ec.selectedTransferor = testData.TestAgreementParty2.Id;
        ec.agencyTransfer = testData.TestAgencyTransfer;

		//Methods
		ec.getTransferorOptions();  
		ec.getTransfereeOptions();  
        
        //Select Parties
		ec.selectedTransferee = testData.TestAgreementParty3.Id;
        ec.selectedTransferor = testData.TestAgreementParty2.Id;
        
        ec.updateTransferDetails();
        
        ec.actionResetLenderParties();
        

		ec.getDisabled();
		ec.actionUpdateTransferDetails();
		ec.actionUpdateTransferee();

		//Set Amount
		 ec.transferAmount = 30;

		 //Select Parties
		ec.selectedTransferee = testData.TestAgreementParty3.Id;
        ec.selectedTransferor = testData.TestAgreementParty2.Id;
         ec.updateTransferDetails();

		ec.actionSave();

		Test.stopTest();
	}
}