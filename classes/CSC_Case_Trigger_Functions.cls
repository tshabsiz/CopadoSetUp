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
* 20170919 - Rudolf Niehaus - CloudSmiths : SLA Adjustment feature 
**/
public class CSC_Case_Trigger_Functions {
    
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
        
        if(!emailAction.contains('Flag as') && !emailAction.contains('Linked to Existing')){
            if(oldStatus != null){
                if(!oldValues.get(updatedCase[0].Id).isClosed && !oldStatus.contains('Closed') && newStatus.contains('Closed') && !skipCommValidation){
                    
                    list<CaseComment> ccmt = [Select ParentId From CaseComment Where ParentId = :updatedCase[0].Id];
                    
                    if(ccmt.size() == 0){
                        updatedCase[0].addError('You cannot Close a Case if there are NO Case Comments. Add at least 1 Case Comment to this Case before closing the Case');
                    }
                }
            }
        }
        
        //map all the service type entries by queue name
        CSC_Case_Functions caseFunc = new CSC_Case_Functions(updatedCase[0]);
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
        if( (updatedCase[0].Queue__c != oldValues.get(updatedCase[0].Id).Queue__c && !isNewQueue) || 
           (updatedCase[0].Service_Type__c != oldValues.get(updatedCase[0].Id).Service_Type__c && !isNewQueue ) ){
               
               list<Group> queueId = [Select Id From Group Where DeveloperName = :serviceMap.get('Queue_Name__c') AND Type = 'Queue'];
               list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :caseFunc.getBusinessHours()];
               
               if(bhId.size() ==0){
                   bhId = [Select Id From BusinessHours Where IsDefault=true];
               }
               
               if(queueId.size() > 0 && !isNewQueue){
                   //reset values based on new queue selection
                   //updatedCase[0].OwnerId = queueId[0].Id;
                   updatedCase[0].OwnerId = userinfo.getUserId();
                   updatedCase[0].Service_Mapping_Entry__c = serviceMap.get('Id');
                   updatedCase[0].Queue__c = serviceMap.get('Queue__c');
                   updatedCase[0].Team__c = serviceMap.get('Team__c');
                   updatedCase[0].Department__c = serviceMap.get('Department__c');
                   updatedCase[0].Full_Department__c = serviceMap.get('Full_Department__c');
                   updatedCase[0].Business_Hours__c = serviceMap.get('Business_Hours__c');
                   updatedCase[0].Complexity__c = serviceMap.get('Complexity__c');
                   updatedCase[0].First_Approval__c = serviceMap.get('First_Approval__c');
                   updatedCase[0].ID_V__c = serviceMap.get('ID_V__c');
                   updatedCase[0].Priority = serviceMap.get('Priority');
                   updatedCase[0].Second_Approval__c = serviceMap.get('Second_Approval__c');
                   updatedCase[0].Service_Mapping_Entry__c = serviceMap.get('Id');
                   updatedCase[0].SLA_Time_Measure__c = serviceMap.get('SLA_Time_Measure__c');
                   updatedCase[0].SLA_Units__c = Decimal.valueOf(serviceMap.get('SLA_Units__c'));
                   updatedCase[0].BusinessHoursId = bhId[0].Id;
               }
               
