/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 22/11/2017 - PG    - Created Class.
 13/03/2018 - PG 	- Removed TestSetup method, as new metadata can see records.

**/
@IsTest
private class HotDocs_Test 
{
    public static Map <String, Schema.RecordTypeInfo> AgreementRecordTypes = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
	@IsTest
	static void api_getInterviewUrl()
	{
		Test.startTest();

		HotDocs_API api = new HotDocs_API();
		api.getInterviewUrl('fake hotdocs id', 'fake answer set id'); 

		Test.stopTest();
	}

	@IsTest 
	static void queue_HotDocsRequest_Manual()
	{
		//Test Data
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		//HotDocs_Request
		HotDocs_Helper.createRequest('<fake work id>', testData.TestAgreement.Id, null); 

		Id hotdocsRequestId = [
			SELECT
				Id
			FROM HotDocs_Request__c
			WHERE
				Work_Item_ID__c = '<fake work id>'
			LIMIT 1
		].Id;

		//Insert an existing request item
		HotDocs_Request_Item__c requestItem = new HotDocs_Request_Item__c(
			Item_ID__c = '123',
			HotDocs_Request__c = hotdocsRequestId,
			Type__c = 'Document'
		);
		insert requestItem;

		Test.startTest();

		//Queue job.
		System.enqueueJob(new HotDocs_Request_Queue(hotdocsRequestId));
		
		Test.stopTest();
	}

	@IsTest
	static void api_createToken_Manual()
	{
		Test.startTest();

		HotDocs_API api = new HotDocs_API();
		api.createToken();

		Test.stopTest();
	}

	@IsTest
	static void api_createSession_Manual()
	{
		Test.startTest();

		HotDocs_API api = new HotDocs_API();
		api.createSession('fake hotdocs id', 'fake answer set id');

		Test.stopTest();
	}

