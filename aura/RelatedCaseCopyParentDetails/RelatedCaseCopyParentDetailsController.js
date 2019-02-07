({  
	loadParent:function(component, event, helper) {  
        window.parentCase = component.get("v.record");
   	},
 
 	createChild:function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": 'Case',
            "recordTypeId": window.parentCase.RecordTypeId,
            "defaultFieldValues": {
           		'AccountId' : window.parentCase.AccountId,
                'Status' : window.parentCase.Status,
                'Priority' : window.parentCase.Priority,
                'ParentId' : window.parentCase.Id,
                'Email_Sender_Name__c' : window.parentCase.Email_Sender_Name__c,
                'Queue__c' : window.parentCase.Queue__c,
                'Team__c' : window.parentCase.Team__c,
                'Department__c' : window.parentCase.Department__c,
                'Team_Manager__c' : window.parentCase.Team_Manager__c,
                'ContactId' : window.parentCase.ContactId,
                'Business_Hours__c' : window.parentCase.Business_Hours__c,
                'Full_Department__c' : window.parentCase.Full_Department__c,
                'Subject' : window.parentCase.Subject,
                'Business_case__c' : window.parentCase.Business_case__c,
                'Description' : window.parentCase.Description,
                'Add_Case_Comment__c' : window.parentCase.Add_Case_Comment__c,
                'Service_Type__c' : window.parentCase.Service_Type__c,
                'Service_Sub_Category__c' : window.parentCase.Service_Sub_Category__c,
                'Service_Category__c' : window.parentCase.Service_Category__c,
                'Channel__c' : window.parentCase.Channel__c,
                'IsEscalated' : window.parentCase.IsEscalated,
                'Number_of_Requests__c' : window.parentCase.Number_of_Requests__c,
                'User_Code__c' : window.parentCase.User_Code__c,
                'Urgent__c' : window.parentCase.Urgent__c,
                'Origin' : window.parentCase.Origin,
                'Training_Date__c' : window.parentCase.Training_Date__c,
                'Training_Method__c' : window.parentCase.Training_Method__c,
                'Reason_for_Cancellation__c' : window.parentCase.Reason_for_Cancellation__c,
                'ID_V_Complete__c' : window.parentCase.ID_V_Complete__c,
                'Issue_Type__c' :window.parentCase.Issue_Type__c
        	}
        });
        createRecordEvent.fire(); 
	}
})