               //adjust SLA Dates
               if(updatedCase[0].Service_Type__c != oldValues.get(updatedCase[0].Id).Service_Type__c){
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
                   
                   list<Service_Mapping__c> sm = [Select Id, Queue_Name__c, Queue__c, Team__c, Department__c, Business_Hours__c, Full_Department__c  
                                                  From Service_Mapping__c  
                                                  Where Queue_Name__c = :queueAPINames[0].DeveloperName Order By Effective_Date__c DESC limit 1];
                   
                   if(sm.size() > 0){
                       
                       updatedCase[0].Full_Department__c = sm[0].Full_Department__c;
                       updatedCase[0].Service_Mapping_Entry__c = sm[0].Id;
                       updatedCase[0].Queue__c = sm[0].Queue__c;
                       updatedCase[0].Team__c = sm[0].Team__c;
                       updatedCase[0].Department__c = sm[0].Department__c;
                       updatedCase[0].Business_Hours__c = sm[0].Business_Hours__c;
                       
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
            String fullTeam = updatedCase[0].Queue__c;
            if( serviceMap.get('Convert_To_RecordType__c') == 'Complaint' && !fullTeam.startsWith('Complaints')){
                
                list<Service_Mapping__c> sm = [Select Id, Queue_Name__c, Queue__c, Team__c, Department__c, Business_Hours__c, Full_Department__c 
                                               From Service_Mapping__c  
                                               Where Queue_Name__c = 'Complaints_Team' Order By Effective_Date__c DESC limit 1];
                
                list<Group> queueId = [Select Id From Group Where DeveloperName = :sm[0].Queue_Name__c AND Type = 'Queue'];
                list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :sm[0].Business_Hours__c];
                
                if(sm.size() > 0){
                    updatedCase[0].OwnerId = queueId[0].Id;
                    updatedCase[0].Full_Department__c = sm[0].Full_Department__c;
                    updatedCase[0].Service_Mapping_Entry__c = sm[0].Id;
                    updatedCase[0].Queue__c = sm[0].Queue__c;
                    updatedCase[0].Team__c = sm[0].Team__c;
                    updatedCase[0].Department__c = sm[0].Department__c;
                    updatedCase[0].Business_Hours__c = sm[0].Business_Hours__c;
                    updatedCase[0].Email_Action__c = 'Transferred';
                    updatedCase[0].Service_Category__c = null;
                    updatedCase[0].Service_Sub_Category__c = null;
                    updatedCase[0].Service_Type__c = null;
                    updatedCase[0].Number_of_Requests__c = null;
                    updatedCase[0].Channel__c = null;
                }
            }
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
        
        //Check if the Adjustment data changed and then move SLA Date forward
        if(updatedCase[0].SLAAdjustment__c != oldValues.get(updatedCase[0].Id).SLAAdjustment__c && updatedCase[0].SLAAdjustment__c >= 0){
            
            //get the original SLA end date
            list<DateTime> originalDates = caseFunc.getSLAEndDate(updatedCase[0].CreatedDate);
            
            //Move SLA end date forward
            if(updatedCase[0].SLAAdjustment__c > 0){
                 //Work on 9 hour days
                Integer addDaysHours = 9 * Integer.valueOf(updatedCase[0].SLAAdjustment__c);
                addDaysHours = addDaysHours * 60 * 60 * 1000;
                
                Integer warningTime = 60 * 60 * 1000; //60min;
                updatedCase[0].SLA_Date_2__c = BusinessHours.add(updatedCase[0].BusinessHoursId, originalDates[1], addDaysHours);
                updatedCase[0].SLA_Date_1__c = BusinessHours.add(updatedCase[0].BusinessHoursId, updatedCase[0].SLA_Date_2__c, (warningTime * -1));
               
            }else if(updatedCase[0].SLAAdjustment__c == 0){
               updatedCase[0].SLA_Date_1__c = originalDates[0]; 
               updatedCase[0].SLA_Date_2__c = originalDates[1]; 
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
        CSC_Case_Functions caseFunc = new CSC_Case_Functions();
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
                
                if(c.RecordTypeId == emailCaseRecTypeId || c.RecordTypeId == supportCaseRecTypeId){
                    
                    if(c.Email_Status__c != 'Actioned' || System.Test.isRunningTest()){
                        
                        //create a list with the original senders email address (Email From Address)
                        list<String> toAddress = new list<String> {c.Email_From_Address__c};
                            Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage();
                        
                        if(caseFunc.orgWideAddressMap.get(c.Queue__c) != null){
                            emailOut.setOrgWideEmailAddressId(OWDIdMap.get(caseFunc.orgWideAddressMap.get(c.Queue__c)));
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
                        
                        if(c.RecordTypeId == emailCaseRecTypeId){
                            if(caseFunc.templateMapEmailReceipt.containsKey(c.Queue__c)){
                                if(String.isNotBlank(caseFunc.templateMapEmailReceipt.get(c.Queue__c))){
                                    emailOut.setTemplateId(caseFunc.templateMapEmailReceipt.get(c.Queue__c));
                                    emailsOutList.add(emailOut);
                                }
                            }
                        }else if(c.RecordTypeId == manualCaseRecTypeId || c.RecordTypeId == supportCaseRecTypeId){
                            if(caseFunc.templateMapCaseCreation.containsKey(c.Queue__c)){
                                if(String.isNotBlank(caseFunc.templateMapCaseCreation.get(c.Queue__c))){
                                    emailOut.setTemplateId(caseFunc.templateMapCaseCreation.get(c.Queue__c));
                                    emailsOutList.add(emailOut);
                                }
                            }
                        }
                        
                        //RN - Use Tasks for phase 2 not emails
                        Task t = new Task();
                        t.Subject = 'Receipt Email Sent to the Client ' + c.Email_From_Address__c;
                        t.WhatId = c.Id;
                        t.Status = 'Completed';
                        t.Priority = 'Normal';
                        t.Description = 'Receipt Email Sent to : ' + c.Email_From_Address__c;
                        emailTasks.Add(t);
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
        CSC_Case_Functions caseFunc = new CSC_Case_Functions();
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
                    
                    if(String.isBlank(caseFunc.templateMapCaseCreation.get(c.Queue__c))){
                        skipResponse = true;
                    }
                    
                    emailOut.setTemplateId(caseFunc.templateMapCaseCreation.get(c.Queue__c));
                    
                    //RN - Leave this line of code here please, just in case business wants to revert back
                    //em.Subject = 'Case Created Email Sent to the Client';
                    //em.TextBody = 'Case Created Email Sent to the Client';
                    t.Subject = 'Case Created Email Sent to the Client ' + c.Email_From_Address__c;
                    t.Description = 'Case Created Email Sent to the Client : ' + c.Email_From_Address__c;
                    
                }else if(c.IsClosed && !oldValues.get(c.Id).IsClosed){
                    
                    if(String.isBlank(caseFunc.templateMapCaseClose.get(c.Queue__c))){
                        skipResponse = true;
                    }
                    
                    emailOut.setTemplateId(caseFunc.templateMapCaseClose.get(c.Queue__c));
                    
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
                        
                        if(String.isBlank(caseFunc.templateMapCaseCreation.get(c.Queue__c))){
                            skipResponse = true;
                        }
                        
                        emailOut.setTemplateId(caseFunc.templateMapCaseCreation.get(c.Queue__c));
                        
                        //RN - Leave this line of code here please, just in case business wants to revert back
                        //em.Subject = 'Complaint Case Created Email Sent to the Client';
                        //em.TextBody = 'Complaint Case Created Email Sent to the Client';
                        t.Subject = 'Complaint Case Created Email Sent to the Client ' + c.Email_From_Address__c;
                        t.Description = 'Complaint Case Created Email Sent to the Client : ' + c.Email_From_Address__c;
                        
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
                
                if(caseFunc.orgWideAddressMap.get(c.Queue__c) != null){
                    emailOut.setOrgWideEmailAddressId(OWDIdMap.get(caseFunc.orgWideAddressMap.get(c.Queue__c)));
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
                    emailTasks.Add(t);
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
                insert emailTasks;
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
            CSC_Case_Functions caseFunc = new CSC_Case_Functions(alertCases[0]);
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
                
                if(caseFunc.templateMapCaseFeedback.containsKey(alertCases[0].Queue__c) || Test.isRunningTest()){
                    
                    if(String.isNotBlank(caseFunc.templateMapCaseFeedback.get(alertCases[0].Queue__c))){
                        
                        emailOut.setTemplateId(caseFunc.templateMapCaseFeedback.get(alertCases[0].Queue__c));
                        emailOut.setTargetObjectId(lstCon[0].Id);
                        emailOut.setTreatTargetObjectAsRecipient(false);
                        emailOut.setToAddresses(toAddress);
                        emailOut.setWhatId(alertCases[0].Id);
                        
                        if(caseFunc.orgWideAddressMap.get(alertCases[0].Queue__c) != null){
                            emailOut.setOrgWideEmailAddressId(OWDIdMap.get(caseFunc.orgWideAddressMap.get(alertCases[0].Queue__c)));
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
                   CSC_Case_Functions caseFunc = new CSC_Case_Functions(manualCases[0]);
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
                   manualCases[0].Service_Mapping_Entry__c = serviceMap.get('Id');
                   manualCases[0].SLA_Time_Measure__c = serviceMap.get('SLA_Time_Measure__c');
                   
                   
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
                    CSC_Case_Functions caseFunc = new CSC_Case_Functions(manualCases[0]);
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
    
    //RN : loop to get related account ids if Cases have new or updated user code value(s)
    //Pass a NULL through as the oldValue map if yu use this for new inserted case records
    //***NB : DO NOT DELETE OUT COMMENTED CODE - BUSINESS STILL DECIDING ******
    /**public static void updateRelatedAccounts( list<Case> newValues, map<Id, Case> oldValues ){

boolean isInsert = false;
if(oldValues == null){
isInsert = true;
}

set<Id> accIds = new set<Id>();
map<Id,String> accCodeMap = new map<Id, String>();

for(Case c :newValues){
if(!isInsert){
if(String.isNotBlank(c.User_Code__c) && c.User_Code__c !=  oldValues.get(c.Id).User_Code__c && String.isNotBlank(c.AccountId)){
accIds.add(c.AccountId);
accCodeMap.put(c.AccountId,c.User_Code__c);
}
}else{
if(String.isNotBlank(c.User_Code__c) && String.isNotBlank(c.AccountId)){
accIds.add(c.AccountId);
accCodeMap.put(c.AccountId,c.User_Code__c);
}
}
}
//update the user code field on the account rec, but ensure we do not overwrite it. 
//The codes are stored comma seperated on both the acc and case
if(accIds.size() > 0){
list<Account> updateAccountList = new list<Account>();

for(Account a :[Select Id, User_Code__c From Account Where Id IN:accIds]){

if(String.isBlank(a.User_Code__c)){

a.User_Code__c = accCodeMap.get(a.Id);

}else{

String accCodes = a.User_Code__c;
set<String> accSet;

if(accCodes.contains(',')){
accSet = new set<String>(accCodes.split(','));
}else{
accSet = new set<String>();
accSet.add(accCodes);
}

String caseCodes = accCodeMap.get(a.Id);
set<String> caseSet;

if(caseCodes.contains(',')){
caseSet = new set<String>(caseCodes.split(','));
}else{
caseSet = new set<String>();
caseSet.add(caseCodes);
}

accSet.addAll(caseSet);
list<String> lstCodes = new List<String>(accSet);
a.User_Code__c = String.join(lstCodes,',');
}

updateAccountList.add(a);
}

try{
if(updateAccountList.size()>0){update updateAccountList;}
}catch(DMLException e){
CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'emailResponses', 'There was an error while updating the user code field on the Account object');
}
}
}**/
    
    
    //RN : Track the transfer of cases between queues and users
    //adhere to business hours and keep track of the case status
    public static void trackTransfer( list<Case> newValues, map<Id,Case> oldValues ){
        
        boolean isInsert = false;
        list<Case_Transfer_Tracking__c> trackingList = new list<Case_Transfer_Tracking__c>();
        list<Case_Transfer_Tracking__c> trackingListUpdate = new list<Case_Transfer_Tracking__c>();
        
        //get case ids 
        set<Id> caseIds = new set<Id>();
        for(Case c :newValues){
            caseIds.add(c.Id);
        }
        
        //insert or update
        if(oldValues == null){
            isInsert = true;
        }
        
        //get default business hours
        list<BusinessHours> defaultBhrs = [Select Id From BusinessHours Where IsDefault=true limit 1];
        
        for(Case c :[Select Id, OwnerId, BusinessHoursId, hOwnerUserName__c, hOwnerQueueName__c, Status, Service_Type__c,IsClosed,
                     ( Select In__c, Out__c, Total_Time_Min__c From Case_Transfer_Tracking__r where Out__c = null) 
                     From Case Where Id IN :caseIds]){
                         
                         if( isInsert ){
                             
                             Case_Transfer_Tracking__c tracking = new Case_Transfer_Tracking__c();
                             
                             tracking.Case__c = c.Id;
                             tracking.From__c = 'System';
                             if(String.isBlank(c.hOwnerUserName__c)){
                                 tracking.To__c = c.hOwnerQueueName__c;
                             }else{
                                 tracking.To__c = c.hOwnerUserName__c;
                             }
                             tracking.In__c = System.now();
                             tracking.In_Status__c = c.Status;
                             tracking.In_Service_Type__c = c.Service_Type__c;
                             trackingList.add(tracking);
                             
                         }else{
                             
                             Case_Transfer_Tracking__c tracking = new Case_Transfer_Tracking__c();
                             //Check if the owner changed
                             if(c.OwnerId != oldValues.get(c.Id).OwnerId || (c.IsClosed && !oldValues.get(c.Id).IsClosed)){
                                 
                                 //Check if this is NOT the first transfer on an existing case
                                 if(c.Case_Transfer_Tracking__r.size() > 0){
                                     
                                     //UPDATE last tracking entry
                                     Id bhrsId = c.BusinessHoursId;
                                     if(String.isBlank(bhrsId)){
                                         bhrsId = defaultBhrs[0].Id;
                                     }
                                     
                                     //get time difference between now and the date/time when the case were transferred
                                     long timeDiff = BusinessHours.diff(bhrsId, c.Case_Transfer_Tracking__r[0].In__c, System.now());
                                     //convert millisecons to min
                                     Integer minDiff = (timeDiff.intValue() / 1000) / 60;
                                     
                                     //update last tracking entry
                                     c.Case_Transfer_Tracking__r[0].Out__c = System.now();
                                     c.Case_Transfer_Tracking__r[0].Total_Time_Min__c = minDiff;
                                     trackingListUpdate.add(c.Case_Transfer_Tracking__r[0]);
                                 } 
                                 
                                 //INSERT new tracking record
                                 tracking.Case__c = c.Id;
                                 if(String.isBlank(c.hOwnerUserName__c)){
                                     tracking.To__c = c.hOwnerQueueName__c;
                                 }else{
                                     tracking.To__c = c.hOwnerUserName__c;
                                 }
                                 if(String.isBlank(oldValues.get(c.Id).hOwnerUserName__c)){
                                     tracking.From__c = oldValues.get(c.Id).hOwnerQueueName__c;
                                 }else{
                                     tracking.From__c = oldValues.get(c.Id).hOwnerUserName__c;
                                 } 
                                 
                                 tracking.In__c = System.now();
                                 tracking.In_Status__c = c.Status;
                                 tracking.In_Service_Type__c = c.Service_Type__c;
                                 trackingList.add(tracking);
                                 
                             }
                         }
                     }    
        
        try{
            if(trackingListUpdate.size()>0){update trackingListUpdate;}
        }catch(DMLException e){
            CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'trackTransfer', 'There was an error while updating an existing case transfer tracking record');
        }
        try{
            if(trackingList.size()>0){insert trackingList;}
        }catch(DMLException e){
            CSC_AuditTrailLog.logException(e, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'trackTransfer', 'There was an error while inserting a new case transfer tracking record');
        }
    }
    
    //RN : Calculate the actual age of a Case by tracking the time a Case spent at support 
    //,in the hands of the client or 3rd party based on pause statuses, adhere to business hours
    public static void trackCaseAge( list<Case> newValues, map<Id,Case> oldValues ){
        
        boolean isInsert = false;
        
        //get case ids
        set<Id> cids = new set<Id>();
        
        for(Case c :newValues){
            cids.add(c.Id);
        }
        
        //get pause status values for each Case
        map<String,set<String>> pauseStatusMap = new map<String,set<String>>();
        map<String,set<String>> pauseStatusMapInt = new map<String,set<String>>();
        
        for(Case c :[ Select Id, Service_Mapping_Entry__r.SLA_Pause_Status__c,
                     Service_Mapping_Entry__r.SLA_Pause_Status_Internal__c  
                     From Case Where Id IN :cids]){
            
            String pauseStatusList = c.Service_Mapping_Entry__r.SLA_Pause_Status__c;
            String pauseStatusListInt = c.Service_Mapping_Entry__r.SLA_Pause_Status_Internal__c;
            
            if(pauseStatusList != null){
                set<String> pauseStatusSet = new set<String>(pauseStatusList.split(','));
                pauseStatusMap.put(c.Id,pauseStatusSet);
            }
            
            if(pauseStatusListInt != null){
                set<String> pauseStatusSetInt = new set<String>(pauseStatusListInt.split(','));
                pauseStatusMapInt.put(c.Id,pauseStatusSetInt);
            }
            
        }
        
        //insert or update based on oldMap status
        if(oldValues == null){
            isInsert = true;
        }
        
        //get default business hours
        list<BusinessHours> defaultBhrs = [Select Id From BusinessHours Where IsDefault=true limit 1];
        
        for(Case c :newValues){
            
            if(isInsert){
                
                c.Last_Status_Change__c = System.now();
                c.Time_With_Customer__c = 0;
                c.Time_With_Support__c = 0;
                c.Time_with_3rd_Party__c = 0;
                c.Case_Age_In_Business_Hours__c = 0;
                
            }else{
                
                //Check if Status changed OR if an email case were premoted to a support case with the same status
                if( (c.Status != oldValues.get(c.Id).Status) || (c.hWasEmailToCaseAction__c)){
                    
                    Integer minDiff = 0;
                    
                    if(c.Last_Status_Change__c != null){
                        //get time difference between now and the date/time when the case were transferred
                        long timeDiff = BusinessHours.diff(c.BusinessHoursId, c.Last_Status_Change__c, System.now());
                        //convert millisecons to min
                        minDiff = (timeDiff.intValue() / 1000) / 60;
                    }
                    
                    set<String> pauseStatusSet = pauseStatusMap.get(c.Id);
                    set<String> pauseStatusSetInt = pauseStatusMapInt.get(c.Id);
                    
                    if(pauseStatusSet != null){
                        
                        if( pauseStatusSet.contains( oldValues.get(c.Id).Status ) ){
                            
                            if(c.Time_with_3rd_Party__c == null){
                                c.Time_with_3rd_Party__c = 0; 
                            }
                            if(c.Time_With_Customer__c == null){
                                c.Time_With_Customer__c = 0; 
                            }
                            if(c.Time_With_Support__c == null){
                                c.Time_With_Support__c = 0; 
                            }
                            
                            c.Time_With_Customer__c += minDiff;
                            c.Last_Status_Change__c = System.now();
                            c.Case_Age_In_Business_Hours__c = (c.Time_With_Support__c + c.Time_With_Customer__c + c.Time_with_3rd_Party__c) / 60;
                            
                        }else if( pauseStatusSetInt.contains( oldValues.get(c.Id).Status )){
                            
                            if(c.Time_with_3rd_Party__c == null){
                                c.Time_with_3rd_Party__c = 0; 
                            }
                            if(c.Time_With_Customer__c == null){
                                c.Time_With_Customer__c = 0; 
                            }
                            if(c.Time_With_Support__c == null){
                                c.Time_With_Support__c = 0; 
                            }
                            
                            c.Time_with_3rd_Party__c += minDiff;
                            c.Last_Status_Change__c = System.now();
                            c.Case_Age_In_Business_Hours__c = (c.Time_With_Support__c + c.Time_With_Customer__c + c.Time_with_3rd_Party__c) / 60;
                            
                        }else{
                            
                            if(c.Time_with_3rd_Party__c == null){
                                c.Time_with_3rd_Party__c = 0; 
                            }
                            if(c.Time_With_Support__c == null){
                                c.Time_With_Support__c = 0; 
                            }
                            if(c.Time_With_Customer__c == null){
                                c.Time_With_Customer__c = 0;
                            }
                            
                            c.Time_With_Support__c += minDiff;
                            c.Last_Status_Change__c = System.now();
                            c.Case_Age_In_Business_Hours__c = (c.Time_With_Support__c + c.Time_With_Customer__c + c.Time_with_3rd_Party__c) / 60;
                        } 
                    }
                }
            }
        }    
    }
    //Tonga MM : Added method that would add the creator of a case as a team member
    public static void addCreatorAsTeamMember(List<Case> newCases)
    {
        try{
            List<CaseTeamMember> caseTeamMembers = new List<CaseTeamMember>();
            
            ID SupportTeamID  = [Select ID from CaseteamRole where name ='Support Team' limit 1].ID;
            for(Case currentCase : newCases)
            {
                if(currentCase.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId())
                caseTeamMembers.add(new CaseTeamMember(parentID = currentCase.ID,MemberID = UserInfo.getUserId(),teamRoleID=SupportTeamID));
            }           
        insert caseTeamMembers;
        }
        catch(Exception exc)
        {
            CSC_AuditTrailLog.logException(exc, 'New', 'Warning', 'CSC_Case_Trigger_Functions', 'AddCaseCreatorAsTeamMember', 'There was an issue with adding a case creator as a team member');
        }       
    }
    
    public static void updatePicCases(list<Case> manualCases, Boolean isBeforeInsert){
        
        
        
        
    }
    
}