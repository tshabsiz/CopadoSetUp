/**
* @Author: Mohsin Wadee
* @Company: Barclays Africa
* @Description: Unit Test for BatchableUserLoginUpdate class.
* Tests executed:
* 1 - Run execute method of Database.Batchable interface implemention.
* Test that users have the field Last_Login_Date__c updated to that of standard LastLoginDate field.
* History
* <Date> <Authors Name> <Brief Description of Change>
* 30-Oct-2015, Mohsin Wadee, Class created.
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_BatchableUserLoginUpdate {
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which executes the BatchableUserLoginUpdate class and 
     *                  ensures the Last_Login_Date__c field for the relevant users is updated,
     *                  and is set to the standard LastLoginDate field.
     * @param:          None.
     * 
     * History:
     * 30-Oct-2015, Mohsin Wadee, US-0722, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/
    static testMethod void Test() {
        Test.startTest();
        string query = 'SELECT Id, LastLoginDate ' + 
            'FROM User WHERE IsActive = True AND LastLoginDate != NULL AND LastLoginDate >= YESTERDAY AND BRID__c != NULL AND ' +
                'Name IN (\'Mohsin Wadee\')'; 
        BatchableUserLoginUpdate userLoginUpdate = new BatchableUserLoginUpdate(query);
        Database.executeBatch(userLoginUpdate);
        Test.stopTest();
        
        List<User> loggedInUsers = [SELECT Id, Name, LastLoginDate, Last_Login_Date__c
                                    FROM User 
                                    WHERE IsActive = True 
                                    AND LastLoginDate != NULL
                                    AND LastLoginDate >= YESTERDAY 
                                    AND BRID__c != NULL AND Name IN ('Mohsin Wadee')];
        
        if (!loggedInUsers.isEmpty()) {
            for(User loggedInUser : loggedInUsers) {
                System.assertEquals(loggedInUser.Last_Login_Date__c, loggedInUser.LastLoginDate);
            }
        }
        
        // Test the other interface methods which are usually not called directly.
       
        userLoginUpdate.finish((Database.BatchableContext) null);
    }
    
    static testMethod void start()
    {
        string query = 'SELECT Id, LastLoginDate ' + 
            'FROM User WHERE IsActive = True AND LastLoginDate != NULL AND LastLoginDate >= YESTERDAY AND BRID__c != NULL AND ' +
                'Name IN (\'Mohsin Wadee\')';
        BatchableUserLoginUpdate userLoginUpdate = new BatchableUserLoginUpdate(query);
        userLoginUpdate.start((Database.BatchableContext) null);
    }
    
    static testMethod void execute()
    {
        List<User> loggedInUsers = [SELECT Id, Name, LastLoginDate, Last_Login_Date__c
                                    FROM User 
                                    WHERE IsActive = True 
                                    AND LastLoginDate != NULL
                                    AND LastLoginDate >= YESTERDAY 
                                    AND BRID__c != NULL AND Name IN ('Mohsin Wadee')];
        
        string query = 'SELECT Id, LastLoginDate ' + 
            'FROM User WHERE IsActive = True AND LastLoginDate != NULL AND LastLoginDate >= YESTERDAY AND BRID__c != NULL AND ' +
                'Name IN (\'Mohsin Wadee\')';
        BatchableUserLoginUpdate userLoginUpdate = new BatchableUserLoginUpdate(query);
        userLoginUpdate.execute((Database.BatchableContext) null, loggedInUsers);
    }        
}