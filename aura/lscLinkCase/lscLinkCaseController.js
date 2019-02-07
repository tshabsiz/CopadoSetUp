/**
* 2018-02-27
* Rudolf Niehaus - CloudSmiths
* 
**/
({
	doInit : function(component, event, helper){
        
         helper.showSpinner(component);
        
        var parentCase = component.get("v.recordId");
        var action = component.get("c.getRelatedCase");
        
        action.setParams({ 
          "parentCaseId":parentCase
        });
        
        action.setCallback(this, function(a){
           component.set("v.relatedCaseList", a.getReturnValue());
           helper.hideSpinner(component); 
        });
         
        $A.enqueueAction(action);
        
    },
    clickSearch : function(component, event, helper) {
        
        helper.showSpinner(component);
        
        var action = component.get("c.searchCases");

        action.setParams({
            "caseId":component.get("v.recordId"),
            "searchCaseNumber":component.get("v.caseNr"),
            "searchSubject":component.get("v.caseSub")
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
         
            var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.relatedCaseList", response.getReturnValue());
                
                helper.hideSpinner(component);
            }
       });

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    clickLink : function(component, event, helper) {
        
        helper.showSpinner(component);
        
        var action = component.get("c.linkEmailToCase");

        action.setParams({
            "selectedCaseId":component.get("v.relatedCaseId"),
            "linkCaseId":component.get("v.recordId")
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
         
            var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS") {
    
                // show success notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email linked to selected related Case",
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
    openNewTab : function(component, event, helper){
         var caseId = event.getSource().get("v.title");
         helper.openTab(component, event, caseId);
    },
    logId : function(component, event, helper){
        var selectedCaseId = event.getSource().get("v.text");
        component.set("v.relatedCaseId", selectedCaseId);
    },
})