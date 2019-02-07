/**
 * Extension controller for EM_Event_Email_Configuration__c.
 * Overrides standard clone and save actions.
 * 
 * @author CloudSmiths
 */ 
public with sharing class evEventEmailConfig_Controller {

   public static final String PARAMETER_CLONE_NAME = 'clone';
   public static final String PARAMETER_CLONE_VALUE_TRUE = '1';
   public static final String EMAIL_VALUE_LOGGED_IN_USER = 'LoggedInUser'; 
   private static final String EMAIL_LABEL_LOGGED_IN_USER = '**Use Logged in User'; 
    
   public EM_Event_Email_Configuration__c record {get;set;}
   public Boolean cloneRecord {get; set;}
   public Boolean selectEvent {get; set;} 
   public String recordName {get; set;} 
   private ApexPages.StandardController stdController {get; set;}    
   private Id originalEventId;
   private Id originalDelegateId; 
   private Map<Id, Event__c> eventsById = new Map<Id, Event__c>();
   private Boolean eventDelegateValid {get; set;}
                    
    
  
    public evEventEmailConfig_Controller(ApexPages.StandardController stdController) {
        this.stdController = stdController;    
        record = (EM_Event_Email_Configuration__c)stdController.getRecord();
        cloneRecord = isClone();
        selectEvent = false;
             
        if (record.Id != null) {            
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
                    Event__r.Name,
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
            recordName = record.Name;
            originalEventId = record.Event__c;
            originalDelegateId = record.Delegate__c;
            
            if (cloneRecord) {
                selectEvent = true;
                recordName = 'Clone of ' + recordName;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Clone of ' + record.Name +
                                                           '; Event: '  +  record.Event__r.Name +
                                ' - On selecting Save, a new Event Email Schedule will be created'));   
            }  
        } else {  // this is a new record
            recordName = '';
            selectEvent = true; 
        }
    }
    
 
 
    /**
     * @return true if the user selected action is Clone.
     */
    private Boolean isClone() {       
        Map<String, String> parameters =  ApexPages.currentPage().getParameters(); 
        String action = parameters.get(PARAMETER_CLONE_NAME);
        return action != null && action.equals(PARAMETER_CLONE_VALUE_TRUE) ? true : false;            
    }
    
    /**
     * Gets events for whose start date >= today - 13 months and
     * builds them into a List<SelectOption> ordered by Start Date Desc and Name.
     */ 
    public List<SelectOption> events {    
        get { 
            if (events == null) {            
                events = new List<SelectOption>();
                // For a clone the original record event must be first 
                eventsById = evEventSelector.selectActiveEventsSince(13);
               
                for (Id eventId : eventsById.keySet()) {
                    Event__c event = eventsById.get(eventId);
                    if (event != null) {
                        if (eventId != record.Event__c) {
                        String label = (event.Start_Date__c != null) ? event.Start_Date__c.format() + ': ' : '';
                        label += event.Name;  
                        events.add(new SelectOption(eventId, label));
                     }  else {
                         SelectOption option = new SelectOption(eventId, event.Name);
                        if (events.isEmpty()) {
                            events.add(option);  
                        }  else {
                            events.add(0, option);
                        }
                     }
                   } // end-if event != null
                 
                } // end-for
                 
            } // end-if events == null
            
            return events;
        }
        set;
    }
    
    
    public List<SelectOption> templates {  
    
        get { 
            if (templates == null) {
            
                templates = new List<SelectOption>();
                templates.add(new SelectOption('',''));
                List<EmailTemplate> Templatelist;
                try {
                 //try get email templates from Event_Email_Templates folder, if that fails , get all email templates so email config can still be setup
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
                catch(exception e) {
                                
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
                for (Integer j=0; j<Templatelist.size(); j++) {                      
                    templates.add(new SelectOption(Templatelist[j].ID,Templatelist[j].Name));  
                }  
            }
            
            return templates;
        }
        set;
    }
    
    public List<SelectOption> orgWideAddresses {   
        get {    
        
            if (orgWideAddresses == null) {
                orgWideAddresses = new List<SelectOption>();
                orgWideAddresses.add(new SelectOption('',''));
                orgWideAddresses.add(new SelectOption(EMAIL_VALUE_LOGGED_IN_USER, EMAIL_LABEL_LOGGED_IN_USER));
                List<OrgWideEmailAddress> citylist =
                    [
                        SELECT 
                        Id, 
                        DisplayName 
                        FROM
                        OrgWideEmailAddress
                        ORDER BY DisplayName
                        //WHERE
                        //IsAllowAllProfiles =  true
                    ];
                for (Integer j=0; j<citylist.size(); j++) {
                    orgWideAddresses.add(new SelectOption(citylist[j].ID,citylist[j].DisplayName));  
                }  
            }
            
            return orgWideAddresses;
        }
        
        set;
    }
    
    public PageReference dosave() {
        System.debug(LoggingLevel.DEBUG, 'evEventEmailConfig_Controller.doSave: clone = ' + cloneRecord + 
                                          ', SMS Text = ' + record.SMS_Text__c  + ', Email Template = ' + record.eMail_Template__c +
                                          ', Send From = ' + record.Send_From__c); 
        Id originalRecordId = record.Id;                                  
        if (record.SMS_Text__c == '') {         
            record.SMS_Text__c = null;
        }
        
        if (record.eMail_Template__c == '') {        
            record.eMail_Template__c = null;
        }       
        
        // Validate the combination of SMS Text, eMail Template and Send From fields
        if (record.SMS_Text__c != null && record.eMail_Template__c != null) {        
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot specify an Email Template and SMS Text.'));		
            return null;
        }
        
        if (record.SMS_Text__c == null && record.eMail_Template__c == null) {       
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify either an Email Template or SMS Text.'));		
            return null;
        }        
        
        if (record.eMail_Template__c != null && record.Send_From__c == null) {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify a Send From.'));		
            return null;
        } 
        
        if (record.eMail_Template__c == null && record.Send_From__c != null) {       
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'You must not specify a Send From for a SMS.'));		
            return null;
        } 
       
         // The selected delegate must be linked to the Event Email Schedule event.
         validateEventDelegate();  
         if (!eventDelegateValid) {
             return null;
         }
        
        
        record.Email_Template_Name__c = null;
        if (record.eMail_Template__c != null) {        
            EmailTemplate template = 	
                [
                    SELECT
                    Name  
                    FROM
                    EmailTemplate 
                    WHERE
                    Id = :record.eMail_Template__c 
                    LIMIT 1
                ];
            record.Email_Template_Name__c= template.Name;
        }
        
       
        if (!String.IsBlank(record.Send_From__c)) {        
            if (record.Send_From__c == EMAIL_VALUE_LOGGED_IN_USER) { 
                record.Send_From_Name__c = EMAIL_LABEL_LOGGED_IN_USER;
            }
            else {
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
        else  {        
            record.Send_From_Name__c = '';
        }
        
         
        if (cloneRecord) {
            record.Id = null;
        }
        try {            
            upsert record;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'evEventEmailConfig_Controller Failed to upsert Event Email Schedule ' + record +
                        '\n' +e.getStackTraceString());
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Save failed; ErrorMessage: ' + 
                                                       e.getMessage())); 
            return null;                                       
        }    
        PageReference acctPage = new PageReference('/' + record.Id);       
        acctPage.setRedirect(true);
        return acctPage;
    } 
    
    public void validateEventDelegate() {
        eventDelegateValid = true;
        String errorMessage = validateDelegate();
         if (!String.isBlank(errorMessage)) {
              ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
              eventDelegateValid = false;
         }
        
    }
    
    /**
     * Validates that the selected Delegate is linked to the selected Event.
     * This validation will happen for create or clone
     */ 
    public String validateDelegate() {
        String errorMessage = null;
        if ((selectEvent &&  !String.isBlank(record.Delegate__c)) && 
            (originalEventId == null || record.Event__c != originalEventId || 
             record.Delegate__c != originalDelegateId )) {
                                        
               Event__c event = eventsById.get(record.Event__c);
               if (event != null) {
                   List<Delegate__c>  delegates = event.Delegates__r;
                   Boolean delegateIsValid = false;
                    if (delegates == null || delegates.isEmpty()) {
                        errorMessage = 'There are no delegates linked to the event. ' + 
                            ' Please clear the Test email Delegate field';
                    } 
                    else {
                        errorMessage = 'For the test email Delegate, please select a delegate who is linked to the event ' +
                            'or clear the Delegate field. Linked delegates include: ';
                        Integer count = 0;    
                        for (Delegate__c delegate : delegates) {
                            count++;
                            if (delegate.Id == record.Delegate__c) {
                                delegateIsValid = true;
                                errorMessage = null;
                                break;
                            }  
                            if (count < 21) {
                                errorMessage += ' ' + delegate.Name;
                                if (delegate.Contact_Full_Name__c != null) {
                                    errorMessage += '(' + delegate.Contact_Full_Name__c + ');';
                                } else {
                                    errorMessage += ';';
                                } 
                                
                            }               
                        }
                      
                    } // end have delegates                    
                
               } // end-if event != null
        } // end-if selectEvent && (event has changed or delegate has changed)
        return errorMessage;
    }
    
}