({
	doInit : function(cmp, event, helper) {
		cmp.set("v.showPlaceholder", false);
	},
    afterScriptsLoaded : function(cmp, event, helper) {
    	helper.onBeforePrepareStakeholders(cmp);   
    },
    onStakeholderRelationshipsLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("stakeholderRelationships");
        $A.util.toggleClass(toShow, "toggle");
    }
})