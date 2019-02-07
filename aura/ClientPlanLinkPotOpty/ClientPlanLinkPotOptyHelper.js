({
	getPotOptys : function(cmp) {
		
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.getPotOptysToLink");
		action.setParams({
            "planId" : planId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.optys", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    moveBack : function(planId, strategyId) {
      
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyDetail",
            componentAttributes: {planId: planId, strategyId: strategyId}
        });
        evt.fire();
    },
    onBeforeLinkOptys : function(cmp, strategyId, optysToLink) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.linkPotOptys");
		action.setParams({
            "strategyId" : strategyId,
            "optysToLink" : optysToLink
        });
        
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during linking potential opportunity.');
                } else {
                    helper.moveBack(planId, strategyId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during linking potential opportunity.');
            }
        });
        $A.enqueueAction(action);
    }
})