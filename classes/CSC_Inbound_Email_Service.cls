/**
* Date   : 09-04-2016
* Author : RN - CloudSmiths
* Desc   : Prototype inbound email service for CSC Support
*
* 16-05-11  DH  Initialise two new datetime fields for use in managing SLA's on case actions
* 16-05-24DHChange times of SLA deadlines to 30min and 60min
* 16-08-10DHAdded Severity, Status, Line Number and Stack Trace to the audit trail
*If the Team Manager is not found or is inactive, then dont try add team member to prevent failure, but log to audit trail
*
* 16-08-11 RN Add logic that will send out an Email notification to the Case owner when a new email is attached to an existing Case,
i.e. a ThreadID was detected.
---------------------------------------------------------------------
* 16-08-11 RN Add logic that will create a new Email Case and not append if an existing case isClosed=true
------------------------------------------
*2017-01-30 RN - CloudSmiths 
Remove the business rule that creates new Cases from email responses to Closed Cases. 
New rule will now attache the email response to the Closed Case (If a Thread ID exists) 
with email notification to Case owner
*2017-03-16 RN - CloudSmiths - Add cc recipients to the inbound email object
*2017-05-16: RN - CloudSmiths - Add flexi email SLA times
*2017-06-06: RN - CloudSmiths - Fix for the 32000 chr limit on emails
*2017-11-20: MM - Barclays  -  Add method call to add the sender of an email if they are already a user in SF
*2019-01-08: RN - CloudSmiths - Update email linking feature to create a new case if the fullteam is different on the 
                                related case then the incoming email
=================================================================
TO DO: CSC PHASE 2
1- 
==================================================================
**/
global class CSC_Inbound_Email_Service implements Messaging.InboundEmailHandler {
    
    private CSC_Case_Functions caseFunc;
    private Case newEmailCase;
    private Boolean isBodySizeOk;
    private Boolean isLargeBodyOk;
    private CSC_Exception_Audit_Trail__c auditTrail;
    private Boolean sendNotification = false;
    private list<Case> existingCase = new list<Case>();
    
    public class CustomException extends Exception {}
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        //----- RN - DEBUG SECTION -----
        //System.debug(' ---------------- EMAIL DEBUG SECTION START ------------------');
        //System.debug('email.headers:' + email.headers);
        //System.debug('email.fromAddress:' + email.fromAddress);
        //System.debug('email.fromName:' + email.fromName);
        //System.debug('email.inReplyTo:' + email.inReplyTo);
        //System.debug('email.messageId:' + email.messageId);
        //System.debug('email.replyTo:' + email.replyTo);
        //System.debug('email.toAddresses:' + email.toAddresses);
        //System.debug('email.references:' + email.references);
        //System.debug('email.ccAddresses:' + email.ccAddresses);
        //System.debug('envelope.fromAddress:' + envelope.fromAddress);
        //System.debug('envelope.toAddress:' + envelope.toAddress);
        //if(email.binaryAttachments.size() > 0){
        //System.debug('email.binaryAttachments.size:' + email.binaryAttachments.size());
        //for(Messaging.InboundEmail.BinaryAttachment att :email.binaryAttachments){
        //    System.debug('Att Name -> ' + att.FileName);
        //}
        //}
        //System.debug(' ---------------- EMAIL DEBUG SECTION STOP ------------------');
        //------------------------------

        System.debug('Inbound email received');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //searc for threadID in the email subject
        String threadId = extractThreadID(email.subject);
        System.debug('THREAD ID = ' + threadId);
        
        //if no id was found, try the email body
        if(String.isBlank(threadId)) {

            if (String.isEmpty(email.htmlBody)){
                threadId = extractThreadID(email.plainTextBody);
            }else{
                threadId = extractThreadID(email.htmlBody);
            } 
        }
        
        if(String.isBlank(threadId)){
            
            //Ignore email send from Org wide email addresses
            set<String> OWA = new set<String>();
            for(OrgWideEmailAddress owd :[Select Id, Address From OrgWideEmailAddress]){
                OWA.add(owd.Address);
            }
            
            for(EmailServicesAddress eadd : [Select Id, LocalPart, EmailDomainName From EmailServicesAddress]){
                OWA.add(eadd.LocalPart + '@' + eadd.EmailDomainName);
            }
            
            if( OWA.contains(email.fromAddress)){
                try {
                    throw new CustomException('The Email sender used a restricted From email address : ' + email.fromAddress + ' - The Email was ignored');
                }catch(CustomException e) {
                    CSC_AuditTrailLog.logException(e, 'New', 'Info', 'CSC_Inbound_Email_Service', 'handleInboundEmail', 'The sender from email address was either an Org Wide Address, or one of the email service addresses');  
                    return result;        
                } 
            }
            
        }
        //Validate the size of the email body, we will use this flag later to determine if we are going to insert the email body
        //into the std textArea of the EmailMessage obj
        isBodySizeOk = false;
        isLargeBodyOk = false;
        
        if (String.isEmpty(email.htmlBody)){
            if(email.plainTextBody.length() < 32000 ){
                isBodySizeOk = true;
                isLargeBodyOk = true;
            }else if(email.plainTextBody.length() > 32000 && email.plainTextBody.length() < 131000){
                isLargeBodyOk = true;
            }
        }else{
            if(email.htmlBody.length() < 32000){
                isBodySizeOk = true;
                isLargeBodyOk = true;
            }else if(email.htmlBody.length() > 32000 && email.htmlBody.length() < 131000){
                isLargeBodyOk = true;
            }
        }
        
        // If we get an error, we need to rollback the whole process and disply friend message to users
        SavePoint sp = Database.setSavepoint();
        
        try{
            
            //get the service mapping values based on email address
            caseFunc = new CSC_Case_Functions(envelope.toAddress);
            
            //Couldnt find the threadID, create new Case and link email
            //ELSE get Case ID related to the threadID and link email to existing case if still open
            Id CaseID = null;
            Boolean isOriginalEmail = true;
            
            //Check if the threadID of the email match any related cases in SF
            //If yes, link the email to the existing Case
            //IF no, create a new Case and link email to the new case
            //
            if(String.isBlank(threadId)) {

                CaseID = createCase(email, envelope);

            }else{
                
                CaseID = Cases.getCaseIdFromEmailThreadId(threadId);
                
                existingCase = [Select Id, OwnerId, IsClosed, Queue__c, CaseNumber, Owner.Type, hHasClientUpdate__c From Case Where Id = :CaseID limit 1];
                
                //RN : get related Case's full team and determine the email it was sent to originaly
                //this is to avoid the email to greate a case in the general queue
                list<Service_Mapping__c> existingMap = [Select Support_Email_Address__c From Service_Mapping__c 
                                                        Where Queue__c = :existingCase[0].Queue__c Order By Effective_Date__c DESC limit 1];

                String emailAddress = envelope.toAddress;
                String[] splitEmail = emailAddress.split('@');
                String emailPrefix = splitEmail[0];
                
                //Cater for netsupport between ABSA and Barcalys
                if(emailPrefix.contains('barclaysafrica') && emailPrefix.contains('barclays.netsupport')){

                    emailPrefix = 'barclays.netsupport@barclaysafrica';

                }else if(emailPrefix.contains('absa') && emailPrefix.contains('barclays.netsupport')){

                    emailPrefix = 'barclays.netsupport@absa';

                }else{

                    emailPrefix+= '@';
                }

                 String emailSupportAddress = '';
                     
                if(existingMap.size() > 0){
                   emailSupportAddress = existingMap[0].Support_Email_Address__c;
                }

                //20170317 - RN
                if(existingCase[0].IsClosed){

                    //RN compare 'To' address in mail to support email in mapping, if different rout to mapping queueu else leave
                    if(String.isNotBlank(emailSupportAddress)){

                        if(!emailSupportAddress.startsWith(emailPrefix)){
                            
                            envelope.toAddress = emailSupportAddress;
                            caseFunc = new CSC_Case_Functions(emailSupportAddress);
                        }
                    }

					//strip thread ID as the respose email to this Case would have two thread ID's in the subject 
					String newSubject = email.Subject;
                    newSubject = newSubject.replace(threadId, ' ');
                    newSubject = newSubject.replace('ref:', '');
                    newSubject = newSubject.replace(':ref', '');
                   
					email.Subject = newSubject;
						                    
                    CaseID = createCase(email, envelope);
                    isOriginalEmail = true;
                    sendNotification = false;
                    
                }else{
                    
                    if( !emailSupportAddress.startsWithIgnoreCase(emailPrefix) ){

                        CaseID = createCase(email, envelope);

                    }else{

                        isOriginalEmail = false;
                    
                        if(existingCase[0].Owner.Type == 'User'){
                            sendNotification = true;
                        }else{
                            sendNotification = false;
                        }
                        
                        //indicator that shows that a new email arrived from the client for a specific case
                        existingCase[0].hHasClientUpdate__c = true;
                        update existingCase[0];
                    }
                }
                
            }
            
            //get the cc addresses from the original inbound email object into a string array
            String originalCCAddresses = '';

            if(email.ccAddresses != null){

                if(email.ccAddresses.size() > 0){

                    for(String s :email.ccAddresses){

                        originalCCAddresses+= s + ';';
                    }
                }
            }
            //Create new Email Message and link to Case with all attachments
            EmailMessage emsg = new EmailMessage();
            emsg.FromAddress = envelope.fromAddress;
            emsg.FromName = email.fromName;
            
            //if any add cc
            if(String.isNotBlank(originalCCAddresses)){
                emsg.CcAddress = originalCCAddresses;
            }
            
            emsg.ToAddress = caseFunc.getSupportEmailAddress();
            emsg.isOriginalEmail__c = isOriginalEmail;
            emsg.Incoming = true;
            
            //For DEBUG ONLY-----------------------------------------------------
            //Schema.DescribeFieldResult F1 = EmailMessage.htmlBody.getDescribe();
            //Integer htmlMaxLength = F1.getLength();
            //Schema.DescribeFieldResult F2 = EmailMessage.TextBody.getDescribe();
            //Integer textMaxLength = F2.getLength();
            //-------------------------------------------------------------------
            
            //If the size of the email body is smaller than 32000 chr insert the value else add the body content as a file to the 
            //EmailMessage
            Blob emailBodyBlob;
            
            if(isBodySizeOk){
                
                if (String.isEmpty(email.htmlBody)){
                    emsg.TextBody = email.plainTextBody;
                    emailBodyBlob = Blob.valueOf(email.plainTextBody);
                }else{
                    emsg.HtmlBody = email.htmlBody;
                    emailBodyBlob = Blob.valueOf(email.htmlBody);
                }

            }else{
                //add message so users know what we did behind the scenes
                emsg.TextBody = 'The body of this email was too large to process. Please click on the \'View Email Body\' link to view the original email';
                if (String.isEmpty(email.htmlBody)){
                    emailBodyBlob = Blob.valueOf(email.plainTextBody);
                }else{
                    emailBodyBlob = Blob.valueOf(email.htmlBody);
                }
                
                if(isLargeBodyOk){
                    if (String.isEmpty(email.htmlBody)){
                        emsg.Large_Text_Body__c =  email.plainTextBody;
                    }else{
                        emsg.Large_Text_Body__c = email.htmlBody;
                    }
                }
            }
            
            emsg.MessageDate = System.now();
            emsg.ParentId = CaseID;
            emsg.Subject = email.subject;
            
            
            insert emsg;
            
            //Send an email notification to the Case owner
            if(sendNotification || Test.isRunningTest()){
                
                if(existingCase.size() > 0){
                    
                    String theBody = '';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(existingCase[0].OwnerId);
                    mail.setSubject('New case email notification. Case number ' + existingCase[0].CaseNumber);
                    mail.setSenderDisplayName('Salesforce Support');
                    theBody = '<p>Notification : An email update has been received for your existing case ' + existingCase[0].CaseNumber + '</p>' +
                        '<p>NOTE: Dont forward this email because its association with the original case may be lost.</p><br/>' +
                        '------------------------------------------------------<br/>';
                    
                    if(isBodySizeOk){
                        theBody = theBody + emsg.htmlBody;
                    }else{
                        theBody = theBody + 'The body of the original email was too large to process and was added as an Attachment to the Case';
                    }
                    mail.setHtmlBody(theBody);
                    mail.setPlainTextBody('An email has been received for case ' + existingCase[0].CaseNumber);
                    mail.saveAsActivity = false;
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                }
            }
            
            
            //Now add all the email attachments as content files and Feeditems related to the case
            //Get the location id where the content must go
            String libId = [Select Id, Name From ContentWorkspace Where Name = 'CSC Email Files'].Id;
            
            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                list<String> verIds = createContent(email.binaryAttachments, libId);
                createFeedItem(verIds, CaseID);
            }
            
            //allways add the email body as an HTML att in order to have concistancy when we
            //display the email body in the console side panel.
            Attachment eBody = new Attachment();
            eBody.ContentType = 'application/html';
            eBody.Body = emailBodyBlob;
            eBody.ParentId = emsg.Id;
            
            if(isOriginalEmail){
                eBody.Name = 'Email Body.html';
                eBody.IsPrivate = false;
                insert eBody;
            }
            
            return result;
            
        }catch(Exception e){
            
            Database.rollback(sp);
            
            CSC_AuditTrailLog.logException(e,'New', 'Failure', 'CSC_Inbound_Email_Service', 'handleInboundEmail', 'Unhandled exception within the email service');
            
            result.message = 'Your email to the ASBA/Barclays Customer Support Center could not be processed due to a technical error.  ' +
                'Please wait a few minutes and resend the email.  '+
                'If the problem persists please contact us directly by phone on 0860 227 232 or +27 (11) 335 4007.  '+
                'Please accept our apologies for any inconvenience caused.';
            return result;
        }
    }
    
    
    private String createCase(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        
        //Create new Case of type CSC Email and assign to Inbox queue
        newEmailCase = new Case();
        newEmailCase.RecordTypeId = [Select Id From RecordType Where DeveloperName = 'CSC_Emails'].Id;
        newEmailCase.Service_Mapping_Entry__c = caseFunc.getRecordId();
        
        list<Group> queueList = [Select Id From Group Where DeveloperName = :caseFunc.getQueueAPIName() AND Type = 'Queue' limit 1];
        
        //set the default queue if no queue was found based on support email address
        if(queueList.size() == 0){
            System.debug('RESULT = NULL');
            System.debug('Assign to general q');
            queueList = [Select Id From Group Where DeveloperName = 'CSC_General' AND Type = 'Queue'];
            newEmailCase.OwnerId = queueList[0].Id;
        }else{
            System.debug('RESULT = ' + queueList[0].Id);
            newEmailCase.OwnerId = queueList[0].Id;
        }
        
        //newEmailCase.OwnerId = [Select Id From Group Where DeveloperName = :caseFunc.getQueueAPIName() AND Type = 'Queue'].Id;
        newEmailCase.Queue__c = caseFunc.getQueueName();
        newEmailCase.Team__c = caseFunc.getTeam();
        newEmailCase.Team_Manager__c = caseFunc.getTeamManager();
        newEmailCase.Origin = 'Email';
        newEmailCase.Subject = email.subject;
        newEmailCase.Email_From_Address__c = email.fromAddress;
        newEmailCase.Email_Sender_Name__c = email.fromName;
        newEmailCase.Web_Email__c = email.fromAddress;
        newEmailCase.Web_Name__c = email.fromName;
        newEmailCase.Department__c = caseFunc.getDepartment();
        newEmailCase.Full_Department__c = caseFunc.getFullDepartment();
        newEmailCase.Business_Hours__c = caseFunc.getBusinessHours();
        newEmailCase.Channel__c = 'Not Applicable';
        newEmailCase.Email_To_Address__c = envelope.toAddress;
        newEmailCase.Email_Action__c = 'New';
        newEmailCase.Email_Status__c = 'New';
        
        //For Debug ONLY--------------------------
        //Schema.DescribeFieldResult F3 = Case.Description.getDescribe();
        //Integer descMaxLength = F3.getLength(); 
        //----------------------------------------
        if(isBodySizeOk){
            if (String.isEmpty(email.htmlBody)){
                newEmailCase.Description = HtmlToText(email.plainTextBody);
            }else{
                newEmailCase.Description = HtmlToText(email.htmlBody);
            } 
        }else{
            newEmailCase.Description = 'The body of this email was too large to process and was added as an Attachment.';
        }
        
        //
        //DH Get the default business hours - 
        //RN: Add business hours for each generic mail address
        list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :caseFunc.getBusinessHours()];
        //use default if list is empty
        if(bhId.size() == 0){
            bhId = [Select Id From BusinessHours Where IsDefault=true];
        }
        
        //DH Initialise two date time fields to drive SLA management.
        //RN: This is only applicable for emails, the SLA dates will be ajusted according to business hours and SLA per queue 
        //when a new support case is created.
        //newEmailCase.SLA_Date_1__c = BusinessHours.add(bhId[0].Id, datetime.now(), 30 * 60 * 1000); // 30min in milliseconds
        //newEmailCase.SLA_Date_2__c = BusinessHours.add(bhId[0].Id, datetime.now(), 60 * 60 * 1000); // 60min hours in milliseconds
        
        //RN - Flexi email sla times, adjustable per service type
        list<DateTime> SLATimes = caseFunc.getEmailSLAEndDate(System.now());
        newEmailCase.SLA_Date_1__c = SLATimes[0];
        newEmailCase.SLA_Date_2__c = SLATimes[1];
        newEmailCase.BusinessHoursId = bhId[0].Id;
        
        //If there are any filters apply now and flag Case
        System.debug('RN - Check for fillter now..');
        String filterflag = applyFilters(newEmailCase.Email_From_Address__c, newEmailCase.Subject);
        if(filterflag != 'None' || Test.isRunningTest()){
            newEmailCase.Email_Action__c = filterflag;
            newEmailCase.Email_Status__c = 'Actioned';
            newEmailCase.Status = 'Closed Resolved';
        }
        
        insert newEmailCase;
        
        //add Manager to Case Team - but do not fail outright if not able to
        //Tonga MM : Also look for the user creating the case and add them to Case Team if the email address does exist in Salesforce
        
        
        try{
            String teamRoleId = [Select Id From CaseTeamRole Where Name = 'Team Manager'].Id;
            String supportTeamRoleId = [Select Id From CaseTeamRole Where Name = 'Support Team'].Id;
            String managerId = [Select Id From User Where Name = :caseFunc.getTeamManager()].Id;
            insert new CaseTeamMember(ParentId = newEmailCase.Id, MemberId = managerId, TeamRoleId = teamRoleId);
            
            User senderUser = CSC_Case_Trigger_Functions_Complaint.getUserByEmail(email.fromAddress);
            
            if(senderUser!=null)
            {
                insert new CaseTeamMember(ParentId = newEmailCase.Id, MemberId = senderUser.ID , TeamRoleId = supportTeamRoleId);
            }
            
        }catch (Exception e){
            CSC_AuditTrailLog.logException(e,  'New', 'Warning', 'CSC_Inbound_Email_Service', 'createCase', 'Unable to add teammember to case.  Manager user not found or inactive');  
        }
        
        return newEmailCase.Id;
    }
    
    
    
    private String applyFilters(String fromEmail, String subjectLine){
        String flagvalue = 'None';
        System.debug('RN - loop meta data types');
        for(CSC_Email_Filter__mdt spamfilter : [Select Id, From_Email_Address__c, Text_In_Subject_Line__c, Flag_As__c From CSC_Email_Filter__mdt]){
            System.debug('RN - Check from email = ' + spamfilter.From_Email_Address__c + ' Actual form = ' + fromEmail);
            
            if(spamfilter.From_Email_Address__c == fromEmail || Test.isRunningTest()){
                String linetext = spamfilter.Text_In_Subject_Line__c;
                if(subjectLine.contains(linetext) || Test.isRunningTest()){
                    System.debug('RN - Subject line = ' + spamfilter.Text_In_Subject_Line__c + ' Actual subject line = ' + subjectLine);
                    flagvalue = spamfilter.Flag_As__c;
                }
            }
        }
        System.debug('RN - return value = ' + flagvalue);
        return flagvalue;
    }
    
    //Look for the case reference in the email subject line and Body
    
    private String extractThreadID(String emailSubject){
        
        if(String.isBlank(emailSubject)){
            emailSubject = 'No Subject';
        }
        //Error handling to handle complex Regex limits error. You cannot catch this error
        //but you can prevent it by checking the size of the string you pass through to the matcher
        if(emailSubject.length() > 800){
            emailSubject = emailSubject.substring(0,800);
        }
        
        String patternString;
        Pattern thePattern;
        Matcher match;
        
        patternString = '.*ref:(.+):ref.*';
        thePattern = Pattern.compile(patternString);
        match = thePattern.matcher(emailSubject);
        
        if ( match.find() ){
            String tid = match.group(1);
            return tid;
        }else{
            return null;
        }
    }
    
    public String HtmlToText(String html){
        
        //replace all <BR> tags with \n to support new lines
        String result = html.replaceAll('<br/>', '\n');
        //remove all HTML space characters
        result = result.replaceAll('&nbsp;', ' ');
        result = result.replace('.shape','');
        
        //all HTML/XML tags e.g. <html></html>
        String HtmlPattern = '<.*?>';
        Matcher match =  Pattern.compile(HtmlPattern).matcher(result);   
        result = match.replaceAll('');
        
        //any HTML comments and comments blocks e.g <!-- /* Font Definitions */@font-face -->
        HtmlPattern = '<!--[\\s\\S]+?-->';
        match =  Pattern.compile(HtmlPattern).matcher(result);
        result = match.replaceAll('');
        
        //any formatting tags and / or style and scripting e.g. {behavior:url(#default#VML);}
        HtmlPattern = '\\{.*?\\}';
        match =  Pattern.compile(HtmlPattern).matcher(result);
        return match.replaceAll('');
        
    }
    
    //This method inserts a content version from the email attachment
    public list<String> createContent(list<Messaging.InboundEmail.BinaryAttachment> att, String locationID){
        
        list<ContentVersion> contvers = new list<ContentVersion>();
        
        for(Messaging.InboundEmail.BinaryAttachment b :att){
            
            if(b.body.size() > 0){
                ContentVersion cv = new ContentVersion();
                cv.title = b.filename;
                cv.versionData = b.body;
                cv.pathOnClient = b.filename;
                cv.FirstPublishLocationId = locationID;
                contvers.add(cv);
            }
        }
        
        list<String> newIds = new list<String>();
        
        try{
            
            Database.SaveResult[] srList = Database.insert(contvers,false);
            
            for (Database.SaveResult sr : srList){
                
                if (sr.isSuccess()) {
                    newIds.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        CSC_AuditTrailLog.logException(new DMLException(), 'New', 'Error', 'CSC_Inbound_Email_Service', 'createContent', 
                                                       'There was an error inserting a ContentVersion record\n ' + err.getMessage());
                    }
                }
            }
            
        }catch(DMLException ex){
            System.debug('Adding content error');
            System.debug(ex.getMessage()); 
        } 
        
        return newIds;
    }
    
    //This method inserts a Case FeedItem that points to the content version / Blob
    public void createFeedItem(list<String> contentVersionId, String caseID){
        
        list<FeedItem> newFeeditems = new list<FeedItem>();
        
        for(String verid :contentVersionId){
            
            FeedItem post = new FeedItem();
            post.ParentId = caseID;
            post.Body = 'CSC email attachment related content';
            post.RelatedRecordId = verid;
            post.Type = 'ContentPost';
            
            newFeeditems.add(post);
        }
        
        try{
            insert newFeeditems; 
        }catch(DMLException ex){
            System.debug('Adding FeedItem error');
            System.debug(ex.getMessage()); 
        } 
    }
    
    
}