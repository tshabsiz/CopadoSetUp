({
    getEventRecord : function(component, event, helper) {
           
        var action1 = component.get("c.getEvent");
        var eventId = component.get("v.recordId");
        
        action1.setParams({
            "eventId":eventId
        });
        
        action1.setCallback(this, function(a) {
            component.set("v.event", a.getReturnValue());
        });

        // Queue this actions to send to the server
        $A.enqueueAction(action1);
    }
})