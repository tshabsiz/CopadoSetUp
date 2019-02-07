/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 13/09/2017 - PG    - Created class.
 30/10/2017 - PG 	- Removed "with sharing".
 02/05/2018 - TdB   - Libra: Add beforeDelete to through exception for Auto created Deal Parties.

**/ 
public class Deal_Party_Helper {
	
	/**
	* Variables.
	**/
	private static final Map<String, RecordTypeInfo> CONDITION_TYPES = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 

	/**
	* After Insert Trigger Handler
	**/
	public static void afterUpdate(List<Deal_Party__c> inputNewList, Map<Id, Deal_Party__c> inputOldMap)
	{
		System.debug('### Deal_Party_Helper : afterUpdate');

		//Check if the condition monitored by has changed.
		conditionsMonitoredByChanged(inputNewList, inputOldMap);
	}
    
    /**
     * Method that checks if the deal party's deal (parent) is of type market transaction.
     * It then loops through all the added deal party relationships and checks if it already exists.
     * If it exists then an error is returned
     *
     * @param triggerNew list of new trigger instances for before insert
     */
    public static void beforeInsert(List<Deal_Party__c> triggerNew){
        advpm__Matter__c matterRecordId = new advpm__Matter__c();
        matterRecordId.RecordTypeId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Market Transaction').getRecordTypeId();
    
        advpm__Matter__c matterPrimeServicesRecordId = new advpm__Matter__c();
        matterPrimeServicesRecordId.RecordTypeId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Market Transaction - Prime Services').getRecordTypeId();
        Set<Id> dealIds = new Set<Id>();
        for(Deal_Party__c dp : triggerNew){
            dealIds.add(dp.Deal__c);
        }
        
        Map<Id, advpm__Matter__c> matters = new Map<Id, advpm__Matter__c>([select Id, RecordTypeId from advpm__Matter__c where Id in :dealIds]);
        List<Deal_Party__c> matterAgreements = [select Id, Relationship__c, Deal__c from Deal_Party__c where Deal__c in :dealIds];
        
        for(Deal_Party__c dealParty : triggerNew){
            if(matters.get(dealParty.Deal__c).RecordTypeId == matterRecordId.RecordTypeId || matters.get(dealParty.Deal__c).RecordTypeId == matterPrimeServicesRecordId.RecordTypeId){
                for (Deal_Party__c agreementRecToCheck : matterAgreements){
                    if (dealParty.Relationship__c == agreementRecToCheck.Relationship__c && dealParty.Deal__c == agreementRecToCheck.Deal__c){
                        dealParty.addError('Relationship of this type has already been added to this Deal and cannot be added again! Please select another Relationship');
                    }
                }
            }
        }
    }

	private static void conditionsMonitoredByChanged(List<Deal_Party__c> inputNewList, Map<Id, Deal_Party__c> inputOldMap)
	{
		System.debug('### Deal_Party_Helper : conditionsMonitoredByChanged');

		//Blank vars.
		Set<Id> dealPartyIds = new Set<Id>();
		List<Condition_Party__c> conditionParties = new List<Condition_Party__c>();
		Set<Id> conditionIds = new Set<Id>();
		Set<Id> includeRecordTypes = new Set<Id>();
		List<Condition__c> conditions = new List<Condition__c>();

		//Build a list of condition record type we interested in.
		for(String typeName : CONDITION_TYPES.KeySet())
		{
			if(typeName == 'General Undertaking' || typeName == 'Financial Covenant' || typeName == 'Information Undertaking')
			{
				includeRecordTypes.add(CONDITION_TYPES.get(typeName).getRecordTypeId());
			}
		}

		//Loop through input records.
		for(Deal_Party__c dealParty : inputNewList)
		{
			//Has the person changed?
			if(dealParty.Conditions_Monitored_By__c != inputOldMap.get(dealParty.Id).Conditions_Monitored_By__c)
			{
				//Add deal party to set.
				dealPartyIds.add(dealParty.Id);
			}
		}

		//Get all condition parties linked to the deal parties for specific record types and active conditions.
		conditionParties = [
			SELECT
				Id,
				Condition__c,
				Condition__r.RecordTypeId,
				Condition__r.Active__c,
				Agreement_Party__r.Deal_Party__r.Id 
			FROM Condition_Party__c
			WHERE 
				Agreement_Party__r.Deal_Party__r.Id IN :dealPartyIds 
				AND Condition__r.RecordTypeId IN :includeRecordTypes
				AND Condition__r.Active__c = true
		];

		//Have condition parties..
		if(!conditionParties.isEmpty())
		{
			//Loop through parties and build unique condition set.
			for(Condition_Party__c conditionParty : conditionParties)
			{
				//Add to set.
				conditionIds.add(conditionParty.Condition__c); 
			}

			//Have conditions to update.
			if(!conditionIds.isEmpty())
			{
				conditions = [
					SELECT 
						Id,
						Forced_Update__c
					FROM Condition__c
					WHERE
						Id IN :conditionIds
				];

				//Loop through conditions.
				for(Condition__c condition : conditions)
				{
					//Force a reschedule to user new mointoring person.
					condition.Forced_Update__c = DateTime.now(); 
				}

				System.debug('### Deal_Party_Helper : conditionsMonitoredByChanged : conditions.size() : '+conditions.size());

				for(Condition__c condition : conditions)
				{
					System.debug('### Deal_Party_Helper : conditionsMonitoredByChanged : condition id : '+condition.Id);
				}

				//Update the records to fire reschedule..
				update conditions; 
			}
		}
	}
    
    public static void beforeDelete(List<Deal_Party__c> inputNewList)
    {
        for(Deal_Party__c eachParty : inputNewList)
        {
            if(eachParty.hAuto_Created__c == True)
            {
                eachParty.AddError('You are not allowed to delete the Deal Party, please contact your Salesforce Administrator');
            }
        }
    }
}