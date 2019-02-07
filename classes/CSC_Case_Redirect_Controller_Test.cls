/**
* Date   : 11-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Case_Redirect_Controller
**/
@IsTest(SeeAllData=true)
public class CSC_Case_Redirect_Controller_Test {
	
    public static testMethod void redirectTest() {
        
        CSC_TestDataFactory.testDataSize = 1;
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
        
        list<Case> Cases = CSC_TestDataFactory.getTestCaseList('Internal Support Case', u.Id);
        insert Cases;
        //list<EmailMessage> ems = CSC_TestDataFactory.getTestEmailMessageList(Cases[0].Id, true);
           
            
         //inbound email and envelope objects
        //Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        //Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        //email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        //CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        
        Test.startTest();
        
        insert sm; 	
        
        //emailService.handleInboundEmail(email, env);
        list<Case> newCase = [Select Id, Queue__c, Department__c,Service_Type__c,SLA_Time_Measure__c, SLA_Units__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
        newCase[0].Queue__c = sm.Queue__c;
        newCase[0].Department__c = sm.Department__c; 
        newCase[0].Service_Type__c = sm.Service_Type__c;
        newCase[0].RecordTypeId = CSC_TestDataFactory.mapCaseRecordTypes.get('CSC Manual Cases').getRecordTypeId();
            
        PageReference pageRef = Page.CSC_Case_Redirect;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
         
        ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
        CSC_Case_Redirect_Controller theCont = new CSC_Case_Redirect_Controller(controller);

        theCont.redirectUser();  
        
        Test.stopTest();
	}
    public static testMethod void redirectTestTwo() 
    {
        CSC_TestDataFactory.testDataSize = 1;
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
        
        list<Case> Cases = CSC_TestDataFactory.getTestCaseList('Internal Support Case', u.Id);
        insert Cases;
               
        Test.startTest();
        
        insert sm; 	
        
        list<Case> newCase = [Select Id, Queue__c, Department__c,Service_Type__c,SLA_Time_Measure__c, SLA_Units__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
        newCase[0].Queue__c = sm.Queue__c;
        newCase[0].Department__c = sm.Department__c; 
        newCase[0].Service_Type__c = sm.Service_Type__c;
        newCase[0].RecordTypeId = CSC_TestDataFactory.mapCaseRecordTypes.get('MNPI Complaint').getRecordTypeId();
            
        PageReference pageRef = Page.CSC_Case_Redirect;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
         
        ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
        CSC_Case_Redirect_Controller theCont = new CSC_Case_Redirect_Controller(controller);

        theCont.redirectUser();  
        
        Test.stopTest();

    }
    public static testMethod void redirectTestThree() 
    {
        CSC_TestDataFactory.testDataSize = 1;
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
        
        list<Case> Cases = CSC_TestDataFactory.getTestCaseList('Internal Support Case', u.Id);
        insert Cases;
               
        Test.startTest();
        
        insert sm; 	
        
        list<Case> newCase = [Select Id, Queue__c, Department__c,Service_Type__c,SLA_Time_Measure__c, SLA_Units__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
        newCase[0].Queue__c = sm.Queue__c;
        newCase[0].Department__c = sm.Department__c; 
        newCase[0].Service_Type__c = sm.Service_Type__c;
        newCase[0].RecordTypeId = CSC_TestDataFactory.mapCaseRecordTypes.get('Digital Ops Cases').getRecordTypeId();
            
        PageReference pageRef = Page.CSC_Case_Redirect;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
         
        ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
        CSC_Case_Redirect_Controller theCont = new CSC_Case_Redirect_Controller(controller);

        theCont.redirectUser();  
        
        Test.stopTest();

    }
}