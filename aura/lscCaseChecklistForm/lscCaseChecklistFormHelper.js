({
    /*
     * Purpose : this function used to call apex controller method. 
     */ 
    callServer : function(component, apexMethod, params, cacheable, callback) {
        var method = "c." + apexMethod;
        var action = component.get(method);
        
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
    
    /*
     * Purpose : this function used to handle state generated error. 
     */ 
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
    
    /*
     * Purpose : this function used to show message. 
     */ 
    showMsg : function(component, event, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },
    
    /*
     * Purpose : this function used to close current tab after click on save button. 
     */ 
    closeFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})