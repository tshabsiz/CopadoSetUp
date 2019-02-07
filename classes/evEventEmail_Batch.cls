// 2018-08-25	Assing the EMail_Setup_to_Use on the delegate before sending email
// 				Only send ONE email to each delegate per batch run
// 2018-02-26	Added ability to process a single Email COnfig record at a time
// 				Removed TasksToInsert (was old requirement)
// 				Re-instated SMS code --- but it wont work until proper gatewat and sender are setup
// 2018-05-15	Added ability to attach delagate schedule to email.
// 
// TOTO:
// 1. Support for "send as logged in user" to be used with the process of a single record from the UI 
// 2. Details for SMS gateway (dest addres, org wide to use, values ) to ge setup on Custom Meta Data										

global class evEventEmail_Batch implements
Database.Batchable<SObject>, Database.Stateful
{
    
   	global List<EM_Event_Email_Configuration__c> emailconfigs = new List<EM_Event_Email_Configuration__c>();
    global map<String,Integer> emailssent = new Map<String,Integer>();
    global map<String,Integer> emailssent_temp = new Map<String,Integer>();
    global OrgWideEmailAddress orgwideAddress;
    global String globaLerror = '';
    global Id globalconfig;
    global Integer DelegatesSkipped = 0;
    
    // a set of Delegate ID's that have been sent to - to ensure only ONE email per delegate per batch
    global set<Id> setDelegatesSentTo = new set<Id>();
      
    global Id EmailConfigID;  // process only this event config
    global Id EventID;  // process only this event
    
    public class MyException extends Exception {}  
    
    //default constructor
    global evEventEmail_Batch() 
    {
        system.debug('evEventEmail_Batch: Will process all active email configs');
        EmailConfigID = null; // will process all active email config records
        return;
    }
    
    //constructor to execute single email config or event send only
    global evEventEmail_Batch(Id i) 
    {
        if (i.getSobjectType() == EM_Event_Email_Configuration__c.getSobjectType())
        {
	        system.debug('evEventEmail_Batch: Will process SINGLE email config:' + i);
        	EmailConfigID = i;  // will process only this config record
        }
        else if (i.getSobjectType() == Event__c.getSobjectType())
        {
	        system.debug('evEventEmail_Batch: Will process email config for a SINGLE EVENT:' + i);
        	EventID = i;  // will process only this config record
        }
        
        return;
    }


    global Database.queryLocator start(Database.BatchableContext ctx)
    { 
        system.debug('evEventEmail_Batch.start with user: '+system.UserInfo.getName());
        
        if (EmailConfigID != null)
        {
            emailconfigs = 
                [ 
                    SELECT 
                    Event__c,
                    Event__r.Name,
                    Email_Template__c,
                    Name, 
                    Start_Days__c,
                    Stop_Days__c,
                    Start_Before_After__c,
                    Stop_Before_After__c,
                    Start_Send_Date__c,
                    Stop_Send_Date__c,
                    Start_Send_Time__c,
                  	Stop_Send_Time__c,
                   	Send_From__c,
                    Send_From_Name__c,
                    Delegate_Attendance_Status__c,
                    Delegate_Invitation_Status__c,
                    Delegate_Registration_Status__c,
                    Delegate_RSVP_Status__c,
                    Survey_Status__c,
                    Delegate__c,
                    Log__c,
                    SMS_Text__c,
                    Email_Setup__c,
                    Email_Setup__r.type__c,
                    Attach_Delegate_Schedule__c,
                    Attach_Speaker_Schedule__c,
                    Type__c,
                    Delegate_Type__c 
                    FROM 
                    EM_Event_Email_Configuration__c 
                    WHERE
                    Active__c = true 
                    AND Id = :EmailConfigID
                ];

        }
        else if (EventID != null)
        {
            emailconfigs = 
                [ 
                    SELECT 
                    Event__c,
                    Event__r.Name,
                    Email_Template__c,
                    Name, 
                    Start_Days__c,
                    Stop_Days__c,
                    Start_Before_After__c,
                    Stop_Before_After__c,
                    Start_Send_Date__c,
                    Stop_Send_Date__c,
                    Start_Send_Time__c,
                  	Stop_Send_Time__c,
                    Send_From__c,
                    Send_From_Name__c,
                    Delegate_Attendance_Status__c,
                    Delegate_Invitation_Status__c,
                    Delegate_Registration_Status__c,
                    Delegate_RSVP_Status__c,
                    Survey_Status__c,
                    Delegate__c,
                    Log__c,
                    SMS_Text__c,
                    Email_Setup__c,
                    Email_Setup__r.type__c,
                    Attach_Delegate_Schedule__c,
                    Type__c,
                    Delegate_Type__c 
                    FROM 
                    EM_Event_Email_Configuration__c 
                    WHERE
                    Active__c = true 
                    AND Event__c = :EventID
                ];
        }
        else
        {
            emailconfigs = 
                [ 
                    SELECT 
                    Event__c,
                    Event__r.Name,
                    Email_Template__c,
                    Name, 
                    Start_Days__c,
                    Stop_Days__c,
                    Start_Before_After__c,
                    Stop_Before_After__c,
                    Start_Send_Date__c,
                    Stop_Send_Date__c,
                    Start_Send_Time__c,
                  	Stop_Send_Time__c,
                    Send_From__c,
                    Send_From_Name__c,
                    Delegate_Attendance_Status__c,
                    Delegate_Invitation_Status__c,
                    Delegate_Registration_Status__c,
                    Delegate_RSVP_Status__c,
                    Survey_Status__c,
                    Delegate__c,
                    Log__c,
                    SMS_Text__c,
                    Email_Setup__c,
                    Email_Setup__r.type__c,
                    Attach_Delegate_Schedule__c,
                    Type__c,
                    Delegate_Type__c 
                    FROM 
                    EM_Event_Email_Configuration__c 
                    WHERE
                    Active__c = true 
                ];
        }
        
       system.debug('evEventEmail_Batch.start: Process configs:' + emailconfigs.size());
         
   /*     
    * TODO - sleect this based on custom metat data parameter for which org wide to use
    * orgwideAddress = 
            [
                SELECT
                Id
                FROM
                OrgWideEmailAddress 
                WHERE
                DisplayName = 'CloudSmiths'
                LIMIT 1	
            ];*/
        
        
        Set<Id> eventIds = new Set<Id>();
        for(EM_Event_Email_Configuration__c config : emailconfigs)
        {
            eventIds.add(config.Event__c);
        }
         
        return Database.GetQuerylocator(
            [
                SELECT
                Id,
                Event__c,
                Event__r.End_Date__c,
                Event__r.Start_Date__c,
                Event__r.OwnerId,
                Contact__r.FirstName,
                Contact__r.IsEmailBounced,	 
                Contact__r.Email,
                Contact__r.MobilePhone,
                Contact__c,
                Survey_Completed__c,
                Status__c,
                Auto_Emails_Sent__c ,
                Invitation_Status__c ,
                Registration_Status__c,
                RSVP_Status__c,
                Host__c,
                Host__r.Team_Member__r.email,
                RecordTypeId,
                Account__c,
                Account__r.Name
                FROM
                Delegate__c
                WHERE
                Event__c IN :eventIds 
            ]		
        );
    }
    
    
    global void execute(Database.BatchableContext ctx, List<Sobject>   scope)
    { 
        system.debug('evEventEmail_Batch.execute: Process delegates:' + scope.size());
        
        Messaging.SingleEmailMessage[] themails = new Messaging.SingleEmailMessage[]{};	
        
        try
        {	
            emailssent_temp.clear();
            
            List<Delegate__c> delegates =(List<Delegate__c>)scope;
            
            if (!delegates.isEmpty())
            {
                for (EM_Event_Email_Configuration__c emailconfig : emailconfigs) 
                {    
                    globalconfig = emailConfig.Id;
                    Set<String> delegateAttendanceStatuses = new Set<String>();
                    Set<String> delegateInvitationStatuses = new Set<String>();
                    Set<String> delegateRegistrationStatuses = new Set<String>();
                    Set<String> delegateRSVPStatuses = new Set<String>();
                    
                    if(emailconfig.Delegate_attendance_status__c != null)
                    {
                        for (String status : emailconfig.Delegate_attendance_status__c.split(';'))
                        {
                            delegateAttendanceStatuses.add(status);
                        }
                    }
                    if(emailconfig.Delegate_Invitation_Status__c != null)
                    { 
                        for (String status : emailconfig.Delegate_Invitation_Status__c.split(';'))
                        {
                            delegateInvitationStatuses.add(status);
                        }
                    }
                    if(emailconfig.Delegate_Registration_Status__c != null)
                    { 
                        for (String status : emailconfig.Delegate_Registration_Status__c.split(';'))
                        {
                            delegateRegistrationStatuses.add(status);
                        }
                    }
                    if(emailconfig.Delegate_RSVP_Status__c != null)
                    {   
                        for (String status : emailconfig.Delegate_RSVP_Status__c.split(';'))
                        {
                            delegateRSVPStatuses.add(status);
                        }
                    }
                    Date today = date.today();
                    Datetime dt = System.now();
                    String today_dow = dt.format('EEE');
                    for (Delegate__c delegate : delegates)
                    {  
                       
                        integer StartDays;
                        integer StopDays;
                        Date sendStartDate; 
                        Date sendStopDate; 
                        String delRecordTypeName = Schema.SObjectType.Delegate__c.getRecordTypeInfosById().get(delegate.recordtypeid).getname();
                        
                        system.debug('emailconfig : '+ emailconfig);
                       
                        if (emailssent_temp.get(emailconfig.Id) == null)  
                        {  
                            emailssent_temp.put(emailconfig.Id,0);
                        }
                        
                        if(emailconfig.Start_Before_After__c.contains('Before')) 
                        {
                            StartDays = emailconfig.Start_Days__c == null ? -9999 : -1*integer.valueof(emailconfig.Start_Days__c);
                        }
                        else if(emailconfig.Start_Before_After__c.Contains('After'))
                        {
                           	StartDays = emailconfig.Start_Days__c == null ? -9999 : integer.valueof(emailconfig.Start_Days__c);
                        }
                                                
                        system.debug('StartDays : '+ StartDays);
                        
                        if(emailconfig.Start_Before_After__c.contains('Start')) 
                        {
                            sendStartDate  = delegate.Event__r.Start_Date__c.addDays(StartDays);
                        }
                        else if(emailconfig.Start_Before_After__c.contains('End')) 
                        {
                            sendStartDate  = delegate.Event__r.End_Date__c.addDays(StartDays);
                        }

                        //DETERMINED END SENDING DATE
                       
                        if(emailconfig.Stop_Before_After__c.contains('Before')) 
                        {
                            StopDays = emailconfig.Stop_Days__c == null ? -9999 : -1*integer.valueof(emailconfig.Stop_Days__c);
                        }
                        else if(emailconfig.Stop_Before_After__c.Contains('After'))
                        {
                           	StopDays = emailconfig.Stop_Days__c == null ? -9999 : integer.valueof(emailconfig.Stop_Days__c);
                        }
                                                
                        system.debug('StopDays : '+ StopDays);
                        
                        if(emailconfig.Stop_Before_After__c.contains('Start')) 
                        {
                            sendStopDate  = delegate.Event__r.Start_Date__c.addDays(StopDays);
                        }
                        else if(emailconfig.Stop_Before_After__c.contains('End')) 
                        {
                            sendStopDate  = delegate.Event__r.End_Date__c.addDays(StopDays);
                        }
                        
                        emailconfig.Start_Send_Date__c = sendStartDate;
                        emailconfig.Stop_Send_Date__c = sendStopDate;
                        
                        system.debug('Processing Delegate: ' + delegate.Id);
                        system.debug('Processing delegateStatuses: ' + delegateAttendanceStatuses);
                        system.debug('delegate.Status__c ' + delegate.Status__c);
                        system.debug('delegate.Invitation_Status__c ' + delegate.Invitation_Status__c);
                        system.debug('delegate.Registration_Status__c ' + delegate.Registration_Status__c);
                        system.debug('delegate.RSVP_Status__c ' + delegate.RSVP_Status__c);
                        system.debug('delegate.Event__c ' + delegate.Event__c);
                        system.debug('emailconfig.Event__c ' + emailconfig.Event__c);
                        system.debug('sendStartDate : '+sendStartDate);
                        system.debug('sendEndDate : '+sendStopDate);
                        system.debug('emailconfig.Delegate_Type__c : '+emailconfig.Delegate_Type__c);
                        if 
                            (
                                (// DP: check if delegate has one of the required record types
                                    emailconfig.Delegate_Type__c == null || emailconfig.Delegate_Type__c == 'All' || emailconfig.Delegate_Type__c == delRecordTypeName
                                )
                                &&
                                (// check if delegate has one of the required statuses
                                    (delegateAttendanceStatuses.isEmpty() || delegateAttendanceStatuses.contains(delegate.Status__c)) 
                                    &&
                                    (delegateInvitationStatuses.isEmpty() || delegateInvitationStatuses.contains(delegate.Invitation_Status__c)) 
                                    &&
                                    (delegateRegistrationStatuses.isEmpty() || delegateRegistrationStatuses.contains(delegate.Registration_Status__c) )
                                    &&
                                    (delegateRSVPStatuses.isEmpty() || delegateRSVPStatuses.contains(delegate.RSVP_Status__c) )
                                )
                                && 
                                delegate.Event__c == emailconfig.Event__c 
                                &&  
                                sendStartDate <= Today
                                && 
                                sendStopDate >= Today // Check email is within window of date and should be sent 
                                && 
                                // Check not already sent 
                                (delegate.Auto_Emails_Sent__c !=null ? delegate.Auto_Emails_Sent__c.indexof(emailconfig.Name) : -1 ) == -1
                            )
                        { 
                            // Check if this delegeate had already been sent an email in this batch, if so continue to next delegate
                            if (setDelegatesSentTo.contains(delegate.id))
                            {
                                system.debug('delegated Skipped due to having already received an email in this run');
                                DelegatesSkipped++;
                                continue;
                            }
                            system.debug('delegated accepted 1/2');
  
/*                            
                            if (emailconfig.Days__c <0 && delegate.Event__r.End_Date__c < date.today())//Days_After_to_Send_eMail__c
                            {
                                system.debug('Check 1 Fail');
                                continue;
                            }
**/
                            //Check if survey needs to be completed and if the delegate has completed the survey otherwise Continue to next record in list
                            if (emailconfig.Survey_Status__c == 'Completed' && !delegate.Survey_Completed__c ) 
                            {
                                system.debug('Survey not completed - skipping');
                                continue; 
                            } 
                            
                            //Check if survey needs to be not completed and if the delegate has not completed the survey otherwise Continue to next record in list
                            if (emailconfig.Survey_Status__c == 'Not Completed' && delegate.Survey_Completed__c ) 
                            {  
                                system.debug('Survey completed - skipping');
                                continue;
                            }
                            //Check if email config testing delegate is not null and if delegate id is equal to email config testing delegate id otherwise Continue to next record in list
                            if (emailconfig.Delegate__c != null && delegate.Id != emailconfig.Delegate__c ) 
                            {  
                                system.debug('Not the test delegate - skipping');
                                continue;
                            }
/*                            
                            //Check if email config Do_Not_Send_Before__c is not null and if 
                            if (emailconfig.Do_Not_Send_Before__c != null && dt.hour()<emailconfig.Do_Not_Send_Before__c )
                            {     
                                system.debug('Check 5 Fail');
                                continue;
                            }
*/
                            system.debug('delegated accepted 2/2');
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            if (emailConfig.SMS_Text__c !=null)
                            {
                                system.debug('Processing SMS ...');
                                
                                if (delegate.contact__r.MobilePhone == null)
                                {
                                    system.debug('mobile is null');
                                    continue;
                                }	
                                String temp = delegate.contact__r.MobilePhone;
                                temp = temp.replace(' ','').replace('(','').replace(')','').replace('+','').replace('-','');
                                if (temp.left(1) == '0')
                                {
                                    temp = '27' + temp.right(temp.length()-1);
                                }
                                if (temp !=null)
                                {
                                    temp = temp +'@2way.co.za';
                                }	
                                
                                List<String> addresses = new List<String>();
                                addresses.add(temp);
                                String SMS = emailConfig.SMS_Text__c;
                                SMS = SMS.replace('<Firstname>',delegate.contact__r.firstName );                               
                                SMS = SMS.replace('<DelegateID>',delegate.Id );                               
                                mail.setToAddresses(addresses);
                               
                                
                                //will be sent from current suer - and FAIL   
                                //mail.setOrgWideEmailAddressId(orgwideAddress.Id);
                                
                                mail.setPlainTextBody(SMS);
                                mail.setSubject('75959');  // info@cloudsmiths.co.za
                                
                                system.debug('sms sent to: '+ temp);
                            }
                            else
                            {	
                                if (delegate.Contact__r.isEmailBounced || 
                                    delegate.Contact__r.email == null ||
                                    delegate.Contact__r.email == '' )
                                {
                                    system.debug('delegate email invalid');
                                    continue;
                                }
                                else
                                {
                                    if (!String.isBlank(emailConfig.Send_From__c) && emailConfig.Send_From__c != 'LoggedInUser')
                                    {
                                    	mail.setOrgWideEmailAddressId(emailConfig.Send_From__c);
                                    }
                                    
                                    list<string> TempCcEmailList = new list<string>();
                                    
                                    if(delegate.Host__c != null)
                                    {
                                        
                                        TempCcEmailList.add(delegate.Host__r.Team_Member__r.email);
                                        mail.setBccAddresses(TempCcEmailList);
                                    }
                                    
                                    
                                    mail.SetTemplateId(emailconfig.eMail_Template__c);
                                    mail.SettargetObjectId(delegate.Contact__c);
                                    mail.SetWhatId(delegate.Contact__c);
                                 
                                    system.debug('mail sent to: '+ delegate.Contact__r.Email);
                                } 
                            }		 
                            
                            if (Test.IsRunningTest() )
                            {
                                mail.settargetObjectId(delegate.Contact__c); 
                                mail.setPlainTextBody('Test eMail');
                            }
                            mail.setWhatId(delegate.Id);
                            mail.setUseSignature(false);
                            mail.setSaveAsActivity(true);
                            
                            //DP
                            if(emailconfig.Attach_Speaker_Schedule__c == true) 
                            {
                                PageReference pdf = Page.evSpeakerSchedule;
                                pdf.getParameters().put('id',delegate.Event__c);
                                pdf.getParameters().put('accid',delegate.Account__c);
                                Blob body;
                                
                                if (Test.IsRunningTest())
                                {
                                    body = Blob.valueOf('UNIT.TEST');
                                }
                                else
                                {
                                    body = pdf.getContent();
                                }
                                
                                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                attach.setContentType('application/pdf');
                                attach.setFileName('Schedule - ' + delegate.Account__r.Name +'.pdf');
                                attach.setInline(false);
                                attach.Body = body;
                                
                                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
                            }
                            //DP 
                            
                            if(emailconfig.Attach_Delegate_Schedule__c == true) 
                            {
                                PageReference pdf = Page.evDelegateSchedule;
                                pdf.getParameters().put('id',delegate.Id);
                                Blob body;
                                
                                if (Test.IsRunningTest())
                                {
                                    body = Blob.valueOf('UNIT.TEST');
                                }
                                else
                                {
                                    body = pdf.getContent();
                                }
                                
                                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                attach.setContentType('application/pdf');
                                attach.setFileName('Schedule.pdf');
                                attach.setInline(false);
                                attach.Body = body;
                                
                                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
                            } 
                            
                            themails.add(mail);
                            
                            if (delegate.Auto_emails_sent__c == null) 
                            { 
                                delegate.Auto_emails_sent__c = ''; 
                            }
                            
                            delegate.Auto_emails_sent__c += emailconfig.Name+' on '+date.today().format()+'; ';
							
                            //DF 
                            if(emailconfig.Email_Setup__r.Type__c ==  'Invitation')
                            {
                                delegate.RSVP_Status__c = 'Invited';
                            }
                            
                            // temporaritly assign the email setup to be available in the sendemail
            				Delegate__c updateDelegate = new Delegate__c(Id=delegate.Id, Email_Setup_to_Use__c=emailconfig.Email_Setup__c);
            				update updateDelegate;
                            setDelegatesSentTo.add(delegate.Id);
                            
                            system.debug('UpdatedDelegate: '+updateDelegate);

                            emailssent_temp.put(emailConfig.Id, emailssent_temp.get(emailConfig.Id)+1); 
                            
                        } 		            
                    }    
                } 
            }
            
            if (!Test.IsRunningTest() )
            {
                System.debug('theMails : '+theMails);
                if (theMails != null)
                {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail( theMails );
                }
            }
            
            update delegates;
            
            // Move the temporary counters to the main counters as the mails have been sent and delegates successfully updated 
            Set <String> countSet = new Set<String>();
            countSet = emailssent_temp.keySet();
            System.debug('countset : '+countset);
            for(string counter:countset)
            {
                Integer batchcount = emailssent.get(counter);
                
                if (batchcount==null) 
                    batchcount=0;
                
                batchcount=batchcount+emailssent_temp.get(counter);
                emailssent.put(counter,batchcount);
            }
        } 
        catch (Exception e)
        {
            if (scope == null)
            { throw new MyException('Scope is null');} 
            else
            {
                globalerror = globalerror + '\n\nConfig: ' + globalconfig + ' - ' + e.getmessage()+ ' : Line:  '+E.getlinenumber(); 
                throw new MyException(e.getmessage()+ ' : Line:  '+e.getlinenumber());
            }
        }
    }
    
    
    
    global void finish(Database.BatchableContext BC)
    {
        List<String> idList = new List<String>();    
        List<String> mailToAddresses = new List<String>();    

        idList.add(UserInfo.GetUserId());

        system.debug('evEventEmail_Batch.finish');

        
        User[] usr = [SELECT email FROM user WHERE id IN :idList];    
        
        for(User u : usr)
        {
            mailtoAddresses.add(u.email);    
        }
        
        String results =''; 
        
        for(EM_Event_Email_Configuration__c config : emailconfigs)
        { 
            config.last_run__c = datetime.now();
            System.debug('evEventEmail_Batch.finish: result for: '+ config.Event__r.Name+ ' '+config.Name + ' sent: '+emailssent.get(config.Id));
            
            // if this was an event or config specific send OR if the batch sent any emails
            if(emailssent.get(config.Id) != null && (emailssent.get(config.Id)> 0 || EventID != null || EmailConfigID != null) )
            {
                String LogEntry = datetime.now().format()+' ' + isnull(emailssent.get(config.Id)) + ' emails/smses sent';
                
                if (config.Log__c == NULL)
                    config.Log__c = LogEntry;
                else
                    config.Log__c += '\n'+LogEntry;           
                
                results = results + '\n    ' + config.Event__r.Name + ' / ' + config.Name + ' : ' + isnull(emailssent.get(config.Id)) + ' emails/smses sent';
            }
        } 
        
        if (DelegatesSkipped == 1) 
        {
	        results = results + '\n\n**NOTE: ' + DelegatesSkipped + ' email was postponed to prevent multiple emails being sent to the same delegate.';
        }
        else if (DelegatesSkipped > 1) 
        {
	        results = results + '\n\n**NOTE: ' + DelegatesSkipped + ' emails were postponed to prevent multiple emails being sent to the same delegate.';
        }
   
        system.debug('evEventEmail_Batch.finish: results:'+results);
        
        update emailConfigs; 
        
        // if this was an event or config specific send OR if the batch send had any error then send summary email
        if (EventID != null || EmailConfigID != null || !String.IsBlank(results) || !String.IsBlank(globalerror) )
        {
            AsyncApexJob a = 
                [
                    SELECT 
                    Id, 
                    Status, 
                    NumberOfErrors, 
                    JobItemsProcessed,
                    TotalJobItems, 
                    CreatedBy.Email,
                    ExtendedStatus
                    FROM 
                    AsyncApexJob 
                    WHERE 
                    Id =	:BC.getJobId()
                ];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(MailToAddresses);
            mail.setSubject('Event Automated Emails Batch Job');
            
            if (a.ExtendedStatus <> null) 
            {
                globalerror = globalerror + a.ExtendedStatus; 
            }
            
            String body;
            
            body = 'The batch Apex job processed ' + a.TotalJobItems + ' delegates with '+ a.NumberOfErrors + ' failures.\n\n';
            if (!String.IsBlank(globalerror))
            {
            	body += globalerror + '\n\n';
            }
            if (!String.IsBlank(results))
            {
            	body += 'Summary of results:\n'+results;
            }
            mail.setPlainTextBody(body);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
    
    private integer isnull(integer input)
    {
        if (input == null)
            return 0;
        else
            return input;
    }	 
}