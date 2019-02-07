/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 18/06/2017 - PG    - Created Trigger. 
 24/08/2017 - PG    - Added "beforeUpdate" method.
                    - Added "calculateLimits" methods to update the percentage and amounts.
 09/11/2017 - TdB   - API Name change. Facility_Limit__c  to Limit__c on Agreements Object
 14/11/2017 - TdB   - Make sure that lowest Parent Limit (Agreement/Facility/Tranche) is not exceeded when creating a Drawdown
 12/12/2017 - PG    - Updated calculateLimits method to handle null values.
 21/02/2018 - TdB   - Set lender portion to 0 if Agreement limit is 0
 12/03/2018 - TdB   - Agreement Limit optional (prevent Users from creating Drawdown and Agency with no Agreement Limit) 
**/ 
public class Agreement_Party_Helper {
    
    /**
    * beforeInsert trigger handler.
    **/
    public static void beforeInsert(List<Agreement_Party__c> inputNewList) 
    {
        //Blank Variables
        Set<Id> dealPartyIds = new Set<Id>();
        Map<Id, Deal_Party__c>  dealParties = new Map<Id, Deal_Party__c>();

        //Loop; through agreements.
        for(Agreement_Party__c agreementParty : inputNewList)
        {
            dealPartyIds.add(agreementParty.Deal_Party__c);
        }

        //Get all the relevant deal parties.
        dealParties = new Map<Id, Deal_Party__c>([
            SELECT 
                Id,
                Relationship__c,
                Relationship__r.Name
            FROM Deal_Party__c
            WHERE
                Id IN :dealPartyIds
        ]); 

        //Update the agreement party record name.
        for(Agreement_Party__c agreementParty : inputNewList)
        {
            agreementParty.Name = dealParties.get(agreementParty.Deal_Party__c).Relationship__r.Name; 
        }
    }

    /**
    * beforeUpdate trigger handler.
    **/
    public static void beforeUpdate(List<Agreement_Party__c> inputNewList, Map<Id, Agreement_Party__c> inputOldMap)
    {
        calculateLimits(inputNewList, inputOldMap);
    }

    /**
    * calculateLimits - Sets the percentage or amount.  Depending on the what was modified.
    **/
    public static void calculateLimits(List<Agreement_Party__c> inputNewList, Map<Id, Agreement_Party__c> inputOldMap)
    {
        //Blank vars.
        Set<Id> agreementIds = new Set<Id>();
        Map<Id, Agreement__c> agreements = new Map<Id, Agreement__c>();

        //Loop through agreement parties.
        for(Agreement_Party__c agreementParty : inputNewList)
        {   
            //Add to set.
            agreementIds.add(agreementParty.Agreement__c);
        }

        //Have agreements to get.
        if(!agreementIds.isEmpty())
        {
            //Get agreements with there Parties.
            agreements = new Map<Id, Agreement__c>([
                SELECT
                    Id,
                    Limit__c,
                    (
                        SELECT
                            Id,
                            Agreement__c,
                            Lender_Percentage__c,
                            Lender_Amount__c
                        FROM Agreement_Parties__r
                    )
                FROM Agreement__c
                WHERE
                    Id IN :agreementIds 
            ]);
        }

        //Loop through agreement parties again to set the values for update.
        for(Agreement_Party__c agreementParty : inputNewList)
        {   
            //Agreements facility limit.
            Decimal agreementFacilityLimit = agreements.get(agreementParty.Agreement__c).Limit__c;

            /*if(agreementFacilityLimit == null)
            {
                agreementParty.addError('Please ensure there is a "Limit" specified on the Agreement.');
                continue;
            }*/


            //Amount was updated, calculate new percentage.
            if(agreementParty.Lender_Amount__c != inputOldMap.get(agreementParty.Id).Lender_Amount__c && agreementParty.Lender_Amount__c != null && agreementFacilityLimit != 0 && agreementFacilityLimit != null)
            {
                agreementParty.Lender_Percentage__c = (agreementParty.Lender_Amount__c != null) ? (agreementParty.Lender_Amount__c / agreementFacilityLimit) * 100 : 0;
            }
            else if(agreementParty.Lender_Amount__c != inputOldMap.get(agreementParty.Id).Lender_Amount__c && agreementParty.Lender_Amount__c != null && agreementFacilityLimit == 0)
            {
                agreementParty.Lender_Percentage__c = 0;
            }
            else if(agreementFacilityLimit == null)
            {
                agreementParty.Lender_Percentage__c = null;
            }

            //Amount was updated, calculate new percentage.
            if(agreementParty.Lender_Percentage__c != inputOldMap.get(agreementParty.Id).Lender_Percentage__c && agreementParty.Lender_Percentage__c != null && agreementFacilityLimit != 0 && agreementFacilityLimit != null)
            {
                agreementParty.Lender_Amount__c = (agreementParty.Lender_Percentage__c != null) ? agreementFacilityLimit * (agreementParty.Lender_Percentage__c / 100) : 0;
            }
            else  if(agreementParty.Lender_Percentage__c != inputOldMap.get(agreementParty.Id).Lender_Percentage__c && agreementParty.Lender_Percentage__c != null && agreementFacilityLimit == 0)
            {
                agreementParty.Lender_Amount__c = 0;
            }
            else if(agreementFacilityLimit == null)
            {
                agreementParty.Lender_Amount__c = null;
            }
        }
    }
}