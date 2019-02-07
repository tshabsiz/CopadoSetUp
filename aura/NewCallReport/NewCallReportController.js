({
	doInit : function(component, event, helper) {
        var actionRecordTypeList = component.get("c.fetchRecordTypeValues");
        component.set("v.isOpen", true);
      actionRecordTypeList.setCallback(this, function(response) {
         component.set("v.lstOfRecordType", response.getReturnValue());
         if (response.getReturnValue().length > 1) {
              component.find("selectid").set("v.value", response.getReturnValue()[1]);
              var create_record = component.get('c.createRecord');
        	  $A.enqueueAction(create_record);
         }
      });
      $A.enqueueAction(actionRecordTypeList);
        
        //Tonga : MM Call server side Method
        var action = component.get("c.isAFricaRDOwned");
        action.setParams({ accountId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var approved = response.getReturnValue();
                
                if(!approved)
                {
                    var lbl_Coverage_Unmanaged = $A.get("$Label.c.lbl_Coverage_Unmanaged");
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Call Report have been disabled for Relationships owned by "+lbl_Coverage_Unmanaged,
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
        
	},
    createRecord: function(component, event, helper) {
      component.set("v.isOpen", true);
 
      var action = component.get("c.getRecTypeId");
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
                "entityApiName": 'Call_Report__c',
                "recordTypeId": RecTypeID,
                "defaultFieldValues": {
                    'Relationship__c' : component.get("v.recordId")}
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
   }
})