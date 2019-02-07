/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist
 * 
 * */
@isTest
public class BoxDocumentViewHelper_test {
    public static Id AccountId ;
    public static Id DealId ;
    public static Id DealPartyId ;
    public static Id AgreementId ;
    public static Id AgreementPartyId ;
    public static Id TestpricebookId;
    public static Id ConditionId;
    public static Id ConditionPartyId;
    public static Id BxdId;
    public static Id ConditionOccId;
    public static Id ProductLevel2Id;
    public static BoxDocument__c boxDocument;
    public static TMG_Product_Level_1__c TestProductLevel1;
    public static TMG_Product_Level_2__c TestProductLevel2;
    public static TMG_Product_Level_3__c TestProductLevel3;
    public static PricebookEntry TestPricebookEntry;
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> mapConditionRecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapConditionOccRecordTypes = Condition_Occurrence__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static void createAccountDeal()
    {
        createProduct(); 
		DateTime todaysDate = System.now().addMonths(1);
        Account acc = new Account();
        acc.Name = generateRandomString(6);
        acc.Type = 'Client';
        acc.Financial_Year_End_Month__c = todaysDate.format('MMMM');
        acc.RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
        insert Acc;
        AccountId = Acc.Id;
        advpm__Matter__c Deal = new advpm__Matter__c();
        Deal.advpm__Primary_Account__c = Acc.id;
        Deal.Name = generateRandomString(6);
        Deal.Standard__c = true;
        Deal.advpm__Status__c = 'Open';
        Deal.advpm__Type__c='Syndicated';
        Deal.Start_Date__c = date.today();
        Deal.RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId();
        Deal.Division__c = 'CIB';
        Deal.TMG_Product_Level_1__c = TestProductLevel1.id;
        Deal.TMG_Product_Level_2__c = TestProductLevel2.id;
        Deal.TMG_Product_Level_3__c = ProductLevel2Id;
        insert Deal;

          DealId =  Deal.Id;
        
        Deal_Party__c TestDealParty = new Deal_Party__c();
        TestDealParty.Deal__c = DealId;
        TestDealParty.Party_Type__c = 'Borrower';
        TestDealParty.Relationship__c = AccountId;
        Insert TestDealParty;
        DealPartyId = TestDealParty.Id;
        
    }
    
     public static void createBxd()
     {
         
        BoxDocument__c bxd = new BoxDocument__c();
        bxd.PII__c = 'Yes';
        //bxd.Drawdown__c
        bxd.Expiry_Date__c = Date.today().addDays(15);
        //bxd.ParentName__c
        //bxd.Account__c
        bxd.Matter__c = DealId;
        //bxd.Agreement__c
        //bxd.Collateral__c
        //bxd.Condition_Occurrence__c
       // bxd.Condition__c
        bxd.Owner_Type__c = 'advpm__Matter__c';
        //bxd.Document_Number__c
        bxd.Name= 'Test Box Document';
        bxd.Type__c = 'Legal Opinion';
        bxd.Status__c = 'Final';
        bxd.Box_Location__c = 'http://test.box.com/123456789'; 
        bxd.Box_Unique_Id__c = generateRandomString(6);
        insert bxd;
        
        boxDocument = bxd;
        BxdId = bxd.Id;
    }
    
    public static void createCustomSettings()
    {    
        ConditionSchedulingSettings__c TestConditionSchedulingSetting  = new ConditionSchedulingSettings__c();
        TestConditionSchedulingSetting.name = 'Default';
        TestConditionSchedulingSetting.Business_Hours__c = 'Monday to Friday 07:30 - 17:00';
        TestConditionSchedulingSetting.Months_In_Advance__c  = 12;
         insert TestConditionSchedulingSetting;
    }
    
    public static void createProduct()
    {
         //TestpricebookId = Test.getStandardPricebookId(); 

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

        /*Product2 TestProduct2 = new Product2();
        TestProduct2.Name = 'Corporate Finance';
        TestProduct2.ProductCode = 'Pro-X';
        TestProduct2.isActive = true;
        insert TestProduct2;
        
        TestPricebookEntry = new PricebookEntry();
        TestPricebookEntry.Pricebook2Id = TestpricebookId;
        TestPricebookEntry.Product2Id = TestProduct2.Id;
        TestPricebookEntry.UnitPrice = 100.00;
        TestPricebookEntry.IsActive = true;
        insert TestPricebookEntry;
        

        Product_Level_2__c TestProductLevel2 =  new Product_Level_2__c();
            TestProductLevel2.Name = 'SUB100';
        TestProductLevel2.Active__c = true;
        TestProductLevel2.Product__c = TestProduct2.id;
        insert TestProductLevel2;*/

        ProductLevel2Id = TestProductLevel3.Id;
    }
    
