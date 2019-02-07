public class BXDtesclassdata {
    
    Public static void setupBase(){
        
        System.debug('### BXDtesclassdata : setupBase');
        
        Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
        Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
         Map <String, Schema.RecordTypeInfo> mapLookupRecordTypes = Lookup__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        TMG_Product_Level_1__c       TestProductLevel1;
        TMG_Product_Level_2__c       TestProductLevel2;
        TMG_Product_Level_3__c       TestProductLevel3;
        //Product2                    TestProduct2;
        //Product_Level_2__c          TestProductLevel2;
        PricebookEntry              TestPricebookEntry;
        Id                          TestpricebookId;
        Lookup__c                    TestLegalQuoteRequest;
        TestpricebookId = Test.getStandardPricebookId();

        //LEGAL QUOTE Details
        TestLegalQuoteRequest = new Lookup__c
        (
            User__c = UserInfo.getUserId(),
            RecordTypeId = mapLookupRecordTypes.get('Legal Quote Request').getRecordTypeId(),
            CurrencyISOCode = 'ZAR'      
        );
        insert TestLegalQuoteRequest;    
        
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
        
        Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
        Insert BusinessUnit;
        
        advpm__Matter__c Matter = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id, 
                                                       Standard__c = true,
                                                       advpm__Status__c = 'Open',
                                                       advpm__Type__c='Syndicated',
                                                       Start_Date__c = date.today(),
                                                       RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
                                                       Division__c = 'CIB',
                                                       TMG_Product_Level_1__c= TestProductLevel1.id,
                                                       TMG_Product_Level_2__c= TestProductLevel2.id ,
                                                       TMG_Product_Level_3__c= TestProductLevel3.id );
        Insert Matter;
        
        RecordType rt;
        rt = [SELECT id,Name,SobjectType FROM RecordType where name ='Legal Request' and SobjectType='Legal_Quote_Request__c' limit 1];
        
        Legal_Quote_Request__c  LegalQuoteRequest = new Legal_Quote_Request__c(RecordTypeId =rt.id,Matter__c=Matter.id, Matter_Difficulty__c='Low',Quote_Title__c='Title',Quote_Description__c='Description');
        Insert LegalQuoteRequest;
        
        Account acc= new Account(Approved__c=True);  //RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId()
        acc.name = Cloudsmiths_TestDataClass.generateRandomString(20);
        rt = [Select id,Name from RecordType Where Name = 'On/Off Panel Law Firm' limit 1]; 
        Acc.RecordTypeId =rt.id;
        Insert Acc;
        
        Contact Con = new Contact(AccountId=Acc.id, FirstName='John',LastName='Doe');
        Insert Con;
        
        
        Legal_Quote__c LegalQuote = new Legal_Quote__c(Legal_Quote_Request__c=LegalQuoteRequest.id,Panel_Type__c='On Panel',Law_Firm__c=Acc.id,Contact__c = Con.id,Box_Webhook__c='53',Quote_Recieved__c = false);
        Insert LegalQuote;
        //  Update LegalQuote;
        
        Custom_FRUP__c CustomFRUP = new Custom_FRUP__c(CustomKey__c = Matter.id);
        Insert CustomFRUP;
        
        String userId = UserInfo.getUserId();
        advpm__Matter_Legal_Hold_Acknowledgement__c Acknowledgement = new advpm__Matter_Legal_Hold_Acknowledgement__c(advpm__Matter__c =Matter.id,  advpm__Recipient__c= userId, advpm__Status__c ='Acknowledged' );    
        
        
        rt = [Select id,Name from RecordType Where Name = 'Agreement' limit 1]; 
        Acc.RecordTypeId =rt.id;
        
        Agreement_Template__c AgreementTemplate = new Agreement_Template__c(Name='Agreement Template');
        Insert AgreementTemplate;
        
        Product_Agreement__c ProductAgreement = new Product_Agreement__c(Agreement_Template__c = AgreementTemplate.id,Name='ProductAgreement', TMG_Product_Level_3__c= TestProductLevel3.Id);
        Insert ProductAgreement;
        
        Agreement__c Agreement = new Agreement__c(TMG_Product_Level_3__c= TestProductLevel3.id,RecordTypeid=rt.id,Matter_Deal__c=Matter.id,Name='Agreement',Agreement_Template__c=AgreementTemplate.id, Agreement_Type__c=ProductAgreement.id);
        
        Insert Agreement;
        
        Drawdown__c Drawdown = new Drawdown__c(Name = 'Agreement',Agreement__c = Agreement.id,Facility_Limit__c=888888,Current_Utilisation__c=9999,Advance_Amount__c=10000,Reference__c = 'abc',Account_Bank__c='HSCB',Account_Branch__c='Melrose',Account_Number__c='11111111',Account_Name__c='Acc Name', Status__c='Governance and Documentation Check Complete');
        //Insert Drawdown;
        
        Deal_Party__c DealParty = new Deal_Party__c(Deal__c=Matter.id,Relationship__c=Acc.id);
        Insert DealParty;
        
        Agreement_Party__c AgreementParty = new Agreement_Party__c(Deal_Party__c=DealParty.id,Agreement__c=Agreement.id);
        Insert AgreementParty;   
    }
    
    Public static void setupFolder(){      
        System.debug('### BXDtesclassdata : setupFolder');
        //Due to other test classes calling this already, rather keep it this way
        setupBoxFolder();
    }    
    
    Public static void setupBoxFolder(){
        
        System.debug('### BXDtesclassdata : setupBoxFolder');

        //Empty List.
        List<Box_Folder_Structure__c> folderStructuresConsolidatedInserts = new  List<Box_Folder_Structure__c>();
        
        Box_Folder_Structure__c  Root = new Box_Folder_Structure__c();
        Root.Name='Root';
        Root.Custom__c = false;
        Root.Folder_Level__c = 1;
        Root.Folder_Name__c = 'Salesforce';
        Root.Folder_Type__c = '';
        Root.Main_Record_Type__c = '';
        Root.Legal_Hold_Policy_Id__c = '';
        Root.Legal_Hold_Policy_Name__c = '';
        Root.Parent_Lookup__c = '';
        Root.Static_Folder__c = true;
        Root.Webhook_Triggers__c = '';
        Root.Webhook_URL__c = '';
        Root.External_Collaboration_Id__c = '';
        Insert Root;
        
        Box_Folder_Structure__c  Matters_Deal = new Box_Folder_Structure__c();
        Matters_Deal.Name='Matters/Deals';
        Matters_Deal.Custom__c = false;
        Matters_Deal.Folder_Level__c = 2;
        Matters_Deal.Folder_Name__c = 'MattersDeals';
        Matters_Deal.Folder_Type__c = '';
        Matters_Deal.Main_Record_Type__c = 'Deal; Legal; Litigation Matter; Default Legal Matter type; Legal Quote; Litigation Quote';
        Matters_Deal.Legal_Hold_Policy_Id__c = '';
        Matters_Deal.Legal_Hold_Policy_Name__c = '';
        Matters_Deal.Parent_Lookup__c = '';
        Matters_Deal.Parent_Structure__c = Root.id;
        Matters_Deal.Static_Folder__c = true;
        Matters_Deal.Webhook_Triggers__c = '';
        Matters_Deal.Webhook_URL__c = '';
        Matters_Deal.External_Collaboration_Id__c = '';
        Insert Matters_Deal;
        
        Box_Folder_Structure__c  collateral = new Box_Folder_Structure__c();
        collateral.Name='Collerals';
        collateral.Custom__c = false;
        collateral.Folder_Level__c = 2;
        collateral.Folder_Name__c = 'Collerals';
        collateral.Folder_Type__c = '';
        collateral.Main_Record_Type__c = 'Collaterals';
        collateral.Legal_Hold_Policy_Id__c = '';
        collateral.Legal_Hold_Policy_Name__c = '';
        collateral.Parent_Lookup__c = '';
        collateral.Parent_Structure__c = Root.id;
        collateral.Static_Folder__c = true;
        collateral.Webhook_Triggers__c = '';
        collateral.Webhook_URL__c = '';
        collateral.External_Collaboration_Id__c = '';
        Insert collateral;
        
        Box_Folder_Structure__c  Deal_Instance = new Box_Folder_Structure__c();
        Deal_Instance.Name='Deal Instance';
        Deal_Instance.Custom__c = false;
        Deal_Instance.Folder_Level__c = 3;
        Deal_Instance.Folder_Name__c = 'TBD';
        Deal_Instance.Folder_Type__c = 'Deal';
        Deal_Instance.Main_Record_Type__c = 'Deal';
        Deal_Instance.Legal_Hold_Policy_Id__c = '';
        Deal_Instance.Legal_Hold_Policy_Name__c = '';
        Deal_Instance.Parent_Lookup__c = '';
        Deal_Instance.Parent_Structure__c = Matters_Deal.id;
        Deal_Instance.Static_Folder__c = true;
        Deal_Instance.Webhook_Triggers__c = '';
        Deal_Instance.Webhook_URL__c = '';
        Deal_Instance.External_Collaboration_Id__c = '0';

        folderStructuresConsolidatedInserts.add(Deal_Instance);
        
        Box_Folder_Structure__c  Collateral_Instance = new Box_Folder_Structure__c();
        Collateral_Instance.Name='Collateral Instance';
        Collateral_Instance.Custom__c = false;
        Collateral_Instance.Folder_Level__c = 3;
        Collateral_Instance.Folder_Name__c = 'TBD';
        Collateral_Instance.Folder_Type__c = 'Collateral';
        Collateral_Instance.Main_Record_Type__c = 'Collaterals';
        Collateral_Instance.Legal_Hold_Policy_Id__c = '';
        Collateral_Instance.Legal_Hold_Policy_Name__c = '';
        Collateral_Instance.Parent_Lookup__c = '';
        Collateral_Instance.Parent_Structure__c = collateral.id;
        Collateral_Instance.Static_Folder__c = true;
        Collateral_Instance.Webhook_Triggers__c = '';
        Collateral_Instance.Webhook_URL__c = '';
        Collateral_Instance.External_Collaboration_Id__c = '0';

        folderStructuresConsolidatedInserts.add(Collateral_Instance);
        
        Box_Folder_Structure__c  LegalInstance = new Box_Folder_Structure__c();
        LegalInstance.Name='Legal Instance';
        LegalInstance.Custom__c = false;
        LegalInstance.Folder_Level__c = 3;
        LegalInstance.Folder_Name__c = 'TBD';
        LegalInstance.Folder_Type__c = 'Legal';
        LegalInstance.Main_Record_Type__c = 'Legal; Legal Quote';
        LegalInstance.Legal_Hold_Policy_Id__c = '';
        LegalInstance.Legal_Hold_Policy_Name__c = '';
        LegalInstance.Parent_Lookup__c = '';
        LegalInstance.Parent_Structure__c = Matters_Deal.id;
        LegalInstance.Static_Folder__c = true;
        LegalInstance.Webhook_Triggers__c = '';
        LegalInstance.Webhook_URL__c = '';
        LegalInstance.External_Collaboration_Id__c = '0';

        folderStructuresConsolidatedInserts.add(LegalInstance);
        
        Box_Folder_Structure__c  LitigationInstance = new Box_Folder_Structure__c();
        LitigationInstance.Name='Litigation Instance';
        LitigationInstance.Custom__c = false;
        LitigationInstance.Folder_Level__c = 3;
        LitigationInstance.Folder_Name__c = '';
        LitigationInstance.Folder_Type__c = 'Litigation Matter';
        LitigationInstance.Main_Record_Type__c = 'Litigation Matter';
        LitigationInstance.Legal_Hold_Policy_Id__c = '627385';
        LitigationInstance.Legal_Hold_Policy_Name__c = 'Legal Management';
        LitigationInstance.Parent_Lookup__c = '';
        LitigationInstance.Parent_Structure__c = Matters_Deal.id;
        LitigationInstance.Static_Folder__c = true;
        LitigationInstance.Webhook_Triggers__c = '';
        LitigationInstance.Webhook_URL__c = '';
        LitigationInstance.External_Collaboration_Id__c = '0';

         folderStructuresConsolidatedInserts.add(LitigationInstance);
        
        Box_Folder_Structure__c  LegalHold = new Box_Folder_Structure__c();
        LegalHold.Name='Legal - Legal Hold';
        LegalHold.Custom__c = false;
        LegalHold.Folder_Level__c = 3;
        LegalHold.Folder_Name__c = '';
        LegalHold.Folder_Type__c = 'Read-Only Legal Hold (Legal RT)';
        LegalHold.Main_Record_Type__c = 'Legal RT';
        LegalHold.Legal_Hold_Policy_Id__c = '627385';
        LegalHold.Legal_Hold_Policy_Name__c = 'Legal Management';
        LegalHold.Parent_Lookup__c = '';
        LegalHold.Parent_Structure__c = Matters_Deal.id;
        LegalHold.Static_Folder__c = true;
        LegalHold.Webhook_Triggers__c = '';
        LegalHold.Webhook_URL__c = '';
        LegalHold.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(LegalHold);
        
        Box_Folder_Structure__c  LitigationLegalHold = new Box_Folder_Structure__c();
        LitigationLegalHold.Name='Litigation - Legal Hold';
        LitigationLegalHold.Custom__c = false;
        LitigationLegalHold.Folder_Level__c = 3;
        LitigationLegalHold.Folder_Name__c = '';
        LitigationLegalHold.Folder_Type__c = 'Read-Only Legal Hold (Litigation RT)';
        LitigationLegalHold.Main_Record_Type__c = 'Litigation RT';
        LitigationLegalHold.Legal_Hold_Policy_Id__c = '627385';
        LitigationLegalHold.Legal_Hold_Policy_Name__c = 'Legal Management';
        LitigationLegalHold.Parent_Lookup__c = '';
        LitigationLegalHold.Parent_Structure__c = Matters_Deal.id;
        LitigationLegalHold.Static_Folder__c = true;
        LitigationLegalHold.Webhook_Triggers__c = '';
        LitigationLegalHold.Webhook_URL__c = '';
        LitigationLegalHold.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(LitigationLegalHold);
        
        Box_Folder_Structure__c  Knowledge = new Box_Folder_Structure__c();
        Knowledge.Name='KM External Collaboration';
        Knowledge.Custom__c = false;
        Knowledge.Folder_Level__c = 3;
        Knowledge.Folder_Name__c = 'TBD';
        Knowledge.Folder_Type__c = 'Knowledge Request';
        Knowledge.Main_Record_Type__c = 'Knowledge Management';
        Knowledge.Legal_Hold_Policy_Id__c = '';
        Knowledge.Legal_Hold_Policy_Name__c = '';
        Knowledge.Parent_Lookup__c = '';
        Knowledge.Parent_Structure__c = Matters_Deal.id;
        Knowledge.Static_Folder__c = true;
        Knowledge.Webhook_Triggers__c = '';
        Knowledge.Webhook_URL__c = '';
        Knowledge.External_Collaboration_Id__c = '0';

        folderStructuresConsolidatedInserts.add(Knowledge);

        Box_Folder_Structure__c  Deal_Agreement = new Box_Folder_Structure__c();
        Deal_Agreement.Name='Deal Agreements';
        Deal_Agreement.Custom__c = true;
        Deal_Agreement.Folder_Level__c = 4;
        Deal_Agreement.Folder_Name__c = 'Agreements';
        Deal_Agreement.Folder_Type__c = 'Agreement';
        Deal_Agreement.Main_Record_Type__c = 'Deal';
        Deal_Agreement.Legal_Hold_Policy_Id__c = '';
        Deal_Agreement.Legal_Hold_Policy_Name__c = '';
        Deal_Agreement.Parent_Lookup__c = '';
        Deal_Agreement.Parent_Structure__c = Matters_Deal.id;
        Deal_Agreement.Static_Folder__c = true;
        Deal_Agreement.Webhook_Triggers__c = '';
        Deal_Agreement.Webhook_URL__c = '';
        Deal_Agreement.Static_Folder__c = true;
        Deal_Agreement.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(Deal_Agreement);
        
        Box_Folder_Structure__c  Deal_ExternalCollab = new Box_Folder_Structure__c();
        Deal_ExternalCollab.Name='Deal External Collaborations';
        Deal_ExternalCollab.Custom__c = true;
        Deal_ExternalCollab.Folder_Level__c = 4;
        Deal_ExternalCollab.Folder_Name__c = 'External Collaboration';
        Deal_ExternalCollab.Folder_Type__c = 'Deal';
        Deal_ExternalCollab.Main_Record_Type__c = 'Deal';
        Deal_ExternalCollab.Legal_Hold_Policy_Id__c = '';
        Deal_ExternalCollab.Legal_Hold_Policy_Name__c = '';
        Deal_ExternalCollab.Parent_Lookup__c = '';
        Deal_ExternalCollab.Parent_Structure__c = Matters_Deal.id;
        Deal_ExternalCollab.Static_Folder__c = true;
        Deal_ExternalCollab.Webhook_Triggers__c = '';
        Deal_ExternalCollab.Webhook_URL__c = '';
        Deal_ExternalCollab.Static_Folder__c = true;
        Deal_ExternalCollab.External_Collaboration_Id__c = '123456789';

        folderStructuresConsolidatedInserts.add(Deal_ExternalCollab);
        
        Box_Folder_Structure__c  Collateral_Valuation = new Box_Folder_Structure__c();
        Collateral_Valuation.Name='Collateral Valuations';
        Collateral_Valuation.Custom__c = true;
        Collateral_Valuation.Folder_Level__c = 4;
        Collateral_Valuation.Folder_Name__c = 'Collaterals';
        Collateral_Valuation.Folder_Type__c = 'Collateral Valuation Master';
        Collateral_Valuation.Main_Record_Type__c = 'Collaterals';
        Collateral_Valuation.Legal_Hold_Policy_Id__c = '';
        Collateral_Valuation.Legal_Hold_Policy_Name__c = '';
        Collateral_Valuation.Parent_Lookup__c = '';
        Collateral_Valuation.Parent_Structure__c = collateral.id;
        Collateral_Valuation.Static_Folder__c = true;
        Collateral_Valuation.Webhook_Triggers__c = '';
        Collateral_Valuation.Webhook_URL__c = '';
        Collateral_Valuation.Static_Folder__c = true;
        Collateral_Valuation.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(Collateral_Valuation);
        
        Box_Folder_Structure__c  Collateral_Monitoring = new Box_Folder_Structure__c();
        Collateral_Monitoring.Name='Collateral Monitorings';
        Collateral_Monitoring.Custom__c = true;
        Collateral_Monitoring.Folder_Level__c = 4;
        Collateral_Monitoring.Folder_Name__c = 'Collaterals';
        Collateral_Monitoring.Folder_Type__c = 'Collateral Monitoring Master';
        Collateral_Monitoring.Main_Record_Type__c = 'Collaterals';
        Collateral_Monitoring.Legal_Hold_Policy_Id__c = '';
        Collateral_Monitoring.Legal_Hold_Policy_Name__c = '';
        Collateral_Monitoring.Parent_Lookup__c = '';
        Collateral_Monitoring.Parent_Structure__c = collateral.id;
        Collateral_Monitoring.Static_Folder__c = true;
        Collateral_Monitoring.Webhook_Triggers__c = '';
        Collateral_Monitoring.Webhook_URL__c = '';
        Collateral_Monitoring.Static_Folder__c = true;
        Collateral_Monitoring.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(Collateral_Monitoring);

        insert folderStructuresConsolidatedInserts;

        folderStructuresConsolidatedInserts.clear();
        
        Box_Folder_Structure__c  LegalQuoteRequests = new Box_Folder_Structure__c();
        LegalQuoteRequests.Name='Legal Quote Requests';
        LegalQuoteRequests.Custom__c = true;
        LegalQuoteRequests.Folder_Level__c = 4;
        LegalQuoteRequests.Folder_Name__c = 'Legal Quote Requests';
        LegalQuoteRequests.Folder_Type__c = 'Legal Request';
        LegalQuoteRequests.Main_Record_Type__c = 'Legal Quote';
        LegalQuoteRequests.Legal_Hold_Policy_Id__c = '';
        LegalQuoteRequests.Legal_Hold_Policy_Name__c = '';
        LegalQuoteRequests.Parent_Lookup__c = 'Matter__c';
        LegalQuoteRequests.Parent_Structure__c = LegalInstance.id;
        LegalQuoteRequests.Static_Folder__c = true;
        LegalQuoteRequests.Webhook_Triggers__c = '';
        LegalQuoteRequests.Webhook_URL__c = '';
        LegalQuoteRequests.Static_Folder__c = true;
        LegalQuoteRequests.External_Collaboration_Id__c = '';
        Insert LegalQuoteRequests;
        
        Box_Folder_Structure__c  Legal_Documents = new Box_Folder_Structure__c();
        Legal_Documents.Name='Legal Documents';
        Legal_Documents.Custom__c = true;
        Legal_Documents.Folder_Level__c = 4;
        Legal_Documents.Folder_Name__c = 'Documents';
        Legal_Documents.Folder_Type__c = 'Legal';
        Legal_Documents.Main_Record_Type__c = 'Legal';
        Legal_Documents.Legal_Hold_Policy_Id__c = '';
        Legal_Documents.Legal_Hold_Policy_Name__c = '';
        Legal_Documents.Parent_Lookup__c = 'Matter__c';
        Legal_Documents.Parent_Structure__c = LegalInstance.id;
        Legal_Documents.Static_Folder__c = true;
        Legal_Documents.Webhook_Triggers__c = '';
        Legal_Documents.Webhook_URL__c = '';
        Legal_Documents.Static_Folder__c = true;
        Legal_Documents.External_Collaboration_Id__c = '';
        Insert Legal_Documents;
        
        
        Box_Folder_Structure__c  Agreement_Instance = new Box_Folder_Structure__c();
        Agreement_Instance.Name='Agreement Instance';
        Agreement_Instance.Custom__c = false;
        Agreement_Instance.Folder_Level__c = 5;
        Agreement_Instance.Folder_Name__c = 'TBD';
        Agreement_Instance.Folder_Type__c = 'Agreement';
        Agreement_Instance.Main_Record_Type__c = 'Deal';
        Agreement_Instance.Legal_Hold_Policy_Id__c = '';
        Agreement_Instance.Legal_Hold_Policy_Name__c = '';
        Agreement_Instance.Parent_Lookup__c = '';
        Agreement_Instance.Parent_Structure__c = Deal_Agreement.id;
        Agreement_Instance.Static_Folder__c = true;
        Agreement_Instance.Webhook_Triggers__c = '';
        Agreement_Instance.Webhook_URL__c = '';
        Agreement_Instance.Static_Folder__c = false;
        Agreement_Instance.External_Collaboration_Id__c = '';
        Insert Agreement_Instance;
        
        Box_Folder_Structure__c  LQRequest_Instance = new Box_Folder_Structure__c();
        LQRequest_Instance.Name='Legal Quote Request Instance';
        LQRequest_Instance.Custom__c = false;
        LQRequest_Instance.Folder_Level__c = 5;
        LQRequest_Instance.Folder_Name__c = 'TBD';
        LQRequest_Instance.Folder_Type__c = 'Legal Request';
        LQRequest_Instance.Main_Record_Type__c = 'Legal Quote';
        LQRequest_Instance.Legal_Hold_Policy_Id__c = '';
        LQRequest_Instance.Legal_Hold_Policy_Name__c = '';
        LQRequest_Instance.Parent_Lookup__c = 'Matter__c';
        LQRequest_Instance.Parent_Structure__c = LegalQuoteRequests.id;
        LQRequest_Instance.Static_Folder__c = true;
        LQRequest_Instance.Webhook_Triggers__c = '';
        LQRequest_Instance.Webhook_URL__c = '';
        LQRequest_Instance.Static_Folder__c = false;
        LQRequest_Instance.External_Collaboration_Id__c = '';
        Insert LQRequest_Instance;
        
        Box_Folder_Structure__c  Conditions = new Box_Folder_Structure__c();
        Conditions.Custom__c = true;
        Conditions.Folder_Level__c = 6;
        Conditions.Folder_Name__c = 'Conditions';
        Conditions.Folder_Type__c = 'Condition Precedent; Financial Covenant; Governance Check; Information Undertaking; General Undertaking';
        Conditions.Main_Record_Type__c = 'Deal';
        Conditions.Legal_Hold_Policy_Id__c = '171828191';
        Conditions.Legal_Hold_Policy_Name__c = 'Policy Name';
        Conditions.Parent_Lookup__c = 'Agreement__c';
        Conditions.Parent_Structure__c = Agreement_Instance.id;
        Conditions.Static_Folder__c = true;
        Conditions.Webhook_Triggers__c = 'FILE.UPLOADED';
        Conditions.Webhook_URL__c = 'https://www.salesforce.com';
        Conditions.Static_Folder__c = false;
        Conditions.External_Collaboration_Id__c = '';
        Insert Conditions;
        
        Box_Folder_Structure__c  LegalQuote = new Box_Folder_Structure__c();
        LegalQuote.Custom__c = true;
        LegalQuote.Folder_Level__c = 6;
        LegalQuote.Folder_Name__c = 'Quotes';
        LegalQuote.Folder_Type__c = 'Legal Quote';
        LegalQuote.Main_Record_Type__c = 'Legal Quote';
        LegalQuote.Legal_Hold_Policy_Id__c = '171828191';
        LegalQuote.Legal_Hold_Policy_Name__c = 'Policy Name';
        LegalQuote.Parent_Lookup__c = 'Legal_Quote_Request__c';
        LegalQuote.Parent_Structure__c = Agreement_Instance.id;
        LegalQuote.Static_Folder__c = true;
        LegalQuote.Webhook_Triggers__c = 'FILE.UPLOADED';
        LegalQuote.Webhook_URL__c = 'https://www.salesforce.com';
        LegalQuote.Static_Folder__c = false;
        LegalQuote.External_Collaboration_Id__c = '';
        Insert LegalQuote;
        
        Box_Folder_Structure__c Litigation_Quote = new Box_Folder_Structure__c();
        Litigation_Quote.Custom__c = true;
        Litigation_Quote.Folder_Level__c = 6;
        Litigation_Quote.Folder_Name__c = 'Quotes';
        Litigation_Quote.Folder_Type__c = 'Litigation Quote';
        Litigation_Quote.Main_Record_Type__c = 'Litigation Quote';
        Litigation_Quote.Legal_Hold_Policy_Id__c = '171828191';
        Litigation_Quote.Legal_Hold_Policy_Name__c = 'Policy Name';
        Litigation_Quote.Parent_Lookup__c = 'Legal_Quote_Request__c';
        Litigation_Quote.Parent_Structure__c = Agreement_Instance.id;
        Litigation_Quote.Static_Folder__c = true;
        Litigation_Quote.Webhook_Triggers__c = 'FILE.UPLOADED';
        Litigation_Quote.Webhook_URL__c = 'https://www.salesforce.com';
        Litigation_Quote.Static_Folder__c = false;
        Litigation_Quote.External_Collaboration_Id__c = '';
        Insert Litigation_Quote;
        
        Box_Folder_Structure__c Off_Panel_Quote = new Box_Folder_Structure__c();
        Off_Panel_Quote.Custom__c = true;
        Off_Panel_Quote.Folder_Level__c = 6;
        Off_Panel_Quote.Folder_Name__c = 'Quotes';
        Off_Panel_Quote.Folder_Type__c = 'Litigation Quote';
        Off_Panel_Quote.Main_Record_Type__c = 'Litigation Quote';
        Off_Panel_Quote.Legal_Hold_Policy_Id__c = '171828191';
        Off_Panel_Quote.Legal_Hold_Policy_Name__c = 'Policy Name';
        Off_Panel_Quote.Parent_Lookup__c = 'Legal_Quote_Request__c';
        Off_Panel_Quote.Parent_Structure__c = Agreement_Instance.id;
        Off_Panel_Quote.Static_Folder__c = true;
        Off_Panel_Quote.Webhook_Triggers__c = 'FILE.UPLOADED';
        Off_Panel_Quote.Webhook_URL__c = 'https://www.salesforce.com';
        Off_Panel_Quote.Static_Folder__c = false;
        Off_Panel_Quote.External_Collaboration_Id__c = '';
        Insert Off_Panel_Quote;
        
        Box_Folder_Structure__c  Condition_Precedence = new Box_Folder_Structure__c();
        Condition_Precedence.Custom__c = false;
        Condition_Precedence.Folder_Level__c = 7;
        Condition_Precedence.Folder_Name__c = 'Conditions Precedent';
        Condition_Precedence.Folder_Type__c = 'Condition Precedent';
        Condition_Precedence.Main_Record_Type__c = 'Deal';
        Condition_Precedence.Legal_Hold_Policy_Id__c = '';
        Condition_Precedence.Legal_Hold_Policy_Name__c = '';
        Condition_Precedence.Parent_Lookup__c = 'Agreement__c';
        Condition_Precedence.Parent_Structure__c = Conditions.id;
        Condition_Precedence.Static_Folder__c = false;
        Condition_Precedence.Webhook_Triggers__c = 'FILE.UPLOADED';
        Condition_Precedence.Webhook_URL__c = 'https://www.salesforce.com';
        Condition_Precedence.Static_Folder__c = true;
        Condition_Precedence.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(Condition_Precedence);
        
        Box_Folder_Structure__c  General_Undertaking = new Box_Folder_Structure__c();
        General_Undertaking.Custom__c = false;
        General_Undertaking.Folder_Level__c = 7;
        General_Undertaking.Folder_Name__c = 'General Undertaking';
        General_Undertaking.Folder_Type__c = 'General Undertaking';
        General_Undertaking.Main_Record_Type__c = 'Deal';
        General_Undertaking.Legal_Hold_Policy_Id__c = '';
        General_Undertaking.Legal_Hold_Policy_Name__c = '';
        General_Undertaking.Parent_Lookup__c = 'Agreement__c';
        General_Undertaking.Parent_Structure__c = Conditions.id;
        General_Undertaking.Static_Folder__c = false;
        General_Undertaking.Webhook_Triggers__c = 'FILE.UPLOADED';
        General_Undertaking.Webhook_URL__c = 'https://www.salesforce.com';
        General_Undertaking.Static_Folder__c = true;
        General_Undertaking.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(General_Undertaking);
        
        Box_Folder_Structure__c  Financial_Covenant = new Box_Folder_Structure__c();
        Financial_Covenant.Custom__c = false;
        Financial_Covenant.Folder_Level__c = 7;
        Financial_Covenant.Folder_Name__c = 'Financial Covenants';
        Financial_Covenant.Folder_Type__c = 'Financial Covenant';
        Financial_Covenant.Main_Record_Type__c = 'Deal';
        Financial_Covenant.Legal_Hold_Policy_Id__c = '';
        Financial_Covenant.Legal_Hold_Policy_Name__c = '';
        Financial_Covenant.Parent_Lookup__c = 'Agreement__c';
        Financial_Covenant.Parent_Structure__c = Conditions.id;
        Financial_Covenant.Static_Folder__c = false;
        Financial_Covenant.Webhook_Triggers__c = 'FILE.UPLOADED';
        Financial_Covenant.Webhook_URL__c = 'https://www.salesforce.com';
        Financial_Covenant.Static_Folder__c = true;
        Financial_Covenant.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(Financial_Covenant);
        
        Box_Folder_Structure__c  Governance_Check = new Box_Folder_Structure__c();
        Governance_Check.Custom__c = false;
        Governance_Check.Folder_Level__c = 7;
        Governance_Check.Folder_Name__c = 'Governance Checks';
        Governance_Check.Folder_Type__c = 'Governance Check';
        Governance_Check.Main_Record_Type__c = 'Deal';
        Governance_Check.Legal_Hold_Policy_Id__c = '';
        Governance_Check.Legal_Hold_Policy_Name__c = '';
        Governance_Check.Parent_Lookup__c = 'Agreement__c';
        Governance_Check.Parent_Structure__c = Conditions.id;
        Governance_Check.Static_Folder__c = false;
        Governance_Check.Webhook_Triggers__c = 'FILE.UPLOADED';
        Governance_Check.Webhook_URL__c = 'https://www.salesforce.com';
        Governance_Check.Static_Folder__c = true;
        Governance_Check.External_Collaboration_Id__c = '';

        folderStructuresConsolidatedInserts.add(Governance_Check);
        
        Box_Folder_Structure__c  Information_Undertaking = new Box_Folder_Structure__c();
        Information_Undertaking.Custom__c = false;
        Information_Undertaking.Folder_Level__c = 7;
        Information_Undertaking.Folder_Name__c = 'Information Undertakings';
        Information_Undertaking.Folder_Type__c = 'Information Undertaking';
        Information_Undertaking.Main_Record_Type__c = 'Deal';
        Information_Undertaking.Legal_Hold_Policy_Id__c = '';
        Information_Undertaking.Legal_Hold_Policy_Name__c = '';
        Information_Undertaking.Parent_Lookup__c = 'Agreement__c';
        Information_Undertaking.Parent_Structure__c = Conditions.id;
        Information_Undertaking.Static_Folder__c = false;
        Information_Undertaking.Webhook_Triggers__c = 'FILE.UPLOADED';
        Information_Undertaking.Webhook_URL__c = 'https://www.salesforce.com';
        Information_Undertaking.Static_Folder__c = true;
        Information_Undertaking.External_Collaboration_Id__c = '';
        

        folderStructuresConsolidatedInserts.add(Information_Undertaking);

        insert folderStructuresConsolidatedInserts;
        
        folderStructuresConsolidatedInserts.clear();
        
        
        Box_Folder_Structure__c  Facilities = new Box_Folder_Structure__c();
        Facilities.Custom__c = true;
        Facilities.Folder_Level__c = 6;
        Facilities.Folder_Name__c = 'Facilities';
        Facilities.Folder_Type__c = 'Facility';
        Facilities.Main_Record_Type__c = 'Deal';
        Facilities.Legal_Hold_Policy_Id__c = '171828191';
        Facilities.Legal_Hold_Policy_Name__c = 'Policy Name';
        Facilities.Parent_Lookup__c = 'Agreement__c';
        Facilities.Parent_Structure__c = Agreement_Instance.id;
        Facilities.Static_Folder__c = true;
        Facilities.Webhook_Triggers__c = 'FILE.UPLOADED';
        Facilities.Webhook_URL__c = 'https://www.salesforce.com';
        Facilities.External_Collaboration_Id__c = '';
        Insert Facilities;
        
        Box_Folder_Structure__c  AgreementAgencyTransfers = new Box_Folder_Structure__c();
        AgreementAgencyTransfers.Custom__c = true;
        AgreementAgencyTransfers.Folder_Level__c = 6;
        AgreementAgencyTransfers.Folder_Name__c = 'Agency Transfers';
        AgreementAgencyTransfers.Folder_Type__c = 'Agreement Agency Transfer';
        AgreementAgencyTransfers.Main_Record_Type__c = 'Deal';
        AgreementAgencyTransfers.Legal_Hold_Policy_Id__c = '171828191';
        AgreementAgencyTransfers.Legal_Hold_Policy_Name__c = 'Policy Name';
        AgreementAgencyTransfers.Parent_Lookup__c = 'Agreement__c';
        AgreementAgencyTransfers.Parent_Structure__c = Agreement_Instance.id;
        AgreementAgencyTransfers.Static_Folder__c = true;
        AgreementAgencyTransfers.Webhook_Triggers__c = 'FILE.UPLOADED';
        AgreementAgencyTransfers.Webhook_URL__c = 'https://www.salesforce.com';
        AgreementAgencyTransfers.External_Collaboration_Id__c = '';
        Insert AgreementAgencyTransfers;
        
        Box_Folder_Structure__c  SPVItem = new Box_Folder_Structure__c();
        SPVItem.Custom__c = true;
        SPVItem.Folder_Level__c = 6;
        SPVItem.Folder_Name__c = 'Note';
        SPVItem.Folder_Type__c = 'Note';
        SPVItem.Main_Record_Type__c = 'Deal';
        SPVItem.Legal_Hold_Policy_Id__c = '171828191';
        SPVItem.Legal_Hold_Policy_Name__c = 'Policy Name';
        SPVItem.Parent_Lookup__c = 'Agreement__c';
        SPVItem.Parent_Structure__c = Agreement_Instance.id;
        SPVItem.Static_Folder__c = true;
        SPVItem.Webhook_Triggers__c = 'FILE.UPLOADED';
        SPVItem.Webhook_URL__c = 'https://www.salesforce.com';
        SPVItem.External_Collaboration_Id__c = '';
        Insert SPVItem;
        
        Box_Folder_Structure__c  Triggerss = new Box_Folder_Structure__c();
        Triggerss.Custom__c = true;
        Triggerss.Folder_Level__c = 6;
        Triggerss.Folder_Name__c = 'Triggers';
        Triggerss.Folder_Type__c = 'Trigger Master';
        Triggerss.Main_Record_Type__c = 'Deal';
        Triggerss.Legal_Hold_Policy_Id__c = '171828191';
        Triggerss.Legal_Hold_Policy_Name__c = 'Policy Name';
        Triggerss.Parent_Lookup__c = 'Agreement__c';
        Triggerss.Parent_Structure__c = Agreement_Instance.id;
        Triggerss.Static_Folder__c = true;
        Triggerss.Webhook_Triggers__c = 'FILE.UPLOADED';
        Triggerss.Webhook_URL__c = 'https://www.salesforce.com';
        Triggerss.External_Collaboration_Id__c = '';
        Insert Triggerss;
        
        Box_Folder_Structure__c  Margin_Ratchets = new Box_Folder_Structure__c();
        Margin_Ratchets.Custom__c = true;
        Margin_Ratchets.Folder_Level__c = 6;
        Margin_Ratchets.Folder_Name__c = 'Margin Ratchets';
        Margin_Ratchets.Folder_Type__c = 'Covenant; Event';
        Margin_Ratchets.Main_Record_Type__c = 'Deal';
        Margin_Ratchets.Legal_Hold_Policy_Id__c = '171828191';
        Margin_Ratchets.Legal_Hold_Policy_Name__c = 'Policy Name';
        Margin_Ratchets.Parent_Lookup__c = 'Agreement__c';
        Margin_Ratchets.Parent_Structure__c = Agreement_Instance.id;
        Margin_Ratchets.Static_Folder__c = true;
        Margin_Ratchets.Webhook_Triggers__c = 'FILE.UPLOADED';
        Margin_Ratchets.Webhook_URL__c = 'https://www.salesforce.com';
        Margin_Ratchets.External_Collaboration_Id__c = '';
        Insert Margin_Ratchets;
        
        Box_Folder_Structure__c  Margin_Ratchet_Watchers = new Box_Folder_Structure__c();
        Margin_Ratchet_Watchers.Custom__c = true;
        Margin_Ratchet_Watchers.Folder_Level__c = 6;
        Margin_Ratchet_Watchers.Folder_Name__c = 'Watchers';
        Margin_Ratchet_Watchers.Folder_Type__c = 'Margin Ratchet';
        Margin_Ratchet_Watchers.Main_Record_Type__c = 'Deal';
        Margin_Ratchet_Watchers.Legal_Hold_Policy_Id__c = '171828191';
        Margin_Ratchet_Watchers.Legal_Hold_Policy_Name__c = 'Policy Name';
        Margin_Ratchet_Watchers.Parent_Lookup__c = 'Margin_Ratchet__c';
        Margin_Ratchet_Watchers.Parent_Structure__c = Agreement_Instance.id;
        Margin_Ratchet_Watchers.Static_Folder__c = true;
        Margin_Ratchet_Watchers.Webhook_Triggers__c = 'FILE.UPLOADED';
        Margin_Ratchet_Watchers.Webhook_URL__c = 'https://www.salesforce.com';
        Margin_Ratchet_Watchers.External_Collaboration_Id__c = '';
        Insert Margin_Ratchet_Watchers;
        
        Box_Folder_Structure__c  Monitoring_Watchers = new Box_Folder_Structure__c();
        Monitoring_Watchers.Custom__c = true;
        Monitoring_Watchers.Folder_Level__c = 6;
        Monitoring_Watchers.Folder_Name__c = 'Watchers';
        Monitoring_Watchers.Folder_Type__c = 'Collateral Monitoring';
        Monitoring_Watchers.Main_Record_Type__c = 'Deal';
        Monitoring_Watchers.Legal_Hold_Policy_Id__c = '171828191';
        Monitoring_Watchers.Legal_Hold_Policy_Name__c = 'Policy Name';
        Monitoring_Watchers.Parent_Lookup__c = 'Collateral_Monitoring__c';
        Monitoring_Watchers.Parent_Structure__c = Agreement_Instance.id;
        Monitoring_Watchers.Static_Folder__c = true;
        Monitoring_Watchers.Webhook_Triggers__c = 'FILE.UPLOADED';
        Monitoring_Watchers.Webhook_URL__c = 'https://www.salesforce.com';
        Monitoring_Watchers.External_Collaboration_Id__c = '';
        Insert Monitoring_Watchers;
        
        Box_Folder_Structure__c  Valuation_Watchers = new Box_Folder_Structure__c();
        Valuation_Watchers.Custom__c = true;
        Valuation_Watchers.Folder_Level__c = 6;
        Valuation_Watchers.Folder_Name__c = 'Watchers';
        Valuation_Watchers.Folder_Type__c = 'Collateral Valuation';
        Valuation_Watchers.Main_Record_Type__c = 'Deal';
        Valuation_Watchers.Legal_Hold_Policy_Id__c = '171828191';
        Valuation_Watchers.Legal_Hold_Policy_Name__c = 'Policy Name';
        Valuation_Watchers.Parent_Lookup__c = 'Collateral_Valuation__c';
        Valuation_Watchers.Parent_Structure__c = Agreement_Instance.id;
        Valuation_Watchers.Static_Folder__c = true;
        Valuation_Watchers.Webhook_Triggers__c = 'FILE.UPLOADED';
        Valuation_Watchers.Webhook_URL__c = 'https://www.salesforce.com';
        Valuation_Watchers.External_Collaboration_Id__c = '';
        Insert Valuation_Watchers;
        
        Box_Folder_Structure__c  Trigger_Watchers = new Box_Folder_Structure__c();
        Trigger_Watchers.Custom__c = true;
        Trigger_Watchers.Folder_Level__c = 6;
        Trigger_Watchers.Folder_Name__c = 'Watchers';
        Trigger_Watchers.Folder_Type__c = 'Trigger';
        Trigger_Watchers.Main_Record_Type__c = 'Deal';
        Trigger_Watchers.Legal_Hold_Policy_Id__c = '171828191';
        Trigger_Watchers.Legal_Hold_Policy_Name__c = 'Policy Name';
        Trigger_Watchers.Parent_Lookup__c = 'Trigger__c';
        Trigger_Watchers.Parent_Structure__c = Agreement_Instance.id;
        Trigger_Watchers.Static_Folder__c = true;
        Trigger_Watchers.Webhook_Triggers__c = 'FILE.UPLOADED';
        Trigger_Watchers.Webhook_URL__c = 'https://www.salesforce.com';
        Trigger_Watchers.External_Collaboration_Id__c = '';
        Insert Trigger_Watchers;
        
        Box_Folder_Structure__c  Facility = new Box_Folder_Structure__c();
        Facility.Custom__c = false;
        Facility.Folder_Level__c = 7;
        Facility.Folder_Name__c = 'TBD';
        Facility.Folder_Type__c = 'Facility';
        Facility.Main_Record_Type__c = 'Deal';
        Facility.Legal_Hold_Policy_Id__c = '171828191';
        Facility.Legal_Hold_Policy_Name__c = 'Policy Name';
        Facility.Parent_Lookup__c = 'Agreement__c';
        Facility.Parent_Structure__c = Facilities.id;
        Facility.Static_Folder__c = false;
        Facility.Webhook_Triggers__c = 'FILE.UPLOADED';
        Facility.Webhook_URL__c = 'https://www.salesforce.com';
        Facility.External_Collaboration_Id__c = '';
        Insert Facility;
        
        Box_Folder_Structure__c  Tranche = new Box_Folder_Structure__c();
        Tranche.Custom__c = true;
        Tranche.Folder_Level__c = 8;
        Tranche.Folder_Name__c = 'Tranches';
        Tranche.Folder_Type__c = 'Tranche';
        Tranche.Main_Record_Type__c = 'Deal';
        Tranche.Legal_Hold_Policy_Id__c = '171828191';
        Tranche.Legal_Hold_Policy_Name__c = 'Policy Name';
        Tranche.Parent_Lookup__c = 'Facility__c';
        Tranche.Parent_Structure__c = Facility.id;
        Tranche.Static_Folder__c = true;
        Tranche.Webhook_Triggers__c = 'FILE.UPLOADED';
        Tranche.Webhook_URL__c = 'https://www.salesforce.com';
        Tranche.External_Collaboration_Id__c = '';
        Insert Tranche;
        
        Box_Folder_Structure__c  FacilityAgencyTransfers = new Box_Folder_Structure__c();
        FacilityAgencyTransfers.Custom__c = true;
        FacilityAgencyTransfers.Folder_Level__c = 8;
        FacilityAgencyTransfers.Folder_Name__c = 'Agency Transfers';
        FacilityAgencyTransfers.Folder_Type__c = 'Facility Agency Transfer';
        FacilityAgencyTransfers.Main_Record_Type__c = 'Deal';
        FacilityAgencyTransfers.Legal_Hold_Policy_Id__c = '171828191';
        FacilityAgencyTransfers.Legal_Hold_Policy_Name__c = 'Policy Name';
        FacilityAgencyTransfers.Parent_Lookup__c = 'Facility__c';
        FacilityAgencyTransfers.Parent_Structure__c = Facility.id;
        FacilityAgencyTransfers.Static_Folder__c = true;
        FacilityAgencyTransfers.Webhook_Triggers__c = 'FILE.UPLOADED';
        FacilityAgencyTransfers.Webhook_URL__c = 'https://www.salesforce.com';
        FacilityAgencyTransfers.External_Collaboration_Id__c = '';
        Insert FacilityAgencyTransfers;
        
        Box_Folder_Structure__c  TrancheInstance = new Box_Folder_Structure__c();
        TrancheInstance.Custom__c = false;
        TrancheInstance.Folder_Level__c = 9;
        TrancheInstance.Folder_Name__c = 'TBD';
        TrancheInstance.Folder_Type__c = 'Tranche';
        TrancheInstance.Main_Record_Type__c = 'Deal';
        TrancheInstance.Legal_Hold_Policy_Id__c = '171828191';
        TrancheInstance.Legal_Hold_Policy_Name__c = 'Policy Name';
        TrancheInstance.Parent_Lookup__c = 'Facility_Tranche__c';
        TrancheInstance.Parent_Structure__c = Tranche.id;
        TrancheInstance.Static_Folder__c = false;
        TrancheInstance.Webhook_Triggers__c = 'FILE.UPLOADED';
        TrancheInstance.Webhook_URL__c = 'https://www.salesforce.com';
        TrancheInstance.External_Collaboration_Id__c = '';
        Insert TrancheInstance;
        
        Box_Folder_Structure__c  TrancheAgencyTransfers = new Box_Folder_Structure__c();
        TrancheAgencyTransfers.Custom__c = true;
        TrancheAgencyTransfers.Folder_Level__c = 9;
        TrancheAgencyTransfers.Folder_Name__c = 'Agency Transfers';
        TrancheAgencyTransfers.Folder_Type__c = 'Tranche Agency Transfer';
        TrancheAgencyTransfers.Main_Record_Type__c = 'Deal';
        TrancheAgencyTransfers.Legal_Hold_Policy_Id__c = '171828191';
        TrancheAgencyTransfers.Legal_Hold_Policy_Name__c = 'Policy Name';
        TrancheAgencyTransfers.Parent_Lookup__c = 'Facility_Tranche__c';
        TrancheAgencyTransfers.Parent_Structure__c = TrancheInstance.id;
        TrancheAgencyTransfers.Static_Folder__c = true;
        TrancheAgencyTransfers.Webhook_Triggers__c = 'FILE.UPLOADED';
        TrancheAgencyTransfers.Webhook_URL__c = 'https://www.salesforce.com';
        TrancheAgencyTransfers.External_Collaboration_Id__c = '';
        Insert TrancheAgencyTransfers;
        
        //Meta
        BoxBaseMetadata__c base = new BoxBaseMetadata__c();
        base.Classification_Template__c = 'Class';
        base.Metadata_Template__c = 'Meta';
        base.Name = 'Deal';
        Insert base;
        
        BoxMetadata__c meta = new BoxMetadata__c();
        meta.BoxBaseMetadata__c = base.Id;
        meta.Classification_Confidential_Key__c = '1';
        meta.Deal_Agreement_Name__c = '1';
        meta.Deal_Beneficiary_Name__c = '1';
        meta.Deal_Borrower_Name__c = '1';
        meta.Deal_Collateral_Type__c = '1';
        meta.Deal_Condition_Type__c = '1';
        meta.Deal_Document_Expiry_Date__c = '1';
        meta.Deal_Document_Name__c = '1';
        meta.Deal_Document_Type__c = '1';
        meta.Deal_Issuer_Name__c = '1';
        meta.Deal_Name__c = '1';
        meta.Deal_Provider_Name__c = '1';
        meta.Deal_SDS__c = '1';
        meta.Deal_Status__c = '1';
        meta.Personal_Information__c = '1';
        meta.Classification_Confidential_Key__c = 'No';
        Insert meta;
    }
}