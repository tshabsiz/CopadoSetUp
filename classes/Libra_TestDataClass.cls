/**
 * Created by Kyle Alexander on 2018/02/21.
 */

public class Libra_TestDataClass {
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> caseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> AccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> AgreementRecordTypes = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> agreementTemplateRecordTypeMap = Agreement_Template__c.sObjectType.getDescribe().getRecordTypeInfosByName();

    public Business_Unit__c testBusinessUnit;
    public advpm__Matter__c testMatter;
    public advpm__Matter__c testMarketTransactionMatter;
    public Account testAccount;
    public Product2 testProduct2;
    public Product_Level_2__c testProductLevel2;
    public Agreement_Template__c testAgreementTemplate;
    public Agreement_Template__c testIsdaAgreementTemplate;
    public Agreement_Template__c testGmslaAgreementTemplate;
    public Agreement_Template__c testGmraAgreementTemplate;
    public Agreement_Template__c testPrimeServicesAgreementTemplate;
    public Agreement_Template__c testCsaAgreementTemplate;
    public Product_Agreement__c testProductAgreement;
    public Agreement__c testAgreement;
    public Amendment__c testAmendment;
    public Supporting_Agreement__c testSupportingAgreement;
    public Deal_Party__c testDealParty;
    public Deal_Party__c testMTDealParty;           
    Public Deal_Party__c testDealPartyBB;
    Public Deal_Party__c testDealPartyCP;
    public Clause__c testClause;
    public Account testRelAccount;
    public Account testBankAccount;
    public Trade_Instrument__c testTradeInstrument;
    public Agreement_Trade_Instrument__c testAgreementTradeInstrument;
    public Agreement_Trade_Instrument__c testSuppAgreementTradeInstrument;
    public Netting_Group__c testNettingGroup;
    public NettingGroupBranch__c testNettingGroupBranchBB;
    public NettingGroupBranch__c testNettingGroupBranchCP;
    public NettingGroupBranch__c testNettingGroupBranchTI;
    
    public Netting_Group__c testNettingNovationGroup;
    public NettingGroupBranch__c testNettingNovationGroupBranchBB;
    public NettingGroupBranch__c testNettingNovationGroupBranchCP;
    public NettingGroupBranch__c testNettingNovationGroupBranchTI;
    
    public Netting_Group__c testNettingSettlementGroup;
    public NettingGroupBranch__c testNettingSettlementGroupBranchBB;
    public NettingGroupBranch__c testNettingSettlementGroupBranchCP;
    public NettingGroupBranch__c testNettingSettlementGroupBranchTI;

