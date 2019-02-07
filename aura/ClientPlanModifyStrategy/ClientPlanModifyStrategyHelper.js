({
	getStrategy : function(cmp, strategyId) {
        
		var action = cmp.get("c.getStrategy");
        action.setParams({ 
            "strategyId" : strategyId
        });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(response);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                cmp.set("v.strategy", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    moveBackToStrategyDetail : function(strategyId) {
    
    	var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyDetail",
            componentAttributes: {strategyId: strategyId}
        });
        evt.fire();
	},
    moveBackToStrategyList : function(planId) {
    
        var timestamp = new Date().getTime();
    	var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyList",
            componentAttributes: {planId: planId, timestamp: timestamp}
        });
        evt.fire();
	},
    onBeforeEditStrategy : function(cmp, strategyId, name) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.editStrategy");
        action.setParams({ 
            "strategyId" : strategyId,
            "name" : name
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editation.');
                } else {
                    helper.moveBackToStrategyDetail(strategyId);
                }
				
            } else  {
                alert('An error occured during editation.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeAddStrategy : function(cmp, planId, name) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addStrategy");
        action.setParams({ 
            "planId" : planId,
            "name" : name
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during adding strategy.');
                } else {
                    helper.moveBackToStrategyList(planId);
                }
				
            } else  {
                alert('An error occured during adding strategy.');
            }
        });
        $A.enqueueAction(action);
    }
})