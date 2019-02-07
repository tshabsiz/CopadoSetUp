@isTest 
public class evDelegate_Trigger_Test 
{
    static testMethod void evDelegate_Trigger_Test()
    {
        evTestDataGenerator TDG = new evTestDataGenerator();
        
        id HostId = TDG.TestDelegate.Host__c;
        system.debug('HostId' + HostId);
        TDG.TestDelegate.Host__c = null;
        UPdate TDG.TestDelegate;
        
        Event_Team_Member__c testETm = 
            [
                SELECT
                id 
                from
                Event_Team_Member__c
                Limit 1
            ];
        
        TDG.TestDelegate.Host__c = testETm.id;
        UPdate TDG.TestDelegate;
    }
}