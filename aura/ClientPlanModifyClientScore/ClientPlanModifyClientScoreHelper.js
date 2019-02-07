({
	prepareScoreAreaBullets : function(cmp) {
        var uniqueKey = cmp.get("v.uniqueKey");
        
        $('.area' + uniqueKey).unbind('keydown');
        
        $('.area' + uniqueKey).on('keydown',function(e) {
            var t = $(this);
            switch(e.which) {
                case 13:
                    t.val(t.val()+'\n• ');
                    return false;
            }
            e.stopImmediatePropagation();
        });
        
        var description = $('.area' + uniqueKey).val();
        var bulletsFixed = cmp.get("v.bulletsFixed");
        if (typeof description !== 'undefined' && !bulletsFixed) {
        	description = description.replace(new RegExp('•', 'g'), '\n•');
            
            if (description.indexOf('\n') == 0) {
            	description = description.substring(1, description.length);
            }
        	$('.area' + uniqueKey).val(description);
            cmp.set("v.bulletsFixed", true);
        }
	},
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
    addScore : function(name, description, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var planId = cmp.get("v.planId");
        var scoreType = cmp.get("v.scoreType");
        
        var action = cmp.get("c.addScore");
        action.setParams({ 
            "planId" : planId,
            "name" : name,
            "description" : description,
            "scoreType" : scoreType
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
    editScore : function(scoreId, name, description, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var planId = cmp.get("v.planId");
        var action = cmp.get("c.editScore");
        action.setParams({ 
            "scoreId" : scoreId,
            "name" : name,
            "description" : description
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