    public Libra_TestDataClass(){

        if(ConditionSchedulingSettings__c.getInstance('Default') == null)
        {
            ConditionSchedulingSettings__c TestConditionSchedulingSetting  = new ConditionSchedulingSettings__c(
                    name = 'Default',
                    Business_Hours__c = 'Monday to Friday 07:30 - 17:00',
                    Months_In_Advance__c  = 12.0
            );
            insert TestConditionSchedulingSetting;
        }

        //BUSINESS UNIT
        testBusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
        Insert testBusinessUnit;

        //MATTER
        testMatter = new advpm__Matter__c
        (
                Name='Matter Test',
                Business_Unit_Cluster_Segment__c=testBusinessUnit.id,
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Litigation Matter').getRecordTypeId()
        );
        Insert testMatter;

        //ACCOUNT
        testAccount = new Account();
        testAccount.RecordTypeId = AccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId();
        testAccount.Name ='Law 1';
        testAccount.BEE_Status__c = 'Level 1';
        testAccount.BO__c =  '5';
        testAccount.BWO__c = '25';
        Insert testAccount;

        Coverage_Country__c coverageCountry = new Coverage_Country__c();
        coverageCountry.Country__c = 'South Africa';
        insert coverageCountry;

        DateTime todaysDate_nextMonth = System.now().addMonths(1);

        //ACCOUNT BANK
        testBankAccount = new Account();
        testBankAccount.Name ='Absa';
        testBankAccount.Type = 'Client';
        testBankAccount.SDS__c = 'SDS';
        testBankAccount.Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM');
        testBankAccount.RecordTypeId = AccountRecordTypes.get('Prospect').getRecordTypeId();
        Insert testBankAccount;

        //ACCOUNT RELATIONSHIP
        testRelAccount = new Account();
        testRelAccount.Name ='ABSA TEST';
        testRelAccount.Type = 'Client';
         Integer length = 10;
        String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
        testRelAccount.SDS__c = key.substring(0, length);
        testRelAccount.Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM');
        testRelAccount.RecordTypeId = AccountRecordTypes.get('Prospect').getRecordTypeId();
        Insert testRelAccount;

        //MARKET TRANSACTION MATTER
        testMarketTransactionMatter = new advpm__Matter__c();
        testMarketTransactionMatter.Name='Market Transaction Test';
        testMarketTransactionMatter.RecordTypeId = mapMatterRecordTypes.get('Market Transaction').getRecordTypeId();
        testMarketTransactionMatter.Bank__c = testBankAccount.id;
        testMarketTransactionMatter.Relationship__c = testRelAccount.id;
        testMarketTransactionMatter.Relationship_Type_picklist__c = 'Asset Manager';
        testMarketTransactionMatter.Master_Agreement_Type__c = 'ISDA Agreement';
        testMarketTransactionMatter.Netting_Complete__c = true;
        Insert testMarketTransactionMatter;

        //PRODUCT
        testProduct2 = new Product2();
        testProduct2.name='Prod2';
        Insert testProduct2;

        //PRODUCT LEVEL 2
        testProductLevel2 = new Product_Level_2__c();
        testProductLevel2.Active__c = true;
        testProductLevel2.Product__c = testProduct2.id;
        Insert testProductLevel2;

        //AGREEMENT TEMPLATE
        List<Agreement_Template__c> agreementTemplateList = new List<Agreement_Template__c>();
        testAgreementTemplate = new Agreement_Template__c();
        testAgreementTemplate.name = 'Agreement template name';
        agreementTemplateList.add(testAgreementTemplate);
        
        //AGREEMENT TEMPLATE - ISDA
        testIsdaAgreementTemplate = new Agreement_Template__c(
            Template_Version__c = '2002 ISDA',
            Agreement_Type__c = 'ISDA Agreement',
            Clause_Origin__c = 'HotDocs',
            HotDocs_Template_ID__c = 'da20b17b-0486-42f6-8755-fb9becbf19e3',
            RecordTypeId = agreementTemplateRecordTypeMap.get('Agreement Template - Master').getRecordTypeId(),
            Name = 'Agreement template name');
        agreementTemplateList.add(testIsdaAgreementTemplate);
        
        //AGREEMENT TEMPLATE - GMSLA
        testGmslaAgreementTemplate = new Agreement_Template__c(
            Template_Version__c = '2010 GMSLA',
            Agreement_Type__c = 'GMSLA Agreement',
            Clause_Origin__c = 'HotDocs',
            HotDocs_Template_ID__c = '221ffe93-414a-437f-aaad-afc29a42364c',
            RecordTypeId = agreementTemplateRecordTypeMap.get('Agreement Template - Master').getRecordTypeId(),
            Name = 'Agreement template name');
        agreementTemplateList.add(testGmslaAgreementTemplate);
        
        //AGREEMENT TEMPLATE - GMRA
        testGmraAgreementTemplate = new Agreement_Template__c(
            Template_Version__c = '2011 GMRA',
            Agreement_Type__c = 'GMRA Agreement',
            Clause_Origin__c = 'HotDocs',
            HotDocs_Template_ID__c = '32201ded-5199-421c-9a21-3bb24c2d8ba9',
            RecordTypeId = agreementTemplateRecordTypeMap.get('Agreement Template - Master').getRecordTypeId(),
            Name = 'Agreement template name');
        agreementTemplateList.add(testGmraAgreementTemplate);
        
        //AGREEMENT TEMPLATE - Prime Services
        testPrimeServicesAgreementTemplate = new Agreement_Template__c(
            Template_Version__c = 'Collective Investment Scheme',
            Agreement_Type__c = 'Prime Services Agreement',
            Clause_Origin__c = 'HotDocs',
            HotDocs_Template_ID__c = 'd04bbf4b-efa2-4788-a10b-b1b58f38a1d9',
            RecordTypeId = agreementTemplateRecordTypeMap.get('Agreement Template - Master').getRecordTypeId(),
            Name = 'Agreement template name');
        agreementTemplateList.add(testPrimeServicesAgreementTemplate);
        
         //AGREEMENT TEMPLATE - CSA
        testCsaAgreementTemplate = new Agreement_Template__c(
            Template_Version__c = 'CSA',
            Agreement_Type__c = 'Supporting Agreement',
            Clause_Origin__c = 'HotDocs',
            HotDocs_Template_ID__c = '0898c3cc-8ed8-4ad2-aa30-d2c1e80ab8cd',
            RecordTypeId = agreementTemplateRecordTypeMap.get('Agreement Template - Master').getRecordTypeId(),
            Name = 'Credit Support Annex');
        agreementTemplateList.add(testCsaAgreementTemplate);
        
        insert agreementTemplateList;

        //PRODUCT AGREEMENT
        testProductAgreement = new Product_Agreement__c();
        testProductAgreement.Agreement_Template__c = testAgreementTemplate.id;
        testProductAgreement.Product__c = testProductLevel2.id;
        Insert testProductAgreement;

        //AGREEMENT
        testAgreement = new Agreement__c();
        testAgreement.Matter_Deal__c = testMarketTransactionMatter.id;
        testAgreement.Client_Name__c = testAccount.id;
        testAgreement.name = 'Agreement Name';
        testAgreement.Agreement_Description__c = 'Testing';
        testAgreement.ReviewDate__c = system.today();
        testAgreement.Limit__c = 5;
        testAgreement.Product__c = testProductLevel2.id;
        testAgreement.Master_Agreement_Required_Prior_to_First__c = true;
        //testAgreement.Break_Clause_days__c = 2;
        Insert testAgreement;

        //AMENDMENT
        testAmendment = new Amendment__c();
        testAmendment.Amendment_Reason__c = 'Test Reason';
        testAmendment.Amendment_Reason_Type__c = 'Other';
        testAmendment.Effective_date__c =  date.today();
        testAmendment.Name_of_Regulation__c = 'Rest Reg Name';
        testAmendment.Agreement__c = testAgreement.id;
        testAmendment.Amendment_Document_Uploaded__c = true;
        Insert testAmendment;

        //SUPPORTING AGREEMENT
        testSupportingAgreement = new Supporting_Agreement__c();
        testSupportingAgreement.Master_Agreement_Type__c = 'ISDA Agreement';
        testSupportingAgreement.Collateral_type__c = 'Bilateral';
        testSupportingAgreement.Transaction_Exposure_Calculation_Method__c = 'Method A';
        testSupportingAgreement.Valuation__c = 50;
        testSupportingAgreement.Valuation_Agent__c = 'Bank';
        testSupportingAgreement.Call_Frequency__c = 'Once Off';
        testSupportingAgreement.Supporting_Agreement_Type__c = 'CSA';
        testSupportingAgreement.Agreement__c = testAgreement.id;
        Insert testSupportingAgreement;

        //DEAL PARTY - Disclosed Principle
        testDealParty = new Deal_Party__c();
        testDealParty.Deal__c = testMatter.id;
        testDealParty.Relationship_Type__c = 'Disclosed Principal';
        testDealParty.Relationship__c = testBankAccount.id;
        insert testDealParty;
        
        //DEAL PARTY - Disclosed Principle
        testMTDealParty = new Deal_Party__c();
        testMTDealParty.Deal__c = testMarketTransactionMatter.id;
        testMTDealParty.Relationship_Type__c = 'Disclosed Principal';
        testMTDealParty.Relationship__c = testBankAccount.id;
        insert testMTDealParty;

        //DEAL PARTY - Bank Branch
        testDealPartyBB = new Deal_Party__c();
        testDealPartyBB.Deal__c = testMatter.id;
        testDealPartyBB.Relationship_Type__c = 'Bank Branch';
        testDealPartyBB.Relationship__c = testBankAccount.id;
        insert testDealPartyBB;

        //DEAL PARTY - Counterparty
        testDealPartyCP = new Deal_Party__c();
        testDealPartyCP.Deal__c = testMatter.id;
        testDealPartyCP.Relationship_Type__c = 'Counterparty';
        testDealPartyCP.Relationship__c = testBankAccount.id;
        insert testDealPartyCP;

        //CLAUSE
        testClause = new Clause__c();
        testClause.Clause_Name__c = 'Clause1';
        insert testClause;

        //TRADE INSTRUMENT
        testTradeInstrument = new Trade_Instrument__c();
        testTradeInstrument.Name = 'Bills';
        insert testTradeInstrument;

        //AGREEMENT TRADE INSTRUMENT - Supp Agreement
        testSuppAgreementTradeInstrument = new Agreement_Trade_Instrument__c();
        testSuppAgreementTradeInstrument.Supporting_Agreement__c = testSupportingAgreement.id;
        testSuppAgreementTradeInstrument.Trade_Instrument__c = testTradeInstrument.id;
        insert testSuppAgreementTradeInstrument;

        //AGREEMENT TRADE INSTRUMENT - Agreement
        testAgreementTradeInstrument = new Agreement_Trade_Instrument__c();
        testAgreementTradeInstrument.Agreement__c = testAgreement.id;
        testAgreementTradeInstrument.Trade_Instrument__c = testTradeInstrument.id;
        insert testAgreementTradeInstrument;

        //NETTING GROUP
        testNettingGroup = new Netting_Group__c();
        testNettingGroup.Matter_Deal__c = testMarketTransactionMatter.id;
        testNettingGroup.Netting_Type__c = 'Close Out';
        testNettingGroup.Net_Across_Bank__c = 'Yes';
        testNettingGroup.Net_Across_Counterparty__c = 'Yes';
        testNettingGroup.Netting_Strength__c = '1';
        testNettingGroup.Cross_Product__c = 'Netting Across all Products';
        insert testNettingGroup;

        //NETTING GROUP BRANCH - Bank
        testNettingGroupBranchBB = new NettingGroupBranch__c();
        testNettingGroupBranchBB.NettingGroup__c = testNettingGroup.id;
        testNettingGroupBranchBB.BranchType__c = 'Bank';
        testNettingGroupBranchBB.Relationship__c = testBankAccount.id;
        insert testNettingGroupBranchBB;

        //NETTING GROUP BRANCH - Counterparty
        testNettingGroupBranchCP = new NettingGroupBranch__c();
        testNettingGroupBranchCP.NettingGroup__c = testNettingGroup.id;
        testNettingGroupBranchCP.BranchType__c = 'Counterparty';
        testNettingGroupBranchCP.Relationship__c = testBankAccount.id;
        insert testNettingGroupBranchCP;

        //NETTING GROUP BRANCH - Trade Instrument
        testNettingGroupBranchTI = new NettingGroupBranch__c();
        testNettingGroupBranchTI.NettingGroup__c = testNettingGroup.id;
        testNettingGroupBranchTI.BranchType__c = 'Trade Instrument';
        testNettingGroupBranchTI.Trade_Instrument__c = testTradeInstrument.id;
        insert testNettingGroupBranchTI;
        
//--------------------------------------------------//
        
        //NETTING Novation GROUP
        testNettingNovationGroup = new Netting_Group__c();
        testNettingNovationGroup.Matter_Deal__c = testMarketTransactionMatter.id;
        testNettingNovationGroup.Netting_Type__c = 'Novation';
        testNettingNovationGroup.Net_Across_Bank__c = 'Yes';
        testNettingNovationGroup.Net_Across_Counterparty__c = 'Yes';
        testNettingNovationGroup.Netting_Strength__c = '1';
        testNettingNovationGroup.Cross_Product__c = 'Netting Across all Products';
        insert testNettingNovationGroup;

        //NETTING GROUP BRANCH - Bank
        testNettingNovationGroupBranchBB = new NettingGroupBranch__c();
        testNettingNovationGroupBranchBB.NettingGroup__c = testNettingNovationGroup.id;
        testNettingNovationGroupBranchBB.BranchType__c = 'Bank';
        testNettingNovationGroupBranchBB.Relationship__c = testBankAccount.id;
        insert testNettingNovationGroupBranchBB;

        //NETTING GROUP BRANCH - Counterparty
        testNettingNovationGroupBranchCP = new NettingGroupBranch__c();
        testNettingNovationGroupBranchCP.NettingGroup__c = testNettingNovationGroup.id;
        testNettingNovationGroupBranchCP.BranchType__c = 'Counterparty';
        testNettingNovationGroupBranchCP.Relationship__c = testBankAccount.id;
        insert testNettingNovationGroupBranchCP;

        //NETTING GROUP BRANCH - Trade Instrument
        testNettingNovationGroupBranchTI = new NettingGroupBranch__c();
        testNettingNovationGroupBranchTI.NettingGroup__c = testNettingNovationGroup.id;
        testNettingNovationGroupBranchTI.BranchType__c = 'Trade Instrument';
        testNettingNovationGroupBranchTI.Trade_Instrument__c = testTradeInstrument.id;
        insert testNettingNovationGroupBranchTI;
        
        //--------------------------------------------------//
        
        //NETTING Settlement GROUP
        testNettingSettlementGroup = new Netting_Group__c();
        testNettingSettlementGroup.Matter_Deal__c = testMarketTransactionMatter.id;
        testNettingSettlementGroup.Netting_Type__c = 'Settlement';
        testNettingSettlementGroup.Net_Across_Bank__c = 'Yes';
        testNettingSettlementGroup.Net_Across_Counterparty__c = 'Yes';
        testNettingSettlementGroup.Netting_Strength__c = '1';
        testNettingSettlementGroup.Cross_Product__c = 'Netting Across all Products';
        insert testNettingSettlementGroup;

        //NETTING GROUP BRANCH - Bank
        testNettingSettlementGroupBranchBB = new NettingGroupBranch__c();
        testNettingSettlementGroupBranchBB.NettingGroup__c = testNettingSettlementGroup.id;
        testNettingSettlementGroupBranchBB.BranchType__c = 'Bank';
        testNettingSettlementGroupBranchBB.Relationship__c = testBankAccount.id;
        insert testNettingSettlementGroupBranchBB;

        //NETTING GROUP BRANCH - Counterparty
        testNettingSettlementGroupBranchCP = new NettingGroupBranch__c();
        testNettingSettlementGroupBranchCP.NettingGroup__c = testNettingSettlementGroup.id;
        testNettingSettlementGroupBranchCP.BranchType__c = 'Counterparty';
        testNettingSettlementGroupBranchCP.Relationship__c = testBankAccount.id;
        insert testNettingSettlementGroupBranchCP;

        //NETTING GROUP BRANCH - Trade Instrument
        testNettingSettlementGroupBranchTI = new NettingGroupBranch__c();
        testNettingSettlementGroupBranchTI.NettingGroup__c = testNettingSettlementGroup.id;
        testNettingSettlementGroupBranchTI.BranchType__c = 'Trade Instrument';
        testNettingSettlementGroupBranchTI.Trade_Instrument__c = testTradeInstrument.id;
        insert testNettingSettlementGroupBranchTI;
    }
}