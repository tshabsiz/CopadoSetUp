({
    handleRecordUpdated : function(component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
        	var win = window.open('/apex/MeetingPrintView?Id=' + component.get("v.recordId"), '_blank');
			win.focus();
        }
	}
})