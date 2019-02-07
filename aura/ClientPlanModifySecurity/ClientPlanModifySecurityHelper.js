({
	getSecurity : function(cmp, securityId) {
        
		var action = cmp.get("c.getSecurity");
        action.setParams({ "securityId" : securityId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.length == 0) {
                    alert('An error occured during getting data.');
                } else {
                	cmp.set("v.sec", data[0]);
                }
				
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
    addSecurity : function(cmp, planId, description, value) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addSecurity");
        action.setParams({ 
            "planId" : planId,
            "description" : description,
            "value" : value
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during adding security.');
                } else {
                	helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during adding security.');
            }
        });
        $A.enqueueAction(action);
    },
    editSecurity : function(cmp, planId, securityId, description, value) {
        
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.editSecurity");
        action.setParams({ 
            "securityId" : securityId,
            "description" : description,
            "value" : value
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editing security.');
                } else {
                	helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during editing security.');
            }
        });
        $A.enqueueAction(action);
    }
})