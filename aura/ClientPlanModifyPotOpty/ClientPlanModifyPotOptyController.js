({
	doInit : function(cmp, event, helper) {
        cmp.set("v.doDoneRendering", true);
        
		helper.getMetadata(cmp);
        
        var optyId = cmp.get("v.optyId");
        if (optyId != null) {
            helper.getPotOpty(cmp, optyId);
        }
	},
    doneRendering : function(cmp, event, helper) {
        var doDoneRendering = cmp.get("v.doDoneRendering");
        
        if (doDoneRendering) {
            var opty = cmp.get("v.opty");
            var optyId = cmp.get("v.optyId");
            
            if (optyId == null) {
                cmp.find("stage").set("v.value", "Potential Opportunity Identified");
                cmp.find("type").set("v.value", "Cross Sell");
                helper.setProbability(cmp);
                cmp.set("v.doDoneRendering", false);
            } else if (typeof opty !== 'undefined') {
                cmp.find("stage").set("v.value", opty.Stage__c);
                cmp.find("type").set("v.value", opty.Type__c);
                cmp.find("probability").set("v.value", opty.Probability__c);
                cmp.set("v.doDoneRendering", false);
            }
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
    onBeforeAddPotOpty : function(cmp, event, helper) {
        var name = cmp.find("name").get("v.value");
        if (typeof name === 'undefined' || name.trim().length == 0) {
            var nameError = cmp.find("nameError");
        	$A.util.toggleClass(nameError, "toggle");
            return;
        }
        
        var closeDate = cmp.find("closeDate").get("v.value");
        closeDate = helper.checkUndefinedField(closeDate);
        if (closeDate != null) {
            var closeDateSplit = closeDate.split('-');
            closeDate = new Date(closeDateSplit[0], closeDateSplit[1] - 1, closeDateSplit[2]).getTime();
        }
        
        var product = cmp.get("v.productId");
        if (typeof product === 'undefined') {
            product = null;
        }
        
        var stage = cmp.find("stage").get("v.value");
        if (typeof stage === 'undefined') {
            stage = 'Potential Opportunity Identified';
        }
        
        var probability = cmp.find("probability").get("v.value");
        probability = helper.checkUndefinedField(probability);
        
        var type = cmp.find("type").get("v.value");
        if (typeof type === 'undefined') {
            type = 'Cross Sell';
        }
        
        var optyId = cmp.get("v.optyId");
        if (optyId == null) {
        	helper.onBeforeAddPotOpty(cmp, name, closeDate, product, stage, probability, type);
        } else {
            helper.onBeforeEditPotOpty(cmp, optyId, name, closeDate, product, stage, probability, type);
        }
    },
    onBeforeConvertPotOpty : function(cmp, event, helper) {
        var closeDate = cmp.find("closeDate").get("v.value");
        closeDate = helper.checkUndefinedField(closeDate);
        if (closeDate == null) {
            var closeDateError = cmp.find("closeDateError");
        	$A.util.toggleClass(closeDateError, "toggle");
            return;
        }
        
        var proceed = confirm('Opportunity will be created and potential opportunity will not be editable anymore. Proceed?');
        
        if (proceed) {
            helper.onBeforeConvertPotOpty(cmp);
        }
	},
    onProductSelected : function(cmp, event, helper) {
    	var productId = event.getParam("productId");
        cmp.set("v.productId", productId);
	}
})