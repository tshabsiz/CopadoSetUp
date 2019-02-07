({
	getMetadata : function(cmp) {
        
		var action = cmp.get("c.getOptyMetadata");
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.stageOptions", data.stage);
                cmp.set("v.typeOptions", data.type);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    setProbability : function(cmp) {
        
        var stage = cmp.find("stage").get("v.value");
        var probability;
        if (stage == 'Needs Analysis') {
            probability = 30;
        } else if (stage == 'Qualified') {
            probability = 20;
        } else {
            probability = 10;
        }
        cmp.find("probability").set("v.value", probability);
    },
    moveBack : function(planId, strategyId) {
      	
        var evt = $A.get("e.force:navigateToComponent");
        
        if (strategyId != null) {
            evt.setParams({
                componentDef: "c:ClientPlanStrategyDetail",
                componentAttributes: {planId: planId, strategyId: strategyId}
            });
        } else {
            evt.setParams({
                componentDef: "c:ClientPlanPlan",
                componentAttributes: {planId: planId}
            });
        }
        evt.fire();
    },
    checkUndefinedField : function(value) {
        return value == 'undefined' ? null : value;
    },
    onBeforeAddOpty : function(cmp, name, closeDate, stage, probability, type) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addOpty");
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        
        var closeDateSplit = closeDate.split('-');
        closeDate = new Date(closeDateSplit[0], closeDateSplit[1] - 1, closeDateSplit[2]).getTime();
        
        action.setParams({
            "planId" : planId,
            "strategyId" : strategyId,
            "name" : name,
            "closeDate" : closeDate,
            "stage" : stage,
            "probability" : probability,
            "type" : type
        });
		
        action.setCallback(this, function(response) {
			cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                if (data) {
                    alert('An error occured during adding opportunity.');
                } else {
                    helper.moveBack(planId, strategyId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during adding opportunity.');
            }
        });
        $A.enqueueAction(action);
    }
})