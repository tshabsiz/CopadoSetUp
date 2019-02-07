({
	doInit  : function(component, event, helper) {
       
        helper.showSpinner(component, event, helper);
        var recordId  = component.get("v.recordId");
        var action = component.get("c.AddViewChargeLoad");
        
        action.setParams({
        model : '',
        recordId: recordId
    });

          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 helper.hideSpinner(component, event, helper);              
                var model = JSON.parse(response.getReturnValue());              
                component.set("v.model", model);
                
                if(model.errorMsg != null && model.errorMsg != ''){
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                    "title": "Error!",
                    "message": model.errorMsg,
                    "type":"error"
                });
                
                toastEvent.fire();
                }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
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
    
    transactionCodeListSelect:function(component, event, helper) {
       
        for (let i = 0; i < component.get("v.model.chargeWrapperList").length; i++) 
        {
            if(i == event.srcElement.id.split('_')[1]){  	
                  var value = event.srcElement.value
                if(value == '--None--'){
                        event.srcElement.classList.add("redborder");               
                    }else{
                        event.srcElement.classList.remove("redborder");
                    }
                
                component.get("v.model.chargeWrapperList")[i].charge.Transaction_Code__c = event.srcElement.value;
                break;
            }
        }
        return;

        
    },
    
    corpCodeListSelect: function(component, event, helper) {
        
        
        
       for (let i = 0; i < component.get("v.model.chargeWrapperList").length; i++) 
        {
            if(i == event.srcElement.id.split('_')[1]){
                
                console.log(event.srcElement);
                var value = event.srcElement.value
                if(value == '--None--'){
                        event.srcElement.classList.add("redborder");               
                    }else{
                        event.srcElement.classList.remove("redborder");
                    }
                
                component.get("v.model.chargeWrapperList")[i].charge.Corp_Code__c = event.srcElement.value;
                break;
            }
        }
        return;
        
    },
    
     effectiveDateChanged: function(component, event, helper) {
       for (let i = 0; i < component.get("v.model.chargeWrapperList").length; i++) 
        {
            if(i == event.srcElement.id.split('_')[1]){
                console.log(event.srcElement);
                var value = document.getElementById(event.srcElement.id).value;
                if(value.includes('d') || value.includes('m')||value.includes('y')){
                        event.srcElement.classList.add("redborder");               
                    }else{
                        event.srcElement.classList.remove("redborder");
                    }             
                component.get("v.model.chargeWrapperList")[i].charge.Effective_Date__c = event.srcElement.value;
                break;
            }
        }
        return;
        
    },
    
    
     CrAccountNoListSelect: function(component, event, helper) {
     for (let i = 0; i < component.get("v.model.chargeWrapperList").length; i++) 
        {
            if(i == event.srcElement.id.split('_')[1]){ 
                
                var value = event.srcElement.value
                if(value == '--None--'){
                        event.srcElement.classList.add("redborder");               
                    }else{
                        event.srcElement.classList.remove("redborder");
                    }
                
                component.get("v.model.chargeWrapperList")[i].charge.CR_Account_No__c = event.srcElement.value;
                break;
            }
        }
        return;
    },

    addnewLine  : function(component, event, helper) {
       
        
                    var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth()+1; //January is 0!
            
            var yyyy = today.getFullYear();
            if(dd<10){
                dd='0'+dd;
            } 
            if(mm<10){
                mm='0'+mm;
            } 
        
       
            var today = dd+'/'+mm+'/'+yyyy;
        
		 var newList = component.get("v.model.chargeWrapperList");
        var add = {
            charge:  {
            //Id : '',
            Case__c :  component.get("v.model.currentCase.Id"),
            Charge_Account_No__c : '',
            Charge_Amount__c : '',
            Transaction_Code__c : '',
            Corp_Code__c : '',
            Cost_Centre__c : '',
            CR_Ref__c : '',
            DR_Ref__c : '',
            CR_Account_No__c : '',
            Effective_Date__c : today.toString()
            },
        index:newList.length};
        console.log(add)
       
        newList.push(add);
        console.log(newList);
        component.set("v.model.chargeWrapperList",[]);
        component.set("v.model.chargeWrapperList",newList);
         //helper.addValidation(component, event, helper);
       return;
       
	},
    checkValidation  : function(component, event, helper) {
        var element = document.getElementById(event.srcElement.id);
        if(element.value == '--None--'){
                element.classList.add("redborder");               
            }else{
                element.classList.remove("redborder");
            }
    },
    
     checkSelectValidation  : function(component, event, helper) {
        var element = document.getElementById(event.srcElement.id);
        if(element.value == ''){
                element.classList.add("redborder");               
            }else{
                element.classList.remove("redborder");
            }
    },
    
    
      saveUpdates  : function(component, event, helper) {
          
          if(helper.addValidation(component, event, helper)){
              return;
          }
          
           helper.showSpinner(component, event, helper);
     console.log(component.get("v.model"))
        var recordId  = component.get("v.recordId");
        var action = component.get("c.saveUpdates1");
			
         action.setParams({
            recordId: recordId,
        	model : JSON.stringify(component.get("v.model"))
    });
     
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 helper.hideSpinner(component, event, helper);
              
                var model = JSON.parse(response.getReturnValue());
              
                component.set("v.model", model);
                 if(model.errorMsg != null && model.errorMsg != ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": model.errorMsg,
                    "type":"Success"
                });
                
                     toastEvent.fire();
                 }else{
                       var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": 'Charge(s) Saved/Updated',
                    "type":"Success"
                });
                
                     toastEvent.fire();
                         
                     }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
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
    
    lockCharges  : function(component, event, helper) {
       
         var charges = component.get("v.model.chargeWrapperList");
         var foundUnsaved = 1==2;
         for(var i = 0; i < charges.length; i++){            
                 foundUnsaved = charges[i].charge.Id == null || charges[i].charge.Id == '';
             if(foundUnsaved) {
                 break;
             }
             
         }
         
         if (foundUnsaved && !confirm('There are unsaved chages on the grid, you will loose the data if you continue')) { 
             return;
         }
        
        var newCharges = [];
        charges.forEach(function(element, index) {            
            foundUnsaved = element.charge.Id == null || element.charge.Id == '';
            if(!foundUnsaved)
            newCharges.push({
                charge: element.charge,
                index:index
            });
        });
        
        component.set("v.model.chargeWrapperList",newCharges);
        
        helper.showSpinner(component, event, helper);          
        
     console.log(component.get("v.model"))
        var recordId  = component.get("v.recordId");
        var action = component.get("c.lockCharges1");
			
         action.setParams({
            recordId: '',
        	model : JSON.stringify(component.get("v.model"))
    });
     
        
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 helper.hideSpinner(component, event, helper);
              
                var model = JSON.parse(response.getReturnValue());
              
                component.set("v.model", model);
                console.log(model)
                  if(model.errorMsg != null && model.errorMsg != ''){
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": model.errorMsg,
                    "type":"error"
                });
                
                toastEvent.fire();
                  }else{
                       var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": 'Case locked',
                    "type":"Success"
                });
                
                toastEvent.fire();
                  }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
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
    
    unlock  : function(component, event, helper) {
          
        helper.showSpinner(component, event, helper);          
        
     console.log(component.get("v.model"))
        var recordId  = component.get("v.recordId");
        var action = component.get("c.unlock11");
			
         action.setParams({
            recordId: '',
        	model : JSON.stringify(component.get("v.model"))
    });
     
        
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 helper.hideSpinner(component, event, helper);
              
                var model = JSON.parse(response.getReturnValue());
              
                component.set("v.model", model);
                
                 if(model.errorMsg != null && model.errorMsg != ''){
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": model.errorMsg,
                    "type":"error"
                });
                
                toastEvent.fire();
                 }else{
                      var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": 'Case unlocked',
                    "type":"Success"
                });
                
                toastEvent.fire();
                 }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
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
    
    
     deletecharge  : function(component, event, helper) {
     
        
          var charges = component.get("v.model.chargeWrapperList");
         var chargesTemp = charges;
         var foundUnsaved = false;
         for(var i = 0; i < charges.length; i++){            
                 foundUnsaved = charges[i].charge.Id == null || charges[i].charge.Id == '';
             if(foundUnsaved) break;
             
         }
     
         if (foundUnsaved && !confirm('There are unsaved chages on the grid, you will loose the data if you continue')) { 
             return;
         }
         
         if(event.srcElement.id == null || event.srcElement.id == '') {
   				
             console.log(event.srcElement.name)
                    // if (index > -1) 
                    {
            				var charges = component.get("v.model.chargeWrapperList");
                        console.log(charges);
                        charges.splice(event.srcElement.name, 1);
                        console.log(charges);
                        var newCharges = [];
                        charges.forEach(function(element, index) {
                            newCharges.push({
                                charge: element.charge,
                                index:index
                            });
                        });
                        console.log(newCharges);
                        
                        component.set("v.model.chargeWrapperList",[]);
                        component.set("v.model.chargeWrapperList", newCharges);
                       
        				}
             
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": 'Charge removed from grid',
                    "type":"Success"
                });
                
                toastEvent.fire();
             
        
             return;
			}
         
        
			
        helper.showSpinner(component, event, helper);
        var action = component.get("c.deleteItem1");
			
         action.setParams({
            recordId: event.srcElement.id,
             model : JSON.stringify(component.get("v.model"))
    });
     
        
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 helper.hideSpinner(component, event, helper);
              
                var model = JSON.parse(response.getReturnValue());
              component.set("v.model", model);
                
                if(model.errorMsg != null && model.errorMsg != ''){
                  
                component.set("v.model", model);
                
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": model.errorMsg,
                    "type":"error"
                });
                
                toastEvent.fire();
                
                }else{
                     var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": 'Charge deleted',
                    "type":"Success"
                });
                
                toastEvent.fire();
                }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
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


})