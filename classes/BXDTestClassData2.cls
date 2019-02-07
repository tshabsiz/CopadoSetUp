/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist
 * 
 * */
public class BXDTestClassData2 {
                  
    
    Public static void Cloudsmiths_TestDataClass() 
    {
        //USER RECORD
    Integer testDataSize = 10;
    Map <String, Schema.RecordTypeInfo> mapContactRecordTypes = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();    
    Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();    
    Map <String, Schema.RecordTypeInfo> mapCaseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName();    
    Map <String, Schema.RecordTypeInfo> mapConditionRecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
    Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    DateTime todaysDate_nextMonth = System.now().addMonths(1);
    
    Account                         TestAccount;
    Id                          TestpricebookId;
    TMG_Product_Level_1__c       TestProductLevel1;
    TMG_Product_Level_2__c       TestProductLevel2;
    TMG_Product_Level_3__c       TestProductLevel3;
    
    //Product2                    TestProduct2;
    //Product_Level_2__c          TestProductLevel2;
    PricebookEntry              TestPricebookEntry;
    Agreement_Template__c       TestAgreementTemplate;
    Product_Agreement__c        TestProductAgreement;
    advpm__Matter__c            TestMatter;
    Agreement__c                TestAgreement;
    Condition__c                testCondition;
    Condition__c                    testConditionGC;
    Deal_Party__c               TestDealParty;
    Agreement_Party__c          TestAgreementParty;
    Condition_Party__c          TestConditionParty;
    List<Condition__c>          TestConditionList;
    Collateral_Type__c          TestCollateralType;
    Collateral_Group__c         TestCollateralGroup;
    Collateral__c                TestCollateral;
    Collateral_Relationship__c   TestCollateralRelationship;
    advpm__Participant__c        TestParticipant1;
    advpm__Participant__c        TestParticipant2;
    advpm__Participant__c        TestParticipant3;
    User        TestUser;
        TestUser = createUser('Barclays Standard User','AdvoUser@fakeddomain11235z.co.za');
        insert TestUser;
        
        //CUSTOM SETTING
        ConditionSchedulingSettings__c TestConditionSchedulingSetting  = new ConditionSchedulingSettings__c
        (
            name = 'Default' ,
            Business_Hours__c = 'Monday to Friday 07:30 - 17:00',
            Months_In_Advance__c  = 12
        );
        insert TestConditionSchedulingSetting;
        
        TestConditionList = new List<Condition__c>(); 
        
        System.debug('TestAccount : '+ TestAccount); 
        TestAccount = new Account
        (
            SDS__c = 'FAKECODE',
            Type = 'Client',
            Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
            RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId()
        );
        TestAccount.name = Cloudsmiths_TestDataClass.generateRandomString(20);
        Insert TestAccount;
        
        TestpricebookId = Test.getStandardPricebookId();
        
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
        
        /*TestProduct2 = new Product2
            (
                Name = 'Corporate Finance',
                ProductCode = 'Pro-X',
                isActive = true
            );
        insert TestProduct2;
        
        TestProductLevel2 =  new Product_Level_2__c
            (
                Name = 'SUB100',
                Active__c = true,
                Product__c = TestProduct2.id
            );
        insert TestProductLevel2;
        
        TestPricebookEntry = new PricebookEntry
            (
                Pricebook2Id = TestpricebookId,
                Product2Id = TestProduct2.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
        insert TestPricebookEntry;*/
        
        TestAgreementTemplate = new Agreement_Template__c
            (
                Name = 'Test'
            );  
        insert TestAgreementTemplate;
        
        TestProductAgreement = new Product_Agreement__c
            (
                Name = 'Test',
                Agreement_Template__c = TestAgreementTemplate.id,
                TMG_Product_Level_3__c= TestProductLevel3.id
            );
        insert TestProductAgreement;
        
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
                TMG_Product_Level_1__c= TestProductLevel1.id,
                TMG_Product_Level_2__c= TestProductLevel2.id,
                TMG_Product_Level_3__c= TestProductLevel3.id
            );
        
        Insert TestMatter;
        TestAgreement = new Agreement__c
            (
                Matter_Deal__c =  TestMatter.id,
                Name = 'Test',
                Agreement_Type__c =    TestProductAgreement.id,
                TMG_Product_Level_3__c= TestProductLevel3.id,
                Signature_Date__c = Date.today().addDays(5),
                Effective_Date__c = Date.today().addDays(5)
            );
        Insert TestAgreement;
        
        TestDealParty = new Deal_Party__c
            (
                Deal__c = TestMatter.id,
                Party_Type__c = 'Borrower',
                Relationship__c = testAccount.id
                
            );
        Insert TestDealParty;
        
        TestAgreementParty = new Agreement_Party__c
            (
                Agreement__c = TestAgreement.id,
                Deal_Party__c  = TestDealParty.id
                
            );
        Insert TestAgreementParty;
        
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
        Insert testCondition;
        
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
        Insert testConditionGC;
        
        //CONDITION PARTY
        TestConditionParty = new Condition_Party__c
        (
            Agreement_Party__c = TestAgreementParty.id, 
            Condition__c   =  testCondition.id
            
        );
        insert TestConditionParty;
        
        Condition_Occurrence__c TestConditionOccurrence = new Condition_Occurrence__c(
            Condition_Party__c=TestConditionParty.id,
            Condition__c = testConditionGC.id,
            name= 'KYC',
            Comments__c='Comments',
            Supporting_Documentation_Uploaded__c=true,
            Box_Documents_Uploaded__c = true
        );

        try 
        {

            insert TestConditionOccurrence;

        } catch(Exception error) 
        {

            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assert(error.getMessage().contains('Please uploaded all supporting documentation'));
        }
            
        TestConditionList.add(testCondition);
        System.debug('TestAccount : '+ TestAccount);
        
        //Collateral Group
        TestCollateralGroup =  new Collateral_Group__c
            (
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
        
        //COLLATERAL
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
            Relationship_Type__c = 'Beneficiary'
        );
        insert TestCollateralRelationship;

        System.debug('TEST DATA:  User: '+TestUser);

        //PARTICIPANTS
        List<advpm__Participant__c> testParticipants = new List<advpm__Participant__c>();
        TestParticipant1 = new advpm__Participant__c(
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
            advpm__Role__c = 'Legal',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant2);

        TestParticipant3 = new advpm__Participant__c(
            advpm__Matter__c = TestMatter.Id,
            Name = 'Part 3',
            advpm__Staff__c = TestUser.Id,
            advpm__Role__c = 'Product',
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
        testParticipants.add(TestParticipant3);
        insert testParticipants;
    }

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
                               Username = username);
        } 
        Catch(Exception e) 
        {
            system.assertEquals('List has no rows for assignment to SObject Profile', e.getMessage());
        }
        return newUser;
    } 
}