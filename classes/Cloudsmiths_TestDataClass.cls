/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___  
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 25/07/2017 - PG    - Formatted some of the code lines.
                    - Added logic to only insert TestConditionSchedulingSetting if it does not exist yet.
 10/08/2017 - PG    - Added Spend Document object.
                    - Updated user to be able to "Approve Spend Schedules."
 28/09/2017 - PG    - Added Lookup__c record object.
                    - Added Agency Drawdown test data.
 10/10/2017 - PG    - Put some inserts into lists.   Need to really fix this class...it is being overused by everyone...
                    - Need more isloated tests for functionality.  Hitting SOQL query limits.
 30/10/2017 - PG    - Consolidated some additional inserts into lists.
 09/11/2017 - TdB   - API Name change. Facility_Limit__c  to Limit__c on Agreements Object
 08/02/2018 - PG    - Added client plan to ACMFacility__c.  
                    - Consolidated some additional inserts into lists.
 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist


**/  
@isTest
public class Cloudsmiths_TestDataClass 
{    
    public static Map <String, Schema.RecordTypeInfo> mapContactRecordTypes = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();    
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();    
    public static Map <String, Schema.RecordTypeInfo> mapCaseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName();    
    public static Map <String, Schema.RecordTypeInfo> mapConditionRecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
    public static Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapConditionOccRecordTypes = Condition_Occurrence__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapNotificationGroupRecordTypes = Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapConditionTemplateRecordTypes = Condition_Template__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapLegalQuoteRequestRecordTypes = Legal_Quote_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapLegalQuoteRecordTypes = Legal_Quote__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapDrawdownRecordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapLookupRecordTypes = Lookup__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    public Account                      TestAccount;
    public Account                      TestLawFirm;
    public Id                           TestpricebookId;
    public TMG_Product_Level_1__c       TestProductLevel1;
    public TMG_Product_Level_2__c       TestProductLevel2;
    public TMG_Product_Level_3__c       TestProductLevel3;
    public PricebookEntry               TestPricebookEntry;
    public Agreement_Template__c        TestAgreementTemplate;
    public Condition_Template__c        TestConditionTemplate;
    public Condition_Template__c        TestConditionTemplate2;
    public Agreement_Condition__c       TestAgreementCondition;
    public Agreement_Condition__c       TestAgreementCondition2;
    public Product_Agreement__c         TestProductAgreement;
    public advpm__Matter__c             TestMatter;
    public Agreement__c                 TestAgreement;
    public Condition__c                 testCondition;
    //public Condition__c 				testConditionActive; 
    public Condition__c                 testConditionGC;
    public Condition__c                 testConditionGCwithoutAgreement;
    public Condition__c                 testConditionFC;
    public Deal_Party__c                TestDealParty;
    public Deal_Party__c                TestDealParty2;
    public Deal_Party__c                TestDealParty3;
    public Agreement_Party__c           TestAgreementParty;
    public Agreement_Party__c           TestAgreementParty2;
    public Agreement_Party__c           TestAgreementParty3;
    public Condition_Party__c           TestConditionParty;
    public Condition_Party__c           TestConditionPartyGC;
    public Condition_Party__c           TestConditionPartyFC;
    public List<Condition__c>           TestConditionList;
    public Collateral_Type__c           TestCollateralType;
    public Collateral_Group__c          TestCollateralGroup;
    public Collateral__c                TestCollateral;
    public Collateral_Relationship__c   TestCollateralRelationship;
    public advpm__Participant__c        TestParticipant1;
    public advpm__Participant__c        TestParticipant2;
    public advpm__Participant__c        TestParticipant3;
    public advpm__Participant__c        TestParticipant4;
    public advpm__Participant__c        TestParticipant5;
    public advpm__Participant__c        TestParticipant6;
    public User                         TestUser;
    public Condition_Occurrence__C      TestConditionOccurrence; 
    public Case                         TestCaseLegal;
    public Attachment                   TestAttachment1;
    public Drawdown__c                  TestDrawdown;
    public Drawdown__c                  TestDrawdownNotInserted;
    public Drawdown__c                  TestDrawdownNotInserted_Agency; 
    public Distribution_Group__c        TestDistroGroupPublic;
    public Distribution_Group__c        TestDistroGroupPrivate;  
    public Notification_Group__c        TestNotificationGroup_F2L_Public;
    public Notification_Group__c        TestNotificationGroup_F2L_Private;
    public Fit_To_Lend_Checklist__c     TestFitToLend; 
    public Fit_To_Lend_Checklist__c     TestFitToLendNotInserted; 
    public Notification_Participant__c  TestNotificationParticipant;
    public Business_Unit__c             TestBusinessUnit; 
    public Contact                      TestContact;
    public Contact                      TestContact2;
    public Legal_Quote_Request__c       TestLegalLegalQuoteRequest;
    public Legal_Quote_Request__c       TestLitigationLegalQuoteRequest;
    public Legal_Quote__c               TestLegalLegalQuote;   
    public Matter_Spend_Document__c     TestSpendDocument;
    public Matter_Spend_Schedule__c     TestSpendSchedule;
    public Lookup__c                    TestAgencyBankDetails;
    public Collateral_Facility__c       TestCollateralFacility;
    public AcmFacility__c               TestAcmFacility;
    public Collateral__c                TestCollateral2; 
    public Agency_Transfer__c           TestAgencyTransfer;
    public Facility__c                  TestFacility;
    public Facility_Tranche__c          TestFacilityTranche;    
    public Margin_Ratchet__c            testCovenantMarginRatchet;
    public Margin_Ratchet__c            testEventMarginRatchet;
    public Margin_Ratchet_Conditions__c testMarginRatchetConditions;
    public Notification_Group__c        testMarginRatchetNotifGroup;
    public Notification_Group__c        testCollateralValuationNotifGroup;
    public Notification_Group__c        testCollateralMonitoringNotifGroup;
    public Notification_Participant__c  testMarginRatchetNotifParticipant;
    public Notification_Participant__c  testMarginRatchetNotifParticipant2;
    public Notification_Participant__c  testCollateralValuationNotifParticipant;
    public Notification_Participant__c  testCollateralMonitoringNotifParticipant;
    public Collateral_Monitoring__c     testCollateralMonitoring;
    public Collateral_Valuation__c      testCollateralValuation;
    public Relationship_Parties__c      testRelationshipParties;
    public Watcher__c                   testMarginRatchetWatcher;
    public Watcher__c                   testCollateralValuationWatcher;
    public Watcher__c                   testCollateralMonitoringWatcher;
    public Watcher__c                   testTriggerWatcher;
    public Lookup__c                    TestLegalQuoteRequest;
    public advpm__Participant__c        TestParticipantMarginRatchet;
    public Trigger__c                   TestTrigger;
    public Notification_Group__c        testTriggerNotifGroup;
    public Notification_Participant__c  testTriggerNotifParticipant;
    public Date                         todaysDate; 
    public Facility_Party__c            TestFacilityParty;
    public Facility_Party__c            TestFacilityParty2;
    public Tranche_Party__c             TestTrancheParty;  
    public Tranche_Party__c             TestTrancheParty2; 
    public Opportunity                  TestOpportunity;
    public Client_Plan__c               TestClientPlan;
    
