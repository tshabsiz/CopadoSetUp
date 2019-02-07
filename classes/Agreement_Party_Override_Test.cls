/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

29/06/2017 - DF    - Created Class.

**/ 
@isTest
public class Agreement_Party_Override_Test 
{
    public static testMethod void Agreement_Party_Override_Test() 
    { 
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestAgreement);   
        
        Agreement_Party_Override test = new Agreement_Party_Override(sc);
        test.saveRecord();

        //Test deselecting a wrapper item.
        test.partyWrappers[0].selected = false;
        test.partyWrappers[1].selected = true;

        //Save again.
        test.saveRecord();
    }
}