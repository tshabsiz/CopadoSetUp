({
	doInit : function(component, event, helper) {
        var flow = component.find("flowData");
        
        var inputVariables = [
            {
                name : "OpportunityID",
                type : "String",
                value: component.get("v.recordId")
            }
        ];
                flow.startFlow("Close_Opportunity",inputVariables);
    },
    handleStatusChange : function(component,event)
    {
        if(event.getParam("status")=="FINISHED")
        {
            var navToObjectEvent = $A.get("e.force:navigateToSObject");
            navToObjectEvent.setParams({"recordId" : component.get("v.recordId"),
                                       "isredirect" : "true" });
            
            navToObjectEvent.fire();
        }
    }
})