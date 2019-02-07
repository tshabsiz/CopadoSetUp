/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist
 * 
 * */
@isTest
public class AcmCollateralTestData
{
    public static String POST_URL = '';
    public static String GET_URL = '';
    public static String POST_METHOD ='POST';
    public static String GET_METHOD ='GET';      
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   

    
    public Account                      TestAccount;
    public Account                      TestAccountChanged;
    public Account                      TestAccountWithoutSDS;
    public Collateral_Type__c           TestCollateralType;
    public Collateral_Group__c          TestCollateralGroup;
    public Collateral__c                TestCollateral;
    public Collateral__c                TestCollateralFacilityScope;
    public Collateral__c                TestCollateralFacilityScopeWithoutFacility;
    public Collateral__c                TestCollateralUnsaved;
    public Collateral__c                TestCollateralUnsavedBenef;
    public Acm_Collateral_Status__c     AcmCollateralStatus;
    public Acm_Collateral_Status__c     AcmCollateralStatusEmailNotSent;
    public Collateral_Relationship__c   TestCollateralRelationshipProvider;
    public Collateral_Relationship__c   TestCollateralRelationshipBeneficiary;
    public Collateral_Relationship__c   TestCollateralRelationshipBeneficiaryNotPrimary;
    public Collateral_Relationship__c   TestCollateralRelationshipBeneficiaryNotPrimaryFac;
    public Collateral_Relationship__c   TestCollateralRelationshipNothing;
    public AcmFacility__c               TestAcmFacility;
    public AcmFacility__c               TestAcmFacilityChange;
    public Collateral_Facility__c       TestCollateralFacility;
    public Collateral_Facility__c       TestCollateralFacilityNotPrimary;
    public AcmIntegration__c            TestAcmIntegration;
    public Facility__c                  TestFacility;
    public advpm__Matter__c             TestMatter;
    //public Product2                     TestProduct2;
    //public Product_Level_2__c           TestProductLevel2;
    public TMG_Product_Level_1__c		TestProductLevel1;
    public TMG_Product_Level_2__c		TestProductLevel2;
    public TMG_Product_Level_3__c		TestProductLevel3;
    public Product_Agreement__c         TestProductAgreement;
    public Agreement__c                 TestAgreement;
    public Agreement_Template__c        TestAgreementTemplate;
    public Client_Plan__c               TestClientPlan;
    public Attachment               	TestAttachment; 
    public Attachment  					TestDocusignAttachment;
    public dsfs__DocuSign_Status__c  	TestDocusignStatus;
    public dsfs__DocuSign_Status__c  	TestDocusignSentStatus;
    public Attachment  					TestDocusignAttachmentSent;
    public BoxDocument__c 				TestBoxDocument;
    
