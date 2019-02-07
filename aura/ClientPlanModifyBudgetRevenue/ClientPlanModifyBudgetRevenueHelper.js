({
	getBR : function(cmp) {
		var brId = cmp.get("v.brId");
        var action = cmp.get("c.getBudgetRevenue");
        action.setParams({ "brId" : brId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.length == 0) {
                	alert('An error occured during getting data.');
                } else {
                	cmp.set("v.br", data[0]);
                    cmp.set("v.productId", data[0].Product_Level_3__c);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    moveBack : function(planId) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanPlan",
            componentAttributes: {planId: planId}
        });
        evt.fire();
    },
    checkField : function(value) {
        
        if (isNaN(parseFloat(value))) {
            return 0;
        } else {
            return parseFloat(value);
        }
    },
    onBeforeAddBudgetRevenue : function(cmp, product, previousYtdRevenues, ytdAnnualizedRevenues,
                                        budgetYtd, actYearAnnRev, annBudget, nextYearBudget, actRwa, actRorwa) {
        
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.addBudgetRevenue");
        action.setParams({
            "planId" : planId,
            "product" : product,
            "previousYtdRevenues" : previousYtdRevenues,
            "ytdAnnualizedRevenues" : ytdAnnualizedRevenues,
            "budgetYtd" : budgetYtd,
            "actYearAnnRev" : actYearAnnRev,
            "annBudget" : annBudget,
            "nextYearBudget" : nextYearBudget,
            "actRwa" : actRwa,
            "actRorwa" : actRorwa
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during saving.');
                } else {
                    helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during saving.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeEditBudgetRevenue : function(cmp, brId, product, previousYtdRevenues, ytdAnnualizedRevenues,
                                           budgetYtd, actYearAnnRev, annBudget, nextYearBudget, actRwa, actRorwa) {
        
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.editBudgetRevenue");
        action.setParams({ 
            "brId" : brId,
            "product" : product,
            "previousYtdRevenues" : previousYtdRevenues,
            "ytdAnnualizedRevenues" : ytdAnnualizedRevenues,
            "budgetYtd" : budgetYtd,
            "actYearAnnRev" : actYearAnnRev,
            "annBudget" : annBudget,
            "nextYearBudget" : nextYearBudget,
            "actRwa" : actRwa,
            "actRorwa" : actRorwa
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editation.');
                } else {
                    helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during editation.');
            }
        });
        $A.enqueueAction(action);
    }
})