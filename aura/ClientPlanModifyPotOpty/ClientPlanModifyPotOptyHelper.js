({
	getMetadata : function(cmp) {
        
		var action = cmp.get("c.getPotOptyMetadata");
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.stageOptions", data.stage);
                cmp.set("v.typeOptions", data.type);
				
            } else {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getPotOpty : function(cmp, optyId) {
      	
        var action = cmp.get("c.getPotOpty");
		action.setParams({
            "optyId" : optyId
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.length == 1) {
                    cmp.set("v.opty", data[0]);
                    cmp.set("v.productId", data[0].Product_Level_3__c);
                } else {
                    alert('An error occured during getting data.');
                }
				
            } else {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    setProbability : function(cmp) {
        
        var stage = cmp.find("stage").get("v.value");
        
        var probability;
        if (stage == 'Potential Opportunity Convert') {
            probability = 5;
        } else if (stage == 'Potential Opportunity Engaged') {
            probability = 3;
        } else {
            probability = 1;
        }
        cmp.find("probability").set("v.value", probability);
    },
    checkUndefinedField : function(value) {
        return value == 'undefined' ? null : value;
    },
    moveBack : function(planId, strategyId) {
        
        var evt = $A.get("e.force:navigateToComponent");
        
        if (strategyId != null) {
            evt.setParams({
                componentDef: "c:ClientPlanStrategyDetail",
                componentAttributes: {planId: planId, strategyId: strategyId}
            });
        } else {
            evt.setParams({
            componentDef: "c:ClientPlanPlan",
            componentAttributes: {planId: planId}
        });
        }
        evt.fire();
    },
    onBeforeAddPotOpty : function(cmp, name, closeDate, product, stage, probability, type) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addPotOpty");
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        
        action.setParams({
            "planId" : planId,
            "strategyId" : strategyId,
            "name" : name,
            "closeDate" : closeDate,
            "product" : product,
            "stage" : stage,
            "probability" : probability,
            "type" : type
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during adding potential opportunity.');
                } else {
                    helper.moveBack(planId, strategyId);
                }
				
            } else {
                console.log(response);
                alert('An error occured during adding potential opportunity.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeEditPotOpty : function(cmp, optyId, name, closeDate, product, stage, probability, type) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var strategyId = cmp.get("v.strategyId");
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.editPotOpty");
        
        action.setParams({
            "optyId" : optyId,
            "name" : name,
            "closeDate" : closeDate,
            "product" : product,
            "stage" : stage,
            "probability" : probability,
            "type" : type
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editation.');
                } else {
                    helper.moveBack(planId, strategyId);
                }
				
            } else {
                console.log(response);
                alert('An error occured during editation.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeConvertPotOpty : function(cmp) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var planId = cmp.get("v.planId");
        var optyId = cmp.get("v.optyId");
        var strategyId = cmp.get("v.strategyId");
        var action = cmp.get("c.convertUnqOpty");
        
        action.setParams({
            "optyId" : optyId
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during conversion.');
                } else {
                    helper.moveBack(planId, strategyId);
                }
				
            } else {
                console.log(response);
                alert('An error occured during conversion.');
            }
        });
        $A.enqueueAction(action);
    }
})