    public AcmCollateralTestData()
    {
        BXDtesclassdata.setupFolder();  
        DateTime todaysDate_nextMonth = System.now().addMonths(1);

        //ACCOUNT
        TestAccount = new Account();
        TestAccount.Name = generateRandomStringBlob(); 
        TestAccount.Type = 'Client';
        TestAccount.SDS__c = 'SDS';
        TestAccount.Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM');
        TestAccount.RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
        insert TestAccount;

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
        
        ProductTestLevel3 = new TMG_Product_Level_3__c
        (
            Name = 'SUB100',
            Active__c = true,
            TMG_Product_Level_2__c = TestProductLevel2.id
        );*/
        
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
        
        //AGREEMENT TEMPLATE
        TestAgreementTemplate = new Agreement_Template__c
        (
            Name = 'Test Agreement Template'
        );  
        insert TestAgreementTemplate;
        
        
        
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
        
        // ATTCHMENT ON AGREEMENT
        TestAttachment = new Attachment
        (
            Name = 'Random Attachment',
            Body = Blob.valueOf('Random String'),
            ParentID = TestAgreement.Id
        );
		Insert TestAttachment;
        
        TestDocusignStatus = new dsfs__DocuSign_Status__c
        (
            dsfs__Envelope_Status__c = 'Completed',
            Agreement__c = TestAgreement.Id
        );
		Insert TestDocusignStatus;
        
        TestDocusignSentStatus = new dsfs__DocuSign_Status__c
        (
            dsfs__Envelope_Status__c = 'Sent',
            Agreement__c = TestAgreement.Id
        );
		Insert TestDocusignSentStatus;
        
        TestDocusignAttachment = new Attachment
        (
            Name = 'Random Attachment',
            Body = Blob.valueOf('Random String'),
            ParentID = TestDocusignStatus.Id
        );
		Insert TestDocusignAttachment;
        
        TestBoxDocument = new BoxDocument__c(
            Name = 'random Name',
            PII__c = 'Yes',
            Owner_Type__c = 'Agreement__c',
            Status__c = 'Final',
            Type__c = 'Agreement',
            Agreement__c = TestAgreement.Id,
            send_to_docusign__c = true
        );
        Insert TestBoxDocument;

        TestAccountChanged = new Account(); 
        TestAccountChanged.Name = generateRandomStringBlob();
        TestAccountChanged.Type = 'Client';
        TestAccountChanged.SDS__c = generateRandomStringBlob();
        TestAccountChanged.Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM');
        TestAccountChanged.RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
        insert TestAccountChanged;
        
        //ACCOUNT WITHOUT SDS
        TestAccountWithoutSDS = new Account();
        TestAccountWithoutSDS.Name = generateRandomStringBlob();
        TestAccountWithoutSDS.Type = 'Client';
        TestAccountWithoutSDS.Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM');
        TestAccountWithoutSDS.RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
        insert TestAccountWithoutSDS;

        // COLLATERAL GROUP
        TestCollateralGroup = new Collateral_Group__c
            (
                Name = 'AVIATION BOND',
                Credit_Code__c = 'AVIATION_BOND'
            );
        insert TestCollateralGroup;
        
        // COLLATERAL TYPE
        TestCollateralType = new Collateral_Type__c
            (
                Name = 'AVIATION BOND',
                Collateral_Group__c = TestCollateralGroup.Id,
                Credit_Code__c = 'AVIATION_BOND',
                Push_to_ACM__c = true
            );
        Insert TestCollateralType;
            
        // COLLATERAL
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
        
        AcmCollateralStatus = new Acm_Collateral_Status__c
            (
                Collateral_Id__c = TestCollateral.Id,
                Status__c = 'Not Sent to ACM'
            );
        insert AcmCollateralStatus;
        
        AcmCollateralStatusEmailNotSent = new Acm_Collateral_Status__c
            (
                Collateral_Id__c = TestCollateral.Id,
                Status__c = 'Not Sent',
                Email_Sent__c = false
            );
        insert AcmCollateralStatusEmailNotSent;
       
        
        // COLLATERAL
        TestCollateralUnsaved = new Collateral__c
            (
                Scope__c = 'Facility',
                Name = 'Collateral Test',
                Status__c = 'Outstanding',
                Account__c = TestAccount.Id,
                Collateral_Group__c = TestCollateralGroup.Id,
                Collateral_Type1__c = TestCollateralType.Id
            );
        
        // COLLATERAL
        TestCollateralUnsavedBenef = new Collateral__c
            (
                Scope__c = 'Beneficiary',
                Name = 'Collateral Test',
                Status__c = 'Outstanding',
                Account__c = TestAccount.Id,
                Beneficiary__c = TestAccount.Id,
                Collateral_Group__c = TestCollateralGroup.Id,
                Collateral_Type1__c = TestCollateralType.Id
            );

        //Client Plan
        TestClientPlan = new Client_Plan__c
        (
            Relationship__c = TestAccount.Id
        );
        insert TestClientPlan; 
        
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
        
        TestAcmFacilityChange = new AcmFacility__c
        (   
            Name = 'Test Changed Acm Facility',
            FACILITYCURRENCY__c = 'USD',
            FACILITYAMOUNT__c = 2000000,
            Facility_Id__c = 'Random id Change',
            FACILITYPRODUCT__c = 'Product Name',
            STARTDATE__c = Date.newInstance(1990, 01, 01),
            EXPIRYDATE__c = Date.newInstance(1990, 01, 02),
            FACILITYPRODUCTDESCRIPTION__c = 'Product Description',
            Relationship__c = TestAccount.Id,
            CLIENTPLAN__c = TestClientPlan.Id
        );

        insert TestAcmFacilityChange;
        
        TestFacility = new Facility__c
            (
                Tenure_Period__c = 'YES',
                Status__c = 'Draft',
                Repayment_Profile_Type__c = 'Capitalised',
                Facility_Type__c = 'Term Loan',
                Availability_Start_Date__c = Date.today(),
                Availability_Period__c = 12,
                Availability__c = 'Day(s)',
                Agreement_Account__c = null,
                Agreement__c = TestAgreement.Id,
                AcmFacility__c = TestAcmFacility.Id
            );
        //insert TestFacility;

        // COLLATERAL
        TestCollateralFacilityScope = new Collateral__c
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
        insert TestCollateralFacilityScope;
        
        TestCollateralFacilityScopeWithoutFacility = new Collateral__c
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
        insert TestCollateralFacilityScopeWithoutFacility;
        
       TestCollateralFacilityScope = new Collateral__c
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
        insert TestCollateralFacilityScope;
                
        TestCollateralFacility = new Collateral_Facility__c
            (
                AcmFacility__c = TestAcmFacility.Id,
                Collateral__c = TestCollateralFacilityScope.Id,
                Facility_Client__c = TestAccount.Id,
                isPrimaryRelationship__c = true
            );
        insert TestCollateralFacility;
        
       TestCollateralFacilityNotPrimary = new Collateral_Facility__c
            (
                AcmFacility__c = TestAcmFacilityChange.Id,
                Collateral__c = TestCollateralFacilityScope.Id,
                Facility_Client__c = TestAccount.Id,
                isPrimaryRelationship__c = false
            );
        insert TestCollateralFacilityNotPrimary;
        
        TestAcmIntegration = new AcmIntegration__c
            (
                Name = 'Dev Test Acm Integration',
                Acm_Service_Account_UserName__c = 'Test Username', 
                Acm_Service_Account_Password__c = 'Test Password', 
                X_IBM_Client_Id__c = 'Test Client Id', 
                X_IBM_Client_Secret__c = 'Test Client Secret', 
                IMPERSONATE__c = false, 
                POST_URL__c = 'http:\\posttest.url', 
                GET_URL__c = 'http:\\gettest.url',
                admin_email__c= 'test@email.com'
            );
        
        insert TestAcmIntegration;
        
        //COLLATERAL RELATIONSHIP
        TestCollateralRelationshipBeneficiary = new Collateral_Relationship__c
            (
                Collateral__c = TestCollateral.Id,
                Relationship__c = TestAccount.Id,
                Relationship_Type__c = 'Beneficiary'
            );
        insert TestCollateralRelationshipBeneficiary;
        
        TestCollateralRelationshipBeneficiaryNotPrimary = new Collateral_Relationship__c
            (
                Collateral__c = TestCollateral.Id,
                Relationship__c = TestAccount.Id,
                Relationship_Type__c = 'Beneficiary',
                isPrimaryRelationship__c = false
            );
        insert TestCollateralRelationshipBeneficiaryNotPrimary;
        
        TestCollateralRelationshipProvider = new Collateral_Relationship__c
            (
                Collateral__c = TestCollateral.Id,
                Relationship__c = TestAccount.Id,
                Relationship_Type__c = 'Provider'
            );
        insert TestCollateralRelationshipProvider; 
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
      
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            AcmIntegration__c acmIntegration = [Select POST_URL__c, GET_URL__c FROM AcmIntegration__c LIMIT 1];
            
            POST_URL = acmIntegration.POST_URL__c;
            GET_URL = acmIntegration.GET_URL__c;

            req.setEndpoint(POST_URL);
                        System.debug('The is the requ : ' +req);
            System.assertEquals('application/json', req.getHeader('Content-Type'));
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint() == 'http:\\test.url\FiveHundred') {
                res.setStatus('OK');
                res.setStatusCode(500);
                res.setBody('Error');
            } else if(req.getEndpoint() == 'http:\\test.url\FourHundred') {
                res.setStatus('OK');
                res.setStatusCode(400);
                res.setBody('Association');
            } else if(req.getEndpoint() == 'http:\\test.url\FourHundredAndOne') {
                res.setStatus('OK');
                res.setStatusCode(401);
            } else if(req.getEndpoint() == 'http:\\test.url\FourHundredAndFive') {
                res.setStatus('OK');
                res.setStatusCode(405);
            }  else {
                res.setHeader('Content-Type', 'application/json');
                res.setStatus('OK');
                res.setStatusCode(200);
            }
            return res;
        }
    }
    
    public class MockHttpResponseGeneratorFacilities implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            String body = '[{"FACILITYID":"Random id", "FACILITYPRODUCT":"TestProduct", "FACILITYPRODUCTDESCRIPTION":"Test Product", "FACILITYACTIVE":"Y", "CPTYID":"ClientId", "BANKRISKTAKER":"CARD", "TENORVALUE":31003, "TENORUNIT":"D", "STARTDATE":"2015-02-13", "EXPIRYDATE":"2100-01-01", "FACILITYCURRENCY":"ZAR", "FACILITYAMOUNT":300000, "PARENTFACILITYID":null, "LOSSGIVENDEFAULT":"43.9000000", "MODIFIEDTIMESTAMP":20170815.100239, "MODIFIEDBY":"acmadmin", "IMPAIRMENTDATE":null, "IMPAIRMENTCURRENCY":null, "IMPAIRMENTAMOUNT":null, "BANKAPPLICATIONKEY":"randomKey" }]';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('OK');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}