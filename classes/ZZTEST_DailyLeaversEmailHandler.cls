/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for DailyLeaversEmailHandler
*              Tests executed:
*               1 - testNoFileAttached()
*                   Test that error message is returned if inbound email doesn't have file attached.
*               2 - testMultipleFilesAttached()
*                   Test that error message is returned if inbound email has multiple files attached.
*               3 - testIncorrectFileType1()
*                   Test that error message is returned if attached text file is different than csv format.
*				4 - testIncorrectFileType2()
*					Test that error message is returned if attached binary file is different than csv format.
*				5 - testEmptyFileAttached1()
*					Test that error message is returned if attached text file is empty.
*				6 - testEmptyFileAttached2()
*					Test that error message is returned if attached binary file is empty.
*				7 - testWrongFileFormatOneLine()
*					Test that error message is returned if attached file contains only one line.
*				8 - testWrongFileFormatNoBRID()
*					Test that error message is returned if attached file doesn't contain "BRID" column.
*				9 - testWrongFileFormatNoLeaveActionDate()
*					Test that error message is returned if attached file doesn't contain "Leave Action Date" column.
*				10 - testInvalidRows()
*					Test that error message is returned if attached file contains invalid rows.
*				11 - testBridsNotFound()
*					Test that error message is returned if attached file contains BRIDs that cannot be found.
*				12 - testSuccessfullyProcessed()
*					Test that users are successfully deactivated.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 16/12/2015  Marta Malinowska   Add tests for checking Leave Action Date
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_DailyLeaversEmailHandler
{
	public static testMethod void testNoFileAttached() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, envelope);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testMultipleFilesAttached() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.body = blob.valueOf('binary attachment text');
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
		textAttachment.body = 'text attachment text';
		textAttachment.fileName = 'textFile.txt';
		textAttachment.mimeTypeSubType = 'text/plain';
		email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { textAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, envelope);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testIncorrectFileType1() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
		textAttachment.body = 'text attachment text';
		textAttachment.fileName = 'textFile.txt';
		textAttachment.mimeTypeSubType = 'text/plain';
		email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { textAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, envelope);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testIncorrectFileType2() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.body = blob.valueOf('binary attachment text');
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'text/plain';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, envelope);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testEmptyFileAttached1() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = 'text/plain';

		// add an Text attachment
		Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
		textAttachment.body = '';
		textAttachment.fileName = 'textFile.txt';
		textAttachment.mimeTypeSubType = 'text/plain';
		email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testEmptyFileAttached2() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.body = blob.valueOf('');
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testWrongFileFormatOneLine() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.body = blob.valueOf('text attachment one line');
		binaryAttachment.fileName = 'textFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments =   new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testWrongFileFormatNoBRID() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.body = blob.valueOf('no brid'+DailyLeaversEmailHandler.LINE_SEPARATOR+'00000');
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testWrongFileFormatNoLeaveActionDate() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.body = blob.valueOf('brid'+DailyLeaversEmailHandler.LINE_SEPARATOR+'00000');
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testInvalidRows() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');

		DateTime futureDateTime = Date.today().addDays(1);
		String futureDate = futureDateTime.format('dd/MM/yyyy')+' 00:00';

		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		String header = '"brid"'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'"Leave Action Date"'+DailyLeaversEmailHandler.LINE_SEPARATOR;
		String row1 = '"00000"'+DailyLeaversEmailHandler.LINE_SEPARATOR;
		String row2 = '""'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'""'+DailyLeaversEmailHandler.LINE_SEPARATOR;
		String row3 = '"00003"'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'"incorrect date format"'+DailyLeaversEmailHandler.LINE_SEPARATOR;
		String row4 = '"00004"'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'"dd/mm/yyyy 00:00"'+DailyLeaversEmailHandler.LINE_SEPARATOR;
		String row5 = '"00005"'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'"'+futureDate+'"';
		binaryAttachment.body = blob.valueOf(header+row1+row2+row3+row4+row5);
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testBridsNotFound() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Error_Message_to__c='deloitte@email.com');

		DateTime currentDateTime = Date.today();
		String currentDate = currentDateTime.format('dd/MM/yyyy')+' 00:00';

		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		String header = 'brid'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'Leave Action Date'+DailyLeaversEmailHandler.LINE_SEPARATOR;
		String row = '000000'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+currentDate;
		binaryAttachment.body = blob.valueOf(header+row);
		binaryAttachment.fileName = 'textFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, false);
	}

	public static testMethod void testSuccessfullyProcessed() {
		insert new EmailHandlerSetting__c(Name='DailyLeavers', Send_Success_Message_to__c='deloitte@email.com');
		// create users to be deactivated
		Profile barclaysStdUser = [SELECT Id FROM Profile WHERE Name='Barclays Standard User']; 
		List<User> users = new List<User>();
		for(Integer i=0; i<5; i++){
			users.add(createUser(barclaysStdUser.Id, 'TESTBRID'+i));
		}
		insert users;

		DateTime currentDateTime = Date.today();
		String currentDate = currentDateTime.format('dd/MM/yyyy')+' 00:00';

		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		// setup the data for the email
		email.subject = 'Test Daily Leavers';
		email.fromAddress = 'deloitte@email.com';
		email.plainTextBody = '';

		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		String header = '"brid"'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'"Leave Action Date"';
		String rows = '';
		for(User u : users){
			rows += DailyLeaversEmailHandler.LINE_SEPARATOR+'"'+u.BRID__c+'"'+DailyLeaversEmailHandler.COLUMN_SEPARATOR+'"'+currentDate+'"';
		}
		binaryAttachment.body = blob.valueOf(header+rows);
		binaryAttachment.fileName = 'binaryFile.csv';
		binaryAttachment.mimeTypeSubType = 'application/vnd.ms-excel';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };

		DailyLeaversEmailHandler dailyLeavers = new DailyLeaversEmailHandler();
		Test.startTest();
			// call the inbound email handler
			Messaging.InboundEmailResult result = dailyLeavers.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(result.success, true);
		for(User u : [SELECT Id, Name, IsActive FROM User WHERE BRID__c LIKE 'TESTBRID%']){
			System.assertEquals(u.IsActive, false);
		}
	}

	public static User createUser(Id profileId, String brid){
		User u = new User(Alias = 'barclays', Email='barclays@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_ZA', ProfileId = profileId, BRID__c = brid,
				TimeZoneSidKey='Africa/Johannesburg', UserName=brid+'@testorg.com');
		return u;
	}

}