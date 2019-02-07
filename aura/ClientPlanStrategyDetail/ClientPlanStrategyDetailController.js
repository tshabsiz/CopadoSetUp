({
	doInit : function(cmp, event, helper) {
		helper.getStrategy(cmp);
	},
    onEditStrategyClicked : function(cmp, event, helper) {
     	helper.showEditStrategyComponent(cmp);   
    },
    onRemoveStrategyClicked : function(cmp, event, helper) {
     	helper.onBeforeRemoveStrategy(cmp);   
    },
    onUnlinkOptyButtonClicked : function(cmp, event, helper) {
        var id = $(event.target).closest('.opty').prop('id').split('-')[1];
        if (id != null) {
            helper.OnBeforeUnlinkOpty(id, cmp);
        }
    },
    onEditPotOptyButtonClicked : function(cmp, event, helper) {
        var id = $(event.target).closest('.opty').prop('id').split('-')[1];
        if (id != null) {
            helper.onBeforeEditPotOpty(id, cmp);
        } 
    },
    onRemovePotOptyButtonClicked : function(cmp, event, helper) {
   		var id = $(event.target).closest('.opty').prop('id').split('-')[1];
        if (id != null) {
            helper.onBeforeRemovePotOpty(id, cmp);
        } 
    },
    onAddPotOptyClicked : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
     	helper.showAddPotOptyComponent(planId, strategyId);   
    },
    onAddOptyClicked : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
     	helper.showAddOptyComponent(planId, strategyId); 
    },
    onLinkOptyClicked : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
     	helper.showLinkOptyComponent(planId, strategyId); 
    },
    onLinkPotOptyClicked : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
     	helper.showLinkPotOptyComponent(planId, strategyId); 
    },
    onMoveBackClicked : function(cmp, event, helper) {
        helper.moveBack(cmp);
    },
    onEditClientRTClicked : function(cmp, event, helper) {
        helper.showEditStrategyRichtextComponent(cmp, true);
    },
    onEditBankRTClicked : function(cmp, event, helper) {
        helper.showEditStrategyRichtextComponent(cmp, false);
    }
})