({
   fetchListOfRecordTypes: function(component, event, helper) {  
      var action1 = component.get("c.getTaskFields");
      action1.setParams({"recId": component.get("v.recordId")});
      action1.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
         	if (response.getReturnValue().Status != 'Converted') {
              helper.createToastEvent("Error!", "New Opportunity only available on Converted Status.");
            } else if (response.getReturnValue().What == undefined) {
              helper.createToastEvent("Error!", "To create a new opportunity Related To field must be populated with a Relationship Group or Prospect.");
            } else if (response.getReturnValue().What.RecordType.Name != 'Relationship Group' && response.getReturnValue().What.RecordType.Name != 'Prospect') {
              helper.createToastEvent("Error!", "To create a new opportunity Related To field must be a Relationship Group or Prospect.");
            } else {
              component.set("v.whatId", response.getReturnValue().WhatId);
              var action2 = component.get("c.fetchRecordTypeValues");
              action2.setCallback(this, function(response) {
                component.set("v.lstOfRecordType", response.getReturnValue());
              });
              $A.enqueueAction(action2);
              component.set("v.isOpen", true);
            }
          } else if (state == "INCOMPLETE") {
            helper.createToastEvent("Oops!", "No Internet Connection");
          } else if (state == "ERROR") {
            helper.createToastEvent("Error!", "Please contact your administrator");
          }
      });
      $A.enqueueAction(action1);
   },
 
   createRecord: function(component, event, helper) {
      component.set("v.isOpen", true);
       
      var action = component.get("c.getRecTypeId");
      var accountId = component.get("v.whatId");
      var recordTypeLabel = component.find("selectid").get("v.value");
      action.setParams({
         "recordTypeLabel": recordTypeLabel
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var createRecordEvent = $A.get("e.force:createRecord");
            var RecTypeID  = response.getReturnValue();
            createRecordEvent.setParams({
               "entityApiName": 'Opportunity',
               "recordTypeId": RecTypeID,
               "defaultFieldValues": {
               		'AccountId' : accountId
               }
            });
            createRecordEvent.fire();  
         } else if (state == "INCOMPLETE") {
            helper.createToastEvent("Oops!", "No Internet Connection");
         } else if (state == "ERROR") {
            helper.createToastEvent("Error!", "Please contact your administrator");
         }
      });
      $A.enqueueAction(action);
   },
 
   closeModal: function(component, event, helper) {
      // set "isOpen" attribute to false to close modal
      component.set("v.isOpen", false);
   },
 
   openModal: function(component, event, helper) {   
      // set "isOpen" attribute to true to show modal
      component.set("v.isOpen", true);   
   }
})