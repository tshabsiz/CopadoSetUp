/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 12/12/2017 - PG    - Updated org-wide address to IMPEX one.
 19/01/2018 - PG    - Added Logic to purge task activities after emails are sent.
 22/01/2018 - TdB 	 - Set From email address to xradocmanvalidations@barclayscapital.com
 12/03/2018 - TdB    - Auto Reject Pending Approvals when cancelling a fit to lend
   
**/           
public class FitToLend_Helper 
{
    public static List<Fit_To_Lend_Checklist__c> approvalStatuses(Set<Id> inputFitToLendIds)
    {
	 List<RecordType> FitToLendRecordType_Cancelled = [SELECT Id, Name, DeveloperName, SobjectType 
                                                         FROM RecordType
                                                         WHERE SobjectType = 'Fit_To_Lend_Checklist__c' 
                                                         AND DeveloperName = 'Fit_To_Lend_Checklist_Cancelled' limit 1];
        List<Fit_To_Lend_Checklist__c> fitToLends = [
            SELECT
                Id,
                Name,
				RecordTypeId,
                Status__c,
                (
                    SELECT
                        Id,
                        Status__c
                    FROM
                    Approvals__r
                )
            FROM Fit_To_Lend_Checklist__c
            WHERE 
                Id IN :inputFitToLendIds
        ];
        
        System.debug('### FitToLend_Helper : approvalStatuses : fitToLends : '+fitToLends);
        
        //Loop through all 
        for(Fit_To_Lend_Checklist__c fitToLend : fitToLends)
        {
            //Number of approvals on this item.
            Integer numApprovals    = fitToLend.Approvals__r.size();
            
            //Counters to determine status
            Integer numApproved     = 0;
            Integer numRejected     = 0;
            
            //Loop through related approval records an count statuses.
            for(Approval__c approvalRecord : fitToLend.Approvals__r)
            {
                if(approvalRecord.Status__c == 'Approved')
                {
                   numApproved++;
                }
                
                if(approvalRecord.Status__c == 'Rejected')
                {
                   numRejected++;
                }
            }
            
            //Set the overall status for fit to lend record.
            if(numApprovals == numApproved)
            {
               fitToLend.Status__c = 'Approved'; 
            }
            else if(numRejected > 0)
            {
				if(FitToLendRecordType_Cancelled.size() > 0)
                {
                    if(fitToLend.recordTypeId == FitToLendRecordType_Cancelled[0].id)
                    {
                        fitToLend.Status__c = 'Cancelled'; 
                    }
                    else
                    {
                        fitToLend.Status__c = 'Rejected'; 
                    }
                }

            }
            else
            {
                fitToLend.Status__c = 'Pending Approval'; 
            }
        }
        
        //Default return.
        return fitToLends;
    }
    
    public static void sendNotificationEmails(Set<Id> inputFitToLendIds) 
    {
        System.debug('### FitToLend_Helper : sendNotificationEmails');
        
        List<OrgWideEmailAddress> OrgWideEmails = [select Id from OrgWideEmailAddress where Address = 'xradocmanvalidations@barclayscapital.com'];
        //Blank list.
        List<Fit_To_Lend_Checklist__c> fitToLends = new List<Fit_To_Lend_Checklist__c>();
        
        //Attachment to fit to lend
        Map<Id, Attachment> fitToLendAttachments = new Map<Id, Attachment>();
        
        //Get any contact for email template.  Never emailed...
        Id randomContactId = [SELECT Id FROM Contact WHERE Email != null LIMIT 1].Id;
        
        //Get file attachments
        for(Attachment attachment : [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId IN :inputFitToLendIds])
        {
            //Not in map already.
            if(!fitToLendAttachments.containsKey(attachment.ParentId))
            {
                fitToLendAttachments.put(attachment.ParentId, attachment);
            }
        }
        
        //Final list of all email messages for sending.
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        //Get the ids of the email template
        Id publicEmailTempateId     = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Public_Fit_to_Lend_Approval_Notifications'].Id;
        Id privateEmailTempateId    = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Private_Fit_to_Lend_Approval_Notification'].Id;
        
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
                Id IN :inputFitToLendIds
        ];

        //Loop through checklists.
        for(Fit_To_Lend_Checklist__c fitToLend : fitToLends)
        {
            //Create the email attachment
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(fitToLendAttachments.get(fitToLend.Id).Name);
            emailAttachment.setBody(fitToLendAttachments.get(fitToLend.Id).Body);
        
            //Loop through notification groups.
            for(Notification_Group__c notifyGroup : fitToLend.Notification_Groups__r)
            {
                System.debug('### FitToLend_Helper : sendNotificationEmails : notifyGroup : FOR');
                
                //Group email address.
                List<String> toAddresses = new List<String> { notifyGroup.Distribution_Group__r.Email_Address__c };
               
                //Single email object.
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setTargetObjectId(randomContactId);
                singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                singleEmail.setToAddresses(toAddresses);
                singleEmail.setWhatId(fitToLend.Id);
                if ( OrgWideEmails.size() > 0 ) 
                {
                    singleEmail.setOrgWideEmailAddressId(OrgWideEmails.get(0).Id);
                }
                
                //Private
                if(notifyGroup.Distribution_Group__r.Group_Type__c == 'Private')
                {
                    singleEmail.setTemplateId(privateEmailTempateId);
                    
                    //Add file attachment.
                    singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
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
            for(Notification_Participant__c notifyParticipant : fitToLend.Notification_Participants__r)
            {
                System.debug('### FitToLend_Helper : sendNotificationEmails : notifyParticipant : FOR');
                
                //Group email address.
                List<String> toAddresses = new List<String> { notifyParticipant.Email_Address__c };
               
                //Single email object.
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setTargetObjectId(randomContactId);
                singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                singleEmail.setToAddresses(toAddresses);
                singleEmail.setWhatId(fitToLend.Id);
                singleEmail.setTemplateId(privateEmailTempateId);
                if ( OrgWideEmails.size() > 0 ) 
                {
                    singleEmail.setOrgWideEmailAddressId(OrgWideEmails.get(0).Id);
                }
                    
                //Add file attachment.
                singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                
                //Add to list.
                emailMessages.add(singleEmail);
            }
        }

        //Send emails.
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);

        //Finally delete any F2L tasks created against the random contact.  Needed as a workaround when using a template.
        List<Task> tasks = [
            SELECT 
                Id 
            FROM Task 
            WHERE 
                WhoId = :randomContactId 
                AND WhatId IN :inputFitToLendIds
        ];

        //Delete records.
        delete tasks;
    }
}