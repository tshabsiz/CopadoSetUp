/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/ 
                                                          
*** CHANGE LOG ***
 
 04/06/2017 - PG    - Created initial class
 21/06/2017 - PG    - Added new Last Chased fields to constructor.
 22/06/2017 - PG    - Added Margin Rachet field
                    - Added a couple fields in main SOQL for "view" page.
 13/07/2017 - PG    - Added "Source" field to SOQL query. 
 11/10/2017 - PG    - Changed to use the consolidated relationship field.
 17/11/2017 - TdB   - Added Margin_Ratchet_Name__c
 01/12/2017 - Tdb	- Add Warning message for in ActionViewRoute - when Financial Covenants Occurance Breached and Margin Ratchets linked
 
**/       
public class Condition_Occurrence_Override  
{
    /**
    * Variables
    **/
    public Condition_Occurrence__c conditionOccurrenceObject { get; set; }
    private String recordTypeName { get; set; }
    private String objectPrefix { get; set; } 
    
    /**
    * Constructor
    **/
    public Condition_Occurrence_Override(ApexPages.StandardController stdController)
    {
        System.debug('### Condition_Occurrence_Override');
        
        //Get the object prefix.
        objectPrefix = Condition_Occurrence__c.sObjectType.getDescribe().getKeyPrefix(); 
        
        //Edit Request / Action
        if(stdController.getId() != null || stdController.getId() != '')
        {
            List<String> fields = new List<String>{
                //Condition Occurrence Detail
                'Id',
                 'Margin_Ratchet_Name__c',
                'Name',
                'CurrencyISOCode',
                'Person_Responsible__c',
                'Participant_User__c',
                'Condition__c',
                'Status__c',
                'Comments__c',
                'Due_Date__c',
                //Deal Information
                'Deal1__c',
                'Division__c',
                'Coverage_Area__c',
                'Product_Area__c',
                'Agreement_Type__c',
                'Product__c',
                'Agreement__c',
                'Relationship_Consolidated__c',
                //Clause
                'Clause__c',
                //Document Information
                'Document_Status__c',
                'Document_Description__c',
                'Supporting_Documentation_Uploaded__c',
                //Actual Base Information
                'Actual_Base_Ratio_From__c',
                'Actual_Base_Ratio_To__c',
                'Actual_Base_Percentage__c',
                'Actual_Base_Multiple__c',
                'Actual_Other__c',
                'Actual_Base_Number__c',
                //Threshold Information
                'Threshold_Type_Text__c',
                'Threshold_Category_Text__c',
                'Threshold_Comparator_Text__c',
                'Margin_Ratchet__c',
                'Source_Text__c',
                //Required Base Information
                'Required_Base_Ratio_From_Num__c',
                'Required_Base_Ratio_To_Num__c',
                'Required_Base_Percentage_Num__c',
                'Required_Base_Multiple_Num__c',
                'Required_Other__c',
                'Required_Base_Number__c',
                //Required Base Range Information
                'Required_Base_Range_Ratio_From_Num__c',
                'Required_Base_Range_Ratio_To_Num__c',
                'Required_Base_Range_Ratio_From_Two_Num__c',
                'Required_Base_Range_Ratio_To_Two_Num__c',
                'Required_Base_Range_Multiple_From_Num__c',
                'Required_Base_Range_Multiple_To_Num__c',
                'Required_Base_Range_Percentage_From_Num__c',
                'Required_Base_Range_Percentage_To_Num__c',
                'Required_Base_Range_Number_From__c',
                'Required_Base_Range_Number_To__c',
                //System Information
                'RecordTypeId',
                'CreatedById',
                'LastModifiedById',
                'Status_Change_Stamp__c',
                //Last Chased
                'Last_Chased_By__c',
                'Last_Chased_On__c'
            };

            if(!Test.isRunningTest())
            {
                //Add fields
                stdController.addFields(fields);
            }
            
            //Get the page record.
            this.conditionOccurrenceObject = (Condition_Occurrence__c)stdController.getRecord();
        }
        //New Request / Action
        else
        {
            conditionOccurrenceObject = new Condition_Occurrence__c();
        }
        
        //Get the record type.
        recordTypeName = Schema.SObjectType.Condition_Occurrence__c.getRecordTypeInfosById().get(conditionOccurrenceObject.RecordTypeId).getName();

    }
    
    /**
    * EDIT Detemines how to route the user based on record type.
    **/
    public PageReference actionEditRoute()
    {
        System.debug('### Condition_Occurrence_Override : actionEditRoute');
        
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
    
    /**
    * VIEW - Detemines how to route the user based on record type.
    **/
    public PageReference actionViewRoute()
    {
        System.debug('### Condition_Occurrence_Override : actionViewRoute '+recordTypeName);
        List<Condition__c> warningCondition = new List<Condition__c>();
        String marginRatchetUrlString = '';
        
        //Did the user select a financial covenant?
        if(recordTypeName == 'Financial Covenant')
        {
            if(conditionOccurrenceObject.status__c == 'Breached')
            {
                warningCondition = [SELECT Id , (SELECT Id, Name, Margin_Ratchet__r.Name, Margin_Ratchet__r.Id, Condition__c from Margin_Ratchet_Conditions__r) FROM Condition__c WHERE id = : conditionOccurrenceObject.Condition__c limit 1] ;
            
                if(warningCondition[0].Margin_Ratchet_Conditions__r.size() > 0)
                {
                    for(Margin_Ratchet_Conditions__c eachMarginRatchet : warningCondition[0].Margin_Ratchet_Conditions__r)
                    {
                        marginRatchetUrlString += '<li  style="margin-left:0px"><a href=' + site.getBaseSecureUrl() + '/' + eachMarginRatchet.Margin_Ratchet__r.Id + '>'  + eachMarginRatchet.Margin_Ratchet__r.Name + '</a></li>';
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Warning,'Please note that the Financial Covenant is breached, Margin Ratchets linked: <ul style="margin-top:5px">' + marginRatchetUrlString + '</ul>'));
                }
            }
       		
            //Stay put.
            return null; 
        }
        else
        {
            //New Page Setup
            PageReference standardPage = new PageReference('/'+conditionOccurrenceObject.Id); 
            standardPage.setRedirect(true);
            
            //Prevent infinite loop. Force override.
            standardPage.getParameters().put('nooverride','1'); 

            //Redirect.
            return standardPage;
        }
    }
    
    public PageReference createBoxPermission(){
        System.debug('### Condition_Occurrence_Override : createBoxPermission : '+conditionOccurrenceObject.Id);
        BxdConditionOccurrenceService.createBoxPermission(conditionOccurrenceObject.Id);
        return null;
    }
}