({
	doInit : function(component, event, helper) {
		var newOpportunityName;
        
        //Tonga : MM Call server side Method
        var action = component.get("c.isAFricaRDOwned");
        var actionGetNewName = component.get("c.getNewName");
        var recordDetails = component.get("v.record");
        
        var recordtype = component.get("v.simpleRecord.RecordType.Name");
        var accountId = null;
        var relatedGroupClientId = null;
        if (recordtype == 'Client') {
            accountId = component.get("v.record.fields.ParentId").value;
        	relatedGroupClientId = component.get("v.recordId");
        } else {
        	accountId = component.get("v.recordId");    
        }
        
        action.setParams({ accountId : component.get("v.recordId") });
        
        
        actionGetNewName.setCallback(this, function(response) {
            newOpportunityName = response.getReturnValue();
            $A.enqueueAction(action);
        });
        
        //Tonga : MM callback function for verifying Coverage unmanaged previously Africa RD Holder
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var approved = response.getReturnValue();
                
                if(approved)
                {
                    var createAcountContactEvent = $A.get("e.force:createRecord");
                createAcountContactEvent.setParams({
                    "entityApiName": "Opportunity",
                    'recordTypeId' : '01224000000Kx2mAAC',
                    "defaultFieldValues": {
                        'Name' : newOpportunityName,
                        'AccountId' :  accountId,
                        'Related_Group_Client__c' : relatedGroupClientId,
                        'Private_Side__c' : true
                    }
                });
                    createAcountContactEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();

                }
                else
                {
                    var lbl_Coverage_Unmanaged = $A.get("$Label.c.lbl_Coverage_Unmanaged");
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "New Opportunity has been disabled for Relationships owned by "+lbl_Coverage_Unmanaged,
                        "type" : "error"
                    });
                    resultsToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();

                }
                
            }
            else if (state === "INCOMPLETE") {
               
            }
        });

        $A.enqueueAction(actionGetNewName);
        

	}
})