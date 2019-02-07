({
	doInit : function(cmp, event, helper) {
        cmp.set("v.doDoneRendering", true);
		helper.getMetadata(cmp);
	},
    doneRendering : function(cmp, event, helper) {
        var doDoneRendering = cmp.get("v.doDoneRendering");
        
        if (doDoneRendering) {
            cmp.find("stage").set("v.value", "Identified");
            cmp.find("type").set("v.value", "Cross Sell");
            cmp.set("v.doDoneRendering", false);
        }
    },
    onStageChanged : function(cmp, event, helper) {
     	helper.setProbability(cmp);
    },
    moveBack : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        helper.moveBack(planId, strategyId);
    },
    onBeforeAddOpty : function(cmp, event, helper) {
        var name = cmp.find("name").get("v.value");
        if (typeof name === 'undefined' || name.trim().length == 0) {
            var nameError = cmp.find("nameError");
        	$A.util.toggleClass(nameError, "toggle");
            return;
        }
        
        var closeDate = cmp.find("closeDate").get("v.value");
        if (closeDate == null || closeDate.split('-').length != 3) {
            var closeDateError = cmp.find("closeDateError");
        	$A.util.toggleClass(closeDateError, "toggle");
            return;
        }
        
        var stage = cmp.find("stage").get("v.value");
        stage = helper.checkUndefinedField(stage);
        
        var probability = cmp.find("probability").get("v.value");
        probability = helper.checkUndefinedField(probability);
        
        var type = cmp.find("type").get("v.value");
        type = helper.checkUndefinedField(type);
        
        helper.onBeforeAddOpty(cmp, name, closeDate, stage, probability, type);
    }
})