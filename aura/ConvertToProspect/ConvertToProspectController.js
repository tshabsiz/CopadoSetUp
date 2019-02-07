({
	doInit : function(component, event, helper) {
		var CompanyName = component.get("v.record.fields.Company_Name__c").value;
        var Surname = component.get("v.record.fields.Surname__c").value;
        var LeadStatus = component.get("v.record.fields.Lead_Status__c").value;
        var resultsToast = $A.get("e.force:showToast");
        var actionconvertMatrixLeadToProspect = component.get("c.convertMatrixLeadToProspect");
        actionconvertMatrixLeadToProspect.setParams({ matrixLeadId : component.get("v.recordId") });
        
        actionconvertMatrixLeadToProspect.setCallback(this, function(response) {
                var result = response.getReturnValue();
                if(result.indexOf('ERROR') >= 0){
					resultsToast.setParams(
                		{
                            "title": "Error",
                            "message": result
                        }
            		);
            		resultsToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
        			dismissActionPanel.fire();
				} else {
					var urlEvent = $A.get("e.force:navigateToURL");
        			urlEvent.setParams({"url":"/"+result});
        			urlEvent.fire();
				}
       	});
        
        if (CompanyName == null || CompanyName.trim() == '' || Surname == null || Surname.trim() == '') {
            resultsToast.setParams(
                		{
                            "title": "Error",
                            "message": "Matrix Lead cannot be converted. Company Name and Surname are required fields."
                        }
            );
            resultsToast.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
        } else if(LeadStatus == null || LeadStatus != 'Contacted') {
            resultsToast.setParams(
                		{
                            "title": "Error",
                            "message": "Only Matrix Leads in status Contacted can be converted."
                        }
            );
            resultsToast.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
		} else if(window.confirm("Are you sure?")) {
  			$A.enqueueAction(actionconvertMatrixLeadToProspect);
		}
	}
})