/**
* Date   : 2018-04-11
* Author : Rudolf Niehaus - CloudSmiths
* Desc   : 
**/
public without sharing class lscSupportCaseMainCont {
    
    @AuraEnabled
    public Static String returnSupportCase(String caseId, String isClonePar){
        
        String errorMessage = 'ERROR:';
        
        CSC_Exception_Audit_Trail__c auditTrail = new  CSC_Exception_Audit_Trail__c();
        
        Case supportCase = [Select Id, ContactId, AccountId, RecordTypeId, RecordType.DeveloperName, 
                            Status, Origin, Subject, Description, CreatedDate, OwnerId, Queue__c, 
                            Email_To_Address__c, Business_Hours__c, Team__c, Department__c,Number_of_Requests__c, 
                            Second_Approval__c, First_Approval__c, Team_Member_Approval__c,Charge_Client__c, 
                            Complexity__c, Service_Type__c, Service_Sub_Category__c, Service_Category__c, ID_V__c, 
                            ID_V_Complete__c, Email_Action__c, Email_From_Address__c, Email_Queue_Position__c, 
                            Email_Sender_Name__c, Email_Status__c, Channel__c, SLA_Date_1__c, SLA_Date_2__c  
                            From Case 
                            Where Id = :caseId];
        
        //get service mapping
        CSC_Case_Functions caseFunc = new CSC_Case_Functions(SupportCase);
        map<String,String> serviceMap = new map<String,String>();
        
        
        Boolean isClone = false;
        Case emailClone = new Case();
        
        serviceMap = caseFunc.getServiceMapping();
        
        //Check if a service type record returned, if not let the user know his selection is invalid
        if(serviceMap.isEmpty()){
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                       //'The Selected Service type, Sub-Category and Category are invalid. ' + 
                                                       //'Please contact your Salesforce Administrator to ensure the service mapping ' + 
                                                       //'is correctly entered in Salesforce'));
            errorMessage+= 'The Selected Service type, Sub-Category and Category are invalid. ' + 
                           'Please contact your Salesforce Administrator to ensure the service mapping ' + 
                           'is correctly entered in Salesforce';
            
            return errorMessage;
            
        }
        
        
        
        //verify if this controller was invoked by the Email Actions VF page in the Service console. if yes 
        //create new clone of exiting Email type case, else just load the exiting case
        //NB - We clone the email case to keep for historical reasons, then update the email Case to promote it to a full Support Case
        //in order to keep the original creation date when the email was recieved for SLA reasons. 
        if(String.isNotBlank(isClonePar)){
            
            // If we get an error, we need to rollback the whole process and disply friend message to users
            SavePoint sp = Database.setSavepoint();
            boolean isManualCase = false;
            
            if(isClonePar == 'false'){
                isManualCase = true;
            }
            
            System.debug('PROMOTE EMAIL TO CASE NOW');
            isClone = true;
            
            //clone the email
            emailClone = supportCase.Clone(false,true,false,false);
            
            //update the original email case in order to premote it to a full support case
            //assign service type map values to case fields
            supportCase.Complexity__c = serviceMap.get('Complexity__c');
            supportCase.First_Approval__c = serviceMap.get('First_Approval__c');
            supportCase.ID_V__c = serviceMap.get('ID_V__c');
            supportCase.Priority = serviceMap.get('Priority');
            supportCase.Second_Approval__c = serviceMap.get('Second_Approval__c');
            supportCase.Service_Mapping_Entry__c = serviceMap.get('Id');
            supportCase.SLA_Time_Measure__c = serviceMap.get('SLA_Time_Measure__c');
            supportcase.SLA_Units__c = Decimal.valueOf(serviceMap.get('SLA_Units__c'));
            supportCase.Email_Action__c = 'None';
            supportCase.Email_Status__c = 'Promoted';
            supportCase.Status = 'In Progress';
            supportCase.hWasEmailToCaseAction__c = false;
            supportCase.Email_Queue_Position__c = CSC_Cherry_Picking_Position.getCaseQueuePosition(caseId);
            supportCase.Actioned_By__c = System.UserInfo.getUserId();
            //System.debug('USER : ' + System.UserInfo.getUserId() + '' + System.UserInfo.getName());
            supportCase.OwnerId = System.UserInfo.getUserId();
            
            if(!isManualCase){
                supportCase.Origin = 'Email';
            }
            supportCase.RunUDFValidation__c = true;
            
            //ajust SLA Dates
            list<DateTime> SLATimes = caseFunc.getSLAEndDate(supportCase.CreatedDate);
            supportCase.SLA_Date_1__c = SLATimes[0];
            supportCase.SLA_Date_2__c = SLATimes[1];
            
            //Section that will convert any service type to a different record type if specified in the mapping table
            if(serviceMap.get('Convert_To_RecordType__c') != null){
                
                list<RecordType> convertToType = [Select Id From RecordType Where DeveloperName = :serviceMap.get('Convert_To_RecordType__c')];
                
                if(convertToType.size() > 0){
                    supportCase.RecordTypeId = convertToType[0].Id;
                }
                
            }else{
                supportCase.RecordTypeId = [Select Id From RecordType Where DeveloperName = 'CSC_Default_Support_Cases'].Id;
            }
            //Set next due date for the feedback email alert to fire
            if( serviceMap.get('Feedback_Time_Measure__c') != null && serviceMap.get('Feedback_Units__c') != null){
                supportCase.Recursive_Client_Alert_Date__c = caseFunc.getFeedbackDueDate(System.now());
                supportCase.Fire_Feedback_Alert__c = false;
                supportCase.Reset_Feedback_Alert__c = true;
            }
            
            try{
                update supportCase;
                
            }catch(DMLException e){
                CSC_AuditTrailLog.logException(e, 'New', 'Failure', 'lscSupportCaseMainCont', 'runProcess', 'There was an error while promoting the email to case');
                errorMessage+= 'There was an error while promoting the email to case';
                return errorMessage;
            }
            
            //Add the Delegated approver for the new case owner as a new Case team memeber  
            String delegatedApproverId = [Select DelegatedApproverId From User Where Id = :supportCase.OwnerId].DelegatedApproverId;
            String teamRoleId = [Select Id From CaseTeamRole Where Name = 'Team Leader'].Id;
            
            System.debug('delegatedApproverId = ' + delegatedApproverId);
            
            if(String.isNotBlank(delegatedApproverId)){
                try{
                    insert new CaseTeamMember(ParentId = supportCase.Id, MemberId = delegatedApproverId, TeamRoleId = teamRoleId); 
                }catch(DMLException teamEx){
                    //just a warning, do not return error string
                    CSC_AuditTrailLog.logException(teamEx, 'New', 'Warning', 'lscSupportCaseMainCont', 'runProcess', 'There was an Error while adding the Delegated approver for the new case owner as a new Case team memeber');
                }
            }
            
            if(!isManualCase){
                try{
                    
                    //insert email clone
                    emailClone.Email_Action__c = 'New Case Created';
                    emailClone.Email_Status__c = 'Actioned';
                    emailClone.Status = 'Closed Resolved';
                    emailClone.RecordTypeId = [Select Id From RecordType Where DeveloperName = 'CSC_Emails'].Id;
                    emailClone.Email_Received_Date__c = supportCase.CreatedDate;
                    emailClone.hRelated_Support_Case__c = supportCase.Id;
                    emailClone.Email_Queue_Position__c = supportCase.Email_Queue_Position__c;
                    emailClone.Actioned_By__c = supportCase.Actioned_By__c;
                    emailClone.RunUDFValidation__c = false;
                    emailClone.ParentId = supportCase.Id;
                    
                    insert emailClone;
                    
                    //clone emailmessage and link existing email attachemts
                    //Get email msg from original case
                    system.debug('Getting EmailMessage for conID = '+caseId);
                    list<EmailMessage> ems = [Select Id, TextBody, HtmlBody, Headers, Subject, MessageDate,  
                                              FromName, FromAddress, ToAddress, CcAddress, BccAddress, 
                                              Incoming, HasAttachment, Status, isOriginalEmail__c  
                                              From EmailMessage  
                                              Where ParentId = :caseId AND 
                                              isOriginalEmail__c = true Order By CreatedDate];
                    
                    if (ems.size() == 0){
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This record does not have an email message attached and cannot be converted into a new support case.'));
                        Database.rollback(sp);
                        errorMessage+= 'This record does not have an email message attached and cannot be converted into a new support case';
                        return errorMessage;     
                    }
                    
                    EmailMessage em = ems[0];
                    //clone message
                    EmailMessage emsg = new EmailMessage();
                    emsg.FromAddress = em.FromAddress;
                    emsg.FromName = em.FromName;
                    emsg.HtmlBody = em.HtmlBody;
                    emsg.TextBody = em.TextBody;
                    emsg.Headers = em.Headers;
                    emsg.CcAddress = em.CcAddress;
                    emsg.BccAddress = em.BccAddress;
                    emsg.Incoming = em.Incoming;
                    emsg.MessageDate = em.MessageDate;
                    emsg.Subject = em.Subject;
                    
                    emsg.ParentId = emailClone.Id;
                    System.debug('Insert the Cloned Email msg..');
                    insert emsg;
                    
                    //insert case feeditems as attachments to the emailobject in order to save on Content limits
                    //first get all teh related content for all feeditems
                    set<Id> verIds = new set<Id>();
                    for(FeedItem f : [Select RelatedRecordId FROM FeedItem Where ParentId = :supportCase.Id and Type = 'ContentPost']){
                        verIds.add(f.RelatedRecordId);
                    }
                    //now loop through the content and create att from them and link them to the cloned emailmessage
                    list<Attachment> emailAttList = new list<Attachment>();
                    for(ContentVersion con :[Select Id, Title, VersionData, PathOnClient FROM ContentVersion Where Id IN :verIds]){
                        Attachment attachment = new Attachment();
                        // attach to the newly created contact record
                        attachment.ParentId = emsg.Id;
                        attachment.Name = con.PathOnClient;
                        attachment.Body = con.VersionData;
                        emailAttList.add(attachment);
                    }
                    
                    //add email body att to new clone
                    list<Attachment> emailBody = [Select Id, Name, Body From Attachment Where Name = 'Email Body.html' and ParentId = :em.Id];
                    if(emailBody.size() > 0){
                        Attachment att = new Attachment();
                        att.ParentId = emsg.Id;
                        att.Name = emailBody[0].Name;
                        att.Body = emailBody[0].Body;
                        emailAttList.add(att);
                    }
                    
                    insert emailAttList;
                    
                }catch(DMLException cloneEx){
                    
                    Database.rollback(sp);
                    
                    CSC_AuditTrailLog.logException(cloneEx, 'New', 'Failure', 'lscSupportCaseMainCont', 'runProcess', 'There was an error while cloning the email case');
                    
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A technical error occured: '+cloneEx.getMessage()));
                    errorMessage+= 'A technical error occured: '+cloneEx.getMessage();
                    return errorMessage;                          
                }
            }
        }else{
            isClone = false;
        }
        
        if(supportCase.RecordType.DeveloperName == 'CSC_Default_Support_Cases' || isClone){
            return caseId;
        }else{
            return caseId;
        }
    }
}