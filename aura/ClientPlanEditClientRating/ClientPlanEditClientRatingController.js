({
	doInit : function(cmp, event, helper) {
        cmp.set("v.doDoneRendering", true);
        helper.getRatingMetadata(cmp);
        helper.getClientPlan(cmp);
	},
    doneRendering : function(cmp, event, helper) {
        var doDoneRendering = cmp.get("v.doDoneRendering");
        
        if (doDoneRendering && typeof cmp.get("v.financialYearEndOptions") !== 'undefined') {
            cmp.set("v.doDoneRendering", false);
            
            //setting default value of fais status
            var fais = cmp.get("v.plan.FAIS_Status__c");
            if (fais != null) {
                cmp.find("fais").set("v.value", fais);
            } else {
				var faisOptions = cmp.get("v.faisOptions");
                if (faisOptions.length > 0) {
                    cmp.find("fais").set("v.value", faisOptions[0]);
                }                
            }
            
            //setting default value of financial year end
            var financialYearEnd = cmp.get("v.plan.Financial_Year_End__c");
            if (financialYearEnd != null) {
                cmp.find("financialYearEnd").set("v.value", financialYearEnd);
            } else {
                var financialYearEndOptions = cmp.get("v.financialYearEndOptions");
                if (financialYearEndOptions.length > 0) {
                    cmp.find("financialYearEnd").set("v.value", financialYearEndOptions[0]);
                }
            }
        }
    },
    moveBack : function(cmp, event, helper) {
        var id = cmp.get("v.planId");
        helper.moveBack(id);
    },
    onBeforeModifyClientRating : function(cmp, event, helper) {
        var tfl = cmp.find("tfl").get("v.value");
        tfl = tfl == 'undefined' ? null : tfl;
        
        var fais = cmp.find("fais").get("v.value");
        fais = fais == 'undefined' ? null : fais;
        
        var lastReviewDate = cmp.find("lastReviewDate").get("v.value");
        lastReviewDate = lastReviewDate == 'undefined' ? null : lastReviewDate;
        if (lastReviewDate != null) {
            var lastReviewDateSplit = lastReviewDate.split('-');
            lastReviewDate = new Date(lastReviewDateSplit[0], lastReviewDateSplit[1] - 1, lastReviewDateSplit[2]).getTime();
            
            var nowStamp = new Date().getTime();
            if (lastReviewDate > nowStamp) {
                var lastReviewDateError = cmp.find("lastReviewDateError");
        		$A.util.toggleClass(lastReviewDateError, "toggle");
                return;
            }
        }
        
        var financialYearEnd = cmp.find("financialYearEnd").get("v.value");
        financialYearEnd = financialYearEnd == 'undefined' ? null : financialYearEnd;
        
        var latestAudited = cmp.find("latestAudited").get("v.value");
        latestAudited = latestAudited == 'undefined' ? null : latestAudited;
        if (latestAudited != null) {
            var latestAuditedSplit = latestAudited.split('-');
            latestAudited = new Date(latestAuditedSplit[0], latestAuditedSplit[1] - 1, latestAuditedSplit[2]).getTime();
            
            var nowStamp = new Date().getTime();
            if (latestAudited > nowStamp) {
                var latestAuditedError = cmp.find("latestAuditedError");
        		$A.util.toggleClass(latestAuditedError, "toggle");
                return;
            }
        }
        
        cmp.set("v.showProgressBar", true);
        helper.modifyClientRating(cmp, tfl, fais, lastReviewDate, financialYearEnd, latestAudited);
    }
})