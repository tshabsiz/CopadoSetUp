trigger OpportunityTrigger on Opportunity (after insert, after update, before update, before insert) {

    // before insert
    if(trigger.isBefore && trigger.isInsert){  
        OpportunityTrigger_Helper.isInsert = true;
        OpportunityTrigger_Helper.setDefaultPriceBook(Trigger.new);
        OpportunityTrigger_Helper.setPrivateCheckboxes(Trigger.new);
        OpportunityTrigger_Helper.updateOpportunitySegmentAndIndustry(Trigger.new, null);
        OpportunityTrigger_Helper.checkOpportunityName(Trigger.new, null);
    } 

    // after insert
    if(trigger.isAfter && trigger.isInsert){        
        OpportunityTrigger_Helper.addAccountableBankerToOppTeam(Trigger.new);
        OpportunityTrigger_Helper.createDefaultOpportunitySplit(Trigger.new);
        OpportunityTrigger_Helper.modifyOpportunityForPrivateSideUser(Trigger.new, null);
        OpportunityTrigger_Helper.AddNewOpportunityShare(Trigger.newMap);
        OpportunityTrigger_Helper.flagProjectNameAsUsed(Trigger.new, null);
    }

    //before update
    if(trigger.isBefore && trigger.isUpdate){
        OpportunityTrigger_Helper.updateOpportunityShare(Trigger.NewMap,Trigger.oldMap);
    	OpportunityTrigger_Helper.updateOpportunitySegmentAndIndustry(Trigger.new, Trigger.oldMap);
    	OpportunityTrigger_Helper.PromoteProductPartner(Trigger.new, Trigger.oldMap);
        if (OpportunityTrigger_Helper.FirstRun) {
            OpportunityTrigger_Helper.checkOpportunityName(Trigger.new, Trigger.oldMap);
            OpportunityTrigger_Helper.FirstRun = false;
        }
        if (!OpportunityTrigger_Helper.isInsert) {
            OpportunityTrigger_Helper.AttachmentCheckSignificantPitch(Trigger.new, Trigger.oldMap);
        }
        OpportunityTrigger_Helper.CheckProductLevel3(Trigger.newMap, Trigger.oldMap);
    }

    // after update
    if(trigger.isAfter && trigger.isUpdate){
        OpportunityTrigger_Helper.addCoverageBanker(Trigger.new,Trigger.oldMap);
        OpportunityTrigger_Helper.setDefaultPriceBookAfterUpdate(Trigger.new, Trigger.oldMap);
        OpportunityTrigger_Helper.replaceAccountableBankerForOppTeam(Trigger.oldMap, Trigger.newMap);
        OpportunityTrigger_Helper.updateIncomeThisYear(Trigger.oldMap, Trigger.newMap);
        OpportunityTrigger_Helper.shareOpportunityTeamMembersWithJLOC(Trigger.oldMap, Trigger.newMap);
        OpportunityTrigger_Helper.modifyOpportunityForPrivateSideUser(Trigger.new, Trigger.oldMap);
        OpportunityTrigger_Helper.flagProjectNameAsUsed(Trigger.new, Trigger.oldMap);
    }

}