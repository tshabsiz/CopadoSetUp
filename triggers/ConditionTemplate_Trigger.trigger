/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 04/07/2017 - PG    - Created trigger.

**/ 
trigger ConditionTemplate_Trigger on Condition_Template__c (after insert, before update)  
{
    List<Condition_Template__c> conditionTemplatesToUpdate = new List<Condition_Template__c>();
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        for(Condition_Template__c conditionTemplate : Trigger.New)
        {
            Condition_Template__c oldConditionTemplate = Trigger.oldMap.get(conditionTemplate.Id);
            
            if(String.isBlank(conditionTemplate.Template_Code__c) || conditionTemplate.Name != oldConditionTemplate.Name)
            {
                conditionTemplate.Template_Code__c = ConditionTemplate_Helper.createTemplateCode(conditionTemplate);
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        for(Condition_Template__c conditionTemplate : Trigger.New)
        {
            if(String.isBlank(conditionTemplate.Template_Code__c)) 
            {
                Condition_Template__c insertedTemplate = new Condition_Template__c();
                insertedTemplate.Id = conditionTemplate.Id;
                insertedTemplate.Template_Code__c = ConditionTemplate_Helper.createTemplateCode(conditionTemplate);
                
                conditionTemplatesToUpdate.add(insertedTemplate);
            }
        }
        
        update conditionTemplatesToUpdate;
    }
}