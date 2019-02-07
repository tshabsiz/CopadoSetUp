/**
* 2018-02-27
* Rudolf Niehaus - CloudSmiths
* 
**/
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
    openTab : function(component, event, caseID) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: caseID,
            focus: true
        }).then(function(response) {
            workspaceAPI.focusTab({
                tabId: response
            });
        }).catch(function(error) {
                console.log(error);
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