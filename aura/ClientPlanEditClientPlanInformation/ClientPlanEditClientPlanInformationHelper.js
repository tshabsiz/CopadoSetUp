({
	getClientPlan : function(cmp) {
        
		var action = cmp.get("c.getClientPlan");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.plan", data);
				console.log(data);
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getClientPlanInfoMetadata : function(cmp) {
        
        var action = cmp.get("c.getMetadata");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
				cmp.set("v.stageOptions", data.stage);
                cmp.set("v.expansionPolicyOptions", data.expansionPolicy);
                cmp.set("v.dgOptions", data.dg);
                
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    moveBack : function(id) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanDetails",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    modifyClientPlanInfo : function(cmp, stage, expansionPolicy, dg, lgd) {
        
        var helper = this;
        var action = cmp.get("c.saveClientPlanInfo");
        var planId = cmp.get("v.planId");
        
        action.setParams({
            "planId" : planId,
            "stage" : stage,
            "expansionPolicy" : expansionPolicy,
            "dg" : dg,
            "lgd" : lgd
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editation.');
                } else {
                    helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during editation.');
            }
        });
        $A.enqueueAction(action);
    }
})