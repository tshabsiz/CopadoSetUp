({
	doInit : function(cmp, event, helper) {
        var securityId = cmp.get("v.securityId");
        if (securityId != null) {
            helper.getSecurity(cmp, securityId);
        }
	},
    moveBack : function(cmp, event, helper) {
        var id = cmp.get("v.planId");
        helper.moveBack(id);
    },
    onBeforeSave : function(cmp, event, helper) {
     	var description = cmp.find("description").get("v.value");
        
        var value = cmp.find("value").get("v.value");
        if (typeof value === 'undefined' || value === '') {
            value = 0;
        }
        
        if (value != null && isNaN(parseFloat(value))) {
            var valueError = cmp.find("valueError");
        	$A.util.toggleClass(valueError, "toggle");
            return;
        }
        
        var securityId = cmp.get("v.securityId");
        var planId = cmp.get("v.planId");
        
        if (securityId == null) {
            helper.addSecurity(cmp, planId, description, value);
        } else {
            helper.editSecurity(cmp, planId, securityId, description, value);
        }
    }
})