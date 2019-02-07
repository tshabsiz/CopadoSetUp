/**
* Date   : 14-07-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Case_Functions
**/
@IsTest(SeeAllData=true)
public class CSC_Case_Functions_Test {

    
    public static testMethod void functionTest(){
        
        //create some service mapping data
        //Service mapping
        CSC_TestDataFactory.testDataSize = 1;
        
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        
        //test cases
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        
        Test.startTest();
        
            CSC_Case_Functions cf = new CSC_Case_Functions('Passwords@absa.co.za');
            String q = cf.getQueueName();
            
            System.assertEquals('EBSH - Passwords', q);
        	
        	CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
            emailService.handleInboundEmail(email, env);

           	list<Case> c = [Select Id, Queue__c, Department__c, Service_Type__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
       	   	c[0].Queue__c = 'EBSH - Passwords';
        	c[0].Department__c = 'EBSH';
        	c[0].Service_Type__c = 'System';
        	update c[0];
        	
        	CSC_Case_Functions cscf = new CSC_Case_Functions(c[0]);
        
        	map<String,String> svMap = cscf.getServiceMapping();
        
			list<DateTime> datelist = cscf.getSLAEndDate(System.Now());
            Boolean b = cscf.isChannelValid();
            String fd = cscf.getFullDepartment();
        	String dep = cscf.getDepartment();
            String comp = cscf.getComplexity();
            String fa = cscf.getFirstApproval();
            String idv = cscf.getIDVRequired();
            String pri = cscf.getPriority();
            String se = cscf.getSecondEscalationTime();
            String qapi = cscf.getQueueAPIName();
            String qn = cscf.getQueueName();
            String t = cscf.getTeam();
            String tm = cscf.getTeamManager();
            String sa = cscf.getSecondApproval();
            String sla = cscf.getSLA();
            String fet = cscf.getFirstEscalationTime();
            String bh = cscf.getBusinessHours();
            String ri = cscf.getRecordId();
            String sea = cscf.getSupportEmailAddress();
            DateTime meDate = cscf.getFeedbackDueDate(System.Today());

        Test.stopTest();
    }
    
}