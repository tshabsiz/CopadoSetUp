/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests - Day1Template 
*
*	12-May-2016 - Mohsin Wadee - US-1089 - in getSampleDay1Template() method had to specify a Client On Boarding object for the test Day 1
*											Template being created.
*/
@isTest
public class ZZTEST_Day1Template {
	
	@isTest static void testSendDay1Template() 
	{
        User user1 = [Select ID from user where id =:userInfo.getUserId()];
        
        System.runAs(user1)
        {
		Day_1_Template__c day1 = ZZTEST_Day1Template.getSampleDay1Template();
		ZZTEST_Day1Template.setUpCustomSettings();
		ZZTEST_Day1Template.attachGStoDay1Template(day1);

		ApexPages.StandardController sc = new ApexPages.StandardController(day1);
		PageReference SendDay1Template = Page.SendDay1Template;
        ApexPages.currentPage().getParameters().put('id',day1.id);
        Test.setCurrentPage(SendDay1Template);

        SendDay1TemplateEmail sendController = new SendDay1TemplateEmail(sc);

        sendController.sendDay1TemplateAsEmail();
        }
	}

	@isTest static void testSendDay1TemplateTestErrors() 
	{
        User user1 = [Select ID from user where id =:userInfo.getUserId()];
        
        System.runAs(user1)
        {
            Day_1_Template__c day1 = ZZTEST_Day1Template.getSampleDay1Template();
            ZZTEST_Day1Template.setUpCustomSettings();
            ZZTEST_Day1Template.attachGStoDay1TemplateErrors(day1);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(day1);
            PageReference SendDay1Template = Page.SendDay1Template;
            ApexPages.currentPage().getParameters().put('id',day1.id);
            Test.setCurrentPage(SendDay1Template);
            
            SendDay1TemplateEmail sendController = new SendDay1TemplateEmail(sc);
            sendController.sendDay1TemplateAsEmail();
        }
		
	}

	private static Day_1_Template__c getSampleDay1Template()
	{
        // Create data container.
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        // Create test account.
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        // Create test contact.
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
    	Contact con = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        // Create test Client On-Boarding.
        Client_On_Boarding__c clientOnBoarding = new Client_On_Boarding__c();
        clientOnBoarding.Client_Contact__c = con.Id;
        clientOnBoarding.Responsible_Department__c = 'New to Bank';
        clientOnBoarding.Priority__c = 'High';
        clientOnBoarding.Type__c = 'New to bank on-boarding (NTB)';
        clientOnBoarding.Case_Category__c = 'DAY 1 TEMPLATE';
        clientOnBoarding.Subject__c = 'Day 1 Template Test Client On-Boarding';
        clientOnBoarding.Relationship_Name__c = acc.Id;
        insert clientOnBoarding;
        
		Day_1_Template__c day1 = new Day_1_Template__c();
        day1.Client_On_Boarding__c = clientOnBoarding.Id;
		
        day1.Primary_Legal_Entity__c = acc.Id;
        try {
			insert day1;
		} catch(Exception e)
		{
			System.debug('XXXXXXXXXXXXXX day1 template sample insert failed ' + e.getMessage());
		}
		return day1;
	}

	private static void attachGStoDay1TemplateErrors(Day_1_Template__c day1)
	{
		ApexPages.StandardController sc = new ApexPages.StandardController(day1);
		PageReference Day1TemplateGSAtt = Page.Day1TemplateGSAtt;
        ApexPages.currentPage().getParameters().put('id',day1.id);

        Day1TemplateGSAttController day1AttController = new Day1TemplateGSAttController(sc);
        day1AttController.fileBody = null; //Blob.valueOf('UNIT.TEST');
        day1AttController.fileName = '';
        day1AttController.processUpload();
        day1AttController.back();
	}

	private static void attachGStoDay1Template(Day_1_Template__c day1)
	{
		ApexPages.StandardController sc = new ApexPages.StandardController(day1);
		PageReference Day1TemplateGSAtt = Page.Day1TemplateGSAtt;
        ApexPages.currentPage().getParameters().put('id',day1.id);

        Day1TemplateGSAttController day1AttController = new Day1TemplateGSAttController(sc);
        day1AttController.fileBody = Blob.valueOf('UNIT.TEST');
        day1AttController.fileName = 'UNITTEST';
        day1AttController.processUpload();
	}

	private static void setUpCustomSettings()
	{
		Day_1_TemplateCS__c c = new Day_1_TemplateCS__c();
		c.Name = 'SendToGroupAddress';
        c.SendToGroupAddress__c = 'jcicharski@deloittece.com';
        try {
			insert c;
		} catch(Exception e)
		{
			System.debug('XXXXXXXXXXXXXX custom settings insert for day1template (email address) failed: ' + e.getMessage());
		}
	}
}