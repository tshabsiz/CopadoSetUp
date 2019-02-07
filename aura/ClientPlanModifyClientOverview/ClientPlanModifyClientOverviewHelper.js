({
	getClientPlan : function(cmp, event, helper) {
        
        var isSector = cmp.get("v.isSector");
        
		var action = cmp.get("c.getClientPlan");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (isSector) {
                	cmp.set("v.rtData", data.Sector_Overview__c);    
                } else {
                    cmp.set("v.rtData", data.Client_Overview__c);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    onBeforeSave : function(value, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        
        var action = cmp.get("c.editRichtextField");
        var planId = cmp.get("v.planId");
        var isSector = cmp.get("v.isSector");
        action.setParams({ 
            "planId" : planId,
            "value" : value,
            "isSector" : isSector
        });
		
        action.setCallback(this, function(response) {
        	cmp.set("v.showProgressBar", false);    
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during saving.');
                } else {
                    helper.moveBack(cmp);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during saving.');
            }
        });
        $A.enqueueAction(action);
    },
    moveBack : function(cmp) {
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanOverview",
            componentAttributes: {planId: id}
        });
        evt.fire();
    }
})