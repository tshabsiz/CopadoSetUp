/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

18/07/2017 - DF    - Created Class.

**/
@isTest
public class Participant_Trigger_Test 
{
    public static testMethod void Participant_Trigger_Test()
    {        
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();
        
        Test.startTest();

        update testData.TestParticipant1;
        delete testData.TestParticipant1; 

        Test.stopTest();
    }
}