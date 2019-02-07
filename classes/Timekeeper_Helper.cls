/**
 * 04/04/2018 - TdB    - Created Class. 
**/

public class Timekeeper_Helper 
{
	public static void checkDuplicate(List<advpm__Timekeeper__c> timekeeperList)
    {
        //Add all Users to a set
        Set<Id> UserIdSet = new Set<Id>();
        Map<Id, advpm__Timekeeper__c> existingTimekeeperMap = new Map<Id, advpm__Timekeeper__c> ();
        String timekeeperUrlString = '';
        
        //Add all Staff User Id's to set
        for(advpm__Timekeeper__c eachTimekeeper : timekeeperList)
        {
            UserIdSet.add(eachTimekeeper.advpm__Staff__c);
        }
        
        //Get all existing Timekeeper records, add to Map <StaffUserId, Timekeeper record>
        for(advpm__Timekeeper__c eachTimekeeper : [SELECT Id, Name, advpm__Staff__c FROM advpm__Timekeeper__c WHERE advpm__Staff__c IN: UserIdSet])
        {
            existingTimekeeperMap.put(eachTimekeeper.advpm__Staff__c, eachTimekeeper);
        }
        
        //Check if Timekeeper duplicate record exist based on Staff/User, display error id exist
        for(advpm__Timekeeper__c eachTimeKeeper : timekeeperList)
        {
            if(existingTimekeeperMap.containsKey(eachTimeKeeper.advpm__Staff__c))
            {
                timekeeperUrlString = '<a href=' + site.getBaseSecureUrl() + '/' + existingTimekeeperMap.get(eachTimeKeeper.advpm__Staff__c).Id + '>'  + existingTimekeeperMap.get(eachTimeKeeper.advpm__Staff__c).Name + '</a>';
				eachTimeKeeper.addError('Timekeeper record ( ' + timekeeperUrlString + ' ) already exist, no duplicates allowed ' , false);                
            }
        }
    }
}