    public Cloudsmiths_TestDataClass() 
    {
        BXDtesclassdata.setupFolder();

        todaysDate = System.Today();
        DateTime todaysDate_nextMonth = System.now().addMonths(1);
        
        //USER RECORD
        TestUser = createUser('Barclays Standard User','AdvoUser@fakeddomain11235z.co.za'); 
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
        
        TestConditionList = new List<Condition__c>(); 
        
        /**
        * ACCOUNTS
        **/
        List<Account> accounts = new List<Account>();

        TestAccount = new Account
        (
            Name = generateRandomString(6), 
            Type = 'Client',
            Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'), 
            SDS__c = 'test',
            RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId() //Added
        );
        accounts.add(TestAccount); 

        TestLawFirm = new Account
        (
             Name = generateRandomString(6), 
             Type = 'Client',
             Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
             RecordTypeId = mapAccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId()
        );
        accounts.add(TestLawFirm); 

        insert accounts;
        
        /**
        * CONTACTS
        **/
        TestContact = new Contact
        (
            AccountId=TestAccount.id, 
            FirstName=generateRandomString(4),
            LastName=generateRandomString(4), 
            email=generateRandomString(4)+'@'+generateRandomString(4)+'.com'
        );
        insert TestContact;


        TestContact2 = new Contact
        (
            AccountId=TestAccount.id, 
            FirstName=generateRandomString(4),
            LastName=generateRandomString(4), 
            email='agents@support.co.za'
        );

        Database.DMLOptions dml = new Database.DMLOptions();                                    
        dml.DuplicateRuleHeader.AllowSave = true;        
        Database.SaveResult sr = Database.insert(TestContact2, dml); 

        /**
        * NOTE
        **/
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
        
        /**
        * PARTICIPANTS
        **/
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
        
        /**
        * AGREEMENT PARTIES
        **/
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
        
        /**
        * CONDITIONS
        **/
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
        
        /*testConditionActive = new Condition__c 
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
        conditions.add(testConditionActive);*/

        testConditionGC = new Condition__c
        (
            Name = 'TestCon',
            Agreement__c =   TestAgreement.id,
            Clause__c = 'Test',
            Recurrence__c = 'Once Off',
            Due_Date__c = date.today(),
            Active__c = false,
            Matter__c =  TestMatter.id,
            recordTypeID = mapConditionRecordTypes.get('Governance Check').getRecordTypeId()            
        );
        conditions.add(testConditionGC);

        testConditionGCwithoutAgreement = new Condition__c 
        (
            Name = 'TestCon',
            Clause__c = 'Test',
            Recurrence__c = 'Once Off',
            Due_Date__c = date.today(),
            Active__c = false,
            Matter__c =  TestMatter.id,
            recordTypeID = mapConditionRecordTypes.get('Governance Check').getRecordTypeId()            
        );
        conditions.add(testConditionGCwithoutAgreement);

        testConditionFC = new Condition__c
        (
            Name = 'TestCon',
            Agreement__c =   TestAgreement.id,
            Clause__c = 'Test',
            Recurrence__c = 'Once Off',
            Due_Date__c = date.today(),
            Active__c = false,
            Matter__c =  TestMatter.id,
            Margin_Ratchet__c = true,
            Threshold_Type__c = 'Base',
            Threshold_Category__c = 'Multiple',          
            Threshold_Comparator__c = 'equals',
            Source__c = 'Manual',
            Required_Base_Multiple__c = 2,
            recordTypeID = mapConditionRecordTypes.get('Financial Covenant').getRecordTypeId()
        );
        conditions.add(testConditionFC);

        insert conditions;

        /**
        * CUSTOM FRUPS
        **/
        List<Custom_FRUP__c> customFrups = new List<Custom_FRUP__c>();

        Custom_FRUP__c frupConditionIU= new Custom_FRUP__c 
        (
            CustomKey__c = TestAgreement.id + ' - ' + mapConditionRecordTypes.get('Information Undertaking').getRecordTypeId(),
            FolderId__c = '4',
            ParentFolderId__c = '0'
        );
        customFrups.add(frupConditionIU);
        
        Custom_FRUP__c frupConditionGC= new Custom_FRUP__c 
        (
            CustomKey__c = TestAgreement.id + ' - ' + mapConditionRecordTypes.get('Condition Precedent').getRecordTypeId(),
            FolderId__c = '5',
            ParentFolderId__c = '0'
        );
        customFrups.add(frupConditionGC);
        
        Custom_FRUP__c frupConditionFC= new Custom_FRUP__c 
        (
            CustomKey__c = TestAgreement.id + ' - ' + mapConditionRecordTypes.get('Financial Covenant').getRecordTypeId(),
            FolderId__c = '6',
            ParentFolderId__c = '0'
        );
        customFrups.add(frupConditionFC);

        Custom_FRUP__c frupAgreements= new Custom_FRUP__c
        (
            CustomKey__c = TestMatter.id + ' - ' + 'Agreements',
            FolderId__c = '2',
            ParentFolderId__c = '0'
        );
        customFrups.add(frupAgreements); 

        insert customFrups;
        
        /**
        * CONDITION PARITES
        **/
        List<Condition_Party__c> conditionParties = new List<Condition_Party__c>();

        TestConditionParty = new Condition_Party__c
        (
            Agreement_Party__c = TestAgreementParty.id, 
            Condition__c   =  testCondition.id
            
        );
        conditionParties.add(TestConditionParty);
        
        //CONDITION PARTY - GC
        TestConditionPartyGC = new Condition_Party__c
        (
            Agreement_Party__c = TestAgreementParty.id, 
            Condition__c   =  testConditionGC.id
            
        );
        conditionParties.add(TestConditionPartyGC);
        
        //CONDITION PARTY - FC
        TestConditionPartyFC = new Condition_Party__c
        (
            Agreement_Party__c = TestAgreementParty.id, 
            Condition__c   =  testConditionFC.id
            
        );
        conditionParties.add(TestConditionPartyFC);

        insert conditionParties;
        
        /**
        * CONDITION OCCURRENCES
        **/
        TestConditionOccurrence = new Condition_Occurrence__c 
        (
            Condition__c = testCondition.id,
            Status__c = 'New',
            Due_Date__c = date.today(),
            Condition_Party__c = TestConditionParty.Id,
            RecordTypeId = mapConditionOccRecordTypes.get('Condition Precedent').getRecordTypeId()
        );
        insert TestConditionOccurrence;
        
        TestConditionList.add(testCondition);
        
        //Collateral Group
        TestCollateralGroup =  new Collateral_Group__c
            (
                Name = 'TEST',
                Credit_Code__c = 'Test'
            );
        
        insert TestCollateralGroup;
        
        //Collateral Type
        TestCollateralType =  new Collateral_type__c
        (
            Credit_Code__c = 'Test',
            Collateral_Group__c = TestCollateralGroup.id,
            Enabled__c = true,
            Push_to_ACM__c = false 
        );        
        insert TestCollateralType;

        //COLLATERAL - BENEFICIARY
        TestCollateral = new Collateral__c
        (
            Name = 'Test Collateral',
            Status__c = 'Outstanding',
            Scope__c = 'Beneficiary',
            Beneficiary__c = TestAccount.Id,
            Account__c = TestAccount.Id,
            Collateral_Type1__c = TestCollateralType.id,
            Collateral_Group__c = TestCollateralGroup.id
        );
        insert TestCollateral;
        
        //COLLATERAL RELATIONSHIP
        TestCollateralRelationship = new Collateral_Relationship__c
        (
            Collateral__c = TestCollateral.Id,
            Relationship__c = TestAccount.Id,
            Relationship_Type__c = 'Provider'
        );
        insert TestCollateralRelationship; 

        //Client Plan
        TestClientPlan = new Client_Plan__c
        (
            Relationship__c = TestAccount.Id
        );
        insert TestClientPlan; 

        //ACM FACILITY
        TestAcmFacility = new AcmFacility__c
        (   
            Name = 'Test Acm Facility',
            FACILITYCURRENCY__c = 'USD',
            FACILITYAMOUNT__c = 2000000,
            Facility_Id__c = 'Random id',
            FACILITYPRODUCT__c = 'Product Name',
            STARTDATE__c = Date.newInstance(1990, 01, 01),
            EXPIRYDATE__c = Date.newInstance(1990, 01, 02),
            FACILITYPRODUCTDESCRIPTION__c = 'Product Description',
            Relationship__c = TestAccount.Id,
            CLIENTPLAN__c = TestClientPlan.Id
        );
        insert TestAcmFacility;
        
        // COLLATERAL with a FACILITY
        TestCollateral2 = new Collateral__c
        (
            Scope__c = 'Facility',
            Name = 'Collateral Test',
            Status__c = 'Outstanding',
            Account__c = TestAccount.Id,
            AcmFacility__c = TestAcmFacility.Id,
            Facility_Client__c = TestAccount.Id,
            Collateral_Group__c = TestCollateralGroup.Id,
            Collateral_Type1__c = TestCollateralType.Id
        );
        insert TestCollateral2;  

        //COLLATERAL FACILITY
        TestCollateralFacility = new Collateral_Facility__c
        (
            AcmFacility__c = TestAcmFacility.Id,
            Collateral__c = TestCollateral2.Id,
            Facility_Client__c = TestAccount.Id,
            isPrimaryRelationship__c = true
        );
        insert TestCollateralFacility;

        //FACILITY
        TestFacility = new Facility__c 
        (
            Name = 'Test Agreement Facility',
            Facility_Type__C = 'Term Loan',
            Facility_Limit__c = 500,
            Agreement__c = TestAgreement.Id,
            Availability_Start_Date__c = System.today(),
            Expiry_Date__c = System.today()
            
        );
        insert TestFacility;
        
        List<Facility_Party__c> facilityPartyList = new List<Facility_Party__c>();
        
        TestFacilityParty = new Facility_Party__c
        (
            Facility__c = TestFacility.id,
            Agreement_Party__c  = TestAgreementParty2.id,
            Facility_Amount__c = null               
        );
        facilityPartyList.add(TestFacilityParty); 
        
        TestFacilityParty2 = new Facility_Party__c
        (
            Facility__c = TestFacility.id,
            Agreement_Party__c  = TestAgreementParty3.id,
            Facility_Amount__c = null               
        );
        facilityPartyList.add(TestFacilityParty2); 
        
        insert facilityPartyList;

        //FACILITY TRANCHE
        TestFacilityTranche = new Facility_Tranche__c 
        (
            Name = 'Test Facility Tranche',
            Tranche_Type__C = 'Term Loan',
            Tranche_Limit__C = 500,
            Facility__c = TestFacility.Id
        );
        insert TestFacilityTranche;
        
        List<Tranche_Party__c> facilityTrancheParty = new List<Tranche_Party__c>();
        TestTrancheParty = new Tranche_Party__c
        (
            Facility_Tranche__c = TestFacilityTranche.id,
            Facility_Party__c  = TestFacilityParty.id,
            Facility_Amount__c = null               
        );
        facilityTrancheParty.add(TestTrancheParty);
        
        TestTrancheParty2 = new Tranche_Party__c
        (
            Facility_Tranche__c = TestFacilityTranche.id,
            Facility_Party__c  = TestFacilityParty2.id,
            Facility_Amount__c = null               
        );
        facilityTrancheParty.add(TestTrancheParty2);
        
        insert facilityTrancheParty;
        
        
        //DISTRO GROUP
        
        List<Distribution_Group__c> distributionGroupList = new List<Distribution_Group__c>();
        
        TestDistroGroupPublic = new Distribution_Group__c
        (
            Name = 'PublicDistro',
            Description__c = 'Blah Blah',
            Email_Address__c = 'public@cloudsmiths.co.za',
            Group_Type__c = 'Public'
        );
        distributionGroupList.add(TestDistroGroupPublic);
        
        TestDistroGroupPrivate = new Distribution_Group__c
        (
            Name = 'PRivateDistro',
            Description__c = 'Blah Blah',
            Email_Address__c = 'private@cloudsmiths.co.za',
            Group_Type__c = 'Private'
        );
        distributionGroupList.add(TestDistroGroupPrivate);
        
        insert distributionGroupList;
        
        List<Lookup__c> lookupList = new List<Lookup__c>();

        //AGENCY BANK DETAILS
        TestAgencyBankDetails = new Lookup__c 
        (
            Active__c = true,
            Account_Branch__c = '123',
            Account_Name__c = '123',
            Account_Number__c = '123',
            Account_Bank__c = '123',
            RecordTypeId = mapLookupRecordTypes.get('Agency Bank Detail').getRecordTypeId(),
            CurrencyISOCode = 'ZAR'      
        );
        lookupList.add(TestAgencyBankDetails); 

        //LEGAL QUOTE Details
        TestLegalQuoteRequest = new Lookup__c
        (
            User__c = TestUser.Id,
            RecordTypeId = mapLookupRecordTypes.get('Legal Quote Request').getRecordTypeId(),
            CurrencyISOCode = 'ZAR'      
        );
        lookupList.add(TestLegalQuoteRequest);    
        
        insert lookupList;
        
        /**
        * Drawdowns
        **/ 
        TestDrawdown = new Drawdown__c
        (
            Name = 'TestDown', 
            Agreement__c = TestAgreement.Id,
            Status__c = 'Governance and Documentation Check  Incomplete', 
            Advance_Amount__c = 100,
            Current_Utilisation__c = 50,
            Facility_Limit__c = 200,
            Account_Name__c = 'Test Acc Name',
            Account_Number__c = '123',
            Account_Branch__c = '123', 
            Account_Bank__c = 'Test Bank Acc',
            Advance_Date__c = Date.today(),
            Reference__c = 'Blah blah',
            Request_Date__c = Date.today(),
            CurrencyISOCode = 'ZAR'
        );
        insert TestDrawdown;

        TestDrawdownNotInserted = new Drawdown__c 
        (
            Name = 'TestDown', 
            Agreement__c = TestAgreement.Id,
            Status__c = 'Governance and Documentation Check  Incomplete',
            Advance_Amount__c = 100,
            Current_Utilisation__c = 50,
            Facility_Limit__c = 200,
            Account_Name__c = 'Test Acc Name',
            Account_Number__c = '123',
            Account_Branch__c = '123', 
            Account_Bank__c = 'Test Bank Acc',
            Advance_Date__c = Date.today(),
            Reference__c = 'Blah blah',
            Request_Date__c = Date.today(),
            RecordTypeId = mapDrawdownRecordTypes.get('Drawdown').getRecordTypeId(),
            CurrencyISOCode = 'ZAR'
        );

        TestDrawdownNotInserted_Agency = new Drawdown__c
        (
            Name = 'TestDown', 
            Agreement__c = TestAgreement.Id,
            Status__c = 'Governance and Documentation Check  Incomplete',
            Advance_Amount__c = 100,
            Current_Utilisation__c = 50,
            Facility_Limit__c = 200,
            Account_Name__c = 'Test Acc Name',
            Account_Number__c = '123',
            Account_Branch__c = '123', 
            Account_Bank__c = 'Test Bank Acc',
            Advance_Date__c = Date.today(),
            Reference__c = 'Blah blah',
            Request_Date__c = Date.today(),
            RecordTypeId = mapDrawdownRecordTypes.get('Drawdown - Agency').getRecordTypeId(),
            CurrencyISOCode = 'ZAR'
        );

        //FIT TO LEND CHECKLIST
        TestFitToLend = new Fit_To_Lend_Checklist__c
        (
            Deal__c = TestMatter.Id,
            Status__c = 'New'
        );
        insert TestFitToLend;
        
        TestNotificationParticipant =  new Notification_Participant__c
        (
            Fit_To_Lend_Checklist__c = TestFitToLend.id,
            Participant__c = TestParticipant1.id,
            DrawDown__c = TestDrawdown.id
        );
        insert TestNotificationParticipant;

        //FIT TO LEND CHECKLIST - NOT INSERTED
        TestFitToLendNotInserted = new Fit_To_Lend_Checklist__c
        (
            Deal__c = TestMatter.Id,
            Status__c = 'New'
        );
        
        //F2L Notification Group
        List<Notification_Group__c> notificationGroups = new List<Notification_Group__c>();

        TestNotificationGroup_F2L_Public = new Notification_Group__c
        (
            Distribution_Group__c = TestDistroGroupPublic.Id,
            Fit_To_Lend__c = TestFitToLend.Id,
            DrawDown__c = TestDrawdown.id,
            RecordTypeId = mapNotificationGroupRecordTypes.get('Fit To Lend Checklist').getRecordTypeId()
        ); 
        notificationGroups.add(TestNotificationGroup_F2L_Public);
        
        //F2L Notification Group
        TestNotificationGroup_F2L_Private = new Notification_Group__c
        (
            Distribution_Group__c = TestDistroGroupPrivate.Id,
            Fit_To_Lend__c = TestFitToLend.Id,
            RecordTypeId = mapNotificationGroupRecordTypes.get('Fit To Lend Checklist').getRecordTypeId()
        ); 
        notificationGroups.add(TestNotificationGroup_F2L_Private);

        insert notificationGroups;

        //AGENCY TRANSFER
        TestAgencyTransfer = new Agency_Transfer__c
        (
            Agreement__c = TestAgreement.Id,
            Transfer_Fee__c = true
        );
        //insert TestAgencyTransfer;

        //BUSIINESS UNIT
        TestBusinessUnit = new Business_Unit__c
        (
            Name = 'Test',
            Segment__c = 'Corporate',
            Cluster_Function__c = 'Corporate and Investment Banking (CIB)'
        );
        insert TestBusinessUnit;
        
        //LEGAL QUOTE REQUEST
        TestLegalLegalQuoteRequest = new Legal_Quote_Request__c
        (
            RecordTypeID = mapLegalQuoteRequestRecordTypes.get('Legal Request').getRecordTypeId(), 
            Matter__c = TestMatter.id,
            Cost_Centre__c = '100',
            Quote_Title__c = 'Test',
            Quote_Description__c= 'Test', 
            Request_Motivation__c= 'Test'
        );
        insert TestLegalLegalQuoteRequest;
        
        List<Custom_FRUP__c> customFRUPList = new List<Custom_FRUP__c>();
        
         //CUSTOM FRUP LQR
        Custom_FRUP__c frupLegalQuoteRequest = new Custom_FRUP__c 
        (
            CustomKey__c = TestMatter.id + ' - ' + 'Legal Quote Requests',
            FolderId__c = '7',
            ParentFolderId__c = '0'
        );
        customFRUPList.add(frupLegalQuoteRequest);
        
        //CUSTOM FRUP LEGAL QUOTE
        Custom_FRUP__c frupLegalQuote = new Custom_FRUP__c 
        (
            CustomKey__c = TestLegalLegalQuoteRequest.id + ' - ' + 'Quotes',
            FolderId__c = '8',
            ParentFolderId__c = '0'
        );
        customFRUPList.add(frupLegalQuote);
        
        Insert customFRUPList;
        
        //LEGAL QUOTE
        TestLegalLegalQuote =  new Legal_Quote__c
        (
            RecordTypeID = mapLegalQuoteRecordTypes.get('Legal Quote').getRecordTypeId(), 
            Legal_Quote_Request__c = TestLegalLegalQuoteRequest.id,
            Law_Firm__c=TestAccount.id,
            Contact__c = TestContact.id
        );
        insert TestLegalLegalQuote;

        TestSpendSchedule = new Matter_Spend_Schedule__c(
            Law_Firm__c = TestLawFirm.Id,
            Status__c = 'Open'
        );
        insert TestSpendSchedule;
        
        TestSpendDocument = new Matter_Spend_Document__c(
            Matter__c = TestMatter.Id,
            Status__c = 'New',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '123',
            BU_Corporate_Code__c = '123',
            Total_Vat_Amount__c = 12
        );
        insert TestSpendDocument;        
        
        //Margin Ratchet - Covenant
        List<Margin_Ratchet__c> marginRatchets = new List<Margin_Ratchet__c>();

        testCovenantMarginRatchet = new Margin_Ratchet__c 
        (
            Name = 'Test Facility Tranche',
            Type__c = 'Covenant',
            Agreement__c = TestAgreement.id,
            Matter_Deal__c = TestMatter.id,
            Frequency__c = 'Once Off',
            Due_Date__c = System.Today()
        );
        marginRatchets.add(testCovenantMarginRatchet);
        
        //Margin Ratchet - Event
        testEventMarginRatchet = new Margin_Ratchet__c 
        (
            Name = 'Test Facility Tranche',
            Type__c = 'Event',
            Agreement__c = TestAgreement.id,
            Matter_Deal__c = TestMatter.id
        );
        marginRatchets.add(testEventMarginRatchet);

        insert marginRatchets;
        
        //Margin Ratchet Condition
        testMarginRatchetConditions = new Margin_Ratchet_Conditions__c 
        (
            Condition__c = testConditionFC.id,
            Margin_Ratchet__c = testCovenantMarginRatchet.id
        );
        insert testMarginRatchetConditions;
        
        //Collateral Monitoring
        testCollateralMonitoring = new Collateral_Monitoring__c 
        (
            Name = 'Test Collateral Monitoring 1',
            Collateral__c = TestCollateral.id,
            Agreement__c = TestAgreement.id,
            Deal__c = TestMatter.id,
            Days__c = ' Days After',
            Frequency__c = 'Monthly',
            Number_of_Days__c = 2,
            Relative_Date__c = 'Effective Date'
        );
        insert testCollateralMonitoring;
        
        //Collateral Valuation
        testCollateralValuation = new Collateral_Valuation__c 
        (
            Name = 'Test Collateral Monitoring 1',
            Collateral__c = TestCollateral.id,
            Agreement__c = TestAgreement.id,
            Deal__c = TestMatter.id,
            Days__c = ' Days After',
            Frequency__c = 'Monthly',
            Number_of_Days__c = 2,
            Relative_Date__c = 'Effective Date'
        );
        insert testCollateralValuation;
        
         //Trigger
        TestTrigger = new Trigger__c 
        (
            Name = 'Test Facility Tranche',
            Agreement__c = TestAgreement.id,
            Deal__c = TestMatter.id,
            Frequency__c = 'Once Off',
            Due_Date__c = System.Today()
        );
        insert TestTrigger;
        
        //Relationship Parties
        testRelationshipParties = new Relationship_Parties__c 
        (
            Agreement_Party__c = TestAgreementParty.id,
            Margin_Ratchet__c = testEventMarginRatchet.id
            
        );
        insert testRelationshipParties;
        
        //Noticifaction Group - Margin Ratchet
        testMarginRatchetNotifGroup = new Notification_Group__c 
        (
            Margin_Ratchet__c = testEventMarginRatchet.id,
            Distribution_Group__c = TestDistroGroupPrivate.id
        );
        insert testMarginRatchetNotifGroup;
        
        
        //Noticifaction Participants - Margin Ratchet
        
        List<Notification_Participant__c> notificationParticipantScheduleList = new List<Notification_Participant__c> ();
        
        testMarginRatchetNotifParticipant = new Notification_Participant__c 
        (
            Margin_Ratchet__c = testEventMarginRatchet.id,
            Participant__c = testParticipants[0].id
        );
        notificationParticipantScheduleList.add(testMarginRatchetNotifParticipant);
        
        //Noticifaction Participants - Margin Ratchet
        testMarginRatchetNotifParticipant2 = new Notification_Participant__c 
        (
            Margin_Ratchet__c = testCovenantMarginRatchet.id,
            Participant__c = TestParticipant2.id
        );
        notificationParticipantScheduleList.add(testMarginRatchetNotifParticipant2);
        
        //Noticifaction Participants - Trigger
        testTriggerNotifParticipant = new Notification_Participant__c 
        (
            Trigger__c = testTrigger.id,
            Participant__c = testParticipants[0].id
        );
        notificationParticipantScheduleList.add(testTriggerNotifParticipant);
        
        insert notificationParticipantScheduleList;
        
        //Noticifaction Group - Trigger
        testTriggerNotifGroup = new Notification_Group__c 
        (
            Trigger__c = testTrigger.id,
            Distribution_Group__c = TestDistroGroupPrivate.id
        );
        insert testTriggerNotifGroup;
        
        List<Watcher__c> watcherList = new  List<Watcher__c>();

        //Watcher - Margin Ratchet
        testMarginRatchetWatcher = new Watcher__c 
        (
            Margin_Ratchet__c = testEventMarginRatchet.id,
            Watcher_Status__c = 'New'
        );
        watcherList.add(testMarginRatchetWatcher);
        
        //Watcher - Collateral Valuation
        testCollateralValuationWatcher = new Watcher__c 
        (
            Collateral_Valuation__c = testCollateralValuation.id,
            Watcher_Status__c = 'New'
        );
        watcherList.add(testCollateralValuationWatcher);
        
        //Watcher - Collateral Monitoring
        testCollateralMonitoringWatcher = new Watcher__c 
        (
            Collateral_Monitoring__c = testCollateralMonitoring.id,
            Watcher_Status__c = 'New'
        );
        watcherList.add(testCollateralMonitoringWatcher);
        
        //Watcher - Trigger
        testTriggerWatcher = new Watcher__c 
        (
            Trigger__c = testTrigger.id,
            Watcher_Status__c = 'New',
            Due_Date__c = todaysDate.addDays(10)
        );
        watcherList.add(testTriggerWatcher);
        
        insert watcherList;
    }
    
    //Generate String
    public static String generateRandomString(Integer len) { 
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; 
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length()); 
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    //New user
    public static User createUser(string profile, string username)
    {
        username = Math.random()+ username;
        user newUser;
        try 
        {
            Profile userProfile = [select Name from Profile where Name = :profile];
            
            newUser = new User(Alias = 'test',
                   Email = 'one@test.sbsa.co.za',
                   Emailencodingkey = 'UTF-8',
                   Lastname = profile + ' User',
                   Languagelocalekey = 'en_US',
                   City = 'Johannesburg',
                   Country = 'South Africa',
                   Division__c = 'Barclays',
                   BRID__c = String.valueOf(Math.random()).left(9),
                   Localesidkey = 'en_US',
                   Profileid = userProfile.Id,
                   Timezonesidkey = 'America/Los_Angeles',
                   Username = username,
                   Can_Approve_Spend_Schedules__c = true
           );
        } 
        catch(Exception e) 
        {
            system.assertEquals('List has no rows for assignment to SObject Profile', e.getMessage());
        }
        return newUser;
    } 
}