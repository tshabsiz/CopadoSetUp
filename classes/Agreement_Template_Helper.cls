/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 04/07/2017 - PG    - Created class.
 29/09/2017 - PG    - Renamed Class from "AgreementTemplate_Helper" to "Agreement_Template_Helper"
                    - Added "afterInsert" && "beforeUpdate" methods.
                    - Added "updateTemplateCode" methods, ncluding override. 

**/ 
public class Agreement_Template_Helper   
{
    /**
    * Before Update Trigger handler.
    **/
    public static void beforeUpdate(List<Agreement_Template__c> inputNewList, Map<Id, Agreement_Template__c> inputOldMap)
    {
        updateTemplateCode(inputNewList, inputOldMap);
    }

    /**
    * After Insert Trigger handler.
    **/
    public static void afterInsert(List<Agreement_Template__c> inputNewList)
    {
        updateTemplateCode(inputNewList); 
    }

    /**
    * Update template code on agreement template.
    **/
    public static void updateTemplateCode(List<Agreement_Template__c> inputNewList)
    {
        //Blank list.
        List<Agreement_Template__c> agreementTemplates = new List<Agreement_Template__c>();

        for(Agreement_Template__c agreementTemplate : inputNewList)
        {
            //Clone sobject
            agreementTemplates.add(agreementTemplate.clone(true,true));
        }

        //Update to force population.
        update agreementTemplates;
    } 

    /**
    * Overload - Update template code on agreement template.
    **/
    public static void updateTemplateCode(List<Agreement_Template__c> inputNewList, Map<Id, Agreement_Template__c> inputOldMap)
    {
        //Loop thorugh agreement templates.
        for(Agreement_Template__c agreementTemplate : inputNewList)
        {
            if(String.isBlank(agreementTemplate.Template_Code__c) || agreementTemplate.Name != inputOldMap.get(agreementTemplate.Id).Name) 
            {
                //Set the code.
                agreementTemplate.Template_Code__c = createTemplateCode(agreementTemplate);
            }
        }   
    }

    /**
    * Generates the template code.
    **/
    public static String createTemplateCode(Agreement_Template__c inputAgreementTemplate)
    {
        String finalTemplateCode = '';
        
        List<String> words = new List<String>();
        words = inputAgreementTemplate.Name.split(' ');
        
        for(String word : words)
        {
            finalTemplateCode += word.capitalize().left(1);
        }
        
        finalTemplateCode += inputAgreementTemplate.Auto_Number__c;
        
        //Return.
        return finalTemplateCode;
    }
}