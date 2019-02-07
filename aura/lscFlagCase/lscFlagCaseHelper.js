({
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
    openTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspace.openTab({
            url: '#/',
            focus: true
        }).then(function(response) {
            workspaceAPI.focusTab({
                tabId: response});
        }).catch(function(error) {
            console.log(error);
        });
    },
    navigateToMyComponent : function(component, event, myComponent ) {
        
        var evt = $A.get("e.force:navigateToComponent");
        
        //alert(myComponent);
        
            evt.setParams({
                componentDef : "c:" + myComponent,
                componentAttributes: {
                  caseId : component.get("v.recordId")
                }
        });
        
        evt.fire();
    },
    openTab : function(component, event, pagename) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/' + pagename,
            focus: true
        });
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})