({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner1");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner1");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
        
    },
    addShadow: function(component, event, fieldId){        
        var element = component.find(fieldId);
        $A.util.addClass(element, "boxshadow");
        return true;
    },
    
    removeShadow: function(component, event, fieldId){
        var element = component.find(fieldId);
        $A.util.removeClass(element, "boxshadow");
        return true;
    },
    
    openComplainCases : function(component, event, cid) {
        
          var workspaceAPI = component.find("workspace");
       
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
             var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:lscCmNewManualCase",
                componentAttributes: {
                    'recordId' : cid,
                    'tabId': focusedTabId
                }
            });
            
            evt.fire();
            
        })
        .catch(function(error) {
            console.log(error);
        });      
    },
    
    openCaseRecordType : function(component, event, cid) {        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:NewCaseRecordTypeSelection",
                componentAttributes: {
                    'recordId' : cid,
                    'tabId': focusedTabId
                }
            });
            
            evt.fire();
        })
        .catch(function(error) {
            console.log(error);
        });       
        
    },
    
    navigateToDetailPage : function (component, event, ID) {
        
       var workspaceAPI = component.find("workspace");
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        
        }).then(function(response){
              var navEvt = $A.get("e.force:navigateToSObject");
              navEvt.setParams({"recordId": ID});
            
        navEvt.fire();
        workspaceAPI.openTab({
               recordId: ID
            }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
       });

            
        })
        .catch(function(error) {
            console.log(error);
        });

      
    },
    

    
     viewCifDetails : function(component, event) {
        var workspaceAPI = component.find("workspace");        
        var selectedCIF;        
        component.get("v.accountOptions").forEach(function(element) {
            console.log(element)
            if(element.Id == component.find("relationships").get("v.value")){
                
                selectedCIF = element.cif;
            }
        });
         
          if(selectedCIF == null){
              selectedCIF = '';
          }
         
        workspaceAPI.getEnclosingTabId()
        .then(function(tabId) {
            workspaceAPI.openSubtab({
                parentTabId: tabId,
                url:'https://'+component.get('v.model.vfUrl') +'/apex/ADAPT360?regId='+ selectedCIF.toUpperCase()+ '&queryType=' + component.get("v.model.qType_r"),
                focus: true
            }).then(function(response) {
                console.log(response);
            })})
        .catch(function(error) {
            console.log(error);
        });
        
    },
    
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    getFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            
            return focusedTabId;
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    setFocusedTabLabel : function(component,tabName) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: tabName
            });
            
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "action:new_case",
                iconAlt: "New Case"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    editRecord : function(component, event, cid) {
        
        var editRecordEvent = $A.get("e.force:editRecord");
        // var editRecordEvent = $A.get("e.force:navigateToSObject");
        
        editRecordEvent.setParams({
            "recordId": cid
        });
        editRecordEvent.fire();
    },
    closeThisTab : function(component, event, tabId) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({tabId: tabId});
    },
    
    searchSF: function(component, event, helper){
        helper.removeShadow(component, event,'relationships');
        
        component.set("v.model.qValue_r", (component.find("regId").get('v.value')).trim())
        component.set("v.model.qType_r", component.find("SearchBy").get('v.value'));
        
        if(component.get("v.model.qType_r") === null ||
           component.get("v.model.qType_r") === 'SearchBy'){
            helper.addShadow(component, event,'SearchBy'); 
            return;
        }else{
            helper.removeShadow(component, event,'SearchBy'); 
        }
        
        if(component.get("v.model.qValue_r") === null ||
           component.get("v.model.qValue_r") === ''){
            helper.addShadow(component, event,'regId'); 
            return;
        }else{
            helper.removeShadow(component, event,'regId'); 
        }
        /*
          if(component.get("v.model.qType_r") === 'cifDetails'){
            helper.openTab2(component, event);
            return;
        } 
        */
        helper.showSpinner(component, event, helper);
        component.set("v.model.relCIF_r", '');
        component.set("v.model.relID_r", '');
        
        component.set("v.model.relName_r", '');
        component.set("v.model.relID_r", '');
        
        component.set("v.model.cifdataOptions_r", []);
        
        
        component.set("v.model.PrimaryClients_r", []);
        component.set("v.model.PrimaryClient_r", null);
        
        component.set("v.model.accountOptions_r", []);
        component.set("v.model.Client_Details_r", []);
        
        var action = component.get("c.searchSalesforceAccounts");
        action.setParams({
            model : JSON.stringify(component.get("v.model"))
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                helper.hideSpinner(component, event, helper);
                console.log(JSON.parse(response.getReturnValue()));
                
                component.set("v.model", JSON.parse(response.getReturnValue()));                
                component.set("v.accountOptions", component.get("v.model.accountOptions_r"));
                
                if(component.get("v.model.ResponseMessage_r").length > 0){
                    var toastEvent = $A.get("e.force:showToast");
                    
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        "type":"warning"
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                helper.addShadow(component, event,'relationships');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    "title": "INCOMPLETE!",
                    "message": response.getReturnValue(),
                    "type":"error"
                });
                
                toastEvent.fire();
                
            }
                else if (state === "ERROR") {
                    helper.hideSpinner(component, event, helper);
                    helper.addShadow(component, event,'relationships');
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                "title": "Error!",
                                "message": errors[0].message,
                                "type":"error"
                            });
                            
                            toastEvent.fire();
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                "title": "Error!",
                                "message": 'An error ocured',
                                "type":"error"
                            });
                            
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            "title": "Error!",
                            "message": "Unknown error",
                            "type":"error"
                        });
                        
                        toastEvent.fire();
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    
})