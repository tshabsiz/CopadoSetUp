({
    doInit  : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        
        var recordId  = component.get("v.recordId");
        var action = component.get("c.GetAccount");
        //alert(component.get("v.recordId"));
        action.setParams({
            model : '',
            recordId: recordId,
            comptaint : component.get("v.comptaint"),
            RecordType: component.get("v.RecordType"),
            cas4_lkid: component.get("v.cas4_lkid")
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {   
                
                helper.hideSpinner(component, event, helper);
                //alert(response.getReturnValue());return;
                var model = JSON.parse(response.getReturnValue());
                console.log(model);
                component.set("v.model", model);
                component.set("v.accountOptions", model.accountOptions_r);
                
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
                            console.log("Error message: " + errors[0].message);
                            
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
        
    },
    newCase : function (component, event, helper) {
        

        var ValidationList = '';
        var formInvalid = false;
        
        var serviceType = component.find("servtype").get("v.value");
        var channel = component.find("cha").get("v.value");
        var requests = component.find("requests").get("v.value");
        var serviceSubCategory = component.find("subCat").get("v.value");
        var fullTeam = component.find("queue").get("v.value");
        var serviceCategory = component.find("cat").get("v.value");
        var department = component.find("dept").get("v.value");
      
        
        
        if(component.get("v.model.relName_r") == null || component.get("v.model.relName_r") == '' || component.get("v.model.relName_r") ==='None'){
            
            helper.addShadow(component, event,'relationships');
            var toastEvent = $A.get("e.force:showToast");
            
           toastEvent.setParams({
                    "title": "Missing Relationship!",
                    "message": "Please link a Relationship to this record first",
                    "type":"warning"
                });
                formInvalid = true;
            toastEvent.fire();
            return;
        }else{
            helper.removeShadow(component, event,'relationships');
        }
        
        
         
        //-----------------------------------------------------------------------------------------
        
        
        
        
        if(serviceType == null || serviceType == '' || serviceType == '--None--'){            
            helper.addShadow(component, event,'servtype');
            formInvalid = true;
            ValidationList += '*Service Type. \n';            
        }
        else if(serviceType != ''){
            
            helper.removeShadow(component, event,'servtype');
            
            if(serviceSubCategory == null || serviceSubCategory == '' || serviceSubCategory == '--None--'){
                helper.addShadow(component, event,'subCat');
                formInvalid = true;
                ValidationList += '*Service Sub-Category. \n';        
                
            }else {//if(serviceCategory != ''){
               helper.removeShadow(component, event,'subCat');
                if(serviceCategory == null || serviceCategory == '' || serviceCategory == '--None--'){
                helper.addShadow(component, event,'cat');
                formInvalid = true;
                ValidationList += '*Service Category. \n';
                }else{
                     helper.removeShadow(component, event,'cat');
                }
            //} 
                }
        }
        if(channel == null || channel == ''|| channel == '--None--'){
            helper.addShadow(component, event,'cha');
            formInvalid = true;
            ValidationList += '*Channel. \n';    
        }else{
            helper.removeShadow(component, event,'cha');
        }
        
        if(requests == null || requests == '' || requests == '0' || requests == 0 ||requests < 0){
            formInvalid = true;
            helper.addShadow(component, event,'requests');
            ValidationList += '*Client Number of Requests should be greter than 0. \n';
        }else{
            helper.removeShadow(component, event,'requests');
        }
        
        
        
        
        
        //******************************************************************************************
        
        
         if(formInvalid === true){
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "title": "Missing Required Information!",
                "message": "\n Please Fill In The Required Fields \n\n"+ValidationList,
                "type":"warning"
            });
            formInvalid = false;
            toastEvent.fire();
            
            return;
             
        }
      
        scrollTo('Top',0,0);
        
        helper.showSpinner(component, event, helper);
        
        var action = component.get("c.NewCase");
        
        action.setParams({
            model : JSON.stringify(component.get("v.model")),
            serviceType: serviceType,
            channel: channel,
            requests: requests,
            serviceSubCategory: serviceSubCategory,
            fullTeam: fullTeam,
            serviceCategory: serviceCategory,
            department: department//,
            //fulldepartment:fulldepartment 
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                helper.hideSpinner(component, event, helper);
                
                 var model = JSON.parse(response.getReturnValue());
                console.log(model);
                component.set("v.model", model);                
                //RN: Get response back - Either the updated case Id OR Error message
                //var caseid = response.getReturnValue();
                
                
                if(component.get("v.model.ResponseMessage_r").length > 0 &&
                   component.get("v.model.ResponseMessage_r").startsWith("ERROR:")){
                    
                    var toastEventNotOk = $A.get("e.force:showToast");
                    
                    toastEventNotOk.setParams({
                        "title": "ERROR!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        "type":"error"
                    });
                
                	toastEventNotOk.fire();
                    
                }else if(component.get("v.model.ResponseMessage_r").length > 0){
                    var toastEventNotOk = $A.get("e.force:showToast");
                    
                    toastEventNotOk.setParams({
                        "title": "ERROR!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        "type":"error"
                    });
                
                	toastEventNotOk.fire();
                }else{
                    
                    var toastEventOk = $A.get("e.force:showToast");
                    
                    toastEventOk.setParams({
                        "title": "Success!",
                        "message": "Case Created",
                        "type":"success"
                    });
                
                	toastEventOk.fire();
                
                	
                    
                     if(component.get("v.model.theCase_r.Service_Type__c") != 'Log Complaint'){
            			//sforce.console.openPrimaryTab(null, '/apex/CSC_Support_Case_Main?id=' + caseId + '&isclone=true' , true, 'New-' + caseNumber);
            			helper.editRecord(component, event, component.get("v.model.theCase_r.Id"));
        			}else{
            			//sforce.console.openPrimaryTab(null, '/apex/CM_New_Manual_Case?id=' + caseId + '&action=edit&comptaint=1', true, 'New-' + caseNumber);
            			helper.openComplainCases(component, event, component.get("v.model.theCase_r.Id"));
        				}
                }
      
            }else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                // do something
                console.log(state);
                console.log(response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "INCOMPLETE!",
                    "message": response.getReturnValue(),
                    "type":"error"
                });
                
                toastEvent.fire();
                
            }else if (state === "ERROR") {
                    helper.hideSpinner(component, event, helper);
                    console.log(state);
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            
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
                        console.log("Unknown error");
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
        
        
    },
    
    cifAccount : function(component, event, helper) {
        
        
        var action = component.get("c.accountSelection");
        
        action.setParams({
            model : JSON.stringify(component.get("v.model"))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var model = JSON.parse(response.getReturnValue());
                console.log(model);
               
                component.set("v.model", model);
                
                var ChargesServiceTypes = component.get("v.model.ChargesServiceTypes").split(';');
                var ChargesServiceTypesTemp = [];
                for (var i = 0, len = ChargesServiceTypes.length; i < len; i++) {
                    //console.log(ChargesServiceTypes[i]);
                    var ChargesServiceTypeTepm =
                        {
                            "lable": ChargesServiceTypes[i], 
                            "value": ChargesServiceTypes[i]
                        };
                    ChargesServiceTypesTemp.push(ChargesServiceTypeTepm);
                }
                component.set("v.model.ChargesServiceTypes", ChargesServiceTypesTemp);
            }
            else if (state === "INCOMPLETE") {
                // do something
                console.log(state);
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
    
     viewCifDetails: function(component, event, helper) {
        helper.viewCifDetails(component, event);
    } ,
    
    caseSubTab: function(component, event, helper) {
        //component.get("v.model")
        console.log(component.get("v.model.qType"));
        var primaryTabId2 = sforce.console.openSubtab(0, '/apex/ADAPT360?regId=' + component.get("v.model.qValue") + '&queryType=' + component.get("v.model.qType"), true, 'CIF: ' + component.get("v.model.relName"), null);
        
        sforce.console.getFocusedPrimaryTabId(primaryTabId2);
    },
    
    
     searchSF: function(component, event, helper) {        
        helper.searchSF(component, event,helper);        
    },
      keyCheck : function(component, event, helper) {
        if(event.which == 13){
            helper.searchSF(component, event,helper);        
            
        }
    },    

    addAccount : function(component, event, helper) {
        
        helper.showSpinner(component, event, helper);
        var action = component.get("c.accountSelection");
        
        console.log(component.get("v.model"));
        
        console.log(component.get("v.model.accountOptions_r"));
        var Id = component.find("relationships").get("v.value");
        component.set("v.model.qValue_r", '');
        component.set("v.model.relCIF_r", '');
        component.set("v.model.relName_r", '');
        component.set("v.model.relID_r",Id);
        
        // return;
        action.setParams({
            model : JSON.stringify(component.get("v.model"))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.hideSpinner(component, event, helper);
                
                component.set("v.model", JSON.parse(response.getReturnValue()));
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
                // do something
                console.log(state);
                console.log(response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
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
                        console.log("Unknown error");
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
    },
    
  
    cifAccount: function(component, event, helper) {
        var action = component.get("c.cifSelection");
        action.setParams({
            model : JSON.stringify(component.get("v.model"))
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.acc", response.getReturnValue());
                component.set("v.showGuestBlock", true);
                alert(response.getReturnValue())
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                // do something
                console.log(state);
                console.log(response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
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
                        console.log("Unknown error");
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
    },
})