({
	handleRecordUpdated : function(component, event, helper) {
		var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
			var attendeeId = component.get("v.recordId");
            var resultsToast = $A.get("e.force:showToast");
            var action = component.get("c.updateAttendeePresent");
			action.setParams({"attendeeId": attendeeId});
            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                
                if (result == attendeeId) {
                    $A.get("e.force:refreshView").fire();
                    resultsToast.setParams(
                		{
                            "title": "Info",
                            "message": "Record updated successfully."
                        }
            		);
            		resultsToast.fire();
                } else {
                    resultsToast.setParams(
                		{
                            "title": "Error",
                            "message": result
                        }
            		);
            		resultsToast.fire();
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
        	});
            
            $A.enqueueAction(action);
        }
	}
})