/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 04/07/2017 - PG    - Created class.

**/ 
public class ConditionTemplate_Helper  
{
    public static String createTemplateCode(Condition_Template__c inputConditionTemplate)
    {
        String finalTemplateCode = '';
        
        List<String> words = new List<String>();
        words = inputConditionTemplate.Name.split(' ');
        
        for(String word : words)
        {
            finalTemplateCode += word.capitalize().left(1);
        }
        
        finalTemplateCode += inputConditionTemplate.Auto_Number__c; 
        
        //Return.
        return finalTemplateCode;
    }
}