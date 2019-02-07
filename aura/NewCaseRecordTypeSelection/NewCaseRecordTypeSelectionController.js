({
    
    doInit  : function(component, event, helper) { 
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {

            if(response){
                 helper.serviceNavigation(component, event, helper);
            }else{
                 helper.salesNavigation(component, event, helper);
            }
        })
        .catch(function(error) {
            console.log(error);
        });
        
         		
        /*
              
        helper.showSpinner(component, event, helper);
        var action = component.get("c.GetRecordTypeIds");
        action.setParams({});
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {   
                helper.hideSpinner(component, event, helper);
                component.set("v.isOpen", true);
                
                var model = JSON.parse(response.getReturnValue());
                
                var options = [];
                for(var i = 0; i < model.length; i++){
                    options.push({
                        'label':model[i].label,
                        'value':model[i].value,
                        'recordId': model[i].recordId,
                        'selected': model[i].label == component.get('v.DefaultSelected') 
                    });
                    if(model[i].label == component.get('v.DefaultSelected'))
                        component.set("v.recordTypeDescription",model[i].value);
                }
                
                
                component.set("v.model", model);
                component.set("v.options", options);    
                
                
                var recordId =  component.get("v.recordId");
                var tabId =  component.get("v.tabId");
                if(recordId != '' && tabId != '')
                {
                   component.set("v.isOpen", false);
                    helper.closeThisTab(component, event, tabId);
                    //helper.closeFocusedTab(component, event, tabId);
                    helper.navigateToDetailPage(component, event, recordId);
                }
                
            }else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "INCOMPLETE!",
                    "message": response.getReturnValue(),
                    "type":"error"
                });
                
                toastEvent.fire();
                
            }else if (state === "ERROR") {
                
                helper.hideSpinner(component, event, helper);
                
                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {                            
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": errors[0].message,
                            "type":"error"
                        });
                        
                        toastEvent.fire();
                        
                    }else{
                        
                        var toastEvent = $A.get("e.force:showToast");
                        
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": 'An error ocured',
                            "type":"error"
                        });
                        
                        toastEvent.fire();
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Unknown error",
                        "type":"error"
                    });
                    
                    toastEvent.fire();
                }
            }
        });
        
        $A.enqueueAction(action);
*/        
    },
    
    recordTypeChanged: function(component, event, helper) {
        var Id = component.find("recordTypes").get("v.value"); 
        var options= component.get("v.options");
        for(var i = 0; i < options.length; i++){
            if(options[i].recordId == Id){
                component.set("v.recordTypeDescription",options[i].value );
            }
        }
        
    },
    
    closeModal: function(component, event, helper) {
        // set "isOpen" attribute to false for hide/close model box 
        component.set("v.isOpen", false);
        //helper.closeFocusedTab(component, event, helper);
        helper.closeFocusedTab(component, event, helper)
    },
    
    next: function(component, event, helper) {
       
        var Id = component.find("recordTypes").get("v.value"); 
        var options= component.get("v.options");
        var componentName = 'c:lscCscNewManualCase';
        for(var i = 0; i < options.length; i++){
            if(options[i].recordId == Id){
                
                if(options[i].label === 'Digital Ops Cases'){
                    componentName = 'c:lscDosNewManualCase';
                    break;
                }
                
                if(options[i].label === 'Complaint'){
                    componentName = 'c:lscCmNewManualCase';
                    break;
                }
                break;
            }
        }
        var evt = $A.get("e.force:navigateToComponent");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            evt.setParams({
                componentDef : componentName,
                componentAttributes: {
                    tabId:focusedTabId
                }
            });
            
            try{
                evt.fire();
            }
            catch(err)
            {
                console.log(err);
            }
        })
        .catch(function(error) {
            console.log(error);
        });
        
        
        
    },
    
    openModal: function(component, event, helper) {
        // set "isOpen" attribute to true to show model box
        component.set("v.isOpen", true);
    },
    
    
    
})