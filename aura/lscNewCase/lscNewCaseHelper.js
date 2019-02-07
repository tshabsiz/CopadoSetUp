({
    
    primaryTabId2: function primaryTabId2(result2){
        console.log(result2);
        //sforce.console.openSubtab(result2.id , '/apex/ADAPT360?regId=' + regId2 + '&queryType=' + queryType, true, 'CIF: ' + document.getElementById('relname').value, null);
    },
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
    
    closeFocusedTab : function(component) {
        
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        }).catch(function(error) {
            console.log(error);
        });
    },
    navHome : function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Case"
        });
        homeEvent.fire();
    },
    openTab : function(component, event, caseID) {
       
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: caseID,
            focus: true
        }).then(function(response) {
            workspaceAPI.focusTab({
                tabId: response
            });
        }).catch(function(error) {
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
    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('allValues');
                //console.log(allValues);
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
            } else if (state === "INCOMPLETE") {
                // do something
                console.log(state);
                console.log(response.getReturnValue());
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }, 
    navigateToComponent : function(component, event) {
        
        var evt = $A.get("e.force:navigateToComponent");
        
        evt.setParams({
            componentDef : "c:lscCaseEditForm",
            componentAttributes: {
                caseIdAtt : component.get("v.recordId"),
                isCloneAtt : "true"
            }
        });
        
        evt.fire();
    },
    editRecord : function(component, event, cid) {
        
      var editRecordEvent = $A.get("e.force:editRecord");
        
      editRecordEvent.setParams({
             "recordId": cid
      });
      
      editRecordEvent.fire();
   },
    
    openComplainCases : function(component, event, cid) {
       var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:lscCmNewManualCase",
            componentAttributes: {
                'recordId' : cid
            }
        });
        
        evt.fire();
   },
 
    searchSF: function(component, event, helper) {
      
        $A.util.removeClass(component.find("relationships"), "boxshadow");
        
        component.set("v.model.qValue_r", (component.find("regId").get('v.value')).trim());
        component.set("v.model.qType_r", component.find("SearchBy").get('v.value'));
        
        if(component.get("v.model.qType_r") == null ||
           component.get("v.model.qType_r") == 'SearchBy'){
            $A.util.addClass(component.find("SearchBy"), "boxshadow");
            return;
        }else{
            $A.util.removeClass(component.find("SearchBy"), "boxshadow");
        }
        
        if(component.get("v.model.qValue_r") == null ||
           component.get("v.model.qValue_r") == ''){
            $A.util.addClass(component.find("regId"), "boxshadow");
            return;
        }else{
            $A.util.removeClass(component.find("regId"), "boxshadow");
        }
        
        if(component.get("v.model.qType_r") == 'cifDetails'){
           helper.openTab2(component, event);
            return;
        }
        
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
                
                component.set("v.model", JSON.parse(response.getReturnValue()));
                
                component.set("v.accountOptions", component.get("v.model.accountOptions_r"));
                
                console.log(component.get("v.model"));
                
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
                    console.log(state);
                    
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