/**
* Date   : 31-05-2016
* Author : RN - CloudSmiths
* Desc   : Function class for the Case trigger
* 1 - updateServiceMapping()
* update the service maping if a user changed the queue
* RN - 201702
* Add feature for MNPI private complaint
* -------------------------------------------
* 20170302 - Rudolf Niehaus
* Exclude Megtape queues from the cherry picking process - running into soql errors for large data sets
* 20170314 - Rudolf Niehaus
* Prevent users from closing a case if there is not at least one case comment 
* 20170322 - Rudolf Niehaus
* Bug fixes : Exclude flagging and linking of emails from the Case comment enforcement
* 20170405 - Rudolf Niehaus - CloudSmiths : Add the single email limits tracking feature
* 20170406 - Rudolf Niehaus - CloudSmiths : Keep queue and full team in sync when change 
* 20170418 - Rudolf Niehaus - CloudSmiths : Add case comments if the Add Case Comment on the case is populated
* 20170419 - Rudolf Niehaus - CloudSmiths : Add logic to skip comments validation
* 20170428 - Rudolf Niehaus - CloudSmiths : Visual Indicator
* 20170504 - Rudolf Niehaus - CloudSmiths : Optimize class to user 1 query to get all case recordtypes into a map, then reference the map multipal times
* 20170504 - Rudolf Niehaus - CloudSmiths : Add logic that will update the related Account record with the User Codes
* 20170511 - Rudolf Niehaus - CloudSmiths : Add logic for account numbers 
* 20170517/23 - Rudolf Niehaus - CloudSmiths : SLA Pause feature
* 20170601 - Rudolf Niehaus - CloudSmiths : Add new Case tracking feature per Case status
* 20170613 - Rudolf Niehaus - CloudSmiths : SLA reset on service type change 
* 2017-07-06: Mabhedle Tonga  - Barclays : Added a method to add case creator as case team member upon case creation
* 20170711 - Rudolf Niehaus - CloudSmiths : SLA Pause feature and timer for 3rd party hold-ups
* 20170711 - Rudolf Niehaus - CloudSmiths : Record time a case is in the hands of a 3rd party
* 20170713 - Rudolf Niehaus - CloudSmiths : Change case owner from queue to user on case closure
**/
public class CSC_Case_Trigger_Functions_Complaint {
    
