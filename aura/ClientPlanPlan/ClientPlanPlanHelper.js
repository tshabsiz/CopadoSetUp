({
	getBudgetRevenues : function(cmp) {
		
        var action = cmp.get("c.getBudgetRevenues");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.budgetRevenues", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getPotOptys : function(cmp) {
        
        var action = cmp.get("c.getPotOptys");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.potOptys", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    getOptys : function(cmp) {
        
        var action = cmp.get("c.getOptys");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data == null) {
                   alert('An error occured during getting data.');
                } else {
                	cmp.set("v.optys", data);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    showAddBRComponent : function(cmp) {
        
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyBudgetRevenue",
            componentAttributes: {planId: planId, brId: null, timestamp: new Date().getTime()}
        });
        evt.fire();
    },
    showEditBRComponent : function(cmp, id) {
        
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyBudgetRevenue",
            componentAttributes: {planId: planId, brId: id, timestamp: new Date().getTime()}
        });
        evt.fire();
    },
    removeBR : function(cmp, brId) {
    	cmp.set("v.showProgressBar", true);
        
        var planId = cmp.get("v.planId");
        
        var action = cmp.get("c.removeBudgetRevenue");
        action.setParams({ "brId" : brId });
        
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                   alert('An error occured during removing product.');
                } else {
                	$A.get('e.force:refreshView').fire();
                }
				
            } else  {
                console.log(response);
                alert('An error occured during removing product.');
            }
        });
        $A.enqueueAction(action);
    },
    showAddPotOptyComponent : function(cmp) {
        
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyPotOpty",
            componentAttributes: {
                planId: planId, 
                strategyId: null, 
                optyId: null, 
                timestamp: new Date().getTime()
            }
        });
        evt.fire();
    },
    showEditPotOptyComponent : function(cmp, optyId) {
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyPotOpty",
            componentAttributes: {
                planId: planId, 
                strategyId: null, 
                optyId: optyId, 
                timestamp: new Date().getTime()
            }
        });
        evt.fire();
    },
    showAddOptyComponent : function(cmp) {
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanAddOpty",
            componentAttributes: {planId: planId, strategyId: null}
        });
        evt.fire();
    }
})