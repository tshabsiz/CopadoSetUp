({
    getTeam : function(cmp) {
      
        var helper = this;
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.getTeamMembers");
        action.setParams({ 
            "planId" : planId
        });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                helper.processTeamData(data, cmp);
                helper.getUsers(cmp, "10", null);
                
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        
        $A.enqueueAction(action);
    },
    processTeamData : function(rawData, cmp) {
    	var ids = [];
        for (var i = 0; i < rawData.length; i++) {
            ids.push(rawData[i].Team_Member__r.Id);
        }
        cmp.set("v.team", ids);
    },
    getTeamRoleOptions : function(cmp) {
        
        var action = cmp.get("c.getRoleOptions");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                cmp.set("v.teamRoleOptions", data);
                
            } else  {
                console.log(response);
                //TODO handle errors
            }
        });
        
        $A.enqueueAction(action);
    },
	getUsers : function(cmp, limitString, name) {
		
        var team = cmp.get("v.team");
        var action = cmp.get("c.getUsers");
        action.setParams({ 
            "limitString" : limitString,
            "name" : name,
            "team" : team
        });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data.length > 0) {
                    cmp.set("v.users", data);
                } else {
                	var users = [{isPlaceholder: true}];
                    cmp.set("v.users", users);
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
            componentDef: "c:ClientPlanDetails",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    onBeforeAddTeamMember : function(cmp, userId, role) {
        
        var helper = this;
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.addTeamMember");
        action.setParams({ 
            "planId" : planId,
            "userId" : userId,
            "role" : role
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during adding team member.');
                } else {
                    helper.moveBack(planId);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during adding team member.');
            }
        });
        
        $A.enqueueAction(action);
    }
})