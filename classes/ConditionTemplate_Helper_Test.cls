/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

27/10/2017 - DF    - Created class.

**/ 
@isTest
public class ConditionTemplate_Helper_Test 
{
    public static testMethod void Test()
    {
        Cloudsmiths_TestDataClass TDC = new Cloudsmiths_TestDataClass();
        string test = ConditionTemplate_Helper.createTemplateCode(TDC.TestConditionTemplate);
    }
}