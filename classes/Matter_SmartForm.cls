/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 19/04/2017 - PG    - Created Class.
 15/06/2017 - TD    - Change Object creation to Case and remove Matter creation.
            
**/
public class Matter_SmartForm {
    
    public case caseObj { get; set; }
    public Id caseMatterRecordTypeId { get; set; }
    public Id insertedCaseId { get; set; }
    public Map<String, String> inputErrors { get; set; }
    public Boolean hasError { get; set; }
    
    //Mandatory Fields
    public String fullName { get; set; }
    public String emailAddress { get; set; }
    
    public String businessUnitContactPerson { get; set; }
    public String subject { get; set; }
    public String description { get; set; }

    //Option Fields
    public String costCentre { get; set; }
    public String clientName { get; set; }
    public String clientEmailAddress { get; set; } 
    public String clientRepresentative { get; set; }
    
    public String LegalDivision { get; set; } 
    public String LegalBusinessArea { get; set; }
   
    
    public Matter_SmartForm()
    {
        caseMatterRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query/Matter Request').getRecordTypeId();
        caseObj = new Case(AccountId = null, ContactId = null, Matter__c = null, RecordTypeId = caseMatterRecordTypeId);
    }
    
    public PageReference validateForm()
    {
        System.debug('### validateForm');
        
        //Clear form errors
        clearFormErrors();
        
        //First Name
        if(String.isBlank(fullName))
        {
            inputErrors.put('fullName','You must specify a value');
        }
        
        //Email Address
        if(String.isBlank(emailAddress) || !Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', emailAddress))
        {
            inputErrors.put('emailAddress','Invalid email address format.');
        }
        
        //Email Address
        if(!String.isBlank(clientEmailAddress) && !Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', clientEmailAddress))
        {
            inputErrors.put('clientEmailAddress','Invalid email address format.');
        }
        
        if(String.isBlank(caseObj.Business_Unit_Cluster_Segment__c))
        {
            inputErrors.put('BusinessUnitLookup','You must specify a business unit.');
        }
        
        //Business Unit Contact Person
        if(String.isBlank(businessUnitContactPerson))
        {
            inputErrors.put('businessUnitContactPerson','You must specify a contact person.');
        }
        
        //Subject
        if(String.isBlank(subject))
        {
            inputErrors.put('subject','You must specify a subject.');
        }
        
        //Description
        if(String.isBlank(description))
        {
            inputErrors.put('description','You must specify a description.');
        }
        
        if(!String.isBlank(caseObj.AccountId) && (String.isBlank(caseObj.ContactId) || caseObj.ContactId == null))
        {
            inputErrors.put('clientRepresentativeLookup','You must a external party representitive.');
        }
        
        if(String.isBlank(caseObj.AccountId) && (!String.isBlank(caseObj.ContactId) || caseObj.ContactId <> null))
        {
            inputErrors.put('clientNameLookup','You must a external party.');
        }
        
        
        if(String.isBlank(caseObj.LegalDivision__c))
        {
            inputErrors.put('LegalDivision','You must specify a Division.');
        }
        if(String.isBlank(caseObj.LegalBusinessArea__c))
        {
            inputErrors.put('LegalBusinessArea','You must specify a  Business Area.');
        }
        
        
        //Did we get any errors.
        for(String key : inputErrors.keySet())
        {
            if(inputErrors.get(key).length() > 0)
            {
                hasError = true;
            }
        }
        
        System.debug('### validateForm : hasError : '+hasError);
        System.debug('### validateForm : inputErrors : '+inputErrors);
        
        //Has the form get error.
        if(!hasError)
        {
            //If insert of matter is success, move to next step.
            if(processForm())
            {
                System.debug('### validateForm : IF :');
                return Page.Matter_SmartFormUpload;
            }
        }
        
        //Return
        return null;
    }
    
    public Boolean processForm() 
    {
        //Id of the matter queue.
        //Id allocationQueueId = [SELECT Id FROM Group where Name = 'Matter Allocation Queue' and Type = 'Queue'].Id;
        //Id of the Legal Request Queue
        //Id legalRequestQueueId = [SELECT Id, DeveloperName FROM Group where DeveloperName = 'Legal_Request_Queue' and Type = 'Queue'].Id;
        
        caseObj.RecordTypeId = caseMatterRecordTypeId;
        //caseObj.OwnerId = legalRequestQueueId;
        caseObj.Status = 'New';
        caseObj.Origin = 'Online';
        caseObj.Type = 'Query';
        caseObj.Email_From_Address__c = emailAddress;
        caseObj.Email_Sender_Name__c = fullName;
        caseObj.ContactConfirmedWith__c = businessUnitContactPerson;
        caseObj.Cost_Centre__c = costCentre;
        caseObj.External_Party_Email_Address__c = clientEmailAddress;
        caseObj.External_Party_Name__c = clientName;
        caseObj.External_Party_Representative__c = clientRepresentative;
        caseObj.Subject = subject;
        caseObj.Description = description;
      //  caseObj.LegalDivision__c = LegalDivision;
     //   caseObj.LegalBusinessArea__c = LegalBusinessArea;
        
        //Use options to activate assignment rules
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        
        //Database Save Point
        Savepoint sp = Database.setSavepoint();
        
        //Insert Data
        try 
        {
            Database.insert(caseObj, dmo);
            insertedCaseId = caseObj.Id;
            
            return true;
        }
        catch(Exception e)
        {
            //Database Rollback
            Database.rollback(sp);
            System.debug('### processForm : exception : '+e.getMessage());
        }

        return false;
    }
    
    public void clearFormErrors() 
    {   
        //Rest for merrors.
        hasError = false;
        
        //Clear Input Errors
        inputErrors = new Map<String, String>();
        inputErrors.put('fullName','');
        inputErrors.put('emailAddress','');
        inputErrors.put('BusinessUnitLookup','');
        inputErrors.put('businessUnitContactPerson','');
        inputErrors.put('description','');
        inputErrors.put('clientNameLookup','');
        inputErrors.put('clientEmailAddress','');
        inputErrors.put('clientRepresentativeLookup','');
        inputErrors.put('subject','');
        
        inputErrors.put('LegalDivision','');
        inputErrors.put('LegalBusinessArea','');
    }
}