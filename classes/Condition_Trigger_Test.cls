@isTest
/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***
17/07/2017 - PG    	- Created Class.
11/01/2018 - PG 	- Removed unneeded bxd setup folder method call. 
					- Move test data class before test.start so governor limits are reset.

**/ 
public class Condition_Trigger_Test {

	public static testMethod void testOnceOff()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//ONCE OFF - Activate
		testDataClass.testCondition.Active__c = true;
        testDataClass.testCondition.Recurrence__c = 'Once Off';
		testDataClass.testCondition.Due_Date__c = Date.today().addDays(3);
		update testDataClass.testCondition;

		//ONCE OFF - Reschedule
		testDataClass.testCondition.Recurrence__c = 'Once Off';
		testDataClass.testCondition.Due_Date__c = Date.today().addDays(3);
		update testDataClass.testCondition;		 

		Test.stopTest();
	}

	/**
	public static testMethod void testOnceRelativeDate()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();

		//ONCE OFF RELATIVE - SIGNATURE - Deactivate
		testDataClass.testCondition.Active__c = false;
		testDataClass.testCondition.Due_Date__c = null;
		testDataClass.testCondition.Recurrence__c = 'Once Off';
		testDataClass.testCondition.Date__c = 'Signature Date';
		testDataClass.testCondition.Number_Of_Days__c = 1;
		testDataClass.testCondition.Days__c = 'Days Before';
		update testDataClass.testCondition;

		//ONCE OFF RELATIVE - SIGNATURE - Activate
		testDataClass.testCondition.Active__c = true;
		update testDataClass.testCondition;

		//ONCE OFF RELATIVE SIGNATURE - Reschedule
		testDataClass.testCondition.Number_Of_Days__c = 2;
		update testDataClass.testCondition;

		Test.stopTest();
	}
	**/

	public static testMethod void testRelativeDate()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//RELATIVE DATE - SIGNATURE - Deactivate
		testDataClass.testCondition.Active__c = false;
		testDataClass.testCondition.Due_Date__c = null;
		testDataClass.testCondition.Recurrence__c = 'Monthly';
		testDataClass.testCondition.Date__c = 'Signature Date';
		testDataClass.testCondition.Number_Of_Days__c = 1;
		testDataClass.testCondition.Days__c = 'Days Before';
		update testDataClass.testCondition;

		//RELATIVE DATE - SIGNATURE - Activate
		testDataClass.testCondition.Active__c = true;
		update testDataClass.testCondition;

		//RELATIVE DATE - SIGNATURE - Reschedule
		testDataClass.testCondition.Number_Of_Days__c = 2;
		update testDataClass.testCondition; 				

		Test.stopTest();
	}

	/**
	public static testMethod void testOnceEffectConditions()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//ONCE OFF RELATIVE - EFFECTIVE - Deactivate
		testDataClass.testCondition.Active__c = false;
		testDataClass.testCondition.Due_Date__c = null;
		testDataClass.testCondition.Recurrence__c = 'Once Off';
		testDataClass.testCondition.Date__c = 'Effective Date';
		testDataClass.testCondition.Number_Of_Days__c = 1;
		testDataClass.testCondition.Days__c = 'Days Before';
		update testDataClass.testCondition;

		//ONCE OFF RELATIVE - EFFECTIVE - Activate
		testDataClass.testCondition.Active__c = true;
		update testDataClass.testCondition;

		//ONCE OFF RELATIVE - EFFECTIVE - Reschedule
		testDataClass.testCondition.Number_Of_Days__c = 2;
		update testDataClass.testCondition; 

		Test.stopTest();
	}


	public static testMethod void testOnceFYEConditions()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();

		//ONCE OFF RELATIVE - FYE - Deactivate
		testDataClass.testCondition.Active__c = false;
		testDataClass.testCondition.Due_Date__c = null;
		testDataClass.testCondition.Recurrence__c = 'Once Off';
		testDataClass.testCondition.Date__c = 'Financial Year End';
		testDataClass.testCondition.Number_Of_Days__c = 1;
		testDataClass.testCondition.Days__c = 'Days Before';
		update testDataClass.testCondition;

		//ONCE OFF RELATIVE - FYE - Activate
		testDataClass.testCondition.Active__c = true;
		update testDataClass.testCondition;

		//ONCE OFF RELATIVE FYE - Reschedule
		testDataClass.testCondition.Number_Of_Days__c = 2; 
		update testDataClass.testCondition;

		Test.stopTest();
	}
	**/

	public static testMethod void testEffectConditions()
	{
		//Test Data
		Cloudsmiths_TestDataClass testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//RELATIVE DATE - EFFECTIVE - Deactivate
		testDataClass.testCondition.Active__c = false;
		testDataClass.testCondition.Due_Date__c = null;
		testDataClass.testCondition.Recurrence__c = 'Monthly';
		testDataClass.testCondition.Date__c = 'Effective Date';
		testDataClass.testCondition.Number_Of_Days__c = 1;
		testDataClass.testCondition.Days__c = 'Days Before';
		update testDataClass.testCondition;

		//RELATIVE DATE - EFFECTIVE - Activate
		testDataClass.testCondition.Active__c = true;
		update testDataClass.testCondition;

		//RELATIVE DATE - EFFECTIVE - Reschedule
		testDataClass.testCondition.Number_Of_Days__c = 2;
		update testDataClass.testCondition; 

		Test.stopTest();
	}

	public static testMethod void testFYEConditions()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//RELATIVE DATE - FYE - Deactivate
		testDataClass.testCondition.Active__c = false;
		testDataClass.testCondition.Due_Date__c = null;
		testDataClass.testCondition.Recurrence__c = 'Monthly';
		testDataClass.testCondition.Date__c = 'Financial Year End';
		testDataClass.testCondition.Number_Of_Days__c = 1;
		testDataClass.testCondition.Days__c = 'Days Before';
		update testDataClass.testCondition;

		//RELATIVE DATE - FYE - Activate
		testDataClass.testCondition.Active__c = true;
		update testDataClass.testCondition;

		//RELATIVE DATE - FYE - Reschedule
		testDataClass.testCondition.Number_Of_Days__c = 2;
		update testDataClass.testCondition;

		Test.stopTest();
	}

	//Governance Check.
	public static testMethod void testGovernanceCheck()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//ONCE OFF - Activate
		testDataClass.testConditionGC.Active__c = true;
		update testDataClass.testConditionGC;

		//ONCE OFF - Reschedule
		testDataClass.testConditionGC.Due_Date__c = Date.today().addDays(3);
		update testDataClass.testConditionGC;

		Test.stopTest();
	}

	//Financial Covenant
	public static testMethod void testFinancialCovenant()
	{	
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Test.startTest();

		//RELATIVE DATE - EFFECTIVE - Deactivate
		testDataClass.testConditionFC.Active__c = false;
		testDataClass.testConditionFC.Due_Date__c = null;
		testDataClass.testConditionFC.Recurrence__c = 'Monthly';
		testDataClass.testConditionFC.Date__c = 'Effective Date';
		testDataClass.testConditionFC.Number_Of_Days__c = 1;
		testDataClass.testConditionFC.Days__c = 'Days Before';
		update testDataClass.testConditionFC;

		//RELATIVE DATE  - Activate
		testDataClass.testConditionFC.Active__c = true;
		update testDataClass.testConditionFC;

		//RELATIVE DATE - Change Required Base
		testDataClass.testConditionFC.Required_Base_Multiple__c = 4;
		update testDataClass.testConditionFC;

		Test.stopTest();
	}
    
    public static testMethod void TestActivateOnInsert()
    {
        BXDtesclassdata.setupFolder();
        
        Account                      TestAccount;
        Account                      TestLawFirm;
        Id                           TestpricebookId;
        TMG_Product_Level_1__c       TestProductLevel1;
        TMG_Product_Level_2__c       TestProductLevel2;
        TMG_Product_Level_3__c       TestProductLevel3;
        PricebookEntry               TestPricebookEntry;
        Agreement_Template__c        TestAgreementTemplate;
        Condition_Template__c        TestConditionTemplate;
        Condition_Template__c        TestConditionTemplate2;
        Agreement_Condition__c       TestAgreementCondition;
        Agreement_Condition__c       TestAgreementCondition2;
        Product_Agreement__c         TestProductAgreement;
        advpm__Matter__c             TestMatter;
        Agreement__c                 TestAgreement;
        Condition__c                 testCondition;
        Condition__c 				testConditionActive; 
        Date                         todaysDate; 
        User                         TestUser;
        Contact                      TestContact;
        Contact                      TestContact2;
        Deal_Party__c                TestDealParty;
        Deal_Party__c                TestDealParty2;
        Deal_Party__c                TestDealParty3;
        Agreement_Party__c           TestAgreementParty;
        Agreement_Party__c           TestAgreementParty2;
        Agreement_Party__c           TestAgreementParty3;
        Map <String, Schema.RecordTypeInfo> mapContactRecordTypes = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();    
        Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();        
        Map <String, Schema.RecordTypeInfo> mapConditionRecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
        Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Map <String, Schema.RecordTypeInfo> mapConditionTemplateRecordTypes = Condition_Template__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        advpm__Participant__c        TestParticipant1;
        advpm__Participant__c        TestParticipant2;
        advpm__Participant__c        TestParticipant3;
        advpm__Participant__c        TestParticipant4;
        advpm__Participant__c        TestParticipant5;
        advpm__Participant__c        TestParticipant6;

        todaysDate = System.Today();
        DateTime todaysDate_nextMonth = System.now().addMonths(1);
        
        //USER RECORD
        TestUser = Cloudsmiths_TestDataClass.createUser('Barclays Standard User','AdvoUser@fakeddomain11235z.co.za'); 
        insert TestUser;

        //CUSTOM SETTING
        if(ConditionSchedulingSettings__c.getInstance('Default') == null)
        {            
            ConditionSchedulingSettings__c TestConditionSchedulingSetting  = new ConditionSchedulingSettings__c(
                name = 'Default',
                Business_Hours__c = 'Monday to Friday 07:30 - 17:00',
                Months_In_Advance__c  = 12.0
            );
            insert TestConditionSchedulingSetting;
        }
        
        List<Condition__c> TestConditionList = new List<Condition__c>(); 
        
        List<Account> accounts = new List<Account>();

        TestAccount = new Account
        (
            Name = Cloudsmiths_TestDataClass.generateRandomString(6), 
            Type = 'Client',
            Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'), 
            SDS__c = 'test',
            RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId() //Added
        );
        accounts.add(TestAccount); 

        TestLawFirm = new Account
        (
             Name = Cloudsmiths_TestDataClass.generateRandomString(6), 
             Type = 'Client',
             Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
             RecordTypeId = mapAccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId()
        );
        accounts.add(TestLawFirm); 

        insert accounts;
        
        TestContact = new Contact
        (
            AccountId=TestAccount.id, 
            FirstName=Cloudsmiths_TestDataClass.generateRandomString(4),
            LastName=Cloudsmiths_TestDataClass.generateRandomString(4), 
            email=Cloudsmiths_TestDataClass.generateRandomString(4)+'@'+Cloudsmiths_TestDataClass.generateRandomString(4)+'.com'
        );
        insert TestContact;


        TestContact2 = new Contact
        (
            AccountId=TestAccount.id, 
            FirstName=Cloudsmiths_TestDataClass.generateRandomString(4),
            LastName=Cloudsmiths_TestDataClass.generateRandomString(4), 
            email='agents@support.co.za'
        );

        Database.DMLOptions dml = new Database.DMLOptions();                                    
        dml.DuplicateRuleHeader.AllowSave = true;        
        Database.SaveResult sr = Database.insert(TestContact2, dml); 


        Note note = new Note();
        note.title = 'note title'; 
        note.parentId = TestContact.Id;
        note.body = 'test';
        insert note;
        
        TestpricebookId = Test.getStandardPricebookId();
        
        //PRODUCT - Level 1
        TestProductLevel1 = new TMG_Product_Level_1__c
        (
            Name = 'Corporate Banking',
            Active__c = true
        );
        insert TestProductLevel1;
        
        //PRODUCT - Level 2
        TestProductLevel2 = new TMG_Product_Level_2__c
        (
            Name = 'Corporate Finance',
            Active__c = true,
            TMG_Product_Level_1__c = TestProductLevel1.id
        );
        insert TestProductLevel2;
        
        //PRODUCT - Level 3
        TestProductLevel3 = new TMG_Product_Level_3__c
        (
            Name = 'SUB100',
            Active__c = true,
            TMG_Product_Level_2__c = TestProductLevel2.id 
        );
        insert TestProductLevel3;
        
        //AGREEMENT TEMPLATE
        TestAgreementTemplate = new Agreement_Template__c
        (
            Name = 'Test Agreement Template'
        );  
        insert TestAgreementTemplate;
        
        //CONDITION TEMPLATE
        List<Condition_Template__c> conditionTemplates = new List<Condition_Template__c>();

        TestConditionTemplate = new Condition_Template__c
        (
            Name = 'Test Condition Template',
            RecordTypeId = mapConditionTemplateRecordTypes.get('Condition Precedent').getRecordTypeId()
        );  
        conditionTemplates.add(TestConditionTemplate);
        
        //CONDITION TEMPLATE
        TestConditionTemplate2 = new Condition_Template__c
        (
            Name = 'Test Condition Template 2',
            RecordTypeId = mapConditionTemplateRecordTypes.get('Information Undertaking').getRecordTypeId()  
        );  
        conditionTemplates.add(TestConditionTemplate2);

        insert conditionTemplates;
        
        //AGREEMENT CONDITIONS
        List<Agreement_Condition__c> agreementConditions = new List<Agreement_Condition__c>();

        TestAgreementCondition = new Agreement_Condition__c
        (
            Agreement_Template__c = TestAgreementTemplate.Id,
            Condition_Template__c = TestConditionTemplate.Id
        );
        agreementConditions.add(TestAgreementCondition);
        
        //AGREEMENT CONDITIONS
        TestAgreementCondition2 = new Agreement_Condition__c(
            Agreement_Template__c = TestAgreementTemplate.Id,
            Condition_Template__c = TestConditionTemplate2.Id
        );
        agreementConditions.add(TestAgreementCondition2);

        insert agreementConditions;
        
        //PRODUCT AGREEMENT
        TestProductAgreement = new Product_Agreement__c
        (
            Name = 'Test',
            Agreement_Template__c = TestAgreementTemplate.id,
            TMG_Product_Level_3__c = TestProductLevel3.id
        );
        insert TestProductAgreement;
        
        //MATTER
        TestMatter = new advpm__Matter__c 
        (
            advpm__Primary_Account__c = TestAccount.id,
            Name = 'Test',
            Standard__c = true,
            advpm__Status__c = 'Open',
            advpm__Type__c='Syndicated',
            Start_Date__c = date.today(),
            RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
            Division__c = 'CIB',
            TMG_Product_Level_1__c = TestProductLevel1.Id,
            TMG_Product_Level_2__c = TestProductLevel2.Id,
            TMG_Product_Level_3__c = TestProductLevel3.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert TestMatter;

        List<advpm__Participant__c> testParticipants = new List<advpm__Participant__c>();

        TestParticipant1 = new advpm__Participant__c
        (
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 1',
            advpm__Staff__c = TestUser.Id,
            advpm__Role__c = 'Transaction Administration',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant1);
        
        TestParticipant2 = new advpm__Participant__c(
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 2',
            advpm__Staff__c = TestUser.Id, 
            advpm__Role__c = 'Credit',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant2);
        
        TestParticipant3 = new advpm__Participant__c
        (
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 3',
            advpm__Staff__c = TestUser.Id,
            advpm__Role__c = 'Product',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant3);
        
        TestParticipant4 = new advpm__Participant__c
        (
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 2',
            advpm__Staff__c = TestUser.Id, 
            advpm__Role__c = 'Legal Counsel',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId() 
        );
        testParticipants.add(TestParticipant4);

        TestParticipant5 = new advpm__Participant__c 
        (
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 2',
            advpm__Staff__c = TestUser.Id, 
            advpm__Role__c = 'Transaction Management',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant5);

        TestParticipant6 = new advpm__Participant__c(
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 2',
            advpm__Staff__c = UserInfo.getUserId(), 
            advpm__Role__c = 'Credit',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant6);
        
        insert testParticipants;      
        
        //AGREEMENT
        TestAgreement = new Agreement__c
        (
            Matter_Deal__c =  TestMatter.id,
            Name = 'Test',
            Agreement_Type__c =    TestProductAgreement.id,
            TMG_Product_Level_3__c = TestProductLevel3.id,
            Signature_Date__c = Date.today().addDays(5),
            Effective_Date__c = Date.today().addDays(5),
            Limit__c = 10000
        );
        Insert TestAgreement;   
        
        //DEAL PARTY
        List<Deal_Party__c> dealParties = new List<Deal_Party__c>();
        TestDealParty = new Deal_Party__c
        (
            Deal__c = TestMatter.id,
            Party_Type__c = 'Borrower',
            Relationship__c = testAccount.id,
            Conditions_Monitored_By__c = TestParticipant1.Id            
        );
        dealParties.add(TestDealParty);

        TestDealParty2 = new Deal_Party__c
        (
            Deal__c = TestMatter.id,
            Party_Type__c = 'Lender',
            Relationship__c = testAccount.id,
            Conditions_Monitored_By__c = TestParticipant1.Id            
        );
        dealParties.add(TestDealParty2);

        TestDealParty3 = new Deal_Party__c
        (
            Deal__c = TestMatter.id,
            Party_Type__c = 'Lender',
            Relationship__c = testAccount.id,
            Conditions_Monitored_By__c = TestParticipant1.Id            
        );
        dealParties.add(TestDealParty3); 

        insert dealParties;

        List<Agreement_Party__c> agreementParties = new List<Agreement_Party__c>();

        TestAgreementParty = new Agreement_Party__c
        (
            Agreement__c = TestAgreement.id,
            Deal_Party__c  = TestDealParty.id,
            Lender_Amount__c = null               
        );
        agreementParties.add(TestAgreementParty);

        TestAgreementParty2 = new Agreement_Party__c
        (
            Agreement__c = TestAgreement.id,
            Deal_Party__c  = TestDealParty2.id,
            Lender_Amount__c = null                  
        );
        agreementParties.add(TestAgreementParty2);

        TestAgreementParty3 = new Agreement_Party__c
        (
            Agreement__c = TestAgreement.id,
            Deal_Party__c  = TestDealParty3.id,
           Lender_Amount__c = null                         
        );
        agreementParties.add(TestAgreementParty3);

        insert agreementParties;

        List<Condition__c> conditions = new List<Condition__c>();

        testCondition = new Condition__c 
        (
            Name = 'TestCon',
            Agreement__c =   TestAgreement.id,
            Clause__c = 'Test',
            Recurrence__c = 'Once Off',
            Due_Date__c = date.today(),
            Active__c = false,
            Matter__c =  TestMatter.id,
            recordTypeID = mapConditionRecordTypes.get('Information Undertaking').getRecordTypeId()            
        );
        conditions.add(testCondition);
        
        testConditionActive = new Condition__c 
        (
            Name = 'TestCon',
            Agreement__c =   TestAgreement.id,
            Clause__c = 'Test',
            Recurrence__c = 'Once Off',
            Due_Date__c = date.today(),
            Active__c = True,
            Matter__c =  TestMatter.id,
            recordTypeID = mapConditionRecordTypes.get('Information Undertaking').getRecordTypeId()            
        );
        conditions.add(testConditionActive);
        
        Test.startTest();
        
        insert conditions;
        
        testCondition.Active__c = True;
        testCondition.Activate_Later__c = False;
        
        Update testCondition;
        
        Test.stopTest();

    }
}