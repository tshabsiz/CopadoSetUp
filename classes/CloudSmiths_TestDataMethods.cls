/**
*** CHANGE LOG ***

30/11/2017 - TdB    - Created Class.

**/ 

public with sharing class CloudSmiths_TestDataMethods 
{
	//Test Data Size
    public static Integer testDataSize = 20;
    
    //Record Types  
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();  
    public static Map <String, Schema.RecordTypeInfo> mapContactRecordTypes = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();  
    public static Map <String, Schema.RecordTypeInfo> mapConditionRecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapConditionOccRecordTypes = Condition_Occurrence__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapNotificationGroupRecordTypes = Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapConditionTemplateRecordTypes = Condition_Template__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapDrawdownRecordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapAgreementRecordTypes = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName();

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
    
    //User
    public static User getTestUser(string profile, string username)
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
    
    //Relationship (Account)
    public static Account getTestRelationship(String recordTypeName) 
    {
        Account testAccount = new Account
        (
            Name = generateRandomString(6), 
            Type = 'Client',
            Financial_Year_End__c = Date.today().addDays(5),
            SDS__c = 'test',
            RecordTypeId = mapAccountRecordTypes.get(recordTypeName).getRecordTypeId()
        );
        return testAccount;
    }  
    
    //Contact
    public static Contact getTestContact(Account relatedAccount, String recordTypeName) 
    {
        Contact testContact = new Contact
        (
            AccountId=relatedAccount.id, 
            FirstName=generateRandomString(4),
            LastName=generateRandomString(4), 
            email=generateRandomString(4)+'@'+generateRandomString(4)+'.com'
        );
        return testContact;
    }  
    
    //Matter/Deal
    public static advpm__Matter__c getTestMatterDeal(Account relatedAccount, String recordTypeName) 
    {
        advpm__Matter__c testMatterDeal = new advpm__Matter__c 
        (
            advpm__Primary_Account__c = relatedAccount.id,
            Name = 'Test',
            Standard__c = true,
            advpm__Status__c = 'Open',
            advpm__Type__c='Syndicated',
            Start_Date__c = date.today(),
            RecordTypeId = mapMatterRecordTypes.get(recordTypeName).getRecordTypeId(),
            Division__c = 'CIB',
            Coverage_Area__c = 'Corporate Banking',
            Product_Area__c = 'Corporate Finance',
            //Product2__c = TestProductLevel2.Id,
            OwnerId = UserInfo.getUserId()
        );
        return testMatterDeal;
    }  
    
    //Agreement
    public static Agreement__c getTestAgreement(advpm__Matter__c relatedMatterDeal, String recordTypeName) 
    {
        Agreement__c testAgreement = new Agreement__c
        (
            Matter_Deal__c =  relatedMatterDeal.id,
            Name = 'Test',
            //Agreement_Type__c =    TestProductAgreement.id,
            //Product__c = TestProductLevel2.id,
            Signature_Date__c = Date.today().addDays(5),
            Effective_Date__c = Date.today().addDays(5),
            recordTypeID = mapAgreementRecordTypes.get(recordTypeName).getRecordTypeId(),
            Limit__c = 10000
        );
        return testAgreement;
    }  
    
    //Condition
    public static Condition__c getTestCondition(advpm__Matter__c relatedMatterDeal, Agreement__c relatedAgreement, String recordTypeName) 
    {
       Condition__c testCondition = new Condition__c 
        (
            Name = 'TestCon',
            Agreement__c =   relatedAgreement.id,
            Clause__c = 'Test',
            Recurrence__c = 'Once Off',
            Due_Date__c = date.today(),
            Active__c = false,
            Matter__c =  relatedMatterDeal.id,
            recordTypeID = mapConditionRecordTypes.get(recordTypeName).getRecordTypeId()            
        );
        return testCondition;
    }  
    
    //Participants
    public static advpm__Participant__c getTestParticipant(advpm__Matter__c relatedMatterDeal, User relatedUser, String recordTypeName) 
    {
       advpm__Participant__c testParticipant = new advpm__Participant__c
        (
            advpm__Matter__c = relatedMatterDeal.Id,
            Name = 'Part 1',
            advpm__Staff__c = relatedUser.Id,
            advpm__Role__c = 'Transaction Administration',
            RecordTypeId = mapParticipantRecordTypes.get(recordTypeName).getRecordTypeId()
        );
        return testParticipant;
    }  
    
    //Deal Party
    public static Deal_Party__c getTestDealParty(advpm__Matter__c relatedMatterDeal, Account relatedRelationship) 
    {
        Deal_Party__c testDealParty = new Deal_Party__c
        (
            Deal__c = relatedMatterDeal.id,
            Party_Type__c = 'Borrower',
            Relationship__c = relatedRelationship.id
            //Conditions_Monitored_By__c = TestParticipant1.Id            
        );
        return testDealParty;
    }  
    
     //Agreement Party
    public static Agreement_Party__c getTestAgreementParty(advpm__Matter__c relatedMatterDeal, Agreement__c relatedAgreement) 
    {
        Agreement_Party__c testAgreementParty = new Agreement_Party__c
        (
            Agreement__c = relatedAgreement.id,
            Deal_Party__c  = relatedMatterDeal.id,
            Lender_Amount__c = null               
        );
        return testAgreementParty;
    }  
    
    //Condition Party
    public static Condition_Party__c getTestConditionParty(Condition__c relatedCondition, Agreement__c relatedAgreement) 
    {
        Condition_Party__c testConditionPartyGC = new Condition_Party__c
        (
            Agreement_Party__c = relatedAgreement.id, 
            Condition__c   =  relatedCondition.id
            
        );
        return testConditionPartyGC;
    }  
    
    //Condition Occurrence
    public static Condition_Occurrence__c getTestConditionOccurence(Condition__c relatedCondition, Condition_Party__c relatedConditionParty, String recordTypeName) 
    {
        Condition_Occurrence__c testConditionOccurrence = new Condition_Occurrence__c 
        (
            Condition__c = relatedCondition.id,
            Status__c = 'New',
            Due_Date__c = date.today(),
            Condition_Party__c = relatedConditionParty.Id,
            RecordTypeId = mapConditionOccRecordTypes.get(recordTypeName).getRecordTypeId()
        );
        return testConditionOccurrence;
    } 
    
    //Collateral
    public static Collateral__c getTestCollateral(Account relatedAccount) 
    {
        Collateral__c testCollateral = new Collateral__c
        (
            Name = 'Test Collateral',
            Status__c = 'Outstanding',
            Scope__c = 'Beneficiary',
            //Beneficiary__c = TestAccount.Id,
            Account__c = relatedAccount.Id
            //Collateral_Type1__c = TestCollateralType.id,
            //Collateral_Group__c = TestCollateralGroup.id
        );
        return testCollateral;
    } 
    
    //Facility
    public static Facility__c getTestFacility(Agreement__c relatedAgreement, String recordTypeName) 
    {
        Facility__c testFacility = new Facility__c 
        (
            Name = 'Test Agreement Facility',
            Facility_Type__C = 'Term Loan',
            Facility_Limit__c = 500,
            Agreement__c = relatedAgreement.Id
        );
        return testFacility;
    } 
    
    //Facility Tranche
    public static Facility_Tranche__c getTestFacilityTranche (Facility__c relatedFacility, String recordTypeName) 
    {
        Facility_Tranche__c testFacilityTranche = new Facility_Tranche__c 
        (
            Name = 'Test Facility Tranche',
            Tranche_Type__C = 'Term Loan',
            Tranche_Limit__C = 500,
            Facility__c = relatedFacility.Id
        );
        return testFacilityTranche;
    } 
    
    //Facility Tranche
    public static Distribution_Group__c getTestDistributionGroup (String groupType) 
    {
         Distribution_Group__c testDistroGroupPublic = new Distribution_Group__c
        (
            Name = 'PublicDistro',
            Description__c = 'Blah Blah',
            Email_Address__c = 'public@cloudsmiths.co.za',
            Group_Type__c = groupType
        );
        return testDistroGroupPublic;
    } 
    
    //Drawdown
    public static Drawdown__c getTestDrawdown (Agreement__c relatedAgreement, String recordTypeName) 
    {
         Drawdown__c testDrawdown = new Drawdown__c
        (
            Name = 'TestDown', 
            Agreement__c = relatedAgreement.Id,
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
        return testDrawdown;
    } 
    
    //Fit To Lend
    public static Fit_To_Lend_Checklist__c getTestFitToLendChecklist (advpm__Matter__c relatedMatterDeal) 
    {
        Fit_To_Lend_Checklist__c testFitToLend = new Fit_To_Lend_Checklist__c 
        (
            Deal__c = relatedMatterDeal.Id,
            Status__c = 'New'
        );        
        return testFitToLend;
    }
    
    //Agency Transfer
    public static Agency_Transfer__c getTestAgencyTransfer (Agreement__c relatedAgreement) 
    {
        Agency_Transfer__c testAgencyTransfer = new Agency_Transfer__c
        (
            Agreement__c = relatedAgreement.Id,
            Transfer_Fee__c = true
        );       
        return testAgencyTransfer;
    } 
    
    //Margin Ratchet
    public static Margin_Ratchet__c getTestMarginRatchet (Agreement__c relatedAgreement, advpm__Matter__c relatedMatterDeal, String marginRatchetType) 
    {
        Margin_Ratchet__c testMarginRatchet = new Margin_Ratchet__c 
        (
            Name = 'Test Facility Tranche',
            Type__c = marginRatchetType,
            Agreement__c = relatedAgreement.id,
            Matter_Deal__c = relatedMatterDeal.id
        );     
        return testMarginRatchet;
    } 
    
    //Margin Ratchet Condition
    public static Margin_Ratchet_Conditions__c getTestMarginRatchetCondition (Margin_Ratchet__c relatedMarginRatchet, Condition__c relatedCondition) 
    {
        Margin_Ratchet_Conditions__c testMarginRatchetConditions = new Margin_Ratchet_Conditions__c 
        (
            Condition__c = relatedCondition.id,
            Margin_Ratchet__c = relatedMarginRatchet.id
        );    
        return testMarginRatchetConditions;
    } 
    
    //Collateral Valuation
    public static Collateral_Valuation__c getTestCollateralValuation (Agreement__c relatedAgreement, advpm__Matter__c relatedMatterDeal, Collateral__c relatedCollateral) 
    {
        Collateral_Valuation__c testCollateralValuation = new Collateral_Valuation__c 
        (
            Name = 'Test Collateral Monitoring 1',
            Collateral__c = relatedCollateral.id,
            Agreement__c = relatedAgreement.id,
            Deal__c = relatedMatterDeal.id,
            Days__c = '	Days After',
            Frequency__c = 'Monthly',
            Number_of_Days__c = 2,
            Relative_Date__c = 'Effective Date'
        ); 
        return testCollateralValuation;
    } 
    
    //Collateral Monitoring
    public static Collateral_Monitoring__c getTestCollateralMonitoring (Agreement__c relatedAgreement, advpm__Matter__c relatedMatterDeal, Collateral__c relatedCollateral) 
    {
        Collateral_Monitoring__c testCollateralMonitoring = new Collateral_Monitoring__c 
        (
            Name = 'Test Collateral Monitoring 1',
            Collateral__c = relatedCollateral.id,
            Agreement__c = relatedAgreement.id,
            Deal__c = relatedMatterDeal.id,
            Days__c = '	Days After',
            Frequency__c = 'Monthly',
            Number_of_Days__c = 2,
            Relative_Date__c = 'Effective Date'
        );
        return testCollateralMonitoring;
    } 
    
     //Relationship Party
    public static Relationship_Parties__c getTestRelationshipParty (Margin_Ratchet__c relatedMarginRatchet,Agreement_Party__c relatedAgreementParty ) 
    {
         Relationship_Parties__c testRelationshipParties = new Relationship_Parties__c 
        (
            Agreement_Party__c = relatedAgreementParty.id,
            Margin_Ratchet__c = relatedMarginRatchet.id
            
        );
        return testRelationshipParties;
    } 
}