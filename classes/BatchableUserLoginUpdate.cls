/**
 * @Author			Mohsin Wadee
 * @Company:		Barclays Africa
 * @Description:	A batchable class to update custom field Last_Login_Date__c to that of standard field LastLoginDate.
 * 					This is so standard users can create their own reports/dashboards to gauge Salesforce usage.
 * 
 * @Date:			30-Oct-2015
 * @Inputs:			None
 * @TestClass:		ZZTEST_BatchableUserLoginUpdate
 * 
 * History:
 * 30-Oct-2015, Mohsin Wadee, US-0722, class created.
 *-------------------------------------------------------------------------------------------------------------------------*/
global class BatchableUserLoginUpdate implements Database.Batchable<sObject> 
{
    global String query { get; set; }
    
    /**
     * @Author			Mohsin Wadee
     * @Company:		Barclays Africa
     * @Description:	Class constructor. Set the query to get the User dataset for which the Last_Login_Date__c field
     * 					will be set.
     * @param:			None.
     * 
     * History:
     * 30-Oct-2015, Mohsin Wadee, US-0722, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/
    global BatchableUserLoginUpdate(string userQuery)
    {
        this.query = userQuery;
    }

	/**
     * @Author			Mohsin Wadee
     * @Company:		Barclays Africa
     * @Description:	Implements the Batchable start method. Gets the dataset based on the query specified in the constructor.
     * @param:			None.
     * 
     * History:
     * 30-Oct-2015, Mohsin Wadee, US-0722, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/    
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
		return Database.getQueryLocator(query);
	}
 
    /**
     * @Author			Mohsin Wadee
     * @Company:		Barclays Africa
     * @Description:	Implements the Batchable execute method. Last_Login_Date__c field is updated for the User object.
     * @param:			None.
     * 
     * History:
     * 30-Oct-2015, Mohsin Wadee, US-0722, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/    
    global void execute(Database.BatchableContext BC, List<User> loggedInUsers)
	{
     	for (User loggedInUser : loggedInUsers)
        {
            loggedInUser.Last_Login_Date__c = loggedInUser.LastLoginDate;
     	}
       
     	Database.SaveResult[] saveResults = Database.update(loggedInUsers, false);
        
        // Error handling occurs here.
        /**
        for (Database.SaveResult saveResult : saveResults)
        {
            if (!saveResult.isSuccess()) 
            {
                for (Database.Error error : saveResult.getErrors())
                {
                    String errorFields = String.join(error.getFields(), ',');
                    String errorMessage = error.getMessage();
                }
            }
		}
        */
	}
    
    /**
     * @Author			Mohsin Wadee
     * @Company:		Barclays Africa
     * @Description:	Implements the Batchable finish method. No additional processing here.
     * @param:			None.
     * 
     * History:
     * 30-Oct-2015, Mohsin Wadee, US-0722, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/   
    global void finish(Database.BatchableContext BC)
    {
    }
}