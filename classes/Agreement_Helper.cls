/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
*** CHANGE LOG ***
 
 17/08/2017 - PG     - Created Class.
 16/02/2018 - TdB    - Add functionality to insert conditions based on template (only after insert)
 22/02/2018 - TdB    - Add functionality to insert conditions Parties
 13/03/2018 - TdB	 - Add deactivateConditions to deactivate condition if Agreement is Extension
 06/04/2018 - TdB  - Libra: Populate Agreement Template based on Agreement Type and Agreement Version

**/
public class Agreement_Helper 
{
	/**
	* Variables.
	**/
	public static Map <String, Schema.RecordTypeInfo> agreementTypes = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static final Map<Id, RecordTypeInfo> TEMPLATE_TYPE_IDS = new Map<Id, RecordTypeInfo>(Condition_Template__c.sObjectType.getDescribe().getRecordTypeInfosById());
    private static final Map<String, RecordTypeInfo> CONDITION_TYPES = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 

	/**
	* Before Insert trigger handler.
	**/
	public static void afterInsert(List<Agreement__c> inputNewList)
	{
		//Blank variables.
		Set<Id> matterIds = new Set<Id>();
		Map<Id, advpm__Matter__c> matters = new Map<Id, advpm__Matter__c>();
		List<Agreement_Party__c> agreementParties = new List<Agreement_Party__c>();
        List<Agreement_Condition__c> agreementConditions = new List<Agreement_Condition__c>();
        List<Condition__c> conditionsToInsert = new List<Condition__c>();
        Set<Id> agreementTemplateIds = new Set<Id>();
        List<Condition_Party__c> conditionPartiesToInsert = new List<Condition_Party__c>();

		//Loop through inserted agreements.
		for(Agreement__c agreement : inputNewList)
		{
			//Make sure it was not created from the library.
			if(agreement.RecordTypeId == agreementTypes.get('Agreement').getRecordTypeId() && agreement.Agreement_Added_From_Libary__c == False && agreement.Matter_Deal__c != null)
			{
				//Add matter ids to set.
				matterIds.add(agreement.Matter_Deal__c); 
			}
            
            if(agreement.Agreement_Template__c != null)
            {
                agreementTemplateIds.add(agreement.Agreement_Template__c);
            }
		}

		//Any matters to process?
		if(!matterIds.isEmpty())
		{
			//Get matters and deal parties for them.
			matters = new Map<Id, advpm__Matter__c>([
				SELECT
					Id,
					(
						SELECT 
							Id,
							Deal__c,
							Relationship__c,
							Conditions_Monitored_By__c
						FROM Deal_Parties__r
					)
				FROM advpm__Matter__c
				WHERE 
					Id IN :matterIds
			]);

			//Loop through inserted agreements.
			for(Agreement__c agreement : inputNewList)
			{
				//Agreement matter record.
				advpm__Matter__c matter = matters.get(agreement.Matter_Deal__c);

				if(matter.Deal_Parties__r.size() > 0)
				{
					//Loop over the matters deal parties
					for(Deal_Party__c dealParty : matter.Deal_Parties__r)
					{
						//New agreement party.
						Agreement_Party__c agreementParty = new Agreement_Party__c();
						agreementParty.Agreement__c = agreement.Id;
						agreementParty.Deal_Party__c = dealParty.Id;

						//Add to insert list.
						agreementParties.add(agreementParty);
					}
				}
			}

			//Any agreement parties to insert.
			if(!agreementParties.isEmpty())
			{
				insert agreementParties;
			}
		}		
        
        
        //Insert Conditions - Exclude CP/IU/Fc if Hotdoc Template Id assigned
        //					- Include GC even if Hotdoc Template Id assigned
        
        //Get a list of all condition templates for the agreements templates used.
        agreementConditions = [
            SELECT
            Id,
            Name,
            Agreement_Template__c,
            Agreement_Template__r.HotDocs_Template_ID__c,
            Agreement_Template__r.Clause_Origin__c,
            Condition_Template__c,
            Condition_Template__r.Name,
            Condition_Template__r.Recurrence__c,
            Condition_Template__r.Date__c,
            Condition_Template__r.Number_of_Days__c,
            Condition_Template__r.Days__c,
            Condition_Template__r.Clause__c,
            Condition_Template__r.RecordTypeId
            FROM Agreement_Condition__c
            WHERE 
            Agreement_Template__c IN :agreementTemplateIds
            ORDER BY 
            Condition_Template__r.RecordType.Name
        ];
        
        //Loop through each agreement and determine which conditions belong to it.
        for(Agreement__c agreement : inputNewList)
        {
            //Loop through each agreement conditions  
            for(Agreement_Condition__c agreementCondition : agreementConditions)
            {                        
                if(agreementCondition.Agreement_Template__c == agreement.Agreement_Template__c && agreement.Agreement_Added_From_Libary__c == False)
                {
                    //New condition object.
                    Condition__c condition          = new Condition__c();
                    condition.Agreement__c          = agreement.Id;
                    condition.Matter__c             = agreement.Matter_Deal__c;
                    
                    //Detemine condition record type id based in condition template record type name
                    String conditionTemplateRecordTypeName = TEMPLATE_TYPE_IDS.get(agreementCondition.Condition_Template__r.RecordTypeId).getName();
                    
                    condition.RecordTypeId          = CONDITION_TYPES.get(conditionTemplateRecordTypeName).getRecordTypeId();
                    
                    //Other template fields.
                    condition.Name                  = agreementCondition.Condition_Template__r.Name;
                    condition.Clause__c             = agreementCondition.Condition_Template__r.Clause__c;
                    condition.Condition_Template__c = agreementCondition.Condition_Template__c;
                    condition.Active__c             = false;
                    
                    //Override template schedule values incase data is bad in Templates.
                    if(conditionTemplateRecordTypeName == 'Condition Precedent' || conditionTemplateRecordTypeName == 'Governance Check') {
                        condition.Recurrence__c         = null; 
                        condition.Date__c               = null;
                        condition.Number_of_Days__c     = null;
                        condition.Days__c               = null;
                    }
                    else {
                        condition.Recurrence__c         = agreementCondition.Condition_Template__r.Recurrence__c;
                        condition.Date__c               = agreementCondition.Condition_Template__r.Date__c;
                        condition.Number_of_Days__c     = agreementCondition.Condition_Template__r.Number_of_Days__c;
                        condition.Days__c               = agreementCondition.Condition_Template__r.Days__c;
                    }
                    

                    if((agreementCondition.Agreement_Template__r.HotDocs_Template_ID__c == null && (agreementCondition.Agreement_Template__r.Clause_Origin__c == null || agreementCondition.Agreement_Template__r.Clause_Origin__c == 'Salesforce')) || (agreementCondition.Agreement_Template__r.HotDocs_Template_ID__c != null && condition.RecordTypeId == CONDITION_TYPES.get('Governance Check').getRecordTypeId()))
                    {
                        //Add condition object to insert list.
                        conditionsToInsert.add(condition);
                    }
                }
            }
        }
        
        //Insert condition records.
        if(!conditionsToInsert.isEmpty()) {
            insert conditionsToInsert;
        }
        
        //Logic to build up the condition parties to be inserted,
        for(Condition__c conditionToInsert : conditionsToInsert)
        {
            //Loop throuhg agreement paries.
            for(Agreement_Party__c agreementPartyToInsert : agreementParties)
            {
                if(conditionToInsert.Agreement__c == agreementPartyToInsert.Agreement__c)
                {
                    //New Condition Party Object
                    Condition_Party__c conditionParty = new Condition_Party__c();
                    conditionParty.Agreement_Party__c = agreementPartyToInsert.Id;
                    conditionParty.Condition__c = conditionToInsert.Id;
                    
                    //Add to list
                    conditionPartiesToInsert.add(conditionParty);
                }
            }
        }
        
        //Make sure we have something to insert.
        if(!conditionPartiesToInsert.isEmpty())
        {
            insert conditionPartiesToInsert;
        }
                
    }
    
