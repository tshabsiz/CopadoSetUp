({
	doInit: function(component, event, helper) {
        var currentUrl = window.location.href;
    	var newUrl = "/apex/CallReport_Send?id=" + component.get("v.recordId") + '&returnUrl=' + currentUrl;
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url":newUrl});
        urlEvent.fire();
 	}
})