    //*** NB - This method only handles one record at a time, it is not built for bulk updates as users only transefer cases via the console
    public static void updateServiceMapping(list<Case> updatedCase, map<Id,Case> oldValues ){
        
        //Check if the case was closed and if there are any comments for the Case
        //Prevent users from closing a case if there is not at least one case comment 
        String oldStatus = oldValues.get(updatedCase[0].Id).Status;
        String newStatus = updatedCase[0].Status;
        String emailAction = '';
        
        list<CaseComment> commList = new list<CaseComment>();
        
        //RN - Get all recordtypes for Cases in a map - use one query then ref map multipal times 
        map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        if(updatedCase[0].Email_Action__c != null){
            emailAction = updatedCase[0].Email_Action__c;
        }
        
        boolean skipCommValidation = false;
        
        if(String.isBlank(oldValues.get(updatedCase[0].Id).Add_Case_Comment__c) && String.isNotBlank(updatedCase[0].Add_Case_Comment__c)){
            
            //Add new case comment automatically
            CaseComment cc = new CaseComment();
            cc.CommentBody = updatedCase[0].Add_Case_Comment__c;
            cc.IsPublished = true;
            cc.ParentId = updatedCase[0].id;
            commList.add(cc);
            
            //reset text field on the Case
            updatedCase[0].Add_Case_Comment__c = null;
            skipCommValidation = true;
            
            //reset indicator
            if(updatedCase[0].hHasClientUpdate__c){
                updatedCase[0].hHasClientUpdate__c = false;
            }
            
        }else if(String.isBlank(oldValues.get(updatedCase[0].Id).Add_Case_Comment__c) && String.isBlank(updatedCase[0].Add_Case_Comment__c)){
            
            skipCommValidation = false;
        }
        
        //Tonga MM : Case comment no longer required when closing a case
       /* if(!emailAction.contains('Flag as') && !emailAction.contains('Linked to Existing')){
            if(oldStatus != null){
                if(!oldValues.get(updatedCase[0].Id).isClosed && !oldStatus.contains('Closed') && newStatus.contains('Closed') && !skipCommValidation){
                    
                    list<CaseComment> ccmt = [Select ParentId From CaseComment Where ParentId = :updatedCase[0].Id];
                    
                    if(ccmt.size() == 0){
                        updatedCase[0].addError('You cannot Close a Case if there are NO Case Comments. Add at least 1 Case Comment to this Case before closing the Case');
                    }
                }
            }
        }*/
        
        //map all the service type entries by queue name
        CSC_Case_Functions_Complaint caseFunc = new CSC_Case_Functions_Complaint(updatedCase[0]);
        map<String,String> serviceMap = caseFunc.getServiceMapping();
        
        //check if owner changed from user -> queue OR queue -> queue
        boolean isNewQueue = false;
        String ownerType = updatedCase[0].OwnerId;
        
        if(updatedCase[0].OwnerId != oldValues.get(updatedCase[0].Id).OwnerId){
            if(!ownerType.startsWith('005')){
                isNewQueue = true;
            }
        }

        //check if the Full team value changed not the owner OR the Service Type not the Owner(queue) 
        if( (updatedCase[0].Resolving_Team__c != oldValues.get(updatedCase[0].Id).Resolving_Team__c && !isNewQueue)){
               
               list<Group> queueId = [Select Id From Group Where DeveloperName = :serviceMap.get('Queue_Name__c') AND Type = 'Queue'];
               list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :caseFunc.getBusinessHours()];
               
               if(bhId.size() ==0){
                   bhId = [Select Id From BusinessHours Where IsDefault=true];
               }
               
               if(queueId.size() > 0 && !isNewQueue){
                   //reset values based on new queue selection
                   updatedCase[0].OwnerId = queueId[0].Id;
                   updatedCase[0].Service_Mapping_Entry__c = serviceMap.get('Id');
                   updatedCase[0].Resolving_Team__c = serviceMap.get('Queue__c');
                   updatedCase[0].Queue__c = serviceMap.get('Queue__c');
                   updatedCase[0].Business_Hours__c = serviceMap.get('Business_Hours__c');
                   updatedCase[0].Complexity__c = serviceMap.get('Complexity__c');
                   updatedCase[0].First_Approval__c = serviceMap.get('First_Approval__c');
                   updatedCase[0].ID_V__c = serviceMap.get('ID_V__c');
                   updatedCase[0].Priority = serviceMap.get('Priority');
                   updatedCase[0].Second_Approval__c = serviceMap.get('Second_Approval__c');
                   updatedCase[0].SLA_Time_Measure__c = serviceMap.get('SLA_Time_Measure__c');
                   updatedCase[0].SLA_Units__c = Decimal.valueOf(serviceMap.get('SLA_Units__c'));
                   updatedCase[0].BusinessHoursId = bhId[0].Id;
                   
                   List<String> nameList = new List<String>();
                   
                   nameList.add(serviceMap.get('Team_Manager__c'));
                   nameList.add(serviceMap.get('Department_Manager__c'));
                   
                   Map<String,ID> nameToIDMap = getNameToID(nameList);
                       
                       if(nameToIDMap.containsKey(serviceMap.get('Team_Manager__c')))
                       {
                           updatedCase[0].Team_Manager_User__c = nameToIDMap.get(serviceMap.get('Team_Manager__c')) ;
                       }
                       if(nameToIDMap.containsKey(serviceMap.get('Department_Manager__c')))
                       {
                           updatedCase[0].Department_manager__c = nameToIDMap.get(serviceMap.get('Department_Manager__c'));
                       }
               }
               
               //adjust SLA Dates
               if(updatedCase[0].Complaint_Service_Type__c != oldValues.get(updatedCase[0].Id).Complaint_Service_Type__c){
                   list<DateTime> SLATimes = caseFunc.getSLAEndDate(updatedCase[0].CreatedDate);
                   updatedCase[0].SLA_Date_1__c = SLATimes[0];
                   updatedCase[0].SLA_Date_2__c = SLATimes[1];
               }
               
               //Set next due date for the feedback email alert to fire
               if( serviceMap.get('Feedback_Time_Measure__c') != null && serviceMap.get('Feedback_Units__c') != null){
                   updatedCase[0].Recursive_Client_Alert_Date__c = caseFunc.getFeedbackDueDate(System.now());
                   updatedCase[0].Fire_Feedback_Alert__c = false;
                   updatedCase[0].Reset_Feedback_Alert__c = true;
               }  
           }else if(isNewQueue){//RN : keep queue and full team in sync 
               
               list<Group> queueAPINames = [Select DeveloperName From Group Where Id = :updatedCase[0].OwnerId];
               
               if(queueAPINames.size() > 0){
                   
                   list<Service_Mapping__c> sm = [Select Id, Queue_Name__c,Team_manager__c,Department_Manager__c, Queue__c, Team__c, Department__c, Business_Hours__c, Full_Department__c  
                                                  From Service_Mapping__c  
                                                  Where Queue_Name__c = :queueAPINames[0].DeveloperName Order By Effective_Date__c DESC limit 1];
                   
                   
                   
                   if(sm.size() > 0){
                       List<String> nameList = new List<String>();
                       
                       nameList.add(sm[0].Team_manager__c);
                       nameList.add(sm[0].Department_manager__c);
                       updatedCase[0].Service_Mapping_Entry__c = sm[0].Id;
                       updatedCase[0].Resolving_Team__c = sm[0].Queue__c;
                       updatedCase[0].Queue__c = sm[0].Queue__c;
                       updatedCase[0].Business_Hours__c = sm[0].Business_Hours__c;
                       
                       Map<String,ID> nameToIDMap = getNameToID(nameList);
                       
                       if(nameToIDMap.containsKey(sm[0].Team_manager__c))
                       {
                           updatedCase[0].Team_Manager_User__c = nameToIDMap.get(sm[0].Team_manager__c) ;
                       }
                       if(nameToIDMap.containsKey(sm[0].Department_manager__c))
                       {
                           updatedCase[0].Department_manager__c = nameToIDMap.get(sm[0].Department_manager__c) ;
                       }
                       
                   }
               }else{
                   updatedCase[0].addError('The system could not find the queue you have selected');
               }
           }
        
        //Section that will convert any service type to a different record type if specified in the mapping table
        if(serviceMap.get('Convert_To_RecordType__c') != null){
            
            list<RecordType> convertToType = [Select Id From RecordType Where DeveloperName = :serviceMap.get('Convert_To_RecordType__c')];
            
            if(convertToType.size() > 0 && convertToType[0].Id != updatedCase[0].RecordTypeId){
                updatedCase[0].RecordTypeId = convertToType[0].Id;
            }
            
            //If converted to complaint and full team is not the complaints team, then update full team
            String fullTeam = updatedCase[0].Resolving_Team__c;
            
        }
        