    public static void deactivateConditions(Set<Id> inputNewList)
    {
        List<Condition__c> deactivateConditionList = new List<Condition__c>();
        for(Condition__c eachCondition : [SELECT Id, Active__c, Agreement__c 
               FROM Condition__c
               WHERE Agreement__c IN : inputNewList
                                         AND Active__c = TRUE])
        {
            eachCondition.Active__c = FALSE;
            deactivateConditionList.add(eachCondition);
        }
        
        Database.SaveResult[] drList = Database.Update(deactivateConditionList, false);

    }
    
    public static void updateWatcherOccurence(Map<Id,Agreement__c> agreementOldMap, Map<Id,Agreement__c> agreementNewMap)
    {
        Set<Id> agreementDateChanged = new Set<Id>();
        List<Margin_Ratchet__c> marginRatchetUpdateList = new List<Margin_Ratchet__c>();
        Margin_Ratchet__c marginRatchetItem ;  
        List<Collateral_Valuation__c> collateralValuationUpdateList = new List<Collateral_Valuation__c>();
        Collateral_Valuation__c collateralValuationItem ;  
         List<Collateral_Monitoring__c> collateralMonitoringUpdateList = new List<Collateral_Monitoring__c>();
        Collateral_Monitoring__c collateralMonitoringItem ;  
        
        //Add all changed facilities to set
        for(Id eachAgreement : agreementNewMap.keySet())
        {
            //Start Date change 
            if(agreementNewMap.get(eachAgreement).Effective_Date__c != agreementOldMap.get(eachAgreement).Effective_Date__c)
            {
                //Add Tranche Id to List to Query watcher to change
                agreementDateChanged.add(eachAgreement);
            }
            if(agreementNewMap.get(eachAgreement).Signature_Date__c != agreementOldMap.get(eachAgreement).Signature_Date__c)
            {
            	//Add Tranche Id to List to Query watcher to change
                agreementDateChanged.add(eachAgreement);
            }
                
           //End Date change
            if(agreementNewMap.get(eachAgreement).Termination_Date__c != agreementOldMap.get(eachAgreement).Termination_Date__c)
            {
                //Add Tranche Id to List to Query watcher to change
                agreementDateChanged.add(eachAgreement);
            } 
        }
        
        //Get all Margin Ratchet link to the Agreement
        for(Margin_Ratchet__c eachMarginRatchet : [SELECT Id, Agreement__c, Start_Date_End_Date_Changed__c
                                              FROM Margin_Ratchet__c 
                                             WHERE Agreement__c IN :agreementDateChanged
                                                  AND Relative_Date__c != 'Other'])
        {
			marginRatchetItem = new Margin_Ratchet__c();
            marginRatchetItem.Id = eachMarginRatchet.id;
            marginRatchetItem.Start_Date_End_Date_Changed__c = true;
            
            marginRatchetUpdateList.add(marginRatchetItem);
        }
        
        if(marginRatchetUpdateList.size() > 0) {
            update marginRatchetUpdateList;
        }
        
        //Get all Collateral Monitoring linked to Agreement
        for(Collateral_Monitoring__c eachCollateralMonitoring : [SELECT Id, Agreement__c, Start_Date_End_Date_Changed__c
                                              FROM Collateral_Monitoring__c 
                                             WHERE Agreement__c IN :agreementDateChanged
                                                  AND Relative_Date__c != 'Other'])
        {
			collateralMonitoringItem = new Collateral_Monitoring__c();
            collateralMonitoringItem.Id = eachCollateralMonitoring.id;
            collateralMonitoringItem.Start_Date_End_Date_Changed__c = True;
            
            collateralMonitoringUpdateList.add(collateralMonitoringItem);
        }
        
        if(collateralMonitoringUpdateList.size() > 0)
        {
            update collateralMonitoringUpdateList;
        }
    }
    
