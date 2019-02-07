({
	doInit : function(component, event, helper) {
		
        
        //Tonga : MM Call server side Method
        var action = component.get("c.isAFricaRDOwned");
        action.setParams({ accountId : component.get("v.recordId") });
        
        var actionCreateClientplan = component.get("c.createClientPlan");
        actionCreateClientplan.setParams({ accountId : component.get("v.recordId") });
        
        var msg;
        actionCreateClientplan.setCallback(this, function(response){
           	msg =  response.getReturnValue();
        });
        
        
        //Tonga : MM callback function for verifying Coverage Unmanaged previously Africa RD Holder
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var approved = response.getReturnValue();
                
                if(approved)
                {
                    
                    if(msg == "false")
                    {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Error",
                            "message": "You cannot create a Client Plan for this relationship because one already exists or you are not a member of the Client Relationship Team."
                        });
                        resultsToast.fire();
                        dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }
                    else
                    {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": '/apex/ClientPlanDetails?planId=' + msg + '&newPlan=true'
                        });
                        urlEvent.fire();
                    }
                    
                    
                }
                else
                {
                    var lbl_Coverage_Unmanaged = $A.get("$Label.c.lbl_Coverage_Unmanaged");
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Call Report have been disabled for Relationships owned by "+lbl_Coverage_Unmanaged,
                        "type" : "error"
                    });
                    resultsToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    
                }
                
            }
            else if (state === "INCOMPLETE") {
                
            }
        });
        $A.enqueueAction(actionCreateClientplan);
        $A.enqueueAction(action);
        
	}
})