    public static void createAgreement()
    {
        Agreement_Template__c TestAgreementTemplate = new Agreement_Template__c();
        TestAgreementTemplate.Name = 'Test';
        insert TestAgreementTemplate;
        
        Product_Agreement__c TestProductAgreement = new Product_Agreement__c();            
        TestProductAgreement.Name = 'Test';
        TestProductAgreement.Agreement_Template__c = TestAgreementTemplate.id;
        TestProductAgreement.TMG_Product_Level_3__c = ProductLevel2Id;
        insert TestProductAgreement;
     
        Agreement__c TestAgreement = new Agreement__c();    
        TestAgreement.Matter_Deal__c =  DealId;
        TestAgreement.Name = 'Test';
        TestAgreement.Agreement_Type__c =  TestProductAgreement.id;
        TestAgreement.TMG_Product_Level_3__c = ProductLevel2Id;
        TestAgreement.Signature_Date__c = Date.today().addDays(5);
        TestAgreement.Effective_Date__c = Date.today().addDays(5);
        insert TestAgreement;
        AgreementId = TestAgreement.Id;
        
        
        Agreement_Party__c TestAgreementParty = new Agreement_Party__c();
        TestAgreementParty.Agreement__c = TestAgreement.id;
        TestAgreementParty.Deal_Party__c  = DealPartyId;
        Insert TestAgreementParty;
        AgreementPartyId = TestAgreementParty.Id;
        
    }
    public static void createCondition()
    {
        
    Condition__c testCondition = new Condition__c();
    testCondition.Name = 'TestCon';
    testCondition.Agreement__c =   AgreementId;
    testCondition.Clause__c = 'Test';
    testCondition.Recurrence__c = 'Once Off';
    testCondition.Due_Date__c = date.today();
    testCondition.Active__c = false;
    testCondition.Matter__c =  DealId;
    testCondition.recordTypeID = mapConditionRecordTypes.get('Governance Check').getRecordTypeId();
    insert testCondition;
    ConditionId = testCondition.Id;
    
    Condition_Party__c TestConditionParty = new Condition_Party__c();
    TestConditionParty.Agreement_Party__c = AgreementPartyId; 
    TestConditionParty.Condition__c   =  testCondition.id;
    insert TestConditionParty;
    ConditionPartyId = TestConditionParty.Id;
    
    
    }
    
    public static void createConditionFC()
    {
        
    Condition__c testCondition = new Condition__c();
    testCondition.Name = 'TestCon';
    testCondition.Agreement__c =   AgreementId;
    testCondition.Clause__c = 'Test';
    testCondition.Recurrence__c = 'Once Off';
    testCondition.Due_Date__c = date.today();
    testCondition.Active__c = false;
    testCondition.Matter__c =  DealId;
    testCondition.Margin_Ratchet__c = true;
    testCondition.Threshold_Type__c = 'Base';
    testCondition.Threshold_Category__c = 'Multiple';          
    testCondition.Threshold_Comparator__c = 'equals';
    testCondition.Source__c = 'Manual';
    testCondition.Required_Base_Multiple__c = 2;
    testCondition.recordTypeID = mapConditionRecordTypes.get('Financial Covenant').getRecordTypeId();
    insert testCondition;
    ConditionId = testCondition.Id;
    
    Condition_Party__c TestConditionParty = new Condition_Party__c();
    TestConditionParty.Agreement_Party__c = AgreementPartyId; 
    TestConditionParty.Condition__c   =  testCondition.id;
    insert TestConditionParty;
    ConditionPartyId = TestConditionParty.Id;
    
    
    }
    
    public static void createConditionOcc()
    {
       
      Condition_Occurrence__c ConditionOcc = new  Condition_Occurrence__c();
      ConditionOcc.Name = 'Bxd Conditon Occ';        
      ConditionOcc.Condition__c = ConditionId;
      insert ConditionOcc;
      
    }
       public static void createConditionOccFC()
    {
       
      Condition_Occurrence__c ConditionOcc = new  Condition_Occurrence__c();
      ConditionOcc.Name = 'Bxd Conditon Occ';
      ConditionOcc.Status__c = 'New';
      ConditionOcc.Due_Date__c = date.today();
      ConditionOcc.Condition__c = ConditionId;
      ConditionOcc.Required_Base_Multiple_Num__c = 2;
      ConditionOcc.Condition_Party__c = ConditionPartyId;
      ConditionOcc.recordTypeID = mapConditionOccRecordTypes.get('Financial Covenant').getRecordTypeId(); 
      insert ConditionOcc;
      ConditionOccId = ConditionOcc.Id;
    }
    @isTest static void viewTest()
    {
           createAccountDeal();
           createBxd();
           BoxDocument__c boxDocument = new BoxDocument__c();
           BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance(); 
           String Query = viewHelper.QueryCreator(BxdId);
           Test.startTest();
           boxDocument = Database.Query(Query);
           Test.stopTest();
           system.assert(boxDocument != null);          
    }
    @isTest static void listTest()
    {
           createAccountDeal();
           createBxd();
           BoxDocument__c boxDocument = new BoxDocument__c();
           BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance(); 
           String Query = viewHelper.QueryCreator(null,DealId,null);
           Test.startTest();
           boxDocument = Database.Query(Query);
           Test.stopTest();
           system.assert(boxDocument != null);          
    }
    @isTest static void listFiltered()
    {
           createAccountDeal();
           createBxd();
           RelatedListBxd boxRelatedList = new RelatedListBxd();
           boxRelatedList.filtered = true;
           boxRelatedList.sortField = 'Name';
           boxRelatedList.boxDocument.Name = 'Test Box Document';
           BoxDocument__c boxDocument = new BoxDocument__c();
           BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance(); 
           String Query = viewHelper.QueryCreator(null,DealId,boxRelatedList);
           Test.startTest();
           boxDocument = Database.Query(Query);
           Test.stopTest();
           system.assert(boxDocument != null);          
    }
    
    @isTest static void rollupTest()
    {
           BXDtesclassdata.setupFolder();
           createAccountDeal();
           createBxd();
           createAgreement();
           RelatedListBxd boxRelatedList = new RelatedListBxd();
           boxRelatedList.filtered = true;
           BoxDocument__c boxDocument = new BoxDocument__c();
           BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance(); 
           String Query = viewHelper.QueryCreator(null,AccountId,boxRelatedList);
           Test.startTest();
           
           boxDocument = Database.Query(Query);
           Test.stopTest();
           system.assert(boxDocument != null);          
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

          
 
}