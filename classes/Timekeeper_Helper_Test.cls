/**
 * 04/04/2018 - TdB    - Created Test Class. 
**/
@isTest(SeeAllData=false)
public class Timekeeper_Helper_Test 
{
	public static testMethod void testTimeKeeper()
    {        
        test.startTest();
        
        advpm__Timekeeper__c testTimekeeper = new advpm__Timekeeper__c(advpm__Staff__c = UserInfo.getUserId());
        insert testTimekeeper;
        
        try
        {
            advpm__Timekeeper__c testTimekeeper2 = new advpm__Timekeeper__c(advpm__Staff__c = UserInfo.getUserId());
            insert testTimekeeper2;
        }catch(Exception e)
        {
            
        }
        
        
        testTimekeeper.advpm__Staff__c = null;
        update testTimekeeper;
        
        testTimekeeper.advpm__Staff__c = UserInfo.getUserId();
        update testTimekeeper;
        
        
        test.stopTest();
    }
}