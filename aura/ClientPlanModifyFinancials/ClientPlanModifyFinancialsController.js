({
	doInit : function(cmp, event, helper) {
        cmp.set("v.doDoneRendering", true);
        
        var financialsId = cmp.get("v.financialsId");
        if (financialsId != null) {
			helper.getFinancials(cmp, financialsId);
        } else {
            var planId = cmp.get("v.planId");
            helper.getFinancialsYears(cmp, planId);
        }
	},
    moveBack : function(cmp, event, helper) {
     	var planId = cmp.get("v.planId");
        helper.moveBack(planId);
    },
    onBeforeModifyFinancials : function(cmp, event, helper) {
        var year = cmp.get("v.year");
        if (year == 'No year available') {
            var yearError = cmp.find("yearError");
        	$A.util.toggleClass(yearError, "toggle");
            return;
        }
        
        var hasError = false;
        hasError = helper.checkDecimalField(cmp, cmp.find("turnover"), cmp.find("turnoverError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("totalAssets"), cmp.find("totalAssetsError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("netAssetValue"), cmp.find("netAssetValueError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("bearingDebt"), cmp.find("bearingDebtError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("cashGenerated"), cmp.find("cashGeneratedError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("ebitda"), cmp.find("ebitdaError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("ebit"), cmp.find("ebitError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("roe"), cmp.find("roeError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("roa"), cmp.find("roaError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("debtEquity"), cmp.find("debtEquityError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("currentRatio"), cmp.find("currentRatioError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("eps"), cmp.find("epsError"));
        if (hasError) return;
        
        hasError = helper.checkDecimalField(cmp, cmp.find("interestCoverRatio"), cmp.find("interestCoverRatioError"));
        if (hasError) return;
        
        if (!hasError) {
            var turnover = cmp.find("turnover").get("v.value");
            var totalAssets = cmp.find("totalAssets").get("v.value");
            var netAssetValue = cmp.find("netAssetValue").get("v.value");
            if (netAssetValue < 20000000) {
             	alert('This is a FAIS impacted client and the status must read applicable.');   
            }
            
            var bearingDebt = cmp.find("bearingDebt").get("v.value");
            var cashGenerated = cmp.find("cashGenerated").get("v.value");
            var ebitda = cmp.find("ebitda").get("v.value");
            var ebit = cmp.find("ebit").get("v.value");
            var roe = cmp.find("roe").get("v.value");
            var roa = cmp.find("roa").get("v.value");
            var debtEquity = cmp.find("debtEquity").get("v.value");
            var currentRatio = cmp.find("currentRatio").get("v.value");
            var eps = cmp.find("eps").get("v.value");
            var interestCoverRatio = cmp.find("interestCoverRatio").get("v.value");
            
            var financialsId = cmp.get("v.financialsId");
            var planId = cmp.get("v.planId");
            
            if (financialsId == null) {
                helper.addFinancials(cmp, planId, year, turnover, totalAssets, netAssetValue, bearingDebt, cashGenerated, ebitda, ebit,
                                    roe, roa, debtEquity, currentRatio, eps, interestCoverRatio);
            } else {
                helper.editFinancials(cmp, planId, financialsId, turnover, totalAssets, netAssetValue, bearingDebt, cashGenerated, ebitda, ebit,
                                    roe, roa, debtEquity, currentRatio, eps, interestCoverRatio);
            }
        }
    },
    onYearChanged : function(cmp, event, helper) {
        var value = event.getParam("value");
        cmp.set("v.year", value);
    }
})