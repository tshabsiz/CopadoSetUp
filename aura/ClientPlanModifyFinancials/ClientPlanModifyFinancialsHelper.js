({
	getFinancials : function(cmp, financialsId) {
		
        var action = cmp.get("c.getFinancialInformation");
        action.setParams({ "finId" : financialsId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.length == 0) {
                	alert('An error occured during getting data.');
                } else {
                	cmp.set("v.financials", data[0]);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getFinancialsYears : function(cmp, planId) {
        var helper = this;
        
        var action = cmp.get("c.getFinancialsYears");
        action.setParams({ "planId" : planId });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                helper.processFinancialsYears(cmp, data);
                
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    processFinancialsYears : function(cmp, data) {
        var usedYearsMap = {};
        for (var i = 0; i < data.length; i++) {
            usedYearsMap[data[i]] = data[i];
        }
        
        var currentYear = new Date().getFullYear();
        
        var yearsOptions = [];
        for (var year = currentYear; year > currentYear - 5; year--) {
            var isToAdd = typeof usedYearsMap[year] === 'undefined' ? true : false;
            
            if (isToAdd) {
                yearsOptions.push(year);
            }
        }
        cmp.set("v.yearsOptions", yearsOptions);
        
        var selectedYear = yearsOptions.length > 0 ? yearsOptions[0] : 'No year available';
        cmp.set("v.selectedYear", selectedYear);
        cmp.set("v.year", selectedYear.toString());
    },
    moveBack : function(planId) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanFinancials",
            componentAttributes: {planId: planId}
        });
        evt.fire();
    },
    checkDecimalField : function(cmp, field, error) {
        var value = field.get("v.value");
        if (typeof value === 'undefined' || value === '') {
            value = 0;
            field.set("v.value", value);
        }
        
        if (value != null && isNaN(parseFloat(value))) {
        	$A.util.toggleClass(error, "toggle");
            return true;
        } else {
            return false;
        }
    },
    addFinancials : function(cmp, planId, year, turnover, totalAssets, netAssetValue, bearingDebt, cashGenerated, ebitda, ebit,
                                    roe, roa, debtEquity, currentRatio, eps, interestCoverRatio) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addFinancials");
        action.setParams({ 
            "planId" : planId,
            "year" : year,
            "turnover" : turnover,
            "totalAssets" : totalAssets,
            "netAssetValue" : netAssetValue,
            "bearingDebt" : bearingDebt,
            "cashGenerated" : cashGenerated,
            "ebitda" : ebitda,
            "ebit" : ebit,
            "roe" : roe,
            "roa" : roa,
            "debtEquity" : debtEquity,
            "currentRatio" : currentRatio,
            "eps" : eps,
            "interestCoverRatio" : interestCoverRatio
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                	alert('An error occured during adding financial information.');
                } else {
                	helper.moveBack(planId);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during adding financial information.');
            }
        });
        $A.enqueueAction(action);
    },
    editFinancials : function(cmp, planId, financialsId, turnover, totalAssets, netAssetValue, bearingDebt, cashGenerated, ebitda, ebit,
                                    roe, roa, debtEquity, currentRatio, eps, interestCoverRatio) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.editFinancials");
        action.setParams({ 
            "financialsId" : financialsId,
            "turnover" : turnover,
            "totalAssets" : totalAssets,
            "netAssetValue" : netAssetValue,
            "bearingDebt" : bearingDebt,
            "cashGenerated" : cashGenerated,
            "ebitda" : ebitda,
            "ebit" : ebit,
            "roe" : roe,
            "roa" : roa,
            "debtEquity" : debtEquity,
            "currentRatio" : currentRatio,
            "eps" : eps,
            "interestCoverRatio" : interestCoverRatio
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                	alert('An error occured during editing financial information.');
                } else {
                	helper.moveBack(planId);
                }
                
            } else  {
                console.log(response);
                alert('An error occured during editing financial information.');
            }
        });
        $A.enqueueAction(action);
    }
})