({
	clickSpam : function(component, event, helper) {
        
        helper.showSpinner(component);
        
        var action = component.get("c.flagCase");
        
        action.setParams({
            "caseId":component.get("v.recordId"),
            "theAction":"Flag as Spam / Junk"
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
         
        var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS") {

                // show success notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Case flagged as Spam",
                    "type":"success"
                });
                
                toastEvent.fire();
                helper.hideSpinner(component);
                
                helper.closeFocusedTab(component);
                helper.navHome(component, event, helper);
                 // refresh record detail
                $A.get("e.force:refreshView").fire();
            }
       });

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    clickDuplicate : function(component, event, helper) {
        
        helper.showSpinner(component);
        
        var action = component.get("c.flagCase");
        
        action.setParams({
            "caseId":component.get("v.recordId"),
            "theAction":"Flag as Duplicate"
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
         
        var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS") {

                // show success notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Case flagged as Duplicate",
                    "type":"success"
                });

                toastEvent.fire();
                helper.hideSpinner(component);
                
                helper.closeFocusedTab(component);
                helper.navHome(component, event, helper);
                
                //Refresh the related list after the home navigation
                $A.get("e.force:refreshView").fire();
            }
       });

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    clickOOO : function(component, event, helper) {
        
        helper.showSpinner(component);
        
        var action = component.get("c.flagCase");
        
        action.setParams({
            "caseId":component.get("v.recordId"),
            "theAction":"Flag as Out of Office"
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
         
        var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS") {
                

                // show success notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Case flagged as Out-of-Office",
                    "type":"success"
                });
                
                toastEvent.fire();
                helper.hideSpinner(component);
                
                helper.closeFocusedTab(component);
                helper.navHome(component, event, helper);
                
                //Refresh the related list after the home navigation
                $A.get("e.force:refreshView").fire();
            }
       });

        // Send action off to be executed
        $A.enqueueAction(action);
    }
})