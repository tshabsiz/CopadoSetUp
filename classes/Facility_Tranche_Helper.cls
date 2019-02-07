/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

12/09/2017 - PG    - Created Class. 
13/03/2018 - TdB   - Add updateCurrencyIsoCode(); before insert and update to set Currency based on Facility Currency

**/
public with sharing class Facility_Tranche_Helper {
    
    /**
* After Insert Trigger Helper
**/
    public static void afterInsert(List<Facility_Tranche__c> inputNewList)
    {
        populateTrancheParties(inputNewList); 
    }
    
    public static void updateCurrencyIsoCode(List<Facility_Tranche__c> inputNewList)
    {
        Set<Id> facilityIds = new Set<Id>();
        Map<Id, Facility__c> facilities = new Map<Id, Facility__c>();
        for(Facility_Tranche__c tranche : inputNewList)
        {
            //Add to set.
            facilityIds.add(tranche.Facility__c);
        }
        
        if(!facilityIds.isEmpty())
        {
            facilities = new Map<Id, Facility__c>([
                    SELECT
                    Id,
                    CurrencyIsoCode
                    FROM Facility__c
                    WHERE
                    Id IN :facilityIds
                ]);
        }
        
        System.debug('facilities : ' + facilities);
   		//Get related Facility ISOCurrency
   		for(Facility_Tranche__c eachTranche : inputNewList)
        {
            System.debug('eachTranche.CurrencyIsoCode : ' + eachTranche.CurrencyIsoCode);
            System.debug('eachTranche.Facility__c : ' + eachTranche.CurrencyIsoCode);
            System.debug('facilities.get(eachTranche.Facility__c) : ' + facilities.get(eachTranche.Facility__c));
            if(facilities.containsKey(eachTranche.Facility__c))
            {
                //if(eachTranche.CurrencyIsoCode != facilities.get(eachTranche.Facility__c).CurrencyIsoCode)
                //{
                    eachTranche.CurrencyIsoCode = facilities.get(eachTranche.Facility__c).CurrencyIsoCode;
                //}
            }
        }

    }
    
    public static void populateTrancheParties(List<Facility_Tranche__c> inputNewList)
    {
        //Blank vars.
        Set<Id> facilityIds = new Set<Id>();
        Map<Id, Facility__c> facilities = new Map<Id, Facility__c>();
        List<Tranche_Party__c> trancheParties = new List<Tranche_Party__c>();
        
        for(Facility_Tranche__c tranche : inputNewList)
        {
            //Add to set.
            facilityIds.add(tranche.Facility__c);
        }
        
        //Have agreement ids.
        if(!facilityIds.isEmpty())
        {
            facilities = new Map<Id, Facility__c>([
                SELECT
                Id,
                CurrencyIsoCode,
                (
                    SELECT
                    Id,
                    Name,
                    Party_Type__c
                    FROM Facility_Parties__r
                )
                FROM Facility__c
                WHERE
                Id IN :facilityIds
            ]);
        }
        
        //We have agreements.
        if(!facilities.isEmpty())
        {
            //Loop through each facility in trigger.
            for(Facility_Tranche__c tranche : inputNewList)
            {
                //Agreement in map.
                if(facilities.containsKey(tranche.Facility__c))
                {
                    //Loop through agreement parties.
                    for(Facility_Party__c facilityParty : facilities.get(tranche.Facility__c).Facility_Parties__r)
                    {
                        //New Facility Party
                        Tranche_Party__c trancheParty = new Tranche_Party__c();
                        trancheParty.Facility_Tranche__c = tranche.Id;
                        trancheParty.Facility_Party__c =  facilityParty.Id;
                        trancheParty.Name = facilityParty.Name;
                        
                        //Add to insert list.
                        trancheParties.add(trancheParty);
                    }
                }
            }
        }
        
        //Have any tranche parties to insert.
        if(!trancheParties.isEmpty())
        {
            insert trancheParties;
        }
    }
    
    public static void updateWatcherOccurence(Map<Id,Facility_Tranche__c> facilityTrancheOldMap, Map<Id,Facility_Tranche__c> facilityTrancheNewMap)
    {
        Set<Id> tranchesDateChanged = new Set<Id>();
        List<Margin_Ratchet__c> marginRatchetUpdateList = new List<Margin_Ratchet__c>();
        Margin_Ratchet__c marginRatchetItem ;  
        
        //Add all changed facilities to set
        for(Id eachFacilityTranche : facilityTrancheNewMap.keySet())
        {
            //Start Date change
            if(facilityTrancheNewMap.get(eachFacilityTranche).Availability_Start_Date__c != facilityTrancheOldMap.get(eachFacilityTranche).Availability_Start_Date__c)
            { 
                //Add Tranche Id to List to Query watcher to change
                tranchesDateChanged.add(eachFacilityTranche);
            }
            if(facilityTrancheNewMap.get(eachFacilityTranche).Signature_Date__c != facilityTrancheOldMap.get(eachFacilityTranche).Signature_Date__c)
            {
            	//Add Tranche Id to List to Query watcher to change
                tranchesDateChanged.add(eachFacilityTranche);
            }
                
           //End Date change
            if(facilityTrancheNewMap.get(eachFacilityTranche).Availability_End_Date__c != facilityTrancheOldMap.get(eachFacilityTranche).Availability_End_Date__c)
            {
                //Add Tranche Id to List to Query watcher to change
                tranchesDateChanged.add(eachFacilityTranche);
            } 
        }
        
        //Get all Margin Ratchet link to the Tranches
        for(Margin_Ratchet__c eachMarginRatchet : [SELECT Id, Facility_Tranche__c, Start_Date_End_Date_Changed__c
                                              FROM Margin_Ratchet__c 
                                             WHERE Facility_Tranche__c IN :tranchesDateChanged ])
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