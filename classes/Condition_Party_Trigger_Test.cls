@isTest(SeeAllData=false)
private class Condition_Party_Trigger_Test 
{   
    static testMethod void testDelete()
    {
        BXDtesclassdata.setupBoxFolder();
        ConditionSchedulingSettings__c setting  = new ConditionSchedulingSettings__c(Name = 'Default', Months_In_Advance__c = 1, Business_Hours__c = 'Default');
        insert setting;
        
        Agreement__c agreement = new Agreement__c();
        insert agreement;

        Condition__c parent = new Condition__c(Active__c = false, Agreement__c = agreement.Id);
        insert parent;

        Condition_Party__c testRecord = new Condition_Party__c(Condition__c = parent.Id);
        insert testRecord;

        delete testRecord;
    }   
}