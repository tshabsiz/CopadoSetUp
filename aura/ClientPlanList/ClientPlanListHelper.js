({
	getAccounts : function(cmp, limitString, name) {
		
		var action = cmp.get("c.getAccounts");
        action.setParams({ 
            "limitString" : limitString,
            "name" : name
        });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data.length > 0) {
                    cmp.set("v.accounts", data);
                } else {
                	var accounts = [{isPlaceholder: true}];
                    cmp.set("v.accounts", accounts);
                }
                
            } else  {
                console.log(response);
                //TODO handle errors
            }
        });
        
        $A.enqueueAction(action);
	},
    onBeforeCreateNewPlan : function(cmp, accountId) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addPlan");
        action.setParams({ 
            "accountId" : accountId
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data == null) {
                    alert('An error occured during creating new plan. Are you in the relationship team?');
                } else {
                	helper.onPlanClicked(data);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during creating new plan. Are you in the relationship team?');
            }
        });
        
        $A.enqueueAction(action);
    },
    onPlanClicked : function(planId) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            "resetHistory": true,
            "componentDef": "c:ClientPlanDetails",
            "componentAttributes": {planId: planId}
        });
        evt.fire();
    }
})