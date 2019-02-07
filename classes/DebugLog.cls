/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 08/11/2017 - PG    - Created Class. 
 15/11/2017 - PG 	- Added error overload for additional reference field on log.
 23/11.2017 - PG 	- Added stack trace limit of 255 characters.
 					- Added "Info" class.

**/ 
global class DebugLog 
{
	public static void create(Log iLog)
	{
		Custom_Log__c logEntry = new Custom_Log__c();
		logEntry.Message__c = iLog.logMessage;
		logEntry.Trace__c = iLog.logTrace;
		logEntry.User__c = UserInfo.getUserId(); 
		logEntry.Class__c = iLog.logClass; 
		logEntry.Method__c  = iLog.logMethod; 
		logEntry.Type__c  = iLog.logType; 
		logEntry.Reference__c = iLog.logReference; 

		//Check if we can do "future" insert.
		if(Limits.getLimitFutureCalls() > 0 && System.isFuture() == false) 
		{
			createFuture(JSON.serialize(logEntry));
		}
		else
		{
			insert logEntry; 
		}
	}

	@future
	public static void createFuture(String iSerialisedLog)
	{
		Custom_Log__c logEntry = (Custom_Log__c)JSON.deserialize(iSerialisedLog, Custom_Log__c.class);
		insert logEntry;
	}

	public virtual class Log
	{
		public String logType;
		public String logMessage;
		public String logTrace;
		public String logClass;
		public String logMethod;
		public String logReference;
	}

	public class Error extends Log
	{
		public Error(Exception e, String iClass, String iMethod) 
		{
			this.logType = 'ERROR';
			this.logMessage = e.getMessage();
			this.logTrace = e.getStackTraceString().left(255);
			this.logClass = iClass;
			this.logMethod = iMethod;
			this.logReference = '';
		}

		public Error(Exception e, String iClass, String iMethod, String iReference)
		{
			this.logType = 'ERROR';
			this.logMessage = e.getMessage();
			this.logTrace = e.getStackTraceString().left(255);
			this.logClass = iClass;
			this.logMethod = iMethod;
			this.logReference = iReference;
		}
	}

	public class Info extends Log
	{
		public Info(String iMessage, String iClass, String iMethod)
		{
			this.logType = 'INFO';
			this.logMessage = iMessage.left(255);
			this.logTrace = 'None';
			this.logClass = iClass;
			this.logMethod = iMethod;
			this.logReference = '';
		}

		public Info(String iMessage, String iClass, String iMethod, String iReference)
		{
			this.logType = 'INFO';
			this.logMessage = iMessage.left(255);
			this.logTrace = 'None';
			this.logClass = iClass;
			this.logMethod = iMethod;
			this.logReference = iReference;
		}
	}
}