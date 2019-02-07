({
    doInit : function(cmp, event, helper) {
        cmp.set("v.limit", 10);
        cmp.set("v.userName", null);
        cmp.set("v.userSelected", false);
        helper.getTeam(cmp);
        helper.getTeamRoleOptions(cmp);
	},
    moveBack : function(cmp, event, helper) {
        var id = cmp.get("v.planId");
        helper.moveBack(id); 
    },
	searchUsers : function(cmp, event, helper) {
		var name = event.source.elements[0].value;
        name = name.trim();
        
        if (name.length > 0) {
            cmp.set("v.limit", 10);
            cmp.set("v.userName", name);
        	helper.getUsers(cmp, "10", name);
        } else {
            cmp.set("v.userName", null);
            helper.getUsers(cmp, "10", null);
        }
	},
    loadMore : function(cmp, event, helper) {
        var userName = cmp.get("v.userName");
     	var limit = cmp.get("v.limit");
        limit += 10;
        cmp.set("v.limit", limit);
        
        var limitString = limit.toString();
        helper.getUsers(cmp, limitString, userName); 
    },
    onUserClicked : function(cmp, event, helper) {
        
     	var elem = $(event.target).closest('.user');
        var id = $(elem).prop('id');
        var name = $(elem).find('.userName').text();
        
        cmp.set("v.selectedId", id);
        cmp.set("v.selectedName", name);
        cmp.set("v.userSelected", true);
        
        var teamRoleOptions = cmp.get("v.teamRoleOptions");
        if (teamRoleOptions.length > 0) {
        	cmp.find("role").set("v.value", teamRoleOptions[0]);
        }
        
    },
    onBeforeAddTeamMember : function(cmp, event, helper) {
        cmp.set("v.showProgressBar", true);
    	var userId = cmp.get("v.selectedId");
        var role = cmp.find("role").get("v.value");
        helper.onBeforeAddTeamMember(cmp, userId, role);
    }
})