/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 *** CHANGE LOG ***

 14/09/2017 - PG    - Created Class.
 18/08/2017 - PG 	- Added the "Before" & "After" delete logic. 
 10/10/2017 - PG 	- Removed "before delete" logic.
 					- Refactored and combined all into "updateSchedulingParties" method.

**/
public class Condition_Party_Helper 
{	
	/**
    * Variables
    **/
    public static final Map<String, RecordTypeInfo> occurrenceTypes = new Map<String, RecordTypeInfo>(Condition_Occurrence__c.sObjectType.getDescribe().getRecordTypeInfosByName());

	//After insert trigger handler.
	public static void afterInsert(List<Condition_Party__c> inputNewList)
	{
		System.debug('### Condition_Party_Helper : afterInsert');

		updateSchedulingParties(inputNewList);

		//addPartyOccurrences(inputNewList); 
	}

	//After delete trigger handler.
	public static void afterDelete(List<Condition_Party__c> inputOldList)
	{
		System.debug('### Condition_Party_Helper : afterDelete');

		updateSchedulingParties(inputOldList);

		//removePartyOccurrences(inputOldList);  
	}

	public static void updateSchedulingParties(List<Condition_Party__c> inputList)
	{
		//Blank vars.
		Set<Id> conditionIds = new Set<Id>();
		List<Condition__c> conditions = new List<Condition__c>();

		//Loop over condition parties.
		for(Condition_Party__c conditionParty : inputList)
		{
			conditionIds.add(conditionParty.Condition__c);
		}

		//Query condition records.
		conditions = [
			SELECT
				Id,
				Forced_Update__c,
				Active__c
			FROM Condition__c
			WHERE 
				Id IN :conditionIds 
				AND Active__c = true
		];

		//Set update on conditions.
		for(Condition__c condition : conditions)
		{
			condition.Forced_Update__c = DateTime.now();
		}

		//update records to reschedule with new parties.
		update conditions;
	}
}