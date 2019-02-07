({
    doInit  : function(component, event, helper) {
        
       var action = component.get("c.returnSupportCase");
       alert(component.get("v.caseIdAtt"));
       action.setParams({
           caseId : component.get("v.caseIdAtt"),
           isClonePar : component.get("v.isCloneAtt")
       });
        
       action.setCallback(this, function(response) {
           
           component.set("v.caseIdAtt", response.getReturnValue());
           
           var editRecordEvent = $A.get("e.force:editRecord");
        
           editRecordEvent.setParams({
               "recordId": component.get("v.caseIdAtt")
           });
           
           editRecordEvent.fire();
       });

       // Send action off to be executed
       $A.enqueueAction(action);
    },
    save : function(component, event, helper) {
       component.find("edit").get("e.recordSave").fire();
    },
    editRecord : function(component, event) {
        
      var editRecordEvent = $A.get("e.force:editRecord");
        
      editRecordEvent.setParams({
             "recordId": component.get("v.caseIdAtt")
      });
      
      editRecordEvent.fire();
   }
})