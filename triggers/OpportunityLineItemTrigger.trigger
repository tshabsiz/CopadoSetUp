/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Trigger for Oportunity Line Item
* @Date:        11/2015
* @TestClass:   ZZTEST_OpportunityLineItemTrigger_Helper
* History
*  <Date> <User> <Description>
*  11/2015 Marek Cech added countProductTotals before insert and update
*--------------------------------------------------------------------------*/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert, after update, after delete) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        OpportunityLineItemTrigger_Helper.countProductTotals(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        OpportunityLineItemTrigger_Helper.countProductTotals(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityLineItemTrigger_Helper.createChatterPostsAfterInsert(Trigger.new);
        OpportunityLineItemTrigger_Helper.UpdateProductPartnerOnOpp(Trigger.new, null);
        OpportunityLineItemTrigger_Helper.updateProductListFromProductAfterModify(Trigger.new);
        OpportunityLineItemTrigger_Helper.crossSellOpps(Trigger.new, null, null);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityLineItemTrigger_Helper.createChatterPostsAfterUpdate(Trigger.new, Trigger.old);
        OpportunityLineItemTrigger_Helper.UpdateProductPartnerOnOpp(Trigger.new, Trigger.oldMap);
        OpportunityLineItemTrigger_Helper.updateProductListFromProductAfterModify(Trigger.new);
        OpportunityLineItemTrigger_Helper.clearRPFCalculations(Trigger.new, Trigger.oldMap);
        OpportunityLineItemTrigger_Helper.crossSellOpps(Trigger.new, Trigger.oldMap, Trigger.old);
    }
    
    if (Trigger.isAfter && Trigger.isDelete) {
        OpportunityLineItemTrigger_Helper.updateProductListFromProductAfterModify(Trigger.old);
        OpportunityLineItemTrigger_Helper.createChatterPostsAfterDelete(Trigger.old);
    }
     
}