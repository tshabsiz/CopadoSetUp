({
    doInit : function(cmp, event, helper) {
        
        helper.getClientPlan(cmp, event, helper);
        helper.getTeamMembers(cmp, event, helper);
        
    },
    stopPropagation : function(cmp, event, helper) {
        event.stopPropagation();  
    },
    onClientPlanInformationLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("clientPlanInformation");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("clientplanInfoMenu");
        $A.util.toggleClass(toShow, "toggle");   
    },
    onClientTeamLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("clientTeam");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("clientTeamMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onEditClientPlanInfoClicked : function(cmp, event, helper) {
        helper.showEditClientPlanInfoComponent(cmp);    
    },
    onRemoveTeamMemberClicked : function(cmp, event, helper) {
        cmp.set("v.showProgressBar", true);
        var elem = $(event.target);
        var memberId = $(elem).closest('.teamMember').prop('id');
        helper.onBeforeRemoveTeamMember(cmp, memberId);
    },
    onAddTeamMemberClicked : function(cmp, event, helper) {
        helper.showAddTeamMemberComponent(cmp);
    }
})