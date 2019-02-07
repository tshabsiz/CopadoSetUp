trigger OpportunitySplitTrigger on Opportunity_Split__c (before insert, before update, after insert) {

    //before insert
    if (trigger.isBefore && trigger.isInsert) {
        OpportunitySplitTrigger_Helper.checkSplitsSumUnder100Percent(trigger.new);
    }
    
    //before update
    if (trigger.isBefore && trigger.isUpdate) {
        OpportunitySplitTrigger_Helper.checkSplitsSumUnder100Percent(trigger.new);
    }
    
}