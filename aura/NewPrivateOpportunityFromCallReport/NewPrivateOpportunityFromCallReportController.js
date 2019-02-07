({  
    handleRecordUpdated: function(component, event, helper) {
    	var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            var newOpportunityName;
        	var actionGetNewName = component.get("c.getNewName");
        
        	actionGetNewName.setCallback(this, function(response) {
                newOpportunityName = response.getReturnValue();
                
                var createOpportunityEvent = $A.get("e.force:createRecord");
                createOpportunityEvent.setParams(
                    {
                        "entityApiName": "Opportunity",
                        'recordTypeId' : '01224000000Kx2mAAC',
                        "defaultFieldValues": {
                            'Name' : newOpportunityName,
                            'AccountId' : component.get("v.record.fields.Relationship__c").value,
                            'Call_Report__c' : component.get("v.recordId"),
                            'Private_Side__c' : true
                        }
                    }
                );
                createOpportunityEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
        	});
            
        	$A.enqueueAction(actionGetNewName);
        }
 	}
})