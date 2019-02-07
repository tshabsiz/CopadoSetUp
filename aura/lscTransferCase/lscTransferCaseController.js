({
	clickTransfer : function(component, event, helper) {
        
        helper.showSpinner(component);
        
        var action = component.get("c.transferCase");
  
        
        action.setParams({
            "caseId":component.get("v.recordId"),
            "qname":component.find("qnames").get("v.value")
        });
       
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
         
        var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS") {

                // show success notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Case successfully transferred",
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
    }
})