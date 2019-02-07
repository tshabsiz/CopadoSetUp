/**
* Date   : 09-04-2016
* Author : RN - CloudSmiths
* Desc   : The main CSC Support case page
NB *** Currently only redirecting to the std page layout...might change this is 
future when we are going to use a VF page that will render fields dynamically based on service type
***
16-08-10DHAdded pagemessage for errors
Do a Database Savepoint as case was half converted due to catch ignoring the error and causing a commit Rollback on error, 
add page message and return - Check for missing Email Messages
2017-03-30 RN - CSC Phase II - Link email clone to support Case after classification
**/
public class CSC_Support_Case_Main_Cont {
    
    public Case supportCase;
    private String conId;
    private Case emailClone;
    private Boolean isClone;
    public map<String,String> serviceMap{get;set;}
    private CSC_Case_Functions caseFunc;
    private CSC_Exception_Audit_Trail__c auditTrail = new  CSC_Exception_Audit_Trail__c();
    
    public CSC_Support_Case_Main_Cont(ApexPages.StandardController controller){
        
        conId = ApexPages.currentPage().getParameters().get('Id');
        // load the current record
        supportCase = [Select Id, ContactId, AccountId, RecordTypeId, RecordType.DeveloperName, 
                       Status, Origin, Subject, Description, CreatedDate, OwnerId, Queue__c, 
                       Email_To_Address__c, Business_Hours__c, Team__c, Department__c,Number_of_Requests__c, 
                       Second_Approval__c, First_Approval__c, Team_Member_Approval__c,Charge_Client__c, 
                       Complexity__c, Service_Type__c, Service_Sub_Category__c, Service_Category__c, ID_V__c, 
                       ID_V_Complete__c, Email_Action__c, Email_From_Address__c, Email_Queue_Position__c, 
                       Email_Sender_Name__c, Email_Status__c, Channel__c, SLA_Date_1__c, SLA_Date_2__c  
                       From Case 
                       Where Id = :conId];
        
        //get service mapping
        caseFunc = new CSC_Case_Functions(SupportCase);
        serviceMap = new map<String,String>();
        
    }
    
    public PageReference runProcess() {
        
        serviceMap = caseFunc.getServiceMapping();
        System.debug('MAPPING = ' + serviceMap);
        System.debug('MAPPING = ' + serviceMap.values());
        
        //Check if a service type record returned, if not let the user know his selection is invalid
        if(serviceMap.isEmpty()){
            System.debug('MAPPING IS NULL');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                       'The Selected Service type, Sub-Category and Category are invalid. ' + 
                                                       'Please contact your Salesforce Administrator to ensure the service mapping ' + 
                                                       'is correctly entered in Salesforce'));
                 return null;
           
        }
        
        
        
        //verify if this controller was invoked by the Email Actions VF page in the Service console. if yes 
        //create new clone of exiting Email type case, else just load the exiting case
        //NB - We clone the email case to keep for historical reasons, then update the email Case to promote it to a full Support Case
        //in order to keep the original creation date when the email was recieved for SLA reasons. 
        if(ApexPages.currentPage().getParameters().get('isclone') != null){
            // If we get an error, we need to rollback the whole process and disply friend message to users
            SavePoint sp = Database.setSavepoint();
            boolean isManualCase = false;
            
            if(ApexPages.currentPage().getParameters().get('isclone') == 'false'){
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
            supportCase.Email_Queue_Position__c = CSC_Cherry_Picking_Position.getCaseQueuePosition(conId);
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
                CSC_AuditTrailLog.logException(e, 'New', 'Failure', 'CSC_Support_Case_Main_Cont', 'runProcess', 'There was an error while promoting the email to case');
            }
            
            //Add the Delegated approver for the new case owner as a new Case team memeber  
            String delegatedApproverId = [Select DelegatedApproverId From User Where Id = :supportCase.OwnerId].DelegatedApproverId;
            String teamRoleId = [Select Id From CaseTeamRole Where Name = 'Team Leader'].Id;
            
            System.debug('delegatedApproverId = ' + delegatedApproverId);
            
            if(String.isNotBlank(delegatedApproverId)){
                try{
                    insert new CaseTeamMember(ParentId = supportCase.Id, MemberId = delegatedApproverId, TeamRoleId = teamRoleId); 
                }catch(DMLException teamEx){
                    CSC_AuditTrailLog.logException(teamEx, 'New', 'Warning', 'CSC_Support_Case_Main_Cont', 'runProcess', 'There was an Error while adding the Delegated approver for the new case owner as a new Case team memeber');
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
                    system.debug('Getting EmailMessage for conID = '+conID);
                    list<EmailMessage> ems = [Select Id, TextBody, HtmlBody, Headers, Subject, MessageDate,  
                                        FromName, FromAddress, ToAddress, CcAddress, BccAddress, 
                                        Incoming, HasAttachment, Status, isOriginalEmail__c  
                                        From EmailMessage  
                                        Where ParentId = :conId AND 
                                        isOriginalEmail__c = true Order By CreatedDate];
                    
                    if (ems.size() == 0){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This record does not have an email message attached and cannot be converted into a new support case.'));
                        Database.rollback(sp);
                        return null;     
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
                    
                    CSC_AuditTrailLog.logException(cloneEx, 'New', 'Failure', 'CSC_Support_Case_Main_Cont', 'runProcess', 'There was an error while cloning the email case');
                  
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A technical error occured: '+cloneEx.getMessage()));
                    return null;                          
                }
        }
        }else{
            isClone = false;
        }
        
        //Validate if this is a CSC Support Case, if yes load VF page, if not redirect to standard Case page 
        //with the nooverride url param to prevent endless loop
        if(supportCase.RecordType.DeveloperName == 'CSC_Default_Support_Cases' || isClone){
            
            //TO DO : Return null here if we are going to use a VF page to disply the Case
            //return null;
            //for now we just redirect back to the std page layout
            //PageReference p = new  PageReference('/' + supportCase.Id + '?nooverride=1');
            PageReference p = new  PageReference('/' + supportCase.Id + '/e');
            p.setRedirect(true);
            return p;
            //*********************************************************************
        }else{//OPEN all other cases in std page layouts by not using the override to the CSC VF page
            PageReference p = new  PageReference('/' + supportCase.Id + '?nooverride=1');
            p.setRedirect(true);
            return p;
        }
    }
    
    public PageReference reload() {
        PageReference p = new  PageReference('/' + supportCase.Id + '?nooverride=1');
        p.setRedirect(true);
        return p;
    }
    
}