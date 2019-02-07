({
	getStrategy : function(cmp, event, helper) {
        
        var isClient = cmp.get("v.isClient");
        
		var action = cmp.get("c.getStrategy");
        var strategyId = cmp.get("v.strategyId");
        action.setParams({ "strategyId" : strategyId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (isClient) {
                	cmp.set("v.rtData", data.Client_Strategy__c);    
                } else {
                    cmp.set("v.rtData", data.Bank_Strategy__c);
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
        var strategyId = cmp.get("v.strategyId");
        var isClient = cmp.get("v.isClient");
        action.setParams({ 
            "strategyId" : strategyId,
            "value" : value,
            "isClient" : isClient
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
        
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyDetail",
            componentAttributes: {planId: planId, strategyId: strategyId}
        });
        evt.fire();
    }
})