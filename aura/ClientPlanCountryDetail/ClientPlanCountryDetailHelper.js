({
	getCountryData : function(cmp) {
		
        var countryId = cmp.get("v.countryId");
        var action = cmp.get("c.getCountry");
        action.setParams({ 
            countryId : countryId
        });

        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                cmp.set("v.country", data);
                
            } else {
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    moveBack : function(planId) {
        var evt = $A.get("e.force:navigateToComponent");
        var timestamp = new Date().getTime();
        evt.setParams({
            componentDef: "c:ClientPlanPresence",
            componentAttributes: {planId: planId, timestamp: timestamp}
        });
        evt.fire();
    },
    onRemoveCountry : function(cmp) {
        
        var helper = this;
        var planId = cmp.get("v.planId");
        var countryId = cmp.get("v.countryId");
        
        cmp.set("v.showProgressBar", true);
        
        var action = cmp.get("c.removeCountry");
        action.setParams({ 
            countryId : countryId
        });

        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during removing country.');
                } else {
                    helper.moveBack(planId);
                }
                
            } else if (state === "ERROR") {
                alert('An error occured during removing country.');
            }
        });
        $A.enqueueAction(action);
    },
    showEditCountryComponent : function(cmp) {
        var planId = cmp.get("v.planId");
        var countryId = cmp.get("v.countryId");
        var engaged = cmp.get("v.country.Engaged__c");
        var primaryBank = cmp.get("v.country.Primary_Bank__c");
        var timestamp = new Date().getTime();
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyCountry",
            componentAttributes: {
                planId: planId, 
                countryId: countryId,
                engaged: engaged,
                primaryBank: primaryBank,
                timestamp: timestamp
            }
        });
        evt.fire();
    }
})