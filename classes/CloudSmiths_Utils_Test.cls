/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

29/06/2017 - DF     - Created Class.
13/03/2018 - PG     - Added "getEnviroment" method run.

**/ 
@isTest
public class CloudSmiths_Utils_Test
{
    public static testMethod void CloudSmiths_Utils_Test() 
    { 
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        CloudSmiths_Utils.convertUrlToBlob('/apex/FitToLend_View?mode=pdf&id='+ testDataClass.TestMatter.id);
        CloudSmiths_Utils.getObjectRecordTypeId(account.SObjectType, 'Client');
        CloudSmiths_Utils.getCreatableFieldsSOQL('Account', '');
        CloudSmiths_Utils.getEnviroment();
        
        system.debug(testDataClass.TestAccount);
        string TestString = 'id =: ' +testDataClass.TestAccount.id;
        CloudSmiths_Utils.getCreatableFieldsSOQL('Account',TestString); 
    }
}