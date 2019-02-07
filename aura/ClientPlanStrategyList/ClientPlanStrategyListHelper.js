({
	getStrategies : function(cmp, name) {
		
        var action = cmp.get("c.getStrategies");
        var planId = cmp.get("v.planId");
        action.setParams({ 
            "planId" : planId,
            "name" : name
        });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                
                if (data.length > 0) {
                    cmp.set("v.strategies", data);
                } else {
                	var strategies = [{isPlaceholder: true}];
                    cmp.set("v.strategies", strategies);
                }
                    
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    showStrategyDetail : function(cmp, strategyId) {
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyDetail",
            componentAttributes: {planId: id, strategyId: strategyId}
        });
        evt.fire();
    },
    showAddStrategyComponent : function(planId) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyStrategy",
            componentAttributes: {planId: planId}
        });
        evt.fire();
    }
})