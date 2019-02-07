({
	moveBack : function(id) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanOverview",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    hasContent : function(toCheck) {
        
        if (toCheck.length > 0) {
            return true;
        } else {
            return false;
        }
    },
    addItem : function(department, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var planId = cmp.get("v.planId");
        var relatedTo = cmp.get("v.relatedTo");
        var isBelow;
        
        if (relatedTo != '') {
            isBelow = relatedTo.startsWith('sub-') ? true : false;
            relatedTo = relatedTo.split('-')[1];
        } else {
            isBelow = true;
        }
        
        var action = cmp.get("c.addOrgItem");
        action.setParams({ 
            "planId" : planId,
            "department" : department,
            "relatedTo" : relatedTo,
            "isBelow" : isBelow
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var hasError = response.getReturnValue();
                if (hasError) {
                    alert('An error occured during adding item.');
                } else {
                    this.moveBack(planId);
                }
            } else {
                console.log(response);
                alert('An error occured during adding item.');
            }
        });
        $A.enqueueAction(action);
    },
    editItem : function(department, itemId, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.editOrgItem");
        action.setParams({ 
            "department" : department,
            "itemId" : itemId
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var hasError = response.getReturnValue();
                if (hasError) {
                    alert('An error occured during editing item.');
                } else {
                    this.moveBack(planId);
                }
            } else {
                console.log(response);
                alert('An error occured during editing item.');
            }
        });
        $A.enqueueAction(action);
    }
})