        //convert to OR from a MNPI private complaint, only if the chackbox have changed
        if(updatedCase[0].MNPI__c != oldValues.get(updatedCase[0].Id).MNPI__c || updatedCase[0].Staff_Error__c != oldValues.get(updatedCase[0].Id).Staff_Error__c){
            
            if(updatedCase[0].MNPI__c || updatedCase[0].Staff_Error__c){
                //This is a MNPI complaint - use std lookup ralationships so we do not inherit the security model and change the record type
                updatedCase[0].Relationship_Name_MNPI__c = updatedCase[0].AccountId;
                updatedCase[0].AccountId = null;
                updatedCase[0].OwnerId = System.UserInfo.getUserId();
                
                String MNPITypeRecId = caseRecordTypeMap.get('MNPI Complaint').getRecordTypeId();
                updatedCase[0].RecordTypeId = MNPITypeRecId;
                
            }else if(!updatedCase[0].MNPI__c && !updatedCase[0].Staff_Error__c){
                
                updatedCase[0].AccountId = updatedCase[0].Relationship_Name_MNPI__c;
                updatedCase[0].Relationship_Name_MNPI__c = null;
                updatedCase[0].Staff_Member_Name__c = null;
                updatedCase[0].Staff_Error_Description__c = null;
                //updatedCase[0].ContactId = updatedCase[0].Contact_MNPI__c;
                //updatedCase[0].Contact_MNPI__c = null;
                
                String CompTypeRecId = caseRecordTypeMap.get('Complaint').getRecordTypeId();
                updatedCase[0].RecordTypeId = CompTypeRecId;
                
            }
            
        }
        
        //If the email action changed we need to know where in the case queue this email was when it was actioned
        //Exclude any Transferred emails as these still needs to be actioned from a different queue
        if(updatedCase[0].Email_Action__c != 'New' && updatedCase[0].Email_Action__c != 'Transferred' && oldValues.get(updatedCase[0].Id).Email_Action__c == 'New'){
            //get Case queue position and update the Case --- this determines where in the queue this email was picked from by the
            //agent
            //## RN - Exclude magtape cases ###
            String magtape = updatedCase[0].Queue__c;
            if(!magtape.contains('Magtapes')){
                updatedCase[0].Email_Queue_Position__c = CSC_Cherry_Picking_Position.getCaseQueuePosition(updatedCase[0].Id);
            }
            updatedCase[0].Actioned_By__c = System.UserInfo.getUserId();
        }
        
        //RN - SLA RAG indicator Pause section ( both external and internal )
        //Check if status change and if a SLA pause status were selected by the user
        if(updatedCase[0].Status != oldValues.get(updatedCase[0].Id).Status){
            
            String pauseStatus = serviceMap.get('SLA_Pause_Status__c');
            String pauseStatusInt = serviceMap.get('SLA_Pause_Status_Internal__c');
            set<String> pauseStatusSet = new set<String>(pauseStatus.split(','));
            set<String> pauseStatusSetInt = new set<String>(pauseStatusInt.split(','));
            
            
            //Re-set pause flag and adjust SLA end date
            if((!pauseStatusSet.contains(updatedCase[0].Status) && pauseStatusSet.contains(oldValues.get(updatedCase[0].Id).Status)) || 
                (!pauseStatusSetInt.contains(updatedCase[0].Status) && pauseStatusSetInt.contains(oldValues.get(updatedCase[0].Id).Status))){
                
                //get diff between current date/time and when the pause was date stamped
                
                DateTime pauseDateTime = updatedCase[0].hSLA_Pause_Date__c;

                long currentTime = System.now().getTime();
                long pauseTime = 0;
                    
                if(pauseDateTime != null){
                    pauseTime  = pauseDateTime.getTime();
                }else{
                    pauseTime = currentTime;
                }
                
                long timeDiff = (currentTime - pauseTime);
                    
                //Move SLA date forward with the timeframe the Case was paused
                Integer warningTime = 60 * 60 * 1000; //60min;
                updatedCase[0].SLA_Date_2__c = BusinessHours.add(updatedCase[0].BusinessHoursId, updatedCase[0].SLA_Date_2__c, timeDiff);
                updatedCase[0].SLA_Date_1__c = updatedCase[0].SLA_Date_2__c;
                updatedCase[0].SLA_Date_1__c = BusinessHours.add(updatedCase[0].BusinessHoursId, updatedCase[0].SLA_Date_1__c, (warningTime * -1));
                 
                updatedCase[0].hSLA_Pause_Flag__c = false;
                updatedCase[0].hSLA_Pause_Date__c = null;
            }
            
            //set SLA pause flag
            if((pauseStatusSet.contains(updatedCase[0].Status) && !pauseStatusSet.contains(oldValues.get(updatedCase[0].Id).Status)) || 
                (pauseStatusSetInt.contains(updatedCase[0].Status) && !pauseStatusSetInt.contains(oldValues.get(updatedCase[0].Id).Status))){
                
                updatedCase[0].hSLA_Pause_Flag__c = true;
                updatedCase[0].hSLA_Pause_Date__c = System.now();
            }
        }
        
        //check if Case Escalated, then update a hidden field on the case in order to send out escalation notifications
        //if(!oldValues.get(updatedCase[0].Id).IsEscalated && updatedCase[0].IsEscalated){
        //     System.debug('CASE JUST Escalated');
        //    updatedCase[0].hSendEscalationNotification__c = true;
        // } 
        
        if(commList.size() > 0){
            try{
                insert commList;
            }catch(DMLException ex){
                CSC_AuditTrailLog.logException(ex, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'updateServiceMapping', 'There was an error adding a new Case Comment automatically');
            }
        }
        
