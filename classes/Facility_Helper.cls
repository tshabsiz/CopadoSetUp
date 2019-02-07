/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 12/09/2017 - PG    - Created Class. 
 13/03/2018 - TdB   - Add updateTrancheCurrencyIsoCode(); - Update related Tranches with updated Currency

**/
public class Facility_Helper 
{

	/**
	* After Insert Trigger Handler.
	**/
	public static void afterInsert(List<Facility__c> inputNewList)
	{
		populateFacilityParties(inputNewList);
	}
    
    public static void updateTrancheCurrencyIsoCode(List<Facility__c> inputNewList)
    {
        List<Facility_Tranche__c> updateTrancheList = new List<Facility_Tranche__c>();
        for(Facility_Tranche__c eachTranche : [Select id , Facility__r.CurrencyIsoCode, CurrencyIsoCode
                                              FROM Facility_Tranche__c 
                                              WHERE Facility__c IN :inputNewList])
        {
            System.debug('eachTranche.CurrencyIsoCode : ' + eachTranche.CurrencyIsoCode);
            System.debug('eachTranche.Facility__r.CurrencyIsoCode : ' + eachTranche.Facility__r.CurrencyIsoCode);
            if(eachTranche.CurrencyIsoCode != eachTranche.Facility__r.CurrencyIsoCode)
            {
                eachTranche.CurrencyIsoCode = eachTranche.Facility__r.CurrencyIsoCode;
                updateTrancheList.add(eachTranche);
            }
        }
        
        if(!updateTrancheList.isEmpty()) 
        {
            Database.SaveResult[] srList = Database.Update(updateTrancheList, false);

        }

    }
    

	public static void populateFacilityParties(List<Facility__c> inputNewList)
	{
		//Blank vars.
		Set<Id> agreementIds = new Set<Id>();
		Map<Id, Agreement__c> agreements = new Map<Id, Agreement__c>();
		List<Facility_Party__c> facilityParties = new List<Facility_Party__c>();

		for(Facility__c facility : inputNewList)
		{
			//Add to set.
			agreementIds.add(facility.Agreement__c);
		}

		//Have agreement ids.
		if(!agreementIds.isEmpty())
		{
			agreements = new Map<Id, Agreement__c>([
				SELECT
					Id,
					(
						SELECT
							Id,
							Name,
							Party_Type__c
						FROM Agreement_Parties__r
					)
				FROM Agreement__c
				WHERE
					Id IN :agreementIds
			]);
		}

		//We have agreements.
		if(!agreements.isEmpty())
		{
			//Loop through each facility in trigger.
			for(Facility__c facility : inputNewList)
			{
				//Agreement in map.
				if(agreements.containsKey(facility.Agreement__c))
				{
					//Loop through agreement parties.
					for(Agreement_Party__c agreementParty : agreements.get(facility.Agreement__c).Agreement_Parties__r)
					{
						//New Facility Party
						Facility_Party__c facilityParty = new Facility_Party__c();
						facilityParty.Facility__c = facility.Id;
						facilityParty.Agreement_Party__c =  agreementParty.Id;
						facilityParty.Name = agreementParty.Name;

						//Add to insert list.
						facilityParties.add(facilityParty);
					}
				}
			}
		}

		//Have any facility parties to insert.
		if(!facilityParties.isEmpty())
		{
			insert facilityParties;
		}
	}	
    
    public static void updateWatcherOccurence(Map<Id,Facility__c> facilityOldMap, Map<Id,Facility__c> facilityNewMap)
    {
        Set<Id> facilityDateChanged = new Set<Id>();
        List<Margin_Ratchet__c> marginRatchetUpdateList = new List<Margin_Ratchet__c>();
        Margin_Ratchet__c marginRatchetItem ;  
        
        //Add all changed facilities to set
        for(Id eachFacility : facilityNewMap.keySet())
        {
            //Start Date change 
            if(facilityNewMap.get(eachFacility).Availability_Start_Date__c != facilityOldMap.get(eachFacility).Availability_Start_Date__c)
            {
                //Add Tranche Id to List to Query watcher to change
                facilityDateChanged.add(eachFacility);
            }
            if(facilityNewMap.get(eachFacility).Signature_Date__c != facilityOldMap.get(eachFacility).Signature_Date__c)
            {
            	//Add Tranche Id to List to Query watcher to change
                facilityDateChanged.add(eachFacility);
            }
                
           //End Date change
            if(facilityNewMap.get(eachFacility).Availability_End_Date__c != facilityOldMap.get(eachFacility).Availability_End_Date__c)
            {
                //Add Tranche Id to List to Query watcher to change
                facilityDateChanged.add(eachFacility);
            } 
        }
        
        //Get all Margin Ratchet link to the Tranches
        for(Margin_Ratchet__c eachMarginRatchet : [SELECT Id, Facility__c, Start_Date_End_Date_Changed__c
                                              FROM Margin_Ratchet__c 
                                             WHERE Facility__c IN :facilityDateChanged ])
        {
			marginRatchetItem = new Margin_Ratchet__c();
            marginRatchetItem.Id = eachMarginRatchet.id;
            marginRatchetItem.Start_Date_End_Date_Changed__c = True;
            
            marginRatchetUpdateList.add(marginRatchetItem);
        }
        
        if(marginRatchetUpdateList.size() > 0) 
        {
            update marginRatchetUpdateList;
        }
    }
}