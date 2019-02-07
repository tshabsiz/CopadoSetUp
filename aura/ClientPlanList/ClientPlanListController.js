({
	doInit : function(cmp, event, helper) {
        
        cmp.set("v.alreadyIn", false);
        cmp.set("v.timestamp", new Date().getTime());
        cmp.set("v.limit", 10);
        cmp.set("v.accName", null);
        helper.getAccounts(cmp, "10", null);
        
	},
    onAccountClicked : function(cmp, event, helper) {
        var account = $(event.target).closest('.account');
        var plans = $(account).find('.clientPlans');
        
        if ( $(plans).css('display') == 'none' ) {
            $('.clientPlans').slideUp();
            $(plans).slideDown();
            return false;
            
        } else {
            $(plans).slideUp();
        }
    },
    onPlanClicked : function(cmp, event, helper) {
        var planId = $(event.target).closest('.clientPlan').prop('id');
        helper.onPlanClicked(planId);
    },
    loadMore : function(cmp, event, helper) {
        var accName = cmp.get("v.accName");
     	var limit = cmp.get("v.limit");
        limit += 10;
        cmp.set("v.limit", limit);
        
        var limitString = limit.toString();
        helper.getAccounts(cmp, limitString, accName); 
    },
    searchAccounts : function(cmp, event, helper) {
        var name = event.source.elements[0].value;
        name = name.trim();
        
        if (name.length > 0) {
            cmp.set("v.limit", 10);
            cmp.set("v.accName", name);
        	helper.getAccounts(cmp, "10", name);
        } else {
            cmp.set("v.accName", null);
            helper.getAccounts(cmp, "10", null);
        }
    },
    stopPropagation : function(cmp, event, helper) {
        event.stopPropagation();  
    },
    onBeforeCreateNewPlan : function(cmp, event, helper) {
        var accountId = $(event.target).closest('.account').prop('id');
        helper.onBeforeCreateNewPlan(cmp, accountId);
    }
})