({
    component : null ,
	showSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    callServer : function(apexMethod, params, cacheable, callback) {
       var method = "c." + apexMethod;
       var action = this.component.get(method);
       
       if(params) {
           action.setParams(params);
       }
       
       if(cacheable) {
           action.setStorable();
       }
       
       action.setCallback(this, function(response) {
           var state = response.getState();
           
           if(state === "SUCCESS") {
               console.log('resp1',response.getReturnValue());
               callback.call(this, response.getReturnValue());
           } else if(state === "ERROR") {
               this.handleActionFailedState( response.getError());
           }
       });
       
       $A.enqueueAction(action);
   },
   
   handleActionFailedState : function(errors) {
       var errorTxt;
        console.log('errors',errors);
       if(errors) {
           var errorMsgs = [];
           for(var index in errors) {
               errorMsgs.push(errors[index].message);
           }            
           errorTxt = errorMsgs.join('<br/>');
       } else {
           errorTxt = 'Something went wrong!';
       }
       console.log('\n errorTxt:', errorTxt);
       this.showMsg(component, event, 'Error', 'error', errorTxt);
   },
    
    navigateToCaseForm : function(component, event, cmpName, templateId, caseId){        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:" + cmpName,
            componentAttributes: {
                templateId : templateId,
                caseId : caseId                
            }
        });
        evt.fire();
    },
    
    showMsg : function(component, event, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },
})