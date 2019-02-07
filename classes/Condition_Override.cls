/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 29/05/2017 - PG    - Created Class.
 21/06/2017 - PG    - Removed "Financial Year End" from Standard fields in constructor.
                    - Removed "Relative Start Date" from constructor.
                    - Added 'Other_Relative_Date__c' to constructor.
 22/06/2017 - PG    - Added LAst Chased and Margin rachet fields..
 01/07/2017 - KK    - Added Box Folder Creation instead of from triggers.
 17/11/2017 - TdB    - Added Margin_Ratchet_Name__c
 02/03/2018 - TdB    - Add CloneCondition Pagerefrence functionality

            
**/       
public class Condition_Override
{  
    /**
    * Variables
    **/
    public Condition__c conditionObject { get; set; }
    private String recordTypeName { get; set; }
    private String objectPrefix { get; set; } 
    
    /**
    * Constructor
    **/
    public Condition_Override(ApexPages.StandardController stdController)
    {
        System.debug('### Condition_Override:'+stdController.getId());
        
        //Get the object prefix.
        objectPrefix = Condition__c.sObjectType.getDescribe().getKeyPrefix();
        
        //Edit Request / Action
        if(stdController.getId() != null || stdController.getId() != '')
        {
            //Fields for sObject.
            Map<String, Schema.SObjectField> conditionFieldMap = Schema.getGlobalDescribe().get('Condition__c').getDescribe().fields.getMap();
            List<String> fields = new List<String>();
            for(Schema.SObjectField eachField :conditionFieldMap.values())
            {
                schema.describeFieldResult dfield = eachField.getDescribe();
                fields.add(string.valueOf(dfield.getName())); 
            }
            
            if(!Test.isRunningTest())
            {
                //Add fields
                stdController.addFields(fields);
            }
            
            //Get the page record.
            this.conditionObject = (Condition__c)stdController.getRecord();
        }
        //New Request / Action
        else
        {
            conditionObject = new Condition__c();
            
            //Set ownerId to current user.
            conditionObject.OwnerId = UserInfo.getUserId();
        }
        
        //Get the record type.
        recordTypeName = Schema.SObjectType.Condition__c.getRecordTypeInfosById().get(conditionObject.RecordTypeId).getName();
    }
    
    /**
    * VIEW - detemines how to route the user based on record type.
    **/
    public PageReference actionViewRoute()
    {
        System.debug('### Condition_Override : actionViewRoute');       
        
        //Did the user select a financial covenant?
        if(recordTypeName == 'Financial Covenant')
        {
            //Stay put.
            return null; 
        }
        else
        {
            //New Page Setup
            PageReference standardPage = new PageReference('/'+conditionObject.Id); 
            standardPage.setRedirect(true);
            
            //Prevent infinite loop. Force override.
            standardPage.getParameters().put('nooverride','1'); 

            //Redirect.
            return standardPage;
        }
    }
    
    /**
    * EDIT Detemines how to route the user based on record type.
    **/
    public PageReference actionEditRoute()
    {
        System.debug('### Condition_Override : actionEditRoute');

        //Did the user select a financial covenant?
        if(recordTypeName == 'Financial Covenant')
        {
            //Stay put.
            return null;
        }
        else
        {
            //Get current page parameters
        	Map<String, String> currentParams = ApexPages.CurrentPage().getParameters();

            //New Page Setup
            PageReference standardPage = new PageReference('/'+objectPrefix+'/e?'); 
            standardPage.setRedirect(true);
            
            //Add passed params.
            standardPage.getParameters().putAll(currentParams);
            
            //Remove some unwanted params.
            standardPage.getParameters().remove('save_new');
            standardPage.getParameters().remove('save');
            
            //Prevent infinite loop. Force override.
            standardPage.getParameters().put('nooverride','1'); 

            //Redirect.
            return standardPage;
        }
    }
    
    //Called from the Jquery action once the page has loaded to call folder creation
    public PageReference createBoxFolder(){
        System.debug('### Condition_Override : createBoxFolder : '+conditionObject.Id);
        Condition__c condition = [SELECT Id, Name, Agreement__c, RecordTypeId FROM Condition__c WHERE Id=:conditionObject.Id LIMIT 1];
        BxdConditionService.createFolderForRecord(condition);
        return null;
    }
    
    public PageReference createBoxPermission(){
        System.debug('### Condition_Override : createBoxPermission : '+conditionObject.Id);
        BxdConditionService.createBoxPermission(conditionObject.Id);
        return null;
    }
    
    public PageReference cloneCondition(){
        Id conditionId = ApexPages.currentPage().getParameters().get('id');
        if(conditionId == null) return null;
        
        Pagereference targetClonePg = Page.Condition_Override;
        targetClonePg.setRedirect(true);
        targetClonePg.getParameters().put('clone', '1');
        targetClonePg.getParameters().put('id', conditionId);
        targetClonePg.getParameters().put('retURL', conditionId);
        targetClonePg.getParameters().put('sfdc.override','1');
        return targetClonePg;
    }
}