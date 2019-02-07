({
	doInit : function(cmp, event, helper) {
        cmp.set("v.doDoneRendering", true);
        helper.getClientPlanInfoMetadata(cmp);
        helper.getClientPlan(cmp);
	},
    doneRendering : function(cmp, event, helper) {
        var doDoneRendering = cmp.get("v.doDoneRendering");
        
        if (doDoneRendering && typeof cmp.get("v.stageOptions") !== 'undefined') {
            cmp.set("v.doDoneRendering", false);
            
            //setting default value of stage
            var stage = cmp.get("v.plan.plan.Status__c");
            if (stage != null) {
                cmp.find("stage").set("v.value", stage);
            } else {
				var stageOptions = cmp.get("v.stageOptions");
                if (stageOptions.length > 0) {
                    cmp.find("stage").set("v.value", stageOptions[0]);
                }                
            }
            
            //setting default value of expansion policy
            var expansionPolicy = cmp.get("v.plan.plan.Expansion_Policy__c");
            if (expansionPolicy != null) {
                cmp.find("expansionPolicy").set("v.value", expansionPolicy);
            } else {
                var expansionPolicyOptions = cmp.get("v.expansionPolicyOptions");
                if (expansionPolicyOptions.length > 0) {
                    cmp.find("expansionPolicy").set("v.value", expansionPolicyOptions[0]);
                }
            }
            
            //setting default value of dg
            var dg = cmp.get("v.plan.plan.DG__c");
            if (dg != null) {
                cmp.find("dg").set("v.value", dg);
            } else {
                var dgOptions = cmp.get("v.dgOptions");
                if (dgOptions.length > 0) {
                    cmp.find("dg").set("v.value", dgOptions[0]);
                }
            }
        }
    },
    moveBack : function(cmp, event, helper) {
        var id = cmp.get("v.planId");
        helper.moveBack(id);
    },
    onBeforeModifyClientPlanInfo : function(cmp, event, helper) {
        var stage = cmp.find("stage").get("v.value");
        stage = stage == 'undefined' ? null : stage;
        
        var expansionPolicy = cmp.find("expansionPolicy").get("v.value");
        expansionPolicy = expansionPolicy == 'undefined' ? null : expansionPolicy;
        
        var dg = cmp.find("dg").get("v.value");
        dg = dg == 'undefined' ? null : dg;
        
        var lgd = cmp.find("lgd").get("v.value");
        if (typeof lgd === 'undefined' || lgd === '') {
            lgd = 0;
        }
        
        if (lgd != null && isNaN(parseFloat(lgd))) {
            var lgdError = cmp.find("lgdError");
        	$A.util.toggleClass(lgdError, "toggle");
            return;
        }
        
        cmp.set("v.showProgressBar", true);
        helper.modifyClientPlanInfo(cmp, stage, expansionPolicy, dg, lgd);
    }
})