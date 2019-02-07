({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchAgentRecords");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : 'User'
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            else{
                response.getError()
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
                component.set("v.Message", errorTxt);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    
    
})