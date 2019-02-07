({
	doInit : function(component, event, helper) {
       var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        var hours = today.getHours();
        var minutes = today.getMinutes();
        
        var accountName  =component.get("v.record.fields.Name").value;
        var recordtype = component.get("v.simpleRecord.RecordType.Name");
        var accountId = null;
        var relatedGroupClientId = null;
        if (recordtype == 'Client') {
            accountId = component.get("v.record.fields.ParentId").value;
        	relatedGroupClientId = component.get("v.recordId");
        } else {
        	accountId = component.get("v.recordId");    
        }
        
        if(dd<10) {
            dd = '0'+dd
        } 
        
        if(mm<10) {
            mm = '0'+mm
        }
        
        if(hours<10) {
        	hours = '0'+hours
        } 
            
        if(minutes<10) {
        	minutes = '0'+minutes
        }
        
        today = yyyy+'/'+mm+'/'+dd+' '+ hours + ':' + minutes;
        
        //Tonga : MM Call server side Method
        var action = component.get("c.isAFricaRDOwned");
        action.setParams({ accountId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var approved = response.getReturnValue();
                
                if(approved)
                { 
                    
                    var createAcountContactEvent = $A.get("e.force:createRecord");
                    createAcountContactEvent.setParams({
                        "entityApiName": "Opportunity",
                        'recordTypeId' : '01224000000Kx2nAAC',
                        "defaultFieldValues": {
                            'Name' :accountName+' '+ today,
                            'AccountId' : accountId,
                            'Related_Group_Client__c' : relatedGroupClientId
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

        $A.enqueueAction(action);
        
	}
})