/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

06/11/2017 - TdB     - Created Class.
					 - Notify Groups and Participants of Cancellation
					 - Update fields and Record Type
22/01/2018 - TdB 	 - Set From email address to xradocmanvalidations@barclayscapital.com
12/03/2018 - TdB    - Auto Reject Pending Approvals when cancelling a fit to lend

**/
public class FitToLendChecklist_Cancelled_Controller 
{
    public String paramFitToLendId { get; set; }
    public List<Fit_To_Lend_Checklist__c> fitToLendChecklistRecord = new List<Fit_To_Lend_Checklist__c>();
    
    public FitToLendChecklist_Cancelled_Controller () 
    {
        //Get Fix to Lend Checklist Id from URL
        paramFitToLendId = ApexPages.currentpage().getparameters().get('Id');
        
        if(paramFitToLendId != null)
        {
            fitToLendChecklistRecord = [SELECT Id, Name, Status__c
                                        FROM Fit_To_Lend_Checklist__c
                                        WHERE Id = :paramFitToLendId ];
        }
        
    }
    
    public String redirectToFitToLend()
    {
        //Get Cancelled/Read Only Record Type
        List<RecordType> FitToLendRecordType_ReadOnly = [SELECT Id, Name, DeveloperName, SobjectType 
                                                         FROM RecordType
                                                         WHERE SobjectType = 'Fit_To_Lend_Checklist__c' 
                                                         AND DeveloperName = 'Fit_To_Lend_Checklist_Cancelled' limit 1];
        
        List<OrgWideEmailAddress> OrgWideEmails = [select Id from OrgWideEmailAddress where Address = 'xradocmanvalidations@barclayscapital.com'];
        
        List<attachment> fitToLendAttachment = new List<attachment>();
        
        if(fitToLendChecklistRecord.size() > 0)
        {
            //Email Notification Groups and Participants to notify of the cancellation
            try
            {
                //Blank list.
                List<Fit_To_Lend_Checklist__c> fitToLends = new List<Fit_To_Lend_Checklist__c>();
                
                //Get any contact for email template.  Never emailed...
                Id randomContactId = [SELECT Id FROM Contact WHERE Email != null LIMIT 1].Id;
                
                //Final list of all email messages for sending.
                List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
                
                //Get the ids of the email template
                Id publicEmailTempateId     = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Public_Fit_to_Lend_Cancellation_Notification'].Id;
                Id privateEmailTempateId    = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Private_Fit_to_Lend_Cancellation_Notification'].Id;
                
                //Get the fit to lend records and notificiation groups.
                fitToLends = [
                    SELECT 
                    Id,
                    Name,
                    (
                        SELECT 
                        Id,
                        Distribution_Group__c,
                        Distribution_Group__r.Name,
                        Distribution_Group__r.Email_Address__c,
                        Distribution_Group__r.Group_Type__c
                        FROM Notification_Groups__r
                    ),
                    (
                        SELECT 
                        Id,
                        Email_Address__c,
                        Participant__c,
                        Participant__r.advpm__Role__c
                        FROM Notification_Participants__r
                    )
                    FROM Fit_To_Lend_Checklist__c
                    WHERE
                    Id = :fitToLendChecklistRecord[0].Id
                ];
                
                if(fitToLends.size() > 0)
                {
                    //Get file attachments
                    fitToLendAttachment = [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId = :fitToLendChecklistRecord[0].id limit 1];
                    
                    //Create the email attachment
                    Messaging.EmailFileAttachment emailAttachment;
                    if(fitToLendAttachment.size() > 0)
                    {
                        emailAttachment = new Messaging.EmailFileAttachment();
                        emailAttachment.setFileName(fitToLendAttachment[0].Name);
                        emailAttachment.setBody(fitToLendAttachment[0].Body);
                    }
                    
                    //Loop through notification groups.
                    for(Notification_Group__c notifyGroup : fitToLends[0].Notification_Groups__r)
                    {
                        //Group email address.
                        List<String> toAddresses = new List<String> { notifyGroup.Distribution_Group__r.Email_Address__c };
                            
                            //Single email object.
                            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        singleEmail.setTargetObjectId(randomContactId);
                        singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                        singleEmail.setToAddresses(toAddresses);
                        singleEmail.setWhatId(fitToLends[0].Id);
                        if ( OrgWideEmails.size() > 0 ) 
                        {
                            singleEmail.setOrgWideEmailAddressId(OrgWideEmails.get(0).Id);
                        }
                        
                        //Private
                        if(notifyGroup.Distribution_Group__r.Group_Type__c == 'Private')
                        {
                            singleEmail.setTemplateId(privateEmailTempateId);
                            
                            //Add file attachment.
                            if(emailAttachment != null)
                            {
                                singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                            }
                            
                        }
                        //Public
                        else
                        {
                            singleEmail.setTemplateId(publicEmailTempateId); 
                        }
                        
                        //Add to list.
                        emailMessages.add(singleEmail);
                    }
                    
                    //Loop through participant notifications.
                    for(Notification_Participant__c notifyParticipant : fitToLends[0].Notification_Participants__r)
                    {
                        //Group email address.
                        List<String> toAddresses = new List<String> { notifyParticipant.Email_Address__c };
                            
                            //Single email object.
                            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        singleEmail.setTargetObjectId(randomContactId);
                        singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                        singleEmail.setToAddresses(toAddresses);
                        singleEmail.setWhatId(fitToLends[0].Id);
                        singleEmail.setTemplateId(privateEmailTempateId);
                        if ( OrgWideEmails.size() > 0 ) 
                        {
                            singleEmail.setOrgWideEmailAddressId(OrgWideEmails.get(0).Id);
                        }
                        
                        //Add file attachment.
                        if(emailAttachment != null)
                        {
                            singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                        }
                        
                        //Add to list.
                        emailMessages.add(singleEmail);
                    }
                    
                }
                
                //Send emails.
                if(emailMessages.size() > 0)
                {
                    Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
                }
            }catch(DMLException ex){
                System.debug('There was an error while sending Cancellation Notifications Emails to Participants and Groups');
                System.debug(ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while sending Cancellation Notifications Emails to Participants and Groups'));
                return null;
            }
            
            //Update Status to Cancelled
            fitToLendChecklistRecord[0].status__c = 'Cancelled';
			fitToLendChecklistRecord[0].Comments__c = 'Approval Cancelled';
            
            //Update Record Type to Read Only 
            if(FitToLendRecordType_ReadOnly.size() > 0)
            {
                fitToLendChecklistRecord[0].recordTypeId = FitToLendRecordType_ReadOnly[0].id;
            }
            
            //Update Fit to Lend Record
            Update  fitToLendChecklistRecord[0];

		//Get all Approval records linked to the Fit to Lend and reject approvals
            List<Approval__c> approvalList = [SELECT Id, Fit_To_Lend_Checklist__c 
                                             FROM Approval__c
                                             WHERE Fit_To_Lend_Checklist__c = :fitToLendChecklistRecord[0].Id];
            
            Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
                //Reject the record
                List<ProcessInstanceWorkItem> processInstanceWorkItemList = [SELECT ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.Status, ActorId
                                                                             FROM ProcessInstanceWorkitem
                                                                             WHERE ProcessInstance.TargetObjectID IN :approvalList AND ProcessInstance.Status = 'Pending'];
            
            for(ProcessInstanceWorkItem workItem : processInstanceWorkItemList){
                Approval.ProcessWorkitemRequest prWkItem = new Approval.ProcessWorkitemRequest();
                prWkItem.setWorkItemID(workItem.id);
                prWkItem.setComments('Approval Cancelled by User: ' + userInfo.getName());
                prWkItem.setAction('Reject');
                prWkItems.add(prWkItem);
            }
            
            if(!prWkItems.isEmpty()){
                Approval.ProcessResult[] appResult = Approval.process(prWkItems);
            }
        }
        
        return  '/' + paramFitToLendId;
        
    }
}