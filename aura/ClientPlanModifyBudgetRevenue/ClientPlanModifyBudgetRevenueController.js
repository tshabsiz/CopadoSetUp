({
	doInit : function(cmp, event, helper) {
        var brId = cmp.get("v.brId");
        if (brId != null) {
			helper.getBR(cmp);
        }
	},
    moveBack : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        helper.moveBack(planId);
    },
    onBeforeModifyBudgetRevenue : function(cmp, event, helper) {
        
     	var product = cmp.get("v.productId");
        if (typeof product === 'undefined' || product == null) {
            var productError = cmp.find("productError");
        	$A.util.toggleClass(productError, "toggle");
            return;
        }
        
        var previousYtdRevenues = cmp.find("previousYtdRevenues").get("v.value");
        previousYtdRevenues = helper.checkField(previousYtdRevenues);
        
        var ytdAnnualizedRevenues = cmp.find("ytdAnnualizedRevenues").get("v.value");
        ytdAnnualizedRevenues = helper.checkField(ytdAnnualizedRevenues);
        
        var budgetYtd = cmp.find("budgetYtd").get("v.value");
        budgetYtd = helper.checkField(budgetYtd);
        
        var actYearAnnRev = cmp.find("actYearAnnRev").get("v.value");
        actYearAnnRev = helper.checkField(actYearAnnRev);
        
        var annBudget = cmp.find("annBudget").get("v.value");
        annBudget = helper.checkField(annBudget);
        
        var nextYearBudget = cmp.find("nextYearBudget").get("v.value");
        nextYearBudget = helper.checkField(nextYearBudget);
        
        var actRwa = cmp.find("actRwa").get("v.value");
        actRwa = helper.checkField(actRwa);
        
        var actRorwa = cmp.find("actRorwa").get("v.value");
        actRorwa = helper.checkField(actRorwa);
        
        var brId = cmp.get("v.brId");
        if (brId != null) {
        	helper.onBeforeEditBudgetRevenue(cmp, brId, product, previousYtdRevenues, ytdAnnualizedRevenues,
        		budgetYtd, actYearAnnRev, annBudget, nextYearBudget, actRwa, actRorwa);
        } else {
            helper.onBeforeAddBudgetRevenue(cmp, product, previousYtdRevenues, ytdAnnualizedRevenues,
        		budgetYtd, actYearAnnRev, annBudget, nextYearBudget, actRwa, actRorwa);
        }
    },
    onProductSelected : function(cmp, event, helper) {
    	var productId = event.getParam("productId");
        cmp.set("v.productId", productId);
	}
})