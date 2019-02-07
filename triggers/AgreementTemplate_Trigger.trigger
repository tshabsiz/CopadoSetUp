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
trigger AgreementTemplate_Trigger on Agreement_Template__c (after insert, before update)  
{
    List<Agreement_Template__c> agreementTemplatesToUpdate = new List<Agreement_Template__c>();
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        for(Agreement_Template__c agreementTemplate : Trigger.New)
        {
            Agreement_Template__c oldAgreementTemplate = Trigger.oldMap.get(agreementTemplate.Id);
            
            if(String.isBlank(agreementTemplate.Template_Code__c) || agreementTemplate.Name != oldAgreementTemplate.Name)
            {
                agreementTemplate.Template_Code__c = AgreementTemplate_Helper.createTemplateCode(agreementTemplate);
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        for(Agreement_Template__c agreementTemplate : Trigger.New)
        {
            if(String.isBlank(agreementTemplate.Template_Code__c)) 
            {
                Agreement_Template__c insertedTemplate = new Agreement_Template__c();
                insertedTemplate.Id = agreementTemplate.Id;
                insertedTemplate.Template_Code__c = AgreementTemplate_Helper.createTemplateCode(agreementTemplate);
                
                agreementTemplatesToUpdate.add(insertedTemplate);
            }
        }
        
        update agreementTemplatesToUpdate;
    }
}