        //RN - check if case was closed and if the owner is not human at that stage
        //this values updatedCase[0].isClosed is only set after the before trigger event :-(
        //So I have to use the case status to determine if a user closed the case as we need to set the owner and that 
        //cannot be done in after trigger events
        if(String.isNotBlank(oldStatus)){
            if(!ownerType.startsWith('005') &&  newStatus.contains('Closed') && !oldStatus.contains('Closed') ){
                updatedCase[0].OwnerId = UserInfo.getUserId();
            }
        }   
    }
    
    public static void emailResponse(list<Case> newEmail){
        //Limits tracking object
        list<System_Limits_Tracker__c> tracker = [Select Id, Name, X24_Running_Limit__c, Use_WorkAround__c 
                                                  From System_Limits_Tracker__c Where Name = 'SingleEmail' limit 1];
        
        //get all the email template ID's into maps 
        CSC_Case_Functions_Complaint caseFunc = new CSC_Case_Functions_Complaint();
        caseFunc.populateQueueTemplateIDMaps();
        
        //RN - Get all recordtypes for Cases in a map - use one query then ref map multipal times 
        map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        //get rectype id's so we can validate if this is an email Case or a new manual case
        String manualCaseRecTypeId = caseRecordTypeMap.get('CSC Manual Cases').getRecordTypeId();
        String supportCaseRecTypeId = caseRecordTypeMap.get('CSC Default Support Cases').getRecordTypeId();
        String emailCaseRecTypeId = caseRecordTypeMap.get('CSC Emails').getRecordTypeId();
        
        
        //get any contact with a valid email address. We need this because you cannot send an email with a template without 
        //the Target Object ID, and this can only be a Lead, Contact or user. The WhatId is the Case and this
        //will populate teh merged fields as we use the case.email_sender_name in the templates.
        list<Contact> lstCon = [Select Id From Contact Where Email = 'agents@support.co.za' limit 1];
        
        map<String,Id> OWDIdMap = new map<String,Id>();
        String defaultOWD = '';
        
        for(OrgWideEmailAddress owd :[Select Id, Address From OrgWideEmailAddress]){
            
            OWDIdMap.put(owd.Address,owd.Id);
            //add the first owd address as the default should we not find any match 
            if(defaultOWD == ''){
                defaultOWD = owd.Id;
            }
        }
        
        //list of emails
        List<Messaging.SingleEmailMessage> emailsOutList = new List<Messaging.SingleEmailMessage>();
        //RN - Leave this line of code here please, just in case business wants to revert back
        //list<EmailMessage> emailMsg = new list<EmailMessage>();
        
        list<Task> emailTasks = new list<Task>();
        
        //loop through the new cases and constructed a list of emails to send out
        for(Case c :newEmail ){
            //RN - Skip email when the from address is empty, this could happens when a user creates a manual case
            if(String.isNotBlank(c.Email_From_Address__c)){
                                    
                    if(c.Email_Status__c != 'Actioned' || System.Test.isRunningTest()){
                        
                        //create a list with the original senders email address (Email From Address)
                        list<String> toAddress = new list<String> {c.Email_From_Address__c};
                            Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage();
                        
                        if(caseFunc.orgWideAddressMap.get(c.Resolving_Team__c) != null){
                            emailOut.setOrgWideEmailAddressId(OWDIdMap.get(caseFunc.orgWideAddressMap.get(c.Resolving_Team__c)));
                        }else{
                            if(String.isNotBlank(defaultOWD)){
                                emailOut.setOrgWideEmailAddressId(defaultOWD);
                            }else{
                                emailOut.setSenderDisplayName('ABSA Support');
                            }
                        }
                        
                        emailOut.setTargetObjectId(lstCon[0].Id);
                        emailOut.setTreatTargetObjectAsRecipient(false);
                        emailOut.setToAddresses(toAddress);
                        emailOut.setWhatId(c.Id);
                        
                        //RN - Use Tasks for phase 2 not emails
                        Task t = new Task();
                        t.Subject = 'Receipt Email Sent to the Client ' + c.Email_From_Address__c;
                        t.WhatId = c.Id;
                        t.Status = 'Completed';
                        t.Priority = 'Normal';
                        t.Description = 'Receipt Email Sent to : ' + c.Email_From_Address__c;
                        emailTasks.Add(t);
                        
                        
                        if(caseFunc.templateMapCaseCreation.containsKey(c.Resolving_Team__c)){
                                if(String.isNotBlank(caseFunc.templateMapCaseCreation.get(c.Resolving_Team__c))){
                                    emailOut.setTemplateId(caseFunc.templateMapCaseCreation.get(c.Resolving_Team__c));
                                    emailsOutList.add(emailOut);
                                }
                            }
                    }
                
            }
        }
        
        //now send the list of emails
        if(emailsOutList.size() > 0){
            
            if(tracker.size()>0){
                if(!tracker[0].Use_WorkAround__c){
                    
                    Messaging.sendEmail(emailsOutList);
                    //increment running limit
                    tracker[0].X24_Running_Limit__c+= 1;
                }
            }else{
                Messaging.sendEmail(emailsOutList);
            }
            try{
                //RN - Keep this line of code here please, just in case business wants to revert back
                //insert emailMsg;
                
                insert emailTasks;
                
            }catch(DMLException e){
                CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'emailResponse', 'There was an error while inserting the Case email message Task');
            }
            try{
                if(tracker.size()>0){
                    update tracker;
                }
            }catch(DMLException e){
                CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'emailResponse', 'There was an error incrementing the 24 hour running limit value');
            }
        }
    }
    
    public static void caseResponse(list<Case> updatedCase, map<Id,Case> oldValues ){
        
        //Limits tracking object
        list<System_Limits_Tracker__c> tracker = [Select Id, Name, X24_Running_Limit__c, Use_WorkAround__c 
                                                  From System_Limits_Tracker__c Where Name = 'SingleEmail' limit 1];
        
        //get all the email template ID's into maps 
        CSC_Case_Functions_Complaint caseFunc = new CSC_Case_Functions_Complaint();
        caseFunc.populateQueueTemplateIDMaps();
        
        //RN - Get all recordtypes for Cases in a map - use one query then ref map multipal times 
        map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        //String emailCaseRecTypeId = [Select Id From RecordType Where DeveloperName = 'CSC_Emails'].Id;
        String emailCaseRecTypeId = caseRecordTypeMap.get('CSC Emails').getRecordTypeId();
        String compMNPIRecId = caseRecordTypeMap.get('MNPI Complaint').getRecordTypeId();
        String compRecId = caseRecordTypeMap.get('Complaint').getRecordTypeId();
        
        //get any contact with a valid email address. We need this because you cannot send an email with a template without 
        //the Target Object ID, and this can only be a Lead, Contact or user. The WhatId is the Case and this
        //will populate the merged fields as we use the case.email_sender_name in the templates.
        
        list<Contact> lstCon = [Select Id From Contact Where Email = 'agents@support.co.za' limit 1];
        map<String,Id> OWDIdMap = new map<String,Id>();
        String defaultOWD = '';
        
        for(OrgWideEmailAddress owd :[Select Id, Address From OrgWideEmailAddress]){
            
            OWDIdMap.put(owd.Address,owd.Id);
            //add the first owd address as the default should we not find any match 
            if(defaultOWD == ''){
                defaultOWD = owd.Id;
            }
        }
        
        //list of emails
        list<Messaging.SingleEmailMessage> emailsOutList = new list<Messaging.SingleEmailMessage>();
        
        //RN - Leave this line of code here please, just in case business wants to revert back
        //list<EmailMessage> emailMsg = new list<EmailMessage>();
        
        list<Task> emailTasks = new list<Task>();
        
        //loop through the updated cases and constructed a list of emails to send out
        for(Case c :updatedCase ){
            
            //RN - Skip email when the from address is empty, this could happens when a user creates a manual case
            if(String.isNotBlank(c.Email_From_Address__c)){
                
                //create a list with the original senders email address (Email From Address)
                list<String> toAddress = new list<String> {c.Email_From_Address__c};
                    Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage();
                
                //RN - Use Tasks for phase 2
                Task t = new Task();
                t.WhatId = c.Id;
                t.Status = 'Completed';
                t.Priority = 'Normal';
                
                Boolean skipResponse = false;
                
                //FOR CSC TYPE EMAILS AND CASES
                //-------------------------------------------------------------------------------
                //check if this is an email type Case that was promoted to a new support Case type OR a Case that was Closed
                if(c.Email_Status__c == 'Promoted' && oldValues.get(c.Id).Email_Status__c == 'New' && !c.IsClosed){ 
                    
                    if(String.isBlank(caseFunc.templateMapCaseCreation.get(c.Resolving_Team__c))){
                        skipResponse = true;
                    }
                    
                    emailOut.setTemplateId(caseFunc.templateMapCaseCreation.get(c.Resolving_Team__c));
                    
                    //RN - Leave this line of code here please, just in case business wants to revert back
                    //em.Subject = 'Case Created Email Sent to the Client';
                    //em.TextBody = 'Case Created Email Sent to the Client';
                    t.Subject = 'Case Created Email Sent to the Client ' + c.Email_From_Address__c;
                    t.Description = 'Case Created Email Sent to the Client : ' + c.Email_From_Address__c;
                    
                }else if(c.IsClosed && !oldValues.get(c.Id).IsClosed){
                    
                    if(String.isBlank(caseFunc.templateMapCaseClose.get(c.Resolving_Team__c))){
                        skipResponse = true;
                    }
                    
                    emailOut.setTemplateId(caseFunc.templateMapCaseClose.get(c.Resolving_Team__c));
                    
                    //RN - Leave this line of code here please, just in case business wants to revert back
                    //em.Subject = 'Case Resolved Email Sent to the Client';
                    //em.TextBody = 'Case Resolved Email Sent to the Client';
                    t.Subject = 'Case Resolved Email Sent to the Client ' + c.Email_From_Address__c;
                    t.Description = 'Case Resolved Email Sent to the Client : ' + c.Email_From_Address__c;
                    
                }else{
                    skipResponse = true;
                }
                
                //FOR COMPLAINTS CASES
                //---------------------------------------------------------------------------
                if((c.RecordTypeId == compMNPIRecId || c.RecordTypeId == compRecId) && !c.IsClosed || System.Test.isRunningTest()){
                    
                    String oldowner = oldValues.get(c.Id).OwnerId;
                    String newowner = c.OwnerId;
                    
                    //changed from a queue to a user as owner
                    if(oldValues.get(c.Id).OwnerId != c.OwnerId && !oldowner.startsWith('005') && newowner.StartsWith('005') && !c.IsClosed){
                        
                        if(String.isBlank(caseFunc.templateMapCaseCreation.get(c.Resolving_Team__c))){
                            skipResponse = true;
                        }
                        
                        emailOut.setTemplateId(caseFunc.templateMapCaseCreation.get(c.Resolving_Team__c));
                        
                      
                        
                        skipResponse = false;
                        
                    }else{
                        skipResponse = true;
                    }
                }
                
                if(c.IsClosed && oldValues.get(c.Id).IsClosed){
                    skipResponse = true;
                }
                if(c.Status == 'Closed Unresolved' || c.Status == 'Closed Duplicate' || c.Suppress_Acknowledge_Alert__c || c.status =='Closed NFFP'){
                    skipResponse = true;
                }
                
                if(String.isNotBlank(c.Email_Action__c)){
                    String eAction = c.Email_Action__c;
                    if(eAction.startsWith('Flag') || eAction.equals('Linked to Existing Case') || c.RecordTypeId == emailCaseRecTypeId){
                        skipResponse = true;
                    }
                }
                
                if(caseFunc.orgWideAddressMap.get(c.Resolving_Team__c) != null){
                    emailOut.setOrgWideEmailAddressId(OWDIdMap.get(caseFunc.orgWideAddressMap.get(c.Resolving_Team__c)));
                }else{
                    if(String.isNotBlank(defaultOWD)){
                        emailOut.setOrgWideEmailAddressId(defaultOWD); 
                    }else{
                        emailOut.setSenderDisplayName('ABSA Support');
                    }
                }
                
                emailOut.setTargetObjectId(lstCon[0].Id);
                emailOut.setTreatTargetObjectAsRecipient(false);
                emailOut.setToAddresses(toAddress);
                emailOut.setWhatId(c.Id);
                
                if(!skipResponse){
                    emailsOutList.add(emailOut);
                    //emailMsg.add(em);
                }
            }
        }
        
        //now send the list of emails and insert email messages into the case feed
        if(emailsOutList.size() > 0){
            
            if(tracker.size() > 0){ 	            
                if(!tracker[0].Use_WorkAround__c){
                    
                    Messaging.sendEmail(emailsOutList);
                    //increment running limit
                    tracker[0].X24_Running_Limit__c+= 1;
                }
            }else{
                Messaging.sendEmail(emailsOutList);
            }
            
            try{
                //RN - Leave this line of code here please, just in case business wants to revert back
                //insert emailMsg;
            }catch(DMLException e){
                CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'caseResponse', 'There was an error while inserting the Case feed email message');
            }
            try{
                if(tracker.size()>0){
                    update tracker;
                }
            }catch(DMLException e){
                CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'caseResponse', 'There was an error incrementing the 24 hour running limit value');
            }
        }
        
        //update related accounts
        //***NB : DO NOT DELETE OUT COMMENTED CODE - BUSINESS STILL DECIDING ******
        //updateRelatedAccounts(updatedCase, oldValues);
    }
    
    //NB - This method only handles **ONE (1)** record at a time, it is not built for bulk updates as it is linked
    //to updates form time base triggers
    //Recursive Client Feedback responses
    public static void feedbackResponse(list<Case> alertCases, map<Id,Case> oldValues){
        
        //Limits tracking object
        list<System_Limits_Tracker__c> tracker = [Select Id, Name, X24_Running_Limit__c, Use_WorkAround__c 
                                                  From System_Limits_Tracker__c Where Name = 'SingleEmail' limit 1];
        
        
        //RN - Skip email when the from address is empty, this could happens when a user creates a manual case
        if(String.isNotBlank(alertCases[0].Email_From_Address__c) && !alertCases[0].Suppress_Acknowledge_Alert__c){
            
            //map all the service type entries by queue name
            CSC_Case_Functions_Complaint caseFunc = new CSC_Case_Functions_Complaint(alertCases[0]);
            map<String,String> serviceMap = caseFunc.getServiceMapping();
            
            caseFunc.populateQueueTemplateIDMaps();
            
            //create a list with the original senders email address (Email From Address)
            list<String> toAddress = new list<String> {alertCases[0].Email_From_Address__c};
                Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage();
            EmailMessage em = new EmailMessage();
            em.FromAddress = alertCases[0].Support_Email_Address__c;
            em.ToAddress = alertCases[0].Email_From_Address__c;
            em.ParentId = alertCases[0].id;
            em.Subject = 'Feedback Email Sent to the Client';
            em.TextBody = 'Feedback Email Sent to the Client';
            
            list<Contact> lstCon = [Select Id From Contact Where Email = 'agents@support.co.za' limit 1];
            map<String,Id> OWDIdMap = new map<String,Id>();
            String defaultOWD = '';
            
            for(OrgWideEmailAddress owd :[Select Id, Address From OrgWideEmailAddress]){
                
                OWDIdMap.put(owd.Address,owd.Id);
                //add the first owd address as the default should we not find any match 
                if(defaultOWD == ''){
                    defaultOWD = owd.Id;
                }
            }
            
            //Check to see if we need to send the recursive feedback email to the client
            if(!oldValues.get(alertCases[0].Id).Fire_Feedback_Alert__c && alertCases[0].Fire_Feedback_Alert__c && !alertCases[0].IsClosed || Test.isRunningTest()){
                
                if(caseFunc.templateMapCaseFeedback.containsKey(alertCases[0].Resolving_Team__c) || Test.isRunningTest()){
                    
                    if(String.isNotBlank(caseFunc.templateMapCaseFeedback.get(alertCases[0].Resolving_Team__c))){
                        
                        emailOut.setTemplateId(caseFunc.templateMapCaseFeedback.get(alertCases[0].Resolving_Team__c));
                        emailOut.setTargetObjectId(lstCon[0].Id);
                        emailOut.setTreatTargetObjectAsRecipient(false);
                        emailOut.setToAddresses(toAddress);
                        emailOut.setWhatId(alertCases[0].Id);
                        
                        if(caseFunc.orgWideAddressMap.get(alertCases[0].Resolving_Team__c) != null){
                            emailOut.setOrgWideEmailAddressId(OWDIdMap.get(caseFunc.orgWideAddressMap.get(alertCases[0].Resolving_Team__c)));
                        }else{
                            if(String.isNotBlank(defaultOWD)){
                                emailOut.setOrgWideEmailAddressId(defaultOWD);
                            }else{
                                emailOut.setSenderDisplayName('ABSA Support');
                            }
                        }
                        
                        //Set next due date for the feedback email alert to fire
                        if( serviceMap.get('Feedback_Time_Measure__c') != null && serviceMap.get('Feedback_Units__c') != null){
                            alertCases[0].Recursive_Client_Alert_Date__c = caseFunc.getFeedbackDueDate(System.now());
                            alertCases[0].Fire_Feedback_Alert__c = false;
                            alertCases[0].Reset_Feedback_Alert__c = true;
                        }
                        
                        //send alert email now
                        if(tracker.size()>0){
                            if(!tracker[0].Use_WorkAround__c){
                                
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailOut});
                                //increment running limit
                                tracker[0].X24_Running_Limit__c+= 1;
                            }
                        }else{
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailOut});
                        }
                        
                        try{
                            insert em;
                        }catch(DMLException e){
                            CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'feedbackResponse', 'There was an error while inserting the Case feed email message');
                        }
                        
                        try{
                            if(tracker.size()>0){
                                update tracker;
                            }
                        }catch(DMLException e){
                            CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'feedbackResponse', 'There was an error incrementing the 24 hour running limit value');
                        }
                    }
                }
            }else if(alertCases[0].IsClosed){
                alertCases[0].Fire_Feedback_Alert__c = false;
                alertCases[0].Reset_Feedback_Alert__c = false;
            }
        }
    }
    
    //NB - This method only handles **ONE (1)** record at a time, it is not built for bulk inserts as users only create
    //manual cases via the console and classic for complaints
    public static void convertManualCases(list<Case> manualCases, Boolean isBeforeInsert){
        
        //RN - Get all recordtypes for Cases in a map - use one query then ref map multipal times 
        map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        String manualCaseRecTypeId = caseRecordTypeMap.get('CSC Manual Cases').getRecordTypeId();
        String convertedCaseRecTypeID = caseRecordTypeMap.get('CSC Default Support Cases').getRecordTypeId();
        String cloneEmailCaseRecTypeID = caseRecordTypeMap.get('CSC Emails').getRecordTypeId();
        String complaintCaseRecTypeId = caseRecordTypeMap.get('Complaint').getRecordTypeId();
        String complaintMNPICaseRecTypeId = caseRecordTypeMap.get('MNPI Complaint').getRecordTypeId();
        String dosCaseRecTypeId = caseRecordTypeMap.get('Digital Ops Cases').getRecordTypeId();
        
        if(isBeforeInsert){
            
            if(manualCases[0].RecordTypeId == manualCaseRecTypeId || manualCases[0].RecordTypeId == complaintCaseRecTypeId || 
               manualCases[0].RecordTypeId == complaintMNPICaseRecTypeId || manualCases[0].RecordTypeId == dosCaseRecTypeId || 
               (manualCases[0].RecordTypeId == convertedCaseRecTypeID && manualCases[0].ParentID != null)){
                   
                   //map all the service type entries by queue name
                   CSC_Case_Functions_Complaint caseFunc = new CSC_Case_Functions_Complaint(manualCases[0]);
                   map<String,String> serviceMap = caseFunc.getServiceMapping();
                   
                   //reset values based on new queue selection, skip complaints recordtype conversion
                   if(manualCases[0].RecordTypeId != complaintCaseRecTypeId){
                       manualCases[0].RecordTypeId = convertedCaseRecTypeID;
                   }
                   
                   manualCases[0].Service_Mapping_Entry__c = serviceMap.get('Id');
                   manualCases[0].Complexity__c = serviceMap.get('Complexity__c');
                   manualCases[0].First_Approval__c = serviceMap.get('First_Approval__c');
                   manualCases[0].ID_V__c = serviceMap.get('ID_V__c');
                   manualCases[0].Priority = serviceMap.get('Priority');
                   manualCases[0].Second_Approval__c = serviceMap.get('Second_Approval__c');
                   manualCases[0].SLA_Time_Measure__c = serviceMap.get('SLA_Time_Measure__c');
                   
                   
                   List<String> nameList = new List<String>();
                   
                   nameList.add(serviceMap.get('Team_Manager__c'));
                   nameList.add(serviceMap.get('Department_Manager__c'));
                   
                   Map<String,ID> nameToIDMap = getNameToID(nameList);
                       
                       if(nameToIDMap.containsKey(serviceMap.get('Team_Manager__c')))
                       {
                           manualCases[0].Team_Manager_User__c = nameToIDMap.get(serviceMap.get('Team_Manager__c')) ;
                       }
                       if(nameToIDMap.containsKey(serviceMap.get('Department_Manager__c')))
                       {
                           manualCases[0].Department_manager__c = nameToIDMap.get(serviceMap.get('Department_Manager__c'));
                       }
                   
                   
                   if(serviceMap.get('SLA_Units__c') != null){
                       manualCases[0].SLA_Units__c = Decimal.valueOf(serviceMap.get('SLA_Units__c'));
                       //Set SLA Dates
                       list<DateTime> SLATimes = caseFunc.getSLAEndDate(System.now());
                       manualCases[0].SLA_Date_1__c = SLATimes[0];
                       manualCases[0].SLA_Date_2__c = SLATimes[1];
                   }else{
                       manualCases[0].SLA_Units__c = 0;
                   }
                   //RN - Section that will convert any service type to a different record type if specified in the mapping table
                   if(serviceMap.get('Convert_To_RecordType__c') != null){
                       
                       list<RecordType> convertToType = [Select Id From RecordType Where DeveloperName = :serviceMap.get('Convert_To_RecordType__c')];
                       
                       if(convertToType.size() > 0 && convertToType[0].Id != manualCases[0].RecordTypeId){
                           manualCases[0].RecordTypeId = convertToType[0].Id;
                       }
                   }
                   //Set next due date for the feedback email alert to fire
                   if( serviceMap.get('Feedback_Time_Measure__c') != null && serviceMap.get('Feedback_Units__c') != null){
                       manualCases[0].Recursive_Client_Alert_Date__c = caseFunc.getFeedbackDueDate(System.now());
                       manualCases[0].Fire_Feedback_Alert__c = false;
                       manualCases[0].Reset_Feedback_Alert__c = true;
                   }
                   //set the queue for complaints cases as these do not have a serivce email address and the email handler have never
                   //touch these type of cases.
                   if(manualCases[0].RecordTypeId == complaintCaseRecTypeId || manualCases[0].RecordTypeId == complaintMNPICaseRecTypeId){
                       
                       list<Group> qlist = [Select Id From Group Where DeveloperName = :caseFunc.getQueueAPIName()];
                       
                       if(qlist.size() > 0){
                           manualCases[0].OwnerId = qlist[0].Id;
                       }  
                       
                   }
                   
                   if(manualCases[0].RecordTypeId == complaintCaseRecTypeId){
                       if(manualCases[0].MNPI__c || manualCases[0].Staff_Error__c){
                           //This is a MNPI complaint - use std lookup ralationships so we do not inherit the security model and change the record type
                           manualCases[0].Relationship_Name_MNPI__c = manualCases[0].AccountId;
                           manualCases[0].AccountId = null;
                           manualCases[0].OwnerId = System.UserInfo.getUserId();
                           
                           list<RecordType> MNPIType = [Select Id From RecordType Where DeveloperName = 'MNPI_Complaint'];
                           
                           if(MNPIType.size() > 0){
                               manualCases[0].RecordTypeId = MNPIType[0].Id;
                           }
                       }
                   }
                   
               }
            
            //update related accounts
            //***NB : DO NOT DELETE OUT COMMENTED CODE - BUSINESS STILL DECIDING ******
            //updateRelatedAccounts(manualCases, null);
            
        }else{
            
            if(manualCases[0].RecordTypeId != cloneEmailCaseRecTypeID){
                if(manualCases[0].RecordTypeId == convertedCaseRecTypeID || manualCases[0].ParentID != null){
                    
                    //map all the service type entries by queue name
                    CSC_Case_Functions_Complaint caseFunc = new CSC_Case_Functions_Complaint(manualCases[0]);
                    map<String,String> serviceMap = caseFunc.getServiceMapping();
                    
                    try{
                        
                        String teamRoleId = [Select Id From CaseTeamRole Where Name = 'Team Manager'].Id;
                        String managerId = [Select Id From User Where Name = :caseFunc.getTeamManager()].Id;
                        insert new CaseTeamMember(ParentId =  manualCases[0].Id, MemberId = managerId, TeamRoleId = teamRoleId);
                        
                    }catch (Exception e){
                        CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'convertManualCases', 'Unable to add team member to case.  Manager user not found or inactive');  
                    }
                    
                    //Add the Delegated approver for the new case owner as a new Case team memeber  
                    list<User> delegatedApprover = [Select DelegatedApproverId From User Where Id = :manualCases[0].OwnerId];
                    String teamRoleId = [Select Id From CaseTeamRole Where Name = 'Team Leader'].Id;
                    
                    if(delegatedApprover.size() > 0){
                        try{
                            insert new CaseTeamMember(ParentId = manualCases[0].Id, MemberId = delegatedApprover[0].DelegatedApproverId, TeamRoleId = teamRoleId); 
                        }catch(DMLException teamEx){
                            CSC_AuditTrailLog.logException(teamEx, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'convertManualCases', 'Unable to add team member to case. There is no Deligated approver for the Case owner'); 
                        }
                    }
                }
            }
        }
    }
 
    
    
    public static void updateSLADdate(List<Case> caseList,Map<ID,Case> oldCaseMap)
    {
        
        Case_Resolution_Date_Setting__c CRDS = Case_Resolution_Date_Setting__c.getValues('Complaint');
        for(Case c : caseList)
        {
            if(String.isBlank(String.valueOf(c.Resolution_Date_Number_of_Times_changed__c)))
            {
                c.Resolution_Date_Number_of_Times_changed__c =0;
            }
            if(c.Estimated_Resolution_Date__c !=oldCaseMap.get(c.ID).Estimated_Resolution_Date__c)
            {
                if(!String.isBlank(c.Reason_for_Resolution_Date__c))
                {
                    
                    
                    
                    c.Resolution_Date_Number_of_Times_changed__c+=1;
                    
                    if(c.Resolution_Date_Number_of_Times_changed__c >CRDS.Number_of_Times_Date_Change_Limit__c)
                    {
                        c.Reason_for_Resolution_Date__c.addError('You have reached your limit on the number of times you are allowed to change this value');
                    }
                    else
                    {
                        c.SLA_Date_1__c = c.Estimated_Resolution_Date__c;
                        c.SLA_Date_2__c = c.Estimated_Resolution_Date__c;
                        Date oldDate = Date.newInstance(oldCaseMap.get(c.ID).SLA_Date_2__c.year(), oldCaseMap.get(c.ID).SLA_Date_2__c.month(), oldCaseMap.get(c.ID).SLA_Date_2__c.day());
                        Date newDate = Date.newInstance(c.SLA_Date_2__c.year(),c.SLA_Date_2__c.month(),c.SLA_Date_2__c.day());
                        Integer NumberOfDaysBetween = oldDate.daysBetween(newDate);
                       
                    if(NumberOfDaysBetween>CRDS.Number_of_Days_Allowed__c)
                    {
                        c.Reason_for_Resolution_Date__c.addError('You can only increase the resolution date by '+ CRDS.Number_of_Days_Allowed__c.setScale(0)+' days(s)');
                    }
                    }                   
                }
                else
                {
                    c.Reason_for_Resolution_Date__c.addError('Please add resolution reason');
                }
            }
        }
    }
    
    public static Map<String,ID> getNameToID(List<String> nameList)
    {
        List<User> UserList = [Select ID,Name from User where Name IN:nameList];
        
        Map<String,ID> nameToIDMap = new Map<String,ID>();
        for(User u :UserList)
        {
            nameToIDMap.put(u.Name, u.ID);
        }
        
        return nameToIDMap;
    }
    
   // Tonga MM : Business requested we put a hold on this feature
   /* public static void updateAccountID(List<Case> newCaseList)
    {
        Set<Id> accountIDSet  = new Set<ID>();
        for(Case c : newCaseList)
        {
            accountIDSet.add(c.AccountId);
        }
        
        Map<ID,Account> accountMap = new Map<ID,Account>([Select ID,ParentID,RecordType.Name,Account.Parent.recordType.Name from Account where ID IN:accountIDSet]);
        for(Case c : newCaseList)
        {
			if(accountMap.containsKey(c.AccountId))
            {                
                Account acc = accountMap.get(c.AccountId);                
                if(acc.RecordType.Name.equalsIgnoreCase('Client') ||acc.RecordType.Name.equalsIgnoreCase('Prospect'))
                {
                    if(!String.isBlank(acc.ParentID))
                    {
                        c.Related_Group_Client2__c = c.AccountId;
                        c.AccountId = acc.ParentID;
                    }
                }
            }
        }
    }*/
    
    public static User getUserByEmail(String fromAddress)
    {
        List<User> userList = new List<User>();
        userList = [Select ID from User where Email =:fromAddress];
        
        if(userList.size()>0)
        {
            return userList[0];
        }
        else
        {
            return null;
        }
    }
}