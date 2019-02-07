/**
* @author Deloitte 
* @date 2015
*
* @group Tests
*
* @description methods to test BCMS integration
*/
               
//@isTest
global class ZZTEST_BCMSIntegration {

    private static final String REFERENCE_ID = 'a0H25000001XqbR';
    private static final Datetime CREATED_TIME = System.now();
    private static final String CASE_ID = '24484f01-761f-45dd-bec1-3279890d4b94';
    private static final String DOC_ID = '25584f01-761f-67dd-aec1-325670d4b94';
    private static final String DOC_ID2 = '25584f01-761f-67dd-aec1-32sdf674b94';
    private static final String STATIC_RESOURCE_NAME = 'Picklists';
    private static final String FILE_EXTENSION = 'txt';
    private static final String SIC_FILE_NAME = 'SICJSON';

    /**
    * @description method to handle creation of different WS mocks. Method routes different webcalls to proper endpoints
    * @param Object stub, 
    * @param Object request, 
    * @param Map<String, Object> response,
    * @param String endpoint, 
    * @param String soapAction, 
    * @param String requestName,
    * @param String responseNS, 
    * @param String responseName, 
    * @param String responseType
    * @return no return value
    */ 
    public class ZZTEST_MockDispatcher implements WebServiceMock {
        public void doInvoke(
            Object stub, 
            Object request, 
            Map<String, Object> response,
            String endpoint, 
            String soapAction, 
            String requestName,
            String responseNS, 
            String responseName, 
            String responseType) {
                if(requestName == 'CreateCase')
                    new ZZTEST_WebServiceMockCreateCase().doInvoke(
                        stub, request, response, 
                        endpoint, soapAction, requestName, 
                        responseNS, responseName, responseType);
                else if(requestName == 'GetCaseByReferenceNumber')
                    new ZZTEST_WebServiceMockRetrieveCase().doInvoke(
                        stub, request, response, 
                        endpoint, soapAction, requestName, 
                        responseNS, responseName, responseType);
                else if(requestName == 'CreateDocument')
                    new ZZTEST_WebServiceMockCreateDoc().doInvoke(
                        stub, request, response, 
                        endpoint, soapAction, requestName, 
                        responseNS, responseName, responseType);
                //else if(requestName == 'GetDocumentsForCase')
                    //new ZZTEST_WebServiceMockRetreiveDocs().doInvoke(
                        //stub, request, response, 
                        //endpoint, soapAction, requestName, 
                        //responseNS, responseName, responseType);
            }
    }

    /**
    * @description Mock WS for case creation
    * @param Object stub, 
    * @param Object request, 
    * @param Map<String, Object> response,
    * @param String endpoint, 
    * @param String soapAction, 
    * @param String requestName,
    * @param String responseNS, 
    * @param String responseName, 
    * @param String responseType
    * @return no return value
    */ 
    public class ZZTEST_WebServiceMockCreateCase {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                WS_BCMS.CreateCaseResponse_element respElement = new WS_BCMS.CreateCaseResponse_element();
                //prepare data
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
                ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
                Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);
                //initialize class
                BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
                WS_BCMS.Case_x caseToRetrieve = new WS_BCMS.Case_x();
                caseToRetrieve = bcmsIntH.createCase_x(bcmsIntH.getDay1Record(day1Temp.Id));
                caseToRetrieve.ReferenceNumber = REFERENCE_ID;
                caseToRetrieve.Id = CASE_ID;

                respElement.createdCase = caseToRetrieve;
                response.put('response_x', respElement); 
            }
    }

    /**
    * @description Mock WS for retreive case
    * @param Object stub, 
    * @param Object request, 
    * @param Map<String, Object> response,
    * @param String endpoint, 
    * @param String soapAction, 
    * @param String requestName,
    * @param String responseNS, 
    * @param String responseName, 
    * @param String responseType
    * @return no return value
    */ 
    public class ZZTEST_WebServiceMockRetrieveCase {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response1,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                WS_BCMS.GetCaseByReferenceNumberResponse_element respElementCase = new WS_BCMS.GetCaseByReferenceNumberResponse_element();

                //prepare data
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
                ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
                Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);
                //initialize class
                BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
                WS_BCMS.Case_x caseToRetrieve = new WS_BCMS.Case_x();
                caseToRetrieve = bcmsIntH.createCase_x(bcmsIntH.getDay1Record(day1Temp.Id));
                caseToRetrieve.ReferenceNumber = REFERENCE_ID;
                caseToRetrieve.Id = CASE_ID;
                
                respElementCase.theCase = caseToRetrieve;
                response1.put('response_x', respElementCase);
            }
    }

    /**
    * @description Mock WS for document retrieval
    * @param Object stub, 
    * @param Object request, 
    * @param Map<String, Object> response,
    * @param String endpoint, 
    * @param String soapAction, 
    * @param String requestName,
    * @param String responseNS, 
    * @param String responseName, 
    * @param String responseType
    * @return no return value
    */ 
    
    /*
    public class ZZTEST_WebServiceMockRetreiveDocs {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                WS_BCMS.GetDocumentsForCaseResponse_element respElement = new WS_BCMS.GetDocumentsForCaseResponse_element();

                //prepare data
                
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
                ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
                Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);
                List<BCMSIntegration_Helper.BCMSDocumentWrapper> docToRetrieve = new List<BCMSIntegration_Helper.BCMSDocumentWrapper>();
                // add attachment to day1template
                Attachment attach = new Attachment();       
                    attach.Name= 'Unit Test Attachment';
                    Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
                    attach.Body = bodyBlob;
                    attach.ParentId = day1Temp.Id;
                    attach.ContentType = 'txt';
                    attach.Description = 'This is my description';
                insert attach;
                //initialize class
                BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
                docToRetrieve = bcmsIntH.createDocument(day1Temp.Id, CASE_ID);
                docToRetrieve[0].documentToCreate.Id = DOC_ID;
                //prepare response
                respElement.documents = new List<WS_BCMS.Document>();
                for(BCMSIntegration_Helper.BCMSDocumentWrapper wrap : docToRetrieve) {
                    respElement.documents.add(wrap.documentToCreate);
                }
                response.put('response_x', respElement);
            }
    }
	*/

        /**
    * @description Mock WS for document creation returning docs
    * @param Object stub, 
    * @param Object request, 
    * @param Map<String, Object> response,
    * @param String endpoint, 
    * @param String soapAction, 
    * @param String requestName,
    * @param String responseNS, 
    * @param String responseName, 
    * @param String responseType
    * @return no return value
    */ 
    public class ZZTEST_WebServiceMockCreateDoc {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                WS_BCMS.CreateDocumentResponse_element respElement = new WS_BCMS.CreateDocumentResponse_element();

                //prepare data
                /*
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
                ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
                Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);
                List<BCMSIntegration_Helper.BCMSDocumentWrapper> docsToRetrieve = new List<BCMSIntegration_Helper.BCMSDocumentWrapper>();
                // add attachment to day1template
                Attachment attach = new Attachment();       
                    attach.Name= 'Unit Test Attachment';
                    Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
                    attach.Body = bodyBlob;
                    attach.ParentId = day1Temp.Id;
                    attach.ContentType = 'txt';
                    attach.Description = 'This is my description';
                insert attach;
                //initialize class
                BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
                docsToRetrieve = bcmsIntH.createDocument(day1Temp.Id, CASE_ID);
                docsToRetrieve[0].documentToCreate.Id = DOC_ID;
                System.debug('XXXXXXXXXX docs from mock docsToRetrieve' + docsToRetrieve);
                //prepare response
                respElement.newDocument = docsToRetrieve[0].documentToCreate;
                response.put('response_x', respElement);
				*/
            }
    }      

    /**
    * @description testing of createcase WS call
    * @param No params
    * @return no return value
    */ 
    //static testMethod void testBCMSCreateCase() {
        static void testBCMSCreateCase() {
        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());
        
        //get the obejct I need to send to WS
        Day_1_Template__c day1data = bcmsIntH.getDay1Record(day1Temp.Id);

        Test.startTest();
            // Call the method that invokes a callout
            WS_BCMS.Case_x output = bcmsIntH.saveBCMSCase(day1data);
        Test.stopTest();
        // Verify that a fake result is returned
        System.debug('XXXXXXXXXX outcome' + output);
        System.assertEquals(REFERENCE_ID, output.ReferenceNumber); 
    }
    
    /**
    * @description testing of retreive case WS call
    * @param No params
    * @return no return value
    */
    //static testMethod void testBCMSRetreiveCase() {
        static void testBCMSRetreiveCase() {
        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();
            // Call the method that invokes a callout
            WS_BCMS.Case_x output = bcmsIntH.retreiveCaseByReferenceNumber(REFERENCE_ID);
        Test.stopTest();
        // Verify that a fake result is returned
        System.debug('XXXXXXXXXX outcome' + output);
        System.assertEquals(REFERENCE_ID, output.ReferenceNumber); 

    }

    /**
    * @description testing of functionality to inform user about missing fields that are required
    * @param No params
    * @return no return value
    */
    //static testMethod void testCheckForEmptyFields() {
        static void testCheckForEmptyFields() {

        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);

        //make sure checked values are empty
        day1Temp.Primary_Legal_Entity__r.Registration_Number__c = null;
        day1Temp.spccn__r.FirstName = null;
        day1Temp.spccn__r.Phone = null;
        day1Temp.spccn__r.Email = null;
        day1Temp.Primary_Legal_Entity__r.BillingStreet = null;
        day1Temp.Primary_Legal_Entity__r.BillingCity = null;
        day1Temp.Primary_Legal_Entity__r.BillingPostalCode = null;
        day1Temp.Primary_Legal_Entity__r.BillingCountry = null;
        day1Temp.SIC_Description__c = null;
        day1Temp.ISC_Description__c = null;
        day1Temp.Legal_Entity__c = null;
        day1Temp.Dosp__c = null;
        day1Temp.MI_Flag__c = null;

        update day1Temp;

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        Test.startTest();

            String returnedErrors = bcmsIntH.checkValuesForDay1Fields(day1Temp);

        Test.stopTest();

        System.assertEquals(true, returnedErrors.containsAny('Please fill'));
    }    

    /**
    * @description testing of create docs WS call
    * @param No params
    * @return no return value
    */
    //static testMethod void testAttachments() {
    
    	/*
        static void testAttachments() {

        List<BCMSIntegration_Helper.BCMSDocumentWrapper> documents = new List<BCMSIntegration_Helper.BCMSDocumentWrapper>();
        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);
        List<WS_BCMS.Document> createdDocs = new List<WS_BCMS.Document>();

        // add attachment to day1template
        Attachment attach = new Attachment();       
            attach.Name= 'Unit Test Attachment';
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.Body = bodyBlob;
            attach.ParentId = day1Temp.Id;
            attach.ContentType = 'txt';
            attach.Description = 'This is my description';
        insert attach;
        
        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();

            documents = bcmsIntH.createDocument(attach.Id, CASE_ID);

            for(BCMSIntegration_Helper.BCMSDocumentWrapper wrap : documents) {
                WS_BCMS.Document createdDoc = bcmsIntH.saveBCMSDocument(wrap.documentToCreate);
                createdDocs.add(createdDoc);
            }

        Test.stopTest();
        System.assertEquals(DOC_ID, createdDocs[0].Id);
    }
	*/

    /**
    * @description testing of method handling case and docs creation
    * @param No params
    * @return no return value
    */
    //static testMethod void testCreateBCMSCase() {
        static void testCreateBCMSCase() {

        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();
            String outcome = bcmsIntH.createBCMSCase(day1Temp.Id);
        Test.stopTest();
    }

    //static testMethod void testreturnCaseDocs() {
        static void testreturnCaseDocs() {

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();
            List<String> returnedDocs = bcmsIntH.returnCaseDocs(CASE_ID);
        Test.stopTest();

        System.assertEquals(DOC_ID, returnedDocs[0]);
    }

    //static testMethod void testCreateBCMSDocument() {
        static void testCreateBCMSDocument() {
        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getInsertedProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        // add attachment to day1template
        Attachment attach = new Attachment();       
            attach.Name= 'Unit Test Attachment';
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.Body = bodyBlob;
            attach.ParentId = day1Temp.Id;
            attach.ContentType = 'txt';
            attach.Description = 'This is my description';
        insert attach;
        
        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();
            String returnedDoc = bcmsIntH.createBCMSDocument(attach.Id, CASE_ID, day1Temp.Id);
        Test.stopTest();
        System.assertEquals(true, returnedDoc.containsAny('The document has been created'));

        List<BCMSDocumentIdPairing__c> pairing = [SELECT Id, BCMSDocumentId__c, SFDocumentId__c FROM BCMSDocumentIdPairing__c];
        System.assertEquals(DOC_ID, pairing[0].BCMSDocumentId__c);

    }

    //static testMethod void testReturnJSONStringAndParse() {
        static void testReturnJSONStringAndParse() {

        //it is not possible to mock static resources in a zip file (summer 15), so I am using Test.isRunningTest to get specific string for testing purposes
        String returnedJsonString = BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, SIC_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME);
        
        Map<String, String> parsedJson = BCMSIntegration_Helper.returnPicklistMap(returnedJsonString);

        System.assertEquals(1155, Integer.ValueOf(parsedJson.get('1 - MONETARY AUTHORITY')));
    }

    //static testMethod void testUpdateBcmsCaseHandler() {
        static void testUpdateBcmsCaseHandler() {

        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);

        String xml = ''
                + '<BCMSCase xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                + '<EventMessageType>AttestationResponse</EventMessageType>'
                + '<InstructionID>3490</InstructionID>'
                + '<AttestationResponse></AttestationResponse>'
                + '</BCMSCase>';

        day1Temp.BCMSXMLData__c = xml;
        day1Temp.BCMS_Client_Id__c = CASE_ID;

        insert day1Temp;

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();
            String outcome = bcmsIntH.updateBcmsCaseHandler(day1Temp.Id);
        Test.stopTest();       
    }

    //static testMethod void testupdateBCMSCase() {
        static void testupdateBCMSCase() {

        //prepare data
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Day1Template day1TempFactory = ZZTEST_DataFactoryFacade.day1Template;
        Day_1_Template__c day1Temp = day1TempFactory.getProduct(ZZTEST_F_Day1Template.Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE, dataContainer);

        String xml = ''
                + '<BCMSCase xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                + '<EventMessageType>AttestationResponse</EventMessageType>'
                + '<InstructionID>3490</InstructionID>'
                + '<AttestationResponse></AttestationResponse>'
                + '</BCMSCase>';

        day1Temp.BCMSXMLData__c = xml;
        day1Temp.BCMS_Client_Id__c = CASE_ID;

        insert day1Temp;

        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

        Test.setMock(WebServiceMock.class, new ZZTEST_MockDispatcher());

        Test.startTest();
            WS_BCMS.Case_x outcome = bcmsIntH.updateBCMSCase(day1Temp);
        Test.stopTest();       
    }    

}