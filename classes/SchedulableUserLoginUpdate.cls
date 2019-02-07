/*
 * @Author			Mohsin Wadee
 * @Company:		Barclays Africa
 * @Description:	A schedulable class which executes the BatchableUserLoginUpdate class..
 * 
 * @Date:			30-Oct-2015
 * @Inputs:			None
 * @TestClass:		SchedulableUserLoginUpdate_Test
 *-------------------------------------------------------------------------------------------------------------------------*/
global class SchedulableUserLoginUpdate implements Schedulable 
{
    global void execute (SchedulableContext ctx)
    {
        string query;
        
        if (Test.isRunningTest())
        {
        	query = 'SELECT Id, LastLoginDate ' + 
            'FROM User WHERE IsActive = True AND LastLoginDate != NULL AND LastLoginDate >= YESTERDAY AND BRID__c != NULL AND ' +
                'Name IN (\'Mohsin Wadee\')';
        }
        else
        {
            query = 'SELECT Id, LastLoginDate ' + 
            'FROM User WHERE IsActive = True AND LastLoginDate != NULL AND LastLoginDate >= YESTERDAY AND BRID__c != NULL';
        }
        
        BatchableUserLoginUpdate batchUserLoginUpdate = new BatchableUserLoginUpdate(query);
        Database.executeBatch(batchUserLoginUpdate);
    }
}