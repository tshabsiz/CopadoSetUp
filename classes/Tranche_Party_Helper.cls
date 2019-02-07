/**
 
*** CHANGE LOG ***

13/12/2017 - TdB    - Created Class. 
22/02/2018 - TdB 	- Calculate Lender Portion based on the Percentage as well. If Amount and Percentage specified, amount wins
14/03/2018 - TdB	- Move Amount and Percentage calculation before th vaidation against parent lender portion 

**/
public with sharing class Tranche_Party_Helper 
{
	public static void calculateLenderPortion(List<Tranche_Party__c> inputNewList, Map<Id, Tranche_Party__c> inputOldMap)
    {
        //Blank vars.
        Set<Id> facilityTrancheIds = new Set<Id>();
        Set<Id> facilityPartyIds = new Set<Id>();
        Set<Id> tranchePartyIds = new Set<Id>();
        Map<Id, Facility_Tranche__c> facilityTrancheMap = new Map<Id, Facility_Tranche__c>();
        Map<Id, Map<String, Decimal>> facilityPartyFacilityTotalMap = new Map<Id, Map<String, Decimal>> ();

        //Loop through Tranche Parties.
        for(Tranche_Party__c trancheParty : inputNewList)
        {   
            //Add to set.
            facilityTrancheIds.add(trancheParty.Facility_Tranche__c);
            tranchePartyIds.add(trancheParty.Id);
            facilityPartyIds.add(trancheParty.Facility_Party__c);
        }
        
         //Have agreements to get.
        if(!facilityTrancheIds.isEmpty())
        {
            //Get agreements with there Parties.
            facilityTrancheMap = new Map<Id, Facility_Tranche__c>([
                SELECT
                    Id,
                    Tranche_Limit__c,
                    (
                        SELECT
                            Id,
                            Facility_Tranche__c,
                            Facility_Percentage__c,
                            Facility_Amount__c
                        FROM Tranche_Parties__r
                    )
                FROM Facility_Tranche__c
                WHERE
                    Id IN :facilityTrancheIds 
            ]);
        }
        
         if(!facilityPartyIds.isEmpty())
        {
            for(Tranche_Party__c eachTrancheParty : [SELECT Facility_Party__c , Facility_Party__r.Facility_Amount__c , Facility_Amount__c FROM Tranche_Party__c WHERE Facility_Party__c IN : facilityPartyIds])
            {
                Decimal tempAmount = 0;
                if(!facilityPartyFacilityTotalMap.containsKey(eachTrancheParty.Facility_Party__c))
                {
                    facilityPartyFacilityTotalMap.put(eachTrancheParty.Facility_Party__c, new Map<String, Decimal>());
                }
                if (facilityPartyFacilityTotalMap.containsKey(eachTrancheParty.Facility_Party__c))
                {
                    facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).put('FacilityPartyFacilityAmount',eachTrancheParty.Facility_Party__r.Facility_Amount__c );
                    if(!facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).containsKey('TranchePartyTotalAmount') && !inputOldMap.containsKey(eachTrancheParty.id))
                    {
                        facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).put('TranchePartyTotalAmount',eachTrancheParty.Facility_Amount__c);
                    }
                    else if(facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).containsKey('TranchePartyTotalAmount') && !inputOldMap.containsKey(eachTrancheParty.id))
                    {
                        if(facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).get('TranchePartyTotalAmount') != null)
                        {
                            tempAmount = facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).get('TranchePartyTotalAmount');
                        	facilityPartyFacilityTotalMap.get(eachTrancheParty.Facility_Party__c).put('TranchePartyTotalAmount',eachTrancheParty.Facility_Amount__c + tempAmount);
                        }
                    }
                }
                
            }
        }
        
        for(Tranche_Party__c trancheParty : inputNewList)
        { 
            //Facility Tranche limit.
            Decimal facilityTrancheLimit = facilityTrancheMap.get(trancheParty.Facility_Tranche__c).Tranche_Limit__c;

            if(facilityTrancheLimit == null)
            {
                trancheParty.addError('Please ensure there is a Facility Limit specified on the Facility Tranche.');
                continue;
            }
            
            
            //Amount was updated, calculate new percentage.
            if(trancheParty.Facility_Amount__c != inputOldMap.get(trancheParty.Id).Facility_Amount__c && trancheParty.Facility_Amount__c != null && facilityTrancheLimit != 0)
            {
                trancheParty.Facility_Percentage__c = (trancheParty.Facility_Amount__c != null) ? (trancheParty.Facility_Amount__c / facilityTrancheLimit) * 100 : 0;
            }
            else if(trancheParty.Facility_Amount__c != inputOldMap.get(trancheParty.Id).Facility_Amount__c && trancheParty.Facility_Amount__c != null && facilityTrancheLimit == 0)
            {
                trancheParty.Facility_Percentage__c = 0;
            }

            //Amount was updated, calculate new percentage.
            if(trancheParty.Facility_Percentage__c != inputOldMap.get(trancheParty.Id).Facility_Percentage__c && trancheParty.Facility_Percentage__c != null && facilityTrancheLimit != 0)
            {
                trancheParty.Facility_Amount__c = (trancheParty.Facility_Percentage__c != null) ? facilityTrancheLimit * (trancheParty.Facility_Percentage__c / 100) : 0;
            }
            else  if(trancheParty.Facility_Percentage__c != inputOldMap.get(trancheParty.Id).Facility_Percentage__c && trancheParty.Facility_Percentage__c != null && facilityTrancheLimit == 0)
            {
                trancheParty.Facility_Amount__c = 0;
            }
            
            //Validate that Lender Portion Facility Amount (multiple) on the Facility does not exceed the Lender Portion Facility Amount on the Agreement
            if(facilityPartyFacilityTotalMap.containsKey(trancheParty.Facility_Party__c) && facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('FacilityPartyFacilityAmount') != null && facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('TranchePartyTotalAmount') != null) 
            {
                if((facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('TranchePartyTotalAmount').setScale(2) + trancheParty.Facility_Amount__c) >  facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('FacilityPartyFacilityAmount').setScale(2))
                {
                    trancheParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Facility Party Facility Amount.');
                }
            }
            else if (facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('FacilityPartyFacilityAmount') != null)
            {
                if(trancheParty.Facility_Amount__c > facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('FacilityPartyFacilityAmount').setScale(2))
                {
                    trancheParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Facility Party Facility Amount.');
                }    
            }
            else if (facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('FacilityPartyFacilityAmount') == null && trancheParty.Facility_Amount__c != null && trancheParty.Facility_Amount__c != 0) 
            {
                trancheParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Facility Party Facility Amount.');
            }
            else if (facilityPartyFacilityTotalMap.get(trancheParty.Facility_Party__c).get('FacilityPartyFacilityAmount') == null && trancheParty.Facility_Percentage__c != null && trancheParty.Facility_Percentage__c != 0) 
            {
                trancheParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Facility Party Facility Amount.');
            }
            
        }
    }
}