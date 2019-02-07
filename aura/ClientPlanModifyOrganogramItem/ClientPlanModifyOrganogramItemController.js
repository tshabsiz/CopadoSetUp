({
	moveBack : function(cmp, event, helper) {
		var id = cmp.get("v.planId");
        helper.moveBack(id);
	},
    onBeforeModifyItem : function(cmp, event, helper) {
        var department = cmp.find("departmentInput").get("v.value");
        var proceed = helper.hasContent(department);
        var itemId = cmp.get("v.itemId");
        
        if (proceed) {
            
            //adding
            if (itemId == null) {
            	helper.addItem(department, cmp);
                
            //editing
            } else {
                helper.editItem(department, itemId, cmp);
            }
        } else {
            $('#departmentElem').addClass('slds-has-error');
            $('#departmentError').show();
        }
    }
})