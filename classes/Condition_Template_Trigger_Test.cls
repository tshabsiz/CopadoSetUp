@isTest(SeeAllData=false)
private class Condition_Template_Trigger_Test 
{   
    static testMethod void testInsertAndUpdate()
    {
        Condition_Template__c testRecord = new Condition_Template__c();
        insert testRecord;

        testRecord.Name = 'Changed Name';
        update testRecord;
    }
}