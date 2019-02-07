/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist 
 * 
 * */
@isTest
public class BxdDocumentTestData
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
    public static Map <String, Schema.RecordTypeInfo> mapSPVItemRecordTypes = SPV_Items__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    
    public Account                      TestAccount;
    public Id                           TestpricebookId;
    public TMG_Product_Level_1__c       TestProductLevel1;
    public TMG_Product_Level_2__c       TestProductLevel2;
    public TMG_Product_Level_3__c       TestProductLevel3;
    //public Product2                     TestProduct2;
    //public Product_Level_2__c           TestProductLevel2;
    public PricebookEntry               TestPricebookEntry;
    public Agreement_Template__c        TestAgreementTemplate;
    public Product_Agreement__c         TestProductAgreement;
    public advpm__Matter__c             TestMatter;
    public Agreement__c                 TestAgreement;
    public Condition__c                 testConditionGC;
    public Condition__c                 testConditionFC;
    public Deal_Party__c                TestDealParty;
    public Agreement_Party__c           TestAgreementParty;
    public Condition_Party__c           TestConditionParty;
    public Condition_Occurrence__c      TestConditionOcc;
    public Collateral_Type__c           TestCollateralType;
    public Collateral_Group__c          TestCollateralGroup;
    public Collateral__c                TestCollateral;
    public Collateral_Relationship__c   TestCollateralRelationshipBorrower;
    public Collateral_Relationship__c   TestCollateralRelationshipIssuer;
    public Collateral_Relationship__c   TestCollateralRelationshipProvider;
    public Collateral_Relationship__c   TestCollateralRelationshipBeneficiary;
    public Collateral_Relationship__c   TestCollateralRelationshipNothing;
    public Drawdown__c                  TestDrawdown;
    public SPV_Items__c                 TestSPVItem;
    
    public BxdDocumentTestData()
    {
        DateTime todaysDate_nextMonth = System.now().addMonths(1);
        BXDtesclassdata.setupBoxFolder();        
        //CUSTOM SETTING
        ConditionSchedulingSettings__c TestConditionSchedulingSetting  = new ConditionSchedulingSettings__c
            (
                name = 'Default' ,
                Business_Hours__c = 'Monday to Friday 07:30 - 17:00',
                Months_In_Advance__c  = 12
            );
        insert TestConditionSchedulingSetting;
        
         //PRODUCT - Level 1
        TestProductLevel1 = new TMG_Product_Level_1__c
        (
            Name = 'Corporate Banking',
            Active__c = true
        );
        insert TestproductLevel1;
        
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
        
        /*//PRODUCT        
        TestProduct2 = new Product2
            (
                Name = 'Corporate Finance',
                ProductCode = 'Pro-X',
                isActive = true
            );
        insert TestProduct2;
        
        //PRODUCT LEVEL 2
        TestProductLevel2 =  new Product_Level_2__c
            (
                Name = 'SUB100',
                Active__c = true,
                Product__c = TestProduct2.id
            );
        insert TestProductLevel2;
        
        //PRICEBOOK ENTRY
        TestpricebookId = Test.getStandardPricebookId();
        TestPricebookEntry = new PricebookEntry
            (
                Pricebook2Id = TestpricebookId,
                Product2Id = TestProduct2.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
        insert TestPricebookEntry;*/
        
        //ACCOUNT
        TestAccount = new Account();
        TestAccount.Name = generateRandomStringBlob();
        TestAccount.Type = 'Client';
        TestAccount.SDS__c = 'SDS';
        TestAccount.Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM');
        TestAccount.RecordTypeId = mapAccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId();
        insert TestAccount;
        
        //MATTER
        
        Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
        Insert BusinessUnit;
        
        TestMatter = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
                Division__c = 'CIB',
                TMG_Product_Level_1__c = TestProductLevel1.id,
                TMG_Product_Level_2__c= TestProductLevel2.id,
                TMG_Product_Level_3__c= TestProductLevel3.id);
        Insert TestMatter;
        
        //DEAL PARTY
        TestDealParty = new Deal_Party__c();
        TestDealParty.Deal__c = TestMatter.Id;
        TestDealParty.Party_Type__c = 'Borrower';
        TestDealParty.Relationship__c = TestAccount.Id;
        Insert TestDealParty;
        
        //AGREEMENT
        TestAgreementTemplate = new Agreement_Template__c();
        TestAgreementTemplate.Name = 'Test Template Agreement';
        insert TestAgreementTemplate;
        
        TestProductAgreement = new Product_Agreement__c();            
        TestProductAgreement.Name = 'Product Agreement';
        TestProductAgreement.Agreement_Template__c = TestAgreementTemplate.id;
        TestProductAgreement.TMG_Product_Level_3__c= TestProductLevel3.id;
        insert TestProductAgreement;
        
        TestAgreement = new Agreement__c();    
        TestAgreement.Matter_Deal__c =  TestMatter.Id;
        TestAgreement.Name = 'Agreement Test';
        TestAgreement.Agreement_Type__c =  TestProductAgreement.id;
        TestAgreement.TMG_Product_Level_3__c = TestProductLevel3.id;
        TestAgreement.Signature_Date__c = Date.today().addDays(5);
        TestAgreement.Effective_Date__c = Date.today().addDays(5);
        TestAgreement.Limit__c = 10000;
        insert TestAgreement;
        
        
        TestAgreementParty = new Agreement_Party__c();
        TestAgreementParty.Agreement__c = TestAgreement.id;
        TestAgreementParty.Deal_Party__c  = TestDealParty.Id;
        Insert TestAgreementParty;
        
        //CUSTOM FRUP GC
        Custom_FRUP__c frupCondGC = new Custom_FRUP__c 
            (
                CustomKey__c = TestAgreement.Id + ' - ' + 'Governance Check',
                FolderId__c = '7',
                ParentFolderId__c = '0'
            );
        Insert frupCondGC;
        
        //CONDITION
        testConditionGC = new Condition__c();
        testConditionGC.Name = 'Condition GCC';
        testConditionGC.Agreement__c =   TestAgreement.Id;
        testConditionGC.Clause__c = 'Test';
        testConditionGC.Recurrence__c = 'Once Off';
        testConditionGC.Due_Date__c = date.today();
        testConditionGC.Active__c = false;
        testConditionGC.Matter__c =  TestMatter.Id;
        testConditionGC.recordTypeID = mapConditionRecordTypes.get('Governance Check').getRecordTypeId();
        insert testConditionGC;
        
        TestConditionParty = new Condition_Party__c();
        TestConditionParty.Agreement_Party__c = TestAgreementParty.Id; 
        TestConditionParty.Condition__c   =  testConditionGC.Id;
        insert TestConditionParty;
        
        //CUSTOM FRUP GC
        Custom_FRUP__c frupCondFC = new Custom_FRUP__c 
            (
                CustomKey__c = TestAgreement.Id + ' - ' + 'Financial Covenant',
                FolderId__c = '8',
                ParentFolderId__c = '0'
            );
        Insert frupCondFC;
        
        testConditionFC = new Condition__c();
        testConditionFC.Name = 'Condition Test Name';
        testConditionFC.Agreement__c = TestAgreement.Id;
        testConditionFC.Clause__c = 'Test';
        testConditionFC.Recurrence__c = 'Once Off';
        testConditionFC.Due_Date__c = date.today();
        testConditionFC.Active__c = false;
        testConditionFC.Matter__c =  TestMatter.Id;
        testConditionFC.Margin_Ratchet__c = true;
        testConditionFC.Threshold_Type__c = 'Base';
        testConditionFC.Threshold_Category__c = 'Multiple';          
        testConditionFC.Threshold_Comparator__c = 'equals';
        testConditionFC.Source__c = 'Manual';
        testConditionFC.Required_Base_Multiple__c = 2;
        testConditionFC.recordTypeID = mapConditionRecordTypes.get('Financial Covenant').getRecordTypeId();
        insert testConditionFC;
        
        Condition_Party__c TestConditionParty = new Condition_Party__c();
        TestConditionParty.Agreement_Party__c = TestAgreementParty.Id; 
        TestConditionParty.Condition__c   =  testConditionFC.id;
        insert TestConditionParty;
        
        TestConditionOcc = new  Condition_Occurrence__c();
        TestConditionOcc.Name = 'Test Occ Name';
        TestConditionOcc.Status__c = 'New';
        TestConditionOcc.Due_Date__c = date.today();
        TestConditionOcc.Condition__c = testConditionFC.Id;
        TestConditionOcc.Required_Base_Multiple_Num__c = 2;
        TestConditionOcc.Condition_Party__c = TestConditionParty.Id;
        TestConditionOcc.recordTypeID = mapConditionOccRecordTypes.get('Financial Covenant').getRecordTypeId(); 
        insert TestConditionOcc;
        
        //DRAWDOWN
        TestDrawdown = new Drawdown__c(
            Name = 'TestDown', 
            Agreement__c = TestAgreement.Id,
            Status__c = 'Governance and Documentation Check  Incomplete',
            Advance_Amount__c = 100,
            Current_Utilisation__c = 50,
            Facility_Limit__c = 200,
            Account_Name__c = 'Name Account',
            Account_Number__c = '123',
            Account_Branch__c = '123', 
            Account_Bank__c = 'Test Bank Acc',
            Advance_Date__c = Date.today(),
            Reference__c = 'Blah blah',
            Request_Date__c = Date.today(),
            Borrower__c = TestAgreementParty.Id
        );
        insert TestDrawdown;
        
        //COLLATERAL GROUP
        TestCollateralGroup = new Collateral_Group__c
            (
                Name = 'AVIATION BOND',
                Credit_Code__c = 'AVIATION_BOND'
            );
        insert TestCollateralGroup;
        
        //COLLATERAL TYPE
        TestCollateralType = new Collateral_Type__c
            (
                Name = 'AVIATION BOND',
                Collateral_Group__c = TestCollateralGroup.Id,
                Credit_Code__c = 'AVIATION_BOND',
                Push_to_ACM__c = true
            );
        Insert TestCollateralType;
            
        //COLLATERAL
        TestCollateral = new Collateral__c
            (
                Scope__c = 'Beneficiary',
                Name = 'Collateral Test',
                Status__c = 'Outstanding',
                Beneficiary__c = TestAccount.Id,
                Account__c = TestAccount.Id,
                Collateral_Group__c = TestCollateralGroup.Id,
                Collateral_Type1__c = TestCollateralType.Id
            );
        insert TestCollateral;
        
        //COLLATERAL RELATIONSHIP        
        TestCollateralRelationshipBeneficiary = new Collateral_Relationship__c
            (
                Collateral__c = TestCollateral.Id,
                Relationship__c = TestAccount.Id,
                Relationship_Type__c = 'Provider'
            );
        insert TestCollateralRelationshipBeneficiary;
        
        TestCollateralRelationshipProvider = new Collateral_Relationship__c
            (
                Collateral__c = TestCollateral.Id,
                Relationship__c = TestAccount.Id,
                Relationship_Type__c = 'Beneficiary'
            );
        insert TestCollateralRelationshipProvider;
        
        TestCollateralRelationshipNothing = new Collateral_Relationship__c
            (
                Collateral__c = TestCollateral.Id,
                Relationship__c = TestAccount.Id
            );
        insert TestCollateralRelationshipNothing; 
        
        //SPV
        System.debug('***# '+mapSPVItemRecordTypes);
        TestSPVItem = new SPV_Items__c(
            Name = 'TestSPV', 
            RecordTypeId = mapSPVItemRecordTypes.get('Note').getRecordTypeId(),
            Agreement__c = TestAgreement.Id
        );
        insert TestSPVItem;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public static String generateRandomStringBlob() {
        Integer length = 10;
        String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
        return key.substring(0, length);
    }
}