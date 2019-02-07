({
	getStrategy : function(cmp, strategyId) {
        
        var helper = this;
		var strategyId = cmp.get("v.strategyId");
        var action = cmp.get("c.getStrategy");
        action.setParams({ 
            "strategyId" : strategyId
        });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data == null) {
                    alert('Strategy was not found!');
                    helper.moveBack(cmp);
                } else {
                	cmp.set("v.strategy", data);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    showEditStrategyComponent : function(cmp) {
        
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyStrategy",
            componentAttributes: {
                strategyId: strategyId,
                planId: planId
            }
        });
        evt.fire();
    },
    onBeforeRemoveStrategy : function(cmp) {
        cmp.set("v.showProgressBar", true);
        
        var timestamp = new Date().getTime();
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        var action = cmp.get("c.removeStrategy");
        action.setParams({ 
            "strategyId" : strategyId
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during removing strategy.');
                } else {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:ClientPlanStrategyList",
                        componentAttributes: {planId: planId, timestamp: timestamp}
                    });
                    evt.fire();
                }
            } else  {
                console.log(response);
                alert('An error occured during removing strategy.');
            }
        });
        $A.enqueueAction(action);
    },
    OnBeforeUnlinkOpty : function(optyId, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var action = cmp.get("c.unlinkOpty");
        action.setParams({ 
            "optyId" : optyId
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during unlinking opportunity.');
                } else {
                    $A.get('e.force:refreshView').fire();
                }
				
            } else  {
                console.log(response);
                alert('An error occured during unlinking opportunity.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeEditPotOpty : function(optyId, cmp) {
    	
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyPotOpty",
            componentAttributes: {
                planId : planId, 
                strategyId : strategyId, 
                optyId : optyId,
                timestamp : new Date().getTime()
            }
        });
        evt.fire();
    },
    onBeforeRemovePotOpty : function(optyId, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var action = cmp.get("c.removePotOpty");
        action.setParams({ 
            "optyId" : optyId
        });
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during removing potential opportunity.');
                } else {
                    $A.get('e.force:refreshView').fire();
                }
				
            } else  {
                console.log(response);
                alert('An error occured during removing potential opportunity.');
            }
        });
        $A.enqueueAction(action);
    },
    showAddPotOptyComponent : function(planId, strategyId) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyPotOpty",
            componentAttributes: {
                planId : planId, 
                strategyId : strategyId, 
                optyId : null,
                timestamp : new Date().getTime()
            }
        });
        evt.fire();
    },
    showAddOptyComponent : function(planId, strategyId) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanAddOpty",
            componentAttributes: {planId: planId, strategyId: strategyId}
        });
        evt.fire();
    },
    showLinkOptyComponent : function(planId, strategyId) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanLinkOpty",
            componentAttributes: {planId: planId, strategyId: strategyId}
        });
        evt.fire();
    },
    showLinkPotOptyComponent : function(planId, strategyId) {
        
    	var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanLinkPotOpty",
            componentAttributes: {planId: planId, strategyId: strategyId}
        });
        evt.fire();
	},
    moveBack : function(cmp) {
        
        var planId = cmp.get("v.planId");
        var timestamp = new Date().getTime();
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanStrategyList",
            componentAttributes: {planId: planId, timestamp: timestamp}
        });
        evt.fire();
    },
    showEditStrategyRichtextComponent : function(cmp, isClient) {
        
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyStrategyRichtext",
            componentAttributes: {planId: planId, strategyId: strategyId, isClient: isClient}
        });
        evt.fire();
    }
})