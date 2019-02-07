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
                cmp.set("v.clientPlan", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getClientFinancials : function(cmp) {
        
        var action = cmp.get("c.getClientFinancials");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.clientFinancialsData", data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    getFacilitiesAndSecurity : function(cmp) {
        
        var action = cmp.get("c.getFacilitiesAndSecurity");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var data = JSON.parse(result);
                cmp.set("v.absaFacilities", data.absaFacilities);
                cmp.set("v.otherFacilities", data.otherFacilities);
                cmp.set("v.security", data.security);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    showEditClientRatingComponent : function(cmp) {
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanEditClientRating",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    showModifyAbsaFacilityComponent : function(cmp, facilityId, isBarclays) {
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyFacility",
            componentAttributes: {
                planId: planId, 
                facilityId: facilityId, 
                isBarclays: isBarclays,
                timestamp: new Date().getTime()
            }
        });
        evt.fire();
    },
    showModifySecurityComponent : function(cmp, securityId) {
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifySecurity",
            componentAttributes: {planId: planId, securityId: securityId}
        });
        evt.fire();
    },
    showModifyFinancialsComponent : function(cmp, financialsId) {
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyFinancials",
            componentAttributes: {planId: planId, financialsId: financialsId}
        });
        evt.fire();
    },
    removeFinancials : function(cmp, financialsId) {
        cmp.set("v.showProgressBar", true);
        
        var action = cmp.get("c.removeFinancials");
        action.setParams({ "financialsId" : financialsId });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {
                    alert('An error occured during removing record.');
                } else {
                    $A.get('e.force:refreshView').fire();
                }
				
            } else  {
                console.log(response);
                alert('An error occured during removing record.');
            }
        });
        $A.enqueueAction(action);
    }
})