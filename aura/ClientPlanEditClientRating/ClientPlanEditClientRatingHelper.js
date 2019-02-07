({
	getClientPlan : function(cmp) {
        
		var action = cmp.get("c.getClientPlan");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(response);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.plan", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getRatingMetadata : function(cmp) {
        
        var action = cmp.get("c.getRatingMetadata");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
				cmp.set("v.faisOptions", data.fais);
                cmp.set("v.financialYearEndOptions", data.financialYearEnd);
                
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
            componentDef: "c:ClientPlanFinancials",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    modifyClientRating : function(cmp, tfl, fais, lastReviewDate, financialYearEnd, latestAudited) {
        
        var helper = this;
        var action = cmp.get("c.saveRating");
        var planId = cmp.get("v.planId");
        
        action.setParams({
            "planId" : planId,
            "tfl" : tfl,
            "fais" : fais,
            "lastReviewDate" : lastReviewDate,
            "financialYearEnd" : financialYearEnd,
            "latestAudited" : latestAudited
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