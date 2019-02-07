/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used to process Daily Leavers csv file received via email.
* @Date:        07/2015
* @ConstructorParam:    
* @TestClass:   ZZTEST_DailyLeaversEmailHandler
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 16/12/2015  Marta Malinowska	 Check Leave Action Date and deactivate only future dated leavers
*------------------------------------------------------------*/
global class DailyLeaversEmailHandler implements Messaging.InboundEmailHandler {

	public static String SUCCESS_EMAIL_SUBJECT = 'Salesforce Daily Leavers Processed Successfully';
	public static String ERROR_EMAIL_SUBJECT = 'Salesforce Daily Leavers Processing Error';

	public static String PROCESSED_SUCCESSFULLY = 'Request has been processed successfully.';
	public static String NOT_PROCESSED_SUCCESSFULLY = 'Request has NOT been processed successfully.\n\n';
	public static String NOT_ALL_PROCESSED_SUCCESSFULLY = 'Request has NOT been processed successfully.\n\n';

	public static String NO_FILE_ATTACHED = 'File has not been attached.';
	public static String MORE_THAN_ONE_FILE_ATTACHED = 'More than one file has been attached.\n';
	public static String EMPTY_FILE = 'Attached file is empty.\n';
	public static String INCORRECT_FILE_TYPE = 'Incorrect type of attached file. Only Microsoft Excel Comma Separated Values File (.csv) is accepted.\n';
	public static String FILE_TOO_BIG = 'File is too big. Only attachments with size less or equal to 5MB are accepted.\n';
	public static String TOO_MANY_ROWS = 'File has too many rows to process. Maximum accepted number of rows is 10 000.\n';
	public static String WRONG_FORMAT_ONE_LINE = 'Attached file has wrong format. Please check if:\n1) rows are put in seperate lines\n2) attached file contains header\n3) attached file contains at least one row to process.\n';
	public static String WRONG_FORMAT_NO_BRID = 'Attached file has wrong format. Please check if:\n1) attached file is in csv format\n2) attached file contains header\n3) header contains "BRID" column.\n';
	public static String WRONG_FORMAT_NO_LEAVE_ACTION_DATE = 'Attached file has wrong format. Please check if:\n1) attached file is in csv format\n2) attached file contains header\n3) header contains "Leave Action Date" column.\n';
	public static String INVALID_ROWS_MSG = 'Please find file  attached with listed rows that cannot be processed.\n';
	public static String CANNOT_DEACTIVATE_USERS = 'Please find file attached with listed BRIDs that cannot be processed.\n';

	public static String HEADER_BRID = 'BRID';
	public static String HEADER_LEAVE_DATE = 'LEAVE ACTION DATE';
	public static String LINE_SEPARATOR = '\r\n';
	public static String COLUMN_SEPARATOR = ',';
	public static String MIME_TYPE_MS_EXCEL = 'application/vnd.ms-excel';
	public static String MIME_TYPE_OCTET_STREAM = 'application/octet-stream';
	public static Integer ONE_MB = 1048576;
	public static Integer MAX_NUMBER_OF_ROWS = 10000;

	private Boolean sendErrorMsg;
	private Boolean sendSuccessMsg;
	private List<Messaging.EmailFileAttachment> errorMsgEmailAttachments;
	private List<Messaging.EmailFileAttachment> successMsgEmailAttachments;
	private Integer BRID_INDEX;
	private Integer LEAVE_ACTION_DATE_INDEX;
	private List<String> rows;
	private List<String> invalidRows;
	private Map<Id, User> usersToDeactivate;
	private Set<String> bridsToDeactivate;
	private List<String> processedRecords;
	private List<String> notProcessedRecords;

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to process daily leavers file attachment sent by email.
    * @param        Messaging.InboundEmail - email message with attachments
    * @param        Messaging.InboundEnvelope - email envelope
    * @Returns:     Messaging.InboundEmailResult - true if processed successfully
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

		//Set send email message flag in case of error/success
		EmailHandlerSetting__c DailyLeavers = EmailHandlerSetting__c.getInstance('DailyLeavers');
		List<String> sendErrorMsgTo = new List<String>();
		List<String> sendSuccessMsgTo = new List<String>();
		if(DailyLeavers != null){
			if(DailyLeavers.Send_Error_Message_to__c != null){
				sendErrorMsgTo = DailyLeavers.Send_Error_Message_to__c.split(',');
			}
			if(DailyLeavers.Send_Success_Message_to__c != null){
				sendSuccessMsgTo = DailyLeavers.Send_Success_Message_to__c.split(',');
			}
		}
		sendErrorMsg = sendErrorMsgTo.isEmpty() ? false : true;
		sendSuccessMsg = sendSuccessMsgTo.isEmpty() ? false : true;

		//Get email attachments
		List<Messaging.InboundEmail.BinaryAttachment> binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
		List<Messaging.Inboundemail.TextAttachment> textAttachments = new List<Messaging.Inboundemail.TextAttachment>();
		if(email.binaryAttachments != null){
			binaryAttachments = email.binaryAttachments;
		} 
		if(email.textAttachments != null){
			textAttachments = email.textAttachments;
		}

		errorMsgEmailAttachments = new List<Messaging.EmailFileAttachment>();
		String filesErrorMsg = checkAttachedFiles(binaryAttachments, textAttachments);
		if(String.isNotBlank(filesErrorMsg)){
			result.success = false;
			if(sendErrorMsg){
				sendEmailResponse(ERROR_EMAIL_SUBJECT, NOT_PROCESSED_SUCCESSFULLY+filesErrorMsg, sendErrorMsgTo, errorMsgEmailAttachments);
			}
			return result;
		}

		invalidRows = new List<String>();
		bridsToDeactivate = new Set<String>();
		usersToDeactivate = new Map<Id, User>();

		//Process Rows
		Boolean allRowsProcessedSuccessfully = processRows();
		if(!allRowsProcessedSuccessfully){
			errorMsgEmailAttachments.add(createEmailAttachment('Invalid_Rows.csv', createAttachmentBody(invalidRows), MIME_TYPE_MS_EXCEL));
		}

		//Process Records
		processedRecords = new List<String>();
		notProcessedRecords = new List<String>();
		Boolean allUsersActiveAndFound = findUsersToDeactivate();
		Boolean allUsersDeactivatedSuccessfully = deactivateUsers();
		if(!allUsersActiveAndFound || !allUsersDeactivatedSuccessfully){
			errorMsgEmailAttachments.add(createEmailAttachment('Deactivation_Errors.csv', createAttachmentBody(notProcessedRecords), MIME_TYPE_MS_EXCEL));
		}
		successMsgEmailAttachments = new List<Messaging.EmailFileAttachment>();
		successMsgEmailAttachments.add(createEmailAttachment('Deactivated_Users_'+DateTime.now()+'.csv', createAttachmentBody(processedRecords), MIME_TYPE_MS_EXCEL));

		if(allRowsProcessedSuccessfully && allUsersActiveAndFound && allUsersDeactivatedSuccessfully){
			result.success = true;
			sendEmailResponse(SUCCESS_EMAIL_SUBJECT, PROCESSED_SUCCESSFULLY, sendSuccessMsgTo, successMsgEmailAttachments);
		} else{
			result.success = false;
			if(sendErrorMsg){
				sendEmailResponse(ERROR_EMAIL_SUBJECT, NOT_PROCESSED_SUCCESSFULLY+CANNOT_DEACTIVATE_USERS, sendErrorMsgTo, errorMsgEmailAttachments);
			}
			if(sendSuccessMsg){
				sendEmailResponse(ERROR_EMAIL_SUBJECT, NOT_PROCESSED_SUCCESSFULLY, sendSuccessMsgTo, successMsgEmailAttachments);
			}
		}

		return result;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to check if only one file has been attached, file type is correct and file is not empty .
    * @param        List of binary attachments
    * @param        List of text attachments
    * @Returns:     String - error message in case of errors, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public String checkAttachedFiles(List<Messaging.InboundEmail.BinaryAttachment> binaryAttachments, List<Messaging.Inboundemail.TextAttachment> textAttachments){
		//Check if there is any attached file
		if(binaryAttachments.isEmpty() && textAttachments.isEmpty()){
			return NO_FILE_ATTACHED;
		}

		//Check if there is more than one file attached
		if(binaryAttachments.size()+textAttachments.size() > 1){
			String emailMsg = MORE_THAN_ONE_FILE_ATTACHED+'Files names: ';
			for(Messaging.InboundEmail.BinaryAttachment binaryAttachment : binaryAttachments){
				emailMsg += '\n- "'+binaryAttachment.fileName+'"';
			}
			for(Messaging.InboundEmail.TextAttachment textAttachment : textAttachments){
				emailMsg += '\n- "'+textAttachment.fileName+'"';
			}
			return emailMsg;
		}

		if(textAttachments.size() > 0){
			Messaging.InboundEmail.TextAttachment textAttachment = textAttachments[0];
			//Check if attachment body is not empty
			if(String.isNotBlank(textAttachment.body)){
				errorMsgEmailAttachments.add(createEmailAttachment(textAttachment.filename, Blob.valueOf(textAttachment.body), textAttachment.mimeTypeSubType));
				return INCORRECT_FILE_TYPE;
			} else{
				return EMPTY_FILE+'File Name: "'+textAttachment.fileName+'"';
			}
		}

		if(binaryAttachments.size() > 0){
			Messaging.InboundEmail.BinaryAttachment binaryAttachment = binaryAttachments[0];
			//Check if attachment body is not empty
			if(binaryAttachment.body.size() > 0){
				String attachFormatErrorMsg = checkAttachmentFormat(binaryAttachment);
				if(String.isNotBlank(attachFormatErrorMsg)){
					errorMsgEmailAttachments.add(createEmailAttachment(binaryAttachment.filename, binaryAttachment.body, binaryAttachment.mimeTypeSubType));
					return attachFormatErrorMsg;
				}
			} else{
				return EMPTY_FILE+'File Name: "'+binaryAttachment.fileName+'"';
			}
			
		}

		return null;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to check if attached file is in csv format, file doesn't exceed max size and contains relevant columns .
    * @param        binary attachment
    * @Returns:     String - error message in case of errors, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public String checkAttachmentFormat(Messaging.InboundEmail.BinaryAttachment binaryAttachment){

		//Check MIME Type
		if(!(binaryAttachment.fileName.endsWithIgnoreCase('.csv') && (binaryAttachment.mimeTypeSubType == MIME_TYPE_MS_EXCEL || binaryAttachment.mimeTypeSubType == MIME_TYPE_OCTET_STREAM))){
			return INCORRECT_FILE_TYPE;
		}

		//Check Size Limit 5MB
		Decimal fileSize = binaryAttachment.body.size();
		if(fileSize > 5*ONE_MB){
			String sFileSize = 'File size: '+(fileSize/ONE_MB).setScale(2)+'MB';
			return FILE_TOO_BIG+'\n'+sFileSize;
		}

		//Check Number of Rows limit 10 000
		String stringBody = binaryAttachment.body.toString();
		Integer numberOfRows = stringBody.countMatches(LINE_SEPARATOR);
		if(numberOfRows > MAX_NUMBER_OF_ROWS){
			String sNumberOfRows = 'Number of rows: '+numberOfRows;
			return TOO_MANY_ROWS+'\n'+sNumberOfRows;
		}

		//Check if attachment has more than one line
		rows = stringBody.split(LINE_SEPARATOR);
		if(rows.size() == 1){
			return WRONG_FORMAT_ONE_LINE;
		}

		//Find BRID and Leave Action Date columns indexes
		List<String> header = rows[0].split(COLUMN_SEPARATOR);
		BRID_INDEX = null;
		LEAVE_ACTION_DATE_INDEX = null;
		for(Integer i=0; i<header.size(); i++){
			if(header[i].removeStart('"').removeEnd('"').toUpperCase() == HEADER_BRID){ 
				BRID_INDEX = i;
			}
			if(header[i].removeStart('"').removeEnd('"').toUpperCase() == HEADER_LEAVE_DATE){ 
				LEAVE_ACTION_DATE_INDEX = i;
			}
		}
		//Check if attachment contains BRID column
		if(BRID_INDEX == null){
			return WRONG_FORMAT_NO_BRID;
		}
		//Check if attachment contains Leave Action Date column
		if(LEAVE_ACTION_DATE_INDEX == null){
			return WRONG_FORMAT_NO_LEAVE_ACTION_DATE;
		}

		return null;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to process rows and check if BRID is not empty and Leave Action Date is in correct format.
    * @param        None
    * @Returns:     true if rows processed successfully, false in case of any errors
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Boolean processRows(){
		Boolean result = true;
		invalidRows.add(rows[0]+',"ERROR"');

		String brid;
		Date leaveActionDate;
		for(Integer i=1; i<rows.size(); i++){
			String[] cols = rows[i].split(COLUMN_SEPARATOR);
			if(cols.size() <= BRID_INDEX || cols.size() <= LEAVE_ACTION_DATE_INDEX){
				invalidRows.add(rows[i]+',"Incorrect Format"');
				result = false;
			} else{
				brid = cols[BRID_INDEX].removeStart('"').removeEnd('"');
				leaveActionDate = getLeaveActionDate(cols[LEAVE_ACTION_DATE_INDEX].removeStart('"').removeEnd('"'));

				if(String.isBlank(brid)){
					invalidRows.add(rows[i]+',"Empty BRID"');
					result = false;
				} else if(leaveActionDate == null){
					invalidRows.add(rows[i]+',"Invalid Leave Action Date format"');
					result = false;
				} else if(leaveActionDate > Date.today()){
					invalidRows.add(rows[i]+',"Future Dated Leaver"');
					result = false;
				} else{
					bridsToDeactivate.add(brid);
				}
			}
		}

		return result;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to query list of users to deactivate.
    * @param        None
    * @Returns:     true if processed successfully, false in case of any errors
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Boolean findUsersToDeactivate(){
		Boolean result = true;
		processedRecords.add('"BRID","RESULT"');
		notProcessedRecords.add('"BRID","ERROR"');

		Set<String> bridsFound = new Set<String>();
		for(User u : [SELECT Id, BRID__c, IsActive FROM User WHERE BRID__c IN :bridsToDeactivate]){
			if(u.IsActive){
				u.IsActive = false;
				u.Automatically_Deactivated__c = true;
				usersToDeactivate.put(u.Id, u);
			} else{
				processedRecords.add('"'+u.BRID__c+'","User has been already deactivated. No action performed."');
				//result = false;
			}
			bridsFound.add(u.BRID__c);
		}

		for(String brid : bridsToDeactivate){
			if(!bridsFound.contains(brid)){
				notProcessedRecords.add('"'+brid+'","BRID not exist in Salesforce."');
				result = false;
			}
		}

		return result;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to deactivate users.
    * @param        None
    * @Returns:     true if processed successfully, false in case of any errors
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Boolean deactivateUsers(){
		Boolean successfullyProcessed = true;
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.OptAllOrNone = false;
		List<User> usersToUpdate = usersToDeactivate.values();
		Database.SaveResult[] srList = Database.update(usersToUpdate, dml);
		for(Integer i=0; i<srList.size(); i++){
			if(srList[i].isSuccess() == false){
				notProcessedRecords.add('"'+usersToUpdate[i].BRID__c+'","'+srList[i].getErrors()[0].getMessage()+'"');
				successfullyProcessed = false;
			} else{
				processedRecords.add('"'+usersToUpdate[i].BRID__c+'","User has been deactivated successfully"');
			}
		}
		return successfullyProcessed;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to prepare response email message.
    * @param        String - email subject
    * @param        String - email body message
    * @param        List of recipents email addresses
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public void sendEmailResponse(String subject, String msg, List<String> toAddresses){
		sendEmailResponse(subject, msg, toAddresses, new List<Messaging.EmailFileAttachment>());
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to prepare response email message with attachment.
    * @param        String - email subject
    * @param        String - email body message
    * @param        List of recipents email addresses
	* @param        List of email attachments
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public void sendEmailResponse(String subject, String msg, List<String> toAddresses, List<Messaging.EmailFileAttachment> emailAttachments){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject(subject);
		mail.setPlainTextBody(msg);
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setFileAttachments(emailAttachments);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to prepare attachment body.
    * @param        List of rows for csv file
    * @Returns:     Blob - attachment body
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Blob createAttachmentBody(List<String> rows){
		String attachmentBody = '';
		for(String r : rows){
			attachmentBody += r+LINE_SEPARATOR;
		}

		return Blob.valueOf(attachmentBody);
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to prepare email attachment
    * @param        String - file name
    * @param        Blob - file body
    * @param        String - file type
    * @Returns:     Messaging.EmailFileAttachment - email attachment
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Messaging.EmailFileAttachment createEmailAttachment(String fileName, Blob body, String contentType){
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
		emailAttachment.setFileName(fileName);
		emailAttachment.setBody(body);
		if(String.isNotBlank(contentType)){
			emailAttachment.setContentType(contentType);
		}
		return emailAttachment;
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to convert Leave Action Date from string to date
    * @param        String - leave action date
    * @Returns:     Date - leave action date
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	private Date getLeaveActionDate(String leaveDateTime){
		String[] leaveDate = leaveDateTime.split(' ');
		String[] cols = leaveDate[0].split('/');
		if(cols.size() < 3){
			return null;
		}
		Integer day;
		Integer month;
		Integer year;
		try{
			day = Integer.valueOf(cols[0]);
			month = Integer.valueOf(cols[1]);
			year = Integer.valueOf(cols[2]);
		} catch(TypeException ex){
			return null;
		}

		return Date.newInstance(year, month, day);
	}
}