	@IsTest
	static void api_createAnswerSet_Manual()
	{
		Test.startTest();

		//New Answer Set
		HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

		//Sample Answers
		List<IHotDocs_Answer> textAnswerList = new List<IHotDocs_Answer>();
		textAnswerList.add(new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data'));
		textAnswerList.add(new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data'));

		//Plain text
		answerSet.add(new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data'));
		answerSet.add(new HotDocs_Answer_Generic('SELECT', 'Sample Variable 2', 'Test Data'));

		//Test both constructors on multi and repeat.
		answerSet.add(new HotDocs_Answer_Multi('Sample Multi', new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data')));
		answerSet.add(new HotDocs_Answer_Repeat('Sample Repeat', new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data')));
		answerSet.add(new HotDocs_Answer_Multi('Sample Multi', textAnswerList));
		answerSet.add(new HotDocs_Answer_Repeat('Sample Repeat', textAnswerList));

		HotDocs_API api = new HotDocs_API();
		api.createAnswerSet('Test Answer', 'Test Description', answerSet); 

		Test.stopTest();
	}

	@IsTest
	static void api_createAnswerSetOverlay_Manual()
	{
		Test.startTest();

		//New Answer Set
		HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

		//Sample Answers
		List<IHotDocs_Answer> textAnswerList = new List<IHotDocs_Answer>();
		textAnswerList.add(new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data'));
		textAnswerList.add(new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data'));

		//Plain text
		answerSet.add(new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data'));
		answerSet.add(new HotDocs_Answer_Generic('SELECT', 'Sample Variable 2', 'Test Data'));

		//Test both constructors on multi and repeat.
		answerSet.add(new HotDocs_Answer_Multi('Sample Multi', new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data')));
		answerSet.add(new HotDocs_Answer_Repeat('Sample Repeat', new HotDocs_Answer_Generic('TEXT', 'Sample Variable', 'Test Data')));
		answerSet.add(new HotDocs_Answer_Multi('Sample Multi', textAnswerList));
		answerSet.add(new HotDocs_Answer_Repeat('Sample Repeat', textAnswerList));

		HotDocs_API api = new HotDocs_API();
		api.createAnswerSetOverlay('Test HotDocs Id','Test Answer', 'Test Description', answerSet); 

		Test.stopTest();
	}

	@IsTest
	static void service_execute_createSession()
	{
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new HotDocs_MockResponse());

		HotDocs_Service service = new HotDocs_Service();
		service.endpoint = 'https://testendpoint.com/Session/CreateSession';
		service.requestMethod = 'POST';

		//Request Headers
		service.requestHeaders.put('Authorization', 'Bearer '+'fake access token');

		//URL parameters
		service.requestParameters.put('templateId', 'fake package id'); 
		service.requestParameters.put('answersetId', 'fake id set'); 

		//Call method.
		service.execute(null);

		Test.stopTest();
	}

	@IsTest
	static void page_HotDocsInterview()
	{
		//Test Data
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		Test.startTest();

		PageReference pageRef = Page.HotDocs_Interview;
		pageRef.getParameters().put('id', testData.TestAgreement.Id);
		Test.setCurrentPage(pageRef);

		HotDocs_Interview controller = new HotDocs_Interview();

		//Set Template ID
		controller.hotDocsTemplateId = 'fake template id';

		//Methods.
		controller.actionLaunchInterview(); 
		HotDocs_Interview.createRequest('fake work item id',testData.TestAgreement.Id, null); 

		Test.stopTest();  
	}

	@IsTest
	static void schedule_Monitoring()
	{
		//Test Data
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		//HotDocs_Request
		HotDocs_Helper.createRequest('<fake work id>', testData.TestAgreement.Id, null);

		Id hotdocsRequestId = [
			SELECT
				Id
			FROM HotDocs_Request__c
			WHERE
				Work_Item_ID__c = '<fake work id>'
			LIMIT 1
		].Id;

		Test.startTest();

		//Run class
		HotDocs_Request_Monitoring scheduledClass = new HotDocs_Request_Monitoring();      
		String testSchedule = '0 0 23 * * ?';
        System.schedule('Test Class', testSchedule, scheduledClass);

		Test.stopTest();
	}
    
    @IsTest
	static void page_HotDocsIsdaInterview()
	{
		//Test Data
		Libra_TestDataClass testData = new Libra_TestDataClass();
        
        advpm__Matter__c testMarketTransactionMatter = new advpm__Matter__c(
            Name='Market Transaction Test',
            RecordTypeId = mapMatterRecordTypes.get('Market Transaction').getRecordTypeId(),
            Bank__c = testData.testBankAccount.id,
            Relationship__c = testData.testRelAccount.id,
            Relationship_Type_picklist__c = 'Asset Manager',
            Master_Agreement_Type__c = 'Prime Services Agreement',
            Netting_Complete__c = true);
        Insert testMarketTransactionMatter;
        
        //AGREEMENT
        Agreement__c testIsdaAgreement = new Agreement__c (
            Matter_Deal__c = testMarketTransactionMatter.id,
            Client_Name__c = testData.testAccount.id,
            name = 'Agreement Name',
            Agreement_Description__c = 'Testing',
            ReviewDate__c = system.today(),
            Limit__c = 5,
            Product__c = testData.testProductLevel2.id,
            Master_Agreement_Required_Prior_to_First__c = true,
            recordTypeId = AgreementRecordTypes.get('ISDA Agreement').getRecordTypeId());
        Insert testIsdaAgreement;

		Test.startTest();

		PageReference pageRef = Page.HotDocs_Interview;
		pageRef.getParameters().put('id', testIsdaAgreement.Id);
		Test.setCurrentPage(pageRef);

		HotDocs_Interview controller = new HotDocs_Interview();

		//Set Template ID
		controller.hotDocsTemplateId = '<fake ISDA work id>';

		//Methods.
		controller.actionLaunchInterview(); 
		HotDocs_Interview.createRequest('<fake ISDA work id>',testIsdaAgreement.Id, null); 
        
        HotDocs_Request__c hotdocsRequest = [
			SELECT
				Id,
            Status__c
			FROM HotDocs_Request__c
			WHERE
				Work_Item_ID__c = '<fake ISDA work id>'
			LIMIT 1
		];
        hotdocsRequest.Status__c = 'Completed';
        
        update hotdocsRequest;
        
        //Queue job.
		System.enqueueJob(new HotDocs_Request_Queue(hotdocsRequest.Id));

		Test.stopTest();  
	}
    
     @IsTest
	static void page_HotDocsGmslaInterview()
	{
		//Test Data
		Libra_TestDataClass testData = new Libra_TestDataClass();
        
        advpm__Matter__c testMarketTransactionMatter = new advpm__Matter__c(
            Name='Market Transaction Test',
            RecordTypeId = mapMatterRecordTypes.get('Market Transaction').getRecordTypeId(),
            Bank__c = testData.testBankAccount.id,
            Relationship__c = testData.testRelAccount.id,
            Relationship_Type_picklist__c = 'Asset Manager',
            Master_Agreement_Type__c = 'Prime Services Agreement',
            Netting_Complete__c = true);
        Insert testMarketTransactionMatter;
        
        //AGREEMENT
        Agreement__c testGmslaAgreement = new Agreement__c (
            Matter_Deal__c = testMarketTransactionMatter.id,
            Client_Name__c = testData.testAccount.id,
            name = 'Agreement Name',
            Agreement_Description__c = 'Testing',
            ReviewDate__c = system.today(),
            Limit__c = 5,
            Product__c = testData.testProductLevel2.id,
            Master_Agreement_Required_Prior_to_First__c = true,
            recordTypeId = AgreementRecordTypes.get('GMSLA Agreement').getRecordTypeId());
        Insert testGmslaAgreement;

		Test.startTest();

		PageReference pageRef = Page.HotDocs_Interview;
		pageRef.getParameters().put('id', testGmslaAgreement.Id);
		Test.setCurrentPage(pageRef);

		HotDocs_Interview controller = new HotDocs_Interview();

		//Set Template ID
		controller.hotDocsTemplateId = '<fake GMSLA work id>';

		//Methods.
		controller.actionLaunchInterview(); 
		HotDocs_Interview.createRequest('<fake GMSLA work id>',testGmslaAgreement.Id, null); 
        
         Id hotdocsRequestId = [
			SELECT
				Id
			FROM HotDocs_Request__c
			WHERE
				Work_Item_ID__c = '<fake GMSLA work id>'
			LIMIT 1
		].Id;
        
        //Queue job.
		System.enqueueJob(new HotDocs_Request_Queue(hotdocsRequestId));

		Test.stopTest();  
	}
    
     @IsTest
	static void page_HotDocsGmraInterview()
	{
		//Test Data
		Libra_TestDataClass testData = new Libra_TestDataClass();
        
        advpm__Matter__c testMarketTransactionMatter = new advpm__Matter__c(
            Name='Market Transaction Test',
            RecordTypeId = mapMatterRecordTypes.get('Market Transaction').getRecordTypeId(),
            Bank__c = testData.testBankAccount.id,
            Relationship__c = testData.testRelAccount.id,
            Relationship_Type_picklist__c = 'Asset Manager',
            Master_Agreement_Type__c = 'Prime Services Agreement',
            Netting_Complete__c = true);
        Insert testMarketTransactionMatter;
        
        //AGREEMENT
        Agreement__c testGmraAgreement = new Agreement__c (
            Matter_Deal__c = testMarketTransactionMatter.id,
            Client_Name__c = testData.testAccount.id,
            name = 'Agreement Name',
            Agreement_Description__c = 'Testing',
            ReviewDate__c = system.today(),
            Limit__c = 5,
            Product__c = testData.testProductLevel2.id,
            Master_Agreement_Required_Prior_to_First__c = true,
            recordTypeId = AgreementRecordTypes.get('GMRA Agreement').getRecordTypeId());
        Insert testGmraAgreement;

		Test.startTest();

		PageReference pageRef = Page.HotDocs_Interview;
		pageRef.getParameters().put('id', testGmraAgreement.Id);
		Test.setCurrentPage(pageRef);

		HotDocs_Interview controller = new HotDocs_Interview();

		//Set Template ID
		controller.hotDocsTemplateId = '<fake GMRA work id>';

		//Methods.
		controller.actionLaunchInterview(); 
		HotDocs_Interview.createRequest('<fake GMRA work id>',testGmraAgreement.Id, null); 
        
        Id hotdocsRequestId = [
			SELECT
				Id
			FROM HotDocs_Request__c
			WHERE
				Work_Item_ID__c = '<fake GMRA work id>'
			LIMIT 1
		].Id;
        
        //Queue job.
		System.enqueueJob(new HotDocs_Request_Queue(hotdocsRequestId));

		Test.stopTest();  
	}
    
     @IsTest
	static void page_HotDocsPrimeServicesInterview()
	{
		//Test Data
		Libra_TestDataClass testData = new Libra_TestDataClass();
        
        Test.startTest();
        advpm__Matter__c testMarketTransactionMatter = new advpm__Matter__c(
            Name='Market Transaction Test',
            RecordTypeId = mapMatterRecordTypes.get('Market Transaction').getRecordTypeId(),
            Bank__c = testData.testBankAccount.id,
            Relationship__c = testData.testRelAccount.id,
            Relationship_Type_picklist__c = 'Collective Investment Scheme Manager',
            Master_Agreement_Type__c = 'Prime Services Agreement',
            Prime_Services_Client__c = 'Yes',
            Netting_Complete__c = true);
        Insert testMarketTransactionMatter;

        //AGREEMENT
        Agreement__c testPrimeServicesAgreement = new Agreement__c (
            Matter_Deal__c = testMarketTransactionMatter.id,
            Client_Name__c = testData.testAccount.id,
            name = 'Agreement Name',
            Agreement_Description__c = 'Testing',
            ReviewDate__c = system.today(),
            Limit__c = 5,
            Product__c = testData.testProductLevel2.id,
            Master_Agreement_Required_Prior_to_First__c = true,
            recordTypeId = AgreementRecordTypes.get('Prime Services Agreement').getRecordTypeId());
        //Insert testPrimeServicesAgreement;
        Id agreementInsertId;
        for(Agreement__c eachAgreement : [ SELECT
                                          Id
                                          FROM Agreement__c
                                          WHERE
                                          Matter_Deal__c =: testMarketTransactionMatter.id
                                          AND Id != null
                                          LIMIT 1
                                         ])
        {
            agreementInsertId = eachAgreement.id;
            
            
            
            
            PageReference pageRef = Page.HotDocs_Interview;
            pageRef.getParameters().put('id', agreementInsertId);
            Test.setCurrentPage(pageRef);
            
            HotDocs_Interview controller = new HotDocs_Interview();
            controller.agreement = testPrimeServicesAgreement;
            
            //Set Template ID
            controller.hotDocsTemplateId = '<fake PRIME work id>';
            
            //Methods.
            controller.actionLaunchInterview(); 
            controller.buildPrimeServicesAnswerFile();
            HotDocs_Interview.createRequest('<fake PRIME work id>',agreementInsertId, null); 
            
            Id hotdocsRequestId = [
                SELECT
                Id
                FROM HotDocs_Request__c
                WHERE
                Work_Item_ID__c = '<fake PRIME work id>'
                LIMIT 1
            ].Id;
            
            //Queue job.
            System.enqueueJob(new HotDocs_Request_Queue(hotdocsRequestId));
        }
		Test.stopTest();  
	}
    
     @IsTest
	static void page_HotDocsCsaInterview()
	{
		//Test Data
		Libra_TestDataClass testData = new Libra_TestDataClass();
        
        advpm__Matter__c testMarketTransactionMatter = new advpm__Matter__c(
            Name='Market Transaction Test',
            RecordTypeId = mapMatterRecordTypes.get('Market Transaction').getRecordTypeId(),
            Bank__c = testData.testBankAccount.id,
            Relationship__c = testData.testRelAccount.id,
            Relationship_Type_picklist__c = 'Asset Manager',
            Master_Agreement_Type__c = 'Prime Services Agreement',
            Netting_Complete__c = true);
        Insert testMarketTransactionMatter;

        //AGREEMENT
        Agreement__c testIsdaAgreement = new Agreement__c (
            Matter_Deal__c = testMarketTransactionMatter.id,
            Client_Name__c = testData.testAccount.id,
            name = 'Agreement Name',
            Agreement_Description__c = 'Testing',
            ReviewDate__c = system.today(),
            Limit__c = 5,
            Product__c = testData.testProductLevel2.id,
            Master_Agreement_Required_Prior_to_First__c = true,
            recordTypeId = AgreementRecordTypes.get('ISDA Agreement').getRecordTypeId());
        Insert testIsdaAgreement;
        
        Supporting_Agreement__c testSupportingAgreement = new Supporting_Agreement__c();
        testSupportingAgreement.Master_Agreement_Type__c = 'ISDA Agreement';
        testSupportingAgreement.Collateral_type__c = 'Bilateral';
        testSupportingAgreement.Transaction_Exposure_Calculation_Method__c = 'Method A';
        testSupportingAgreement.Valuation__c = 50;
        testSupportingAgreement.Valuation_Agent__c = 'Bank';
        testSupportingAgreement.Call_Frequency__c = 'Once Off';
        testSupportingAgreement.Supporting_Agreement_Type__c = 'CSA';
        testSupportingAgreement.Agreement__c = testIsdaAgreement.id;
        Insert testSupportingAgreement;

		Test.startTest();

		PageReference pageRef = Page.HotDocs_Interview;
		pageRef.getParameters().put('id', testIsdaAgreement.Id);
        pageRef.getParameters().put('csaId', testSupportingAgreement.id);
		Test.setCurrentPage(pageRef);

		HotDocs_Interview controller = new HotDocs_Interview();

		//Set Template ID
		controller.hotDocsTemplateId = '<fake ISDA work id>';

		//Methods.
		controller.actionLaunchInterview(); 
		HotDocs_Interview.createRequest('<fake ISDA work id>',testIsdaAgreement.Id, testSupportingAgreement.id); 
        
        Id hotdocsRequestId = [
			SELECT
				Id
			FROM HotDocs_Request__c
			WHERE
				Work_Item_ID__c = '<fake ISDA work id>'
			LIMIT 1
		].Id;
        
        //Queue job.
		System.enqueueJob(new HotDocs_Request_Queue(hotdocsRequestId));

		Test.stopTest();  
	}
}