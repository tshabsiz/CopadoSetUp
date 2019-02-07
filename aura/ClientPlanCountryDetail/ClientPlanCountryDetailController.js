({
	doInit : function(cmp, event, helper) {
		helper.getCountryData(cmp);
	},
    onRemoveCountryClicked : function(cmp, event, helper) {
     	var proceed = confirm('Country will be deleted. Continue?');   
        if (proceed) {
            helper.onRemoveCountry(cmp);
        }
    },
    onEditCountryClicked : function(cmp, event, helper) {
    	helper.showEditCountryComponent(cmp);  
    },
    onMoveBackClicked : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        helper.moveBack(planId);
	}
})