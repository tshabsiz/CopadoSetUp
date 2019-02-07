({
	getClientPlan : function(cmp, event, helper) {
        
		var action = cmp.get("c.getClientPlan");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.clientPlan", data.plan);
                cmp.set("v.planProgress", data.planProgress);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getTeamMembers : function(cmp, event, helper) {
        
        var action = cmp.get("c.getTeamMembers");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.teamMembers", data);
				console.log(data);
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    showEditClientPlanInfoComponent : function(cmp) {
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanEditClientPlanInformation",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    onBeforeRemoveTeamMember : function(cmp, memberId) {
        
        var action = cmp.get("c.removeTeamMember");
        action.setParams({ "memberId" : memberId });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during removing team member.');
                } else {
                    $A.get('e.force:refreshView').fire();
                }
				
            } else  {
                console.log(response);
                alert('An error occured during removing team member.');
            }
        });
        $A.enqueueAction(action);
    },
    showAddTeamMemberComponent : function(cmp) {
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyTeamMember",
            componentAttributes: {planId: id}
        });
        evt.fire();
    }
})