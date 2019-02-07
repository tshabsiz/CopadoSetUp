({
	doInit : function(component, event, helper) {

        if(component.get("v.record.fields.Annualised_Income__c").value==0)
        {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/apex/AddProductToOpportunity?oppId=' + component.get("v.recordId")
            });
            urlEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
        else
        {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "message": "Product already exists."
            });
            resultsToast.fire();
            dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
	}
})