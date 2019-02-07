({
	doInit : function(cmp, event, helper) {
		helper.getStrategy(cmp, event, helper);
	},
    onBeforeSave : function(cmp, event, helper) {
        
        var value = cmp.find("inputRT").get("v.value");
        helper.onBeforeSave(value, cmp);
    },
    moveBack : function(cmp, event, helper) {
     	helper.moveBack(cmp);   
    }
})