({
	doInit : function(component, event, helper) {
    	var actionRecordTypeList = component.get("c.fetchRecordTypeValues");
        component.set("v.isOpen", true);
        actionRecordTypeList.setCallback(this, function(response) {
           component.set("v.lstOfRecordType", response.getReturnValue());
        });
      	$A.enqueueAction(actionRecordTypeList);        
	},
    createRecord: function(component, event, helper) {
      component.set("v.isOpen", true);
 	  
      var acctId = component.get("v.record.fields.AccountId").value;
      var recordId = component.get("v.recordId");
      var action = component.get("c.getRecTypeId");
      var recordTypeLabel = component.find("selectid").get("v.value");
      action.setParams({
         "recordTypeLabel": recordTypeLabel
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var createRecordEvent = $A.get("e.force:createRecord");
            var RecTypeID = response.getReturnValue();
            
            createRecordEvent.setParams({
                "entityApiName": 'Call_Report__c',
                "recordTypeId": RecTypeID,
                "defaultFieldValues": {
                    'Relationship__c' : acctId,
                    'CR_Contact__c' : recordId
                }
            });
            createRecordEvent.fire();
             
         } else if (state == "INCOMPLETE") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Oops!",
               "message": "No Internet Connection"
            });
            toastEvent.fire();
             
         } else if (state == "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Error!",
               "message": "Please contact your administrator"
            });
            toastEvent.fire();
         }
      });
      $A.enqueueAction(action);
   },
 
   closeModal: function(component, event, helper) {
      // set "isOpen" attribute to false for hide/close model box 
      component.set("v.isOpen", false);
   },
 
   openModal: function(component, event, helper) {
      // set "isOpen" attribute to true to show model box
      
   }
})