    public static void agreementTemplateAssignment(List<Agreement__c> inputNewList)
    {
        Map<String, Id> agreementTemplateMap = new Map<String, Id>();
        
        //Agreement Template - Master Record Type Id
        Id masterAgreementTemplateRecTypeId = Schema.SObjectType.Agreement_Template__c.getRecordTypeInfosByName().get('Agreement Template - Master').getRecordTypeId();

        //Get all "Agreement Template - Master" Agreement Templates based on Master Agreemnt Version and Record Type
        //Key = Agreement Type + Template Version
        //Value = Agreement Template Id
        for(Agreement_Template__c eachAgreementTemplate : [SELECT Id, Name, RecordTypeId, Agreement_Type__c, Template_Version__c 
                                                           FROM Agreement_Template__c
                                                           WHERE RecordTypeId = :masterAgreementTemplateRecTypeId
                                                          ])
        {
            agreementTemplateMap.put(eachAgreementTemplate.Agreement_Type__c + '###' + eachAgreementTemplate.Template_Version__c, eachAgreementTemplate.Id);
        }
        
        //Loop through Agreement and assign Agreement Template (if any) based on Agreement Type and Version
        for(Agreement__c eachAgreement : inputNewList)
        {
            if(eachAgreement.Master_Agreement_Type__c != null && eachAgreement.Master_Agreement_Version__c != null)
            {
                if(agreementTemplateMap.containsKey(eachAgreement.Master_Agreement_Type__c + '###' + eachAgreement.Master_Agreement_Version__c))
                {
                    eachAgreement.Agreement_Template__c = agreementTemplateMap.get(eachAgreement.Master_Agreement_Type__c + '###' + eachAgreement.Master_Agreement_Version__c);
                }
            }
        }
    }
    
    public static void defaultClauses(List<Agreement__c> triggerNew){
        List<Clause__c> GMRAclauses = [SELECT id FROM Clause__c WHERE GMRA_Default__c = true];
        List<Clause__c> GMSLAclauses = [SELECT id FROM Clause__c WHERE GMSLA_Default__c = true];
        
        for(Agreement__c ag : triggerNew)
        {
            //Add all default GMRA's to Agreement_Clause__c - i.e. link default clauses to agreement
            if(ag.RecordTypeId == agreementTypes.get('GMRA Agreement').getRecordTypeId()){
                
                List<Agreement_Clause__c> agreementClauses = new List<Agreement_Clause__c>();
                for(Clause__c cl : GMRAclauses) {
                    Agreement_Clause__c ac = new Agreement_Clause__c();
                    ac.Agreement__c = ag.id;
                    ac.Clause__c = cl.id;
                    agreementClauses.add(ac);
                }
                insert agreementClauses;
            }
            //Add all default GMSLA's to Agreement_Clause__c - i.e. link default clauses to agreement
            else if(ag.RecordTypeId == agreementTypes.get('GMSLA Agreement').getRecordTypeId()){
                List<Agreement_Clause__c> agreementClauses = new List<Agreement_Clause__c>();
                for(Clause__c cl : GMSLAclauses){
                    Agreement_Clause__c ac = new Agreement_Clause__c();
                    ac.Agreement__c = ag.id;
                    ac.Clause__c = cl.id;
                    agreementClauses.add(ac);
                }
                insert agreementClauses;
            }
        }
    }
}