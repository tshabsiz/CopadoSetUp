/**
 
*** CHANGE LOG ***

13/12/2017 - TdB    - Created Class. 
22/02/2018 - TdB 	- Calculate Lender Portion based on the Percentage as well. If Amount and Percentage specified, amount wins
14/03/2018 - TdB	- Move Amount and Percentage calculation before th vaidation against parent lender portion 

**/

public with sharing class Facility_Party_Helper 
{
    public static void calculateLenderPortion(List<Facility_Party__c> inputNewList, Map<Id, Facility_Party__c> inputOldMap)
    {
        //Blank vars.
        Set<Id> facilityIds = new Set<Id>();
        Set<Id> agreementPartyIds = new Set<Id>();
       // Set<Id> facilityPartyIds = new Set<Id>();
        Map<Id, Facility__c> facilityMap = new Map<Id, Facility__c>();
        Map<Id, Map<String, Decimal>> agreementPartyFacilityTotalMap = new Map<Id, Map<String, Decimal>> ();

        //Loop through Facility Parties.
        for(Facility_Party__c facilityParty : inputNewList)
        {   
            //Add to set.
            facilityIds.add(facilityParty.Facility__c);
            //facilityPartyIds.add(facilityParty.id);
            agreementPartyIds.add(facilityParty.Agreement_Party__c);
        }
        
         //Have Facilities to get.
        if(!facilityIds.isEmpty())
        {
            //Get Facilities with there Parties.
            facilityMap = new Map<Id, Facility__c>([
                SELECT
                    Id,
                    Facility_Limit__c,
                    (
                        SELECT
                            Id,
                            Facility__c,
                        	Agreement_Party__c,
                            Facility_Percentage__c,
                            Facility_Amount__c
                        FROM Facility_Parties__r
                    )
                FROM Facility__c
                WHERE
                    Id IN :facilityIds 
            ]);
        }
        
        if(!agreementPartyIds.isEmpty())
        {
            for(Facility_Party__c eachFacility : [SELECT Agreement_Party__c , Agreement_Party__r.Lender_Amount__c , Facility_Amount__c FROM Facility_Party__c WHERE Agreement_Party__c IN :agreementPartyIds])
            {
                Decimal tempAmount = 0;
                if(!agreementPartyFacilityTotalMap.containsKey(eachFacility.Agreement_Party__c))
                {
                    agreementPartyFacilityTotalMap.put(eachFacility.Agreement_Party__c, new Map<String, Decimal>());
                }
                if (agreementPartyFacilityTotalMap.containsKey(eachFacility.Agreement_Party__c))
                {
                    agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).put('AgreementPartyFacilityAmount',eachFacility.Agreement_Party__r.Lender_Amount__c );
                    if(!agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).containsKey('FacilityPartTotalAmount') && !inputOldMap.containsKey(eachFacility.id))
                    {
                        agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).put('FacilityPartTotalAmount',eachFacility.Facility_Amount__c);
                    }
                    else if(agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).containsKey('FacilityPartTotalAmount') && !inputOldMap.containsKey(eachFacility.id))
                    {
                        if(agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).get('FacilityPartTotalAmount') != null)
                        {
                            tempAmount = agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).get('FacilityPartTotalAmount');
                            agreementPartyFacilityTotalMap.get(eachFacility.Agreement_Party__c).put('FacilityPartTotalAmount',eachFacility.Facility_Amount__c + tempAmount);
                        }  
                    }
                }

            }
        }
        
        for(Facility_Party__c facilityParty : inputNewList)
        { 
            //Facility limit.
            Decimal facilityLimit = facilityMap.get(facilityParty.Facility__c).Facility_Limit__c;

            if(facilityLimit == null)
            {
                facilityParty.addError('Please ensure there is a Facility Limit specified on the Facility.');
                continue;
            }

            //Amount was updated, calculate new percentage.
            if(facilityParty.Facility_Amount__c != inputOldMap.get(facilityParty.Id).Facility_Amount__c && facilityParty.Facility_Amount__c != null && facilityLimit != 0)
            {
                facilityParty.Facility_Percentage__c = (facilityParty.Facility_Amount__c != null) ? (facilityParty.Facility_Amount__c / facilityLimit) * 100 : 0;
            }
            else if(facilityParty.Facility_Amount__c != inputOldMap.get(facilityParty.Id).Facility_Amount__c && facilityParty.Facility_Amount__c != null && facilityLimit == 0)
            {
                facilityParty.Facility_Percentage__c = 0;
            }

            //Percentage was updated, calculate new Amount.
            if(facilityParty.Facility_Percentage__c != inputOldMap.get(facilityParty.Id).Facility_Percentage__c && facilityParty.Facility_Percentage__c != null && facilityLimit != 0)
            {
                facilityParty.Facility_Amount__c = (facilityParty.Facility_Percentage__c != null) ? facilityLimit * (facilityParty.Facility_Percentage__c / 100) : 0;
            }
            else  if(facilityParty.Facility_Percentage__c != inputOldMap.get(facilityParty.Id).Facility_Percentage__c && facilityParty.Facility_Percentage__c != null && facilityLimit == 0)
            {
                facilityParty.Facility_Amount__c = 0;
            }
            
            //Validate that Lender Portion Facility Amount (multiple) on the Facility does not exceed the Lender Portion Facility Amount on the Agreement
            if(agreementPartyFacilityTotalMap.containsKey(facilityParty.Agreement_Party__c) && agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('FacilityPartTotalAmount')  != null && agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('AgreementPartyFacilityAmount') != null)
            {
				if((agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('FacilityPartTotalAmount').setScale(2) +  facilityParty.Facility_Amount__c) >  agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('AgreementPartyFacilityAmount').setScale(2)) 
                {
                    facilityParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Agreement Party Facility Amount.');
                }
            }
            else if(agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('AgreementPartyFacilityAmount') != null)
            {
                if(facilityParty.Facility_Amount__c >  agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('AgreementPartyFacilityAmount').setScale(2))
                {
                    facilityParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Agreement Party Facility Amount.');
                }  
            }
            else if (agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('AgreementPartyFacilityAmount') == null && facilityParty.Facility_Amount__c != null && facilityParty.Facility_Amount__c != 0)
            {
                facilityParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Agreement Party Facility Amount.');
            }
            else if (agreementPartyFacilityTotalMap.get(facilityParty.Agreement_Party__c).get('AgreementPartyFacilityAmount') == null && facilityParty.Facility_Percentage__c != null && facilityParty.Facility_Percentage__c != 0)
            {
                facilityParty.addError('Please ensure that the Facility Amount does not exceed the corresponding Agreement Party Facility Amount.');
            }
               
        }
    }

}