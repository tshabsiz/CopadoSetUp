/**
* @author Deloitte 
* @date 2015
*
* @group Organisation (Opportunity_Split__c) 
*
* @description Opportunity Split Trigger Helper class
*/
public class OpportunitySplitTrigger_Helper {

    //maximum summarized percentage per opportunity
    private static final Decimal MAX_PERCENTAGE_SPLIT  = 100;

    /**
    * @description Checks whether summarized splits (by opportunity) are below 100 percent.
    * @param List<Opportunity_Split__c> splits - opportunity splits to check
    */
    public static void checkSplitsSumUnder100Percent(List<Opportunity_Split__c> splits) {
        List<Id> opportunityIds = new List<Id>();
        for (Opportunity_Split__c split: splits) {
            opportunityIds.add(split.Opportunity__c);
        }
        
        List<Opportunity_Split__c> storedSplitsList = [
            SELECT Id, Opportunity__c, Percentage__c FROM Opportunity_Split__c 
            WHERE Opportunity__c IN :opportunityIds
        ];
        
        Map<Id, List<Opportunity_Split__c>> storedSplitsByOpp = groupSplitsByOpp(storedSplitsList);
        Map<Id, List<Opportunity_Split__c>> triggeredSplitsByOpp = groupSplitsByOpp(splits);
        
        for (Id oppId: opportunityIds) {
            List<Opportunity_Split__c> storedSplits = storedSplitsByOpp.get(oppId);
            List<Opportunity_Split__c> triggeredSplits = triggeredSplitsByOpp.get(oppId);
            
            Decimal sumPercentage = 0;
            if (storedSplits == null) {
                sumPercentage = sumPercentage(triggeredSplits);
            } else {
                List<Opportunity_Split__c> splitsToCheck = replaceStoredSplitsByTriggered(storedSplits, 
                    triggeredSplits);
                sumPercentage = sumPercentage(splitsToCheck);
            }
            
            if (sumPercentage > MAX_PERCENTAGE_SPLIT ) {
                addOver100Error(triggeredSplits, sumPercentage);
            }
        }
    }
    
    /**
    * @description Summarizes percentage of splits given in parameter.
    * @param List<Opportunity_Split__c> splits - opportunity splits to summarize
    * @return Decimal - summarized percentage
    */
    @testVisible
    private static Decimal sumPercentage(List<Opportunity_Split__c> splits) {
        Decimal sum = 0;
        for (Opportunity_Split__c split: splits) {
            sum += split.Percentage__c;
        }
        return sum;
    }
    
    /**
    * @description Adds error to opportunity splits in parameter.
    * @param List<Opportunity_Split__c> splits - opportunity splits to add error to
    * @param Decimal sumPercentage - summarized percentage of splits in parameter
    */
    @testVisible
    private static void addOver100Error(List<Opportunity_Split__c> splits, Decimal sumPercentage) {
        for (Opportunity_Split__c split: splits) {
            split.Percentage__c.addError(Label.Splits_Sum_Over_100_Percent + ' (' + Label.Currently + 
                ' ' + sumPercentage + ').');
        }
    }
    
    /*
    * @description Replaces opportunity splits stored in DB with triggered ones. Compares them with Id.
    * @param List<Opportunity_Split__c> storedSplits - opportunity splits stored in DB
    * @param List<Opportunity_Split__c> triggeredSplits - triggered opportunity splits 
    * @return List<Opportunity_Split__c> - unique opportunity splits
    */
    @testVisible
    private static List<Opportunity_Split__c> replaceStoredSplitsByTriggered(
        List<Opportunity_Split__c> storedSplits, List<Opportunity_Split__c> triggeredSplits) {
        
        List<Opportunity_Split__c> result = new List<Opportunity_Split__c>();
        
        //adding triggered instead of stored
        for (Opportunity_Split__c storedSplit: storedSplits) {
            Opportunity_Split__c currentSplit = storedSplit;
            
            for (Opportunity_Split__c triggeredSplit: triggeredSplits) {
                if (currentSplit.Id == triggeredSplit.Id) {
                    currentSplit = triggeredSplit;
                    break;
                }
            }
            result.add(currentSplit);
        }
        
        //adding triggered splits => no Id
        for (Opportunity_Split__c triggeredSplit: triggeredSplits) {
            if (triggeredSplit.Id == null) {
                result.add(triggeredSplit);
            }
        }
        return result;
    }
    
    /**
    * @description Divides opportunity splits by Opportunity__c.
    * @param List<Opportunity_Split__c> splits - opportunity splits to be divided
    * @return Map<Id, List<Opportunity_Split__c>> - map of lists of opportunity splits, 
    *  keyset consists of opportunity ids.
    */
    @testVisible
    private static Map<Id, List<Opportunity_Split__c>> groupSplitsByOpp(List<Opportunity_Split__c> splits) {
    
        Map<Id, List<Opportunity_Split__c>> splitsByOpp = new Map<Id, List<Opportunity_Split__c>>();
        
        for (Opportunity_Split__c split: splits) {
        
            //map already contains given opportunity id
            if (splitsByOpp.containsKey(split.Opportunity__c)) {
                splitsByOpp.get(split.Opportunity__c).add(split);
            } else {
                List<Opportunity_Split__c> oppSplits = new List<Opportunity_Split__c>();
                oppSplits.add(split);
                splitsByOpp.put(split.Opportunity__c, oppSplits);
            }
        }
        return splitsByOpp;
    }

}