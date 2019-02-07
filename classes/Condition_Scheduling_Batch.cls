/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 24/09/2017 - PG    - Created class.

**/  
global class Condition_Scheduling_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	public Integer totalRecordProcessed = 0; 
	global List<String> exceptionList = new List<String>();
	
	global Condition_Scheduling_Batch() { 
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		//Query for all active conditions.
		query = 'SELECT Id, Active__c, Forced_Update__c FROM Condition__c WHERE Active__c = true'; 
		return Database.getQueryLocator(query);
	}
 
   	global void execute(Database.BatchableContext BC, List<Condition__c> scope) 
   	{
		//Loop over records in scope
		for(Condition__c condition : scope)
		{
			//Force reschedule.
			condition.Forced_Update__c = DateTime.now();  
		}

		//update records
		Database.SaveResult[] SaveResultList = Database.update(scope, false);

		//Loop through results.
		for(integer i =0; i < scope.size(); i++)
		{
			//Clear msg.
			String msg = '';

			if(!SaveResultList[i].isSuccess())
			{   
                for(Database.Error error : SaveResultList[i].getErrors())
                {  
                     msg += 'Condition Id : '+scope[i].Id+' : Msg : '+error.getMessage()+'\n\n'; 
                } 
       		}

       		if(msg != '')
       		{
       			exceptionList.add(msg);
       		}
		}
	}
	
	global void finish(Database.BatchableContext BC)   
	{	

		//Get job details.
		AsyncApexJob jobDetails = [SELECT Id, ApexClass.Name, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

		//Send Email.
		Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[]{'peter@cloudsmiths.co.za', 'tshidi@cloudsmiths.co.za'};
		emailMessage.setToAddresses(toAddresses);
		emailMessage.setSubject('Daily Condition Scheduling Batch Job');

		String messageBody = 'The batch Apex job ('+jobDetails.ApexClass.Name+') processed ' + jobDetails.TotalJobItems+' batches with '+ jobDetails.NumberOfErrors + ' failures.';

		for(String error : exceptionList) 
		{
			messageBody += error+'\n';
		}

		emailMessage.setPlainTextBody(messageBody);
		Messaging.sendEmail(new Messaging.singleEmailMessage[]{emailMessage}); 
	}	
}