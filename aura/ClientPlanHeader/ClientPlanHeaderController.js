({
    onMenuClicked : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
    },
	navigateToTitlePage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
		var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanDetails",
            componentAttributes: {planId: id}
        });
        evt.fire();		
	},
    navigateToOverviewPage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanOverview",
            componentAttributes: {planId: id}
        });
        evt.fire();	
    },
    navigateToFinancialsPage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanFinancials",
            componentAttributes: {planId: id}
        });
        evt.fire();	
    },
    navigateToPresencePage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
        var timestamp = new Date().getTime();
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanPresence",
            componentAttributes: {planId: id, timestamp: timestamp}
        });
        evt.fire();	
    },
    navigateToStakeholdersPage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStakeholders",
            componentAttributes: {planId: id}
        });
        evt.fire();	
    },
    navigateToStrategyPage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
        var timestamp = new Date().getTime();
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyList",
            componentAttributes: {planId: id, timestamp: timestamp}
        });
        evt.fire();
    },
    navigateToPlanPage : function(cmp, event, helper) {
        helper.onMenuClicked(cmp);
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanPlan",
            componentAttributes: {planId: id}
        });
        evt.fire();
    }
})