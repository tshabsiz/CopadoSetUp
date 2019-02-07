({
	doInit : function(cmp, event, helper) {
        console.log('a');
		var strategyId = cmp.get("v.strategyId");
        
        if (strategyId != null) {
			helper.getStrategy(cmp, strategyId);
        }
	},
    moveBack : function(cmp, event, helper) {
        var strategyId = cmp.get("v.strategyId");
        var planId = cmp.get("v.planId");
        
        if (strategyId != null) {
        	helper.moveBackToStrategyDetail(strategyId);
        } else {
            helper.moveBackToStrategyList(planId);
        }
    },
    onBeforeModify : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        var name = cmp.find("name").get("v.value");
        //var clientStrategy = cmp.find("clientStrategy").get("v.value");
        //var bankStrategy = cmp.find("bankStrategy").get("v.value");
        
        if (strategyId != null) {
            helper.onBeforeEditStrategy(cmp, strategyId, name);
        } else {
            helper.onBeforeAddStrategy(cmp, planId, name);
        }
    }
})