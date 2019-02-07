public with sharing class evEventEmailConfig_Controller 
{
    public EM_Event_Email_Configuration__c record {get;set;}
    
    public evEventEmailConfig_Controller(ApexPages.StandardController stdController) 
    {
        record = (EM_Event_Email_Configuration__c)stdController.getRecord();
        
        if (record.Id != null)
        {
            record =  
                [
                    SELECT
                    Id,
                    Name,
                    Label__c,
                    Active__c,
                    Type__c,
                    Email_Template__c,
                    Email_Template_Name__c,
                    Event__c,
                    Send_From__c,
                    Send_From_Name__c,
                    Start_Days__c,
                    Stop_Days__c,
                    Start_Before_After__c,
                    Stop_Before_After__c,
                    Start_Send_Date__c,
                    Stop_Send_Date__c,
                    Start_Send_Time__c,
                  	Stop_Send_Time__c,
                    Delegate__c,
                    Survey_Status__c,
                    SMS_Text__c,
                    Delegate_Attendance_Status__c,
                    Delegate_Invitation_Status__c,
                    Delegate_Registration_Status__c,
                    Delegate_RSVP_Status__c,
                    Email_Setup__c,
                    Attach_Delegate_Schedule__c,
                    Attach_Speaker_Schedule__c,
                    Delegate_Type__c 
                    FROM
                    EM_Event_Email_Configuration__c
                    WHERE
                    Id = :record.Id
                    LIMIT 1
                ];	
        }
    }
    
    
    public List<SelectOption> templates    
    {  
        get    
        {
            if (templates == null) 
            {
                templates = new List<SelectOption>();
                templates.add(new SelectOption('',''));
                List<EmailTemplate> Templatelist;
                try
                {//try get email templates from Event_Email_Templates folder, if that fails , get all email templates so email config can still be setup
                    Folder EmailTempFolder1 =  
                        [
                            SELECT
                            id,
                            DeveloperName
                            from
                            Folder
                            Where
                            DeveloperName = 'Event_Email_Templates'
                        ];
                    
                    Folder EmailTempFolder2 =  
                        [
                            SELECT
                            id,
                            DeveloperName
                            from
                            Folder
                            Where
                            DeveloperName = 'Event_Email_Templates_Market_Research'
                        ];
                    
                    Templatelist =
                        [
                            SELECT 
                            Id, 
                            Name 
                            FROM
                            EmailTemplate
                            WHERE
                            isActive = TRUE
                            AND
                            (
                                FolderId =:EmailTempFolder1.id//DF
                                OR
                                FolderId =:EmailTempFolder2.id//DP  
                            )
                            ORDER BY
                            Name
                        ];
                }
                catch(exception e)
                {
                 
                    Templatelist =
                        [
                            SELECT 
                            Id, 
                            Name 
                            FROM
                            EmailTemplate
                            WHERE
                            isActive = TRUE
                            ORDER BY
                            Name
                        ];
                    
                }
                for (Integer j=0;j<Templatelist.size();j++)  
                {      
                    templates.add(new SelectOption(Templatelist[j].ID,Templatelist[j].Name));  
                }  
            }
            
            return templates;
        }
        set;
    }
    
    public List<SelectOption> orgWideAddresses    
    {  
        get    
        {
            if (orgWideAddresses == null) 
            {	
                orgWideAddresses = new List<SelectOption>();
                orgWideAddresses.add(new SelectOption('',''));
                orgWideAddresses.add(new SelectOption('LoggedInUser','**Use Logged in User'));
                List<OrgWideEmailAddress> citylist =
                    [
                        SELECT 
                        Id, 
                        DisplayName 
                        FROM
                        OrgWideEmailAddress
                        //WHERE
                        //IsAllowAllProfiles =  true
                    ];
                for (Integer j=0;j<citylist.size();j++)  
                {      
                    orgWideAddresses.add(new SelectOption(citylist[j].ID,citylist[j].DisplayName));  
                }  
            }
            
            return orgWideAddresses;
        }
        
        set;
    }
    
    public pagereference dosave()
    {
        if (record.SMS_Text__c == '')
        {  
            record.SMS_Text__c = null;
        }
        
        if (record.eMail_Template__c == '')
        {
            record.eMail_Template__c = null;
        }
        
        if (record.SMS_Text__c != null && record.eMail_Template__c !=null)
        {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot specify an Email Template and SMS Text.'));		
            return null;
        }
        
        if (record.SMS_Text__c == null && record.eMail_Template__c == null)
        {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify either an Email Template or SMS Text.'));		
            return null;
        }
        
        record.Email_Template_Name__c= null;
        
        if (record.eMail_Template__c != null)
        {
            EmailTemplate template = 	
                [
                    SELECT
                    Name  
                    FROM
                    EmailTemplate 
                    WHERE
                    Id=:record.eMail_Template__c 
                    LIMIT 1
                ];
            record.Email_Template_Name__c= template.Name;
        }
        
        
        if (record.eMail_Template__c != null && record.Send_From__c==null)
        {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify a Send From.'));		
            return null;
        } 
        
        if (record.eMail_Template__c == null && record.Send_From__c!=null)
        {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You must not specify a Send From for a SMS.'));		
            return null;
        } 
        
        system.debug('record.Send_From__c: '+record.Send_From__c);
        
        if (!String.IsBlank(record.Send_From__c))
        {
            if (record.Send_From__c == 'LoggedInUser') 
            {
                record.Send_From_Name__c = '**Use Logged in User';
            }
            else 
            {
                OrgWideEmailAddress orgwide = 	
                    [
                        SELECT
                        DisplayName 
                        FROM
                        OrgWideEmailAddress 
                        WHERE
                        Id=:record.Send_From__c 
                        LIMIT 1
                    ];
                
                record.Send_From_Name__c = orgwide.DisplayName;
            }
        }
        else 
        {
            record.Send_From_Name__c = '';
        }
        
        upsert record;
        PageReference acctPage = new pagereference('/' + record.Id);
        acctPage.setRedirect(true);
        return acctPage;
    } 
    
}