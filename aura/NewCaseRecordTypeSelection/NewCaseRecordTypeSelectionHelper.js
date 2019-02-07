({
	showSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner1");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner1");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
        
    },
    navigateToComponent : function(component, event) {
        
        var evt = $A.get("e.force:navigateToComponent");
        
        evt.setParams({
            componentDef : "c:lscCaseEditForm",
            componentAttributes: {
                caseIdAtt : component.get("v.recordId"),
                isCloneAtt : "true"
            }
        });
        
        evt.fire();
    },
    
    focusNewTab : function(component, event, CaseId) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Case/'+CaseId+'/view'
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
       })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    salesNavigation : function(component, event, helper) {
        var recordId =  component.get("v.recordId");
        if(recordId != '')
        {
            helper.navigateToDetailPage(component, event, recordId);
            
        }else{
            
             var componentName = 'c:lscCscNewManualCase';
              
              if(component.get("v.pageReference").state.recordTypeId == '01224000000gQUVAA2' ||component.get("v.pageReference").state.recordTypeId == '01224000000gQUV'){
                  componentName = 'c:lscDosNewManualCase';
                  
              }
              
              if(component.get("v.pageReference").state.recordTypeId == '01224000000gQ1NAAU' || component.get("v.pageReference").state.recordTypeId == '01224000000gQ1N'){
                  componentName = 'c:lscCmNewManualCase';
                  
              }
            
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : componentName
            });
            evt.fire();
            
        }
        
    },
    
      serviceNavigation : function(component, event, helper) {
        var recordId =  component.get("v.recordId");
                var tabId =  component.get("v.tabId");
        
                if(recordId != '' && tabId != '')
                {
                    helper.closeThisTab(component, event, tabId);
                    
                    helper.focusNewTab(component, event, recordId);
                    
                    
                    
                   // helper.closeFocusedTab(component, event, helper);
                }
        
          else{
              
              var componentName = 'c:lscCscNewManualCase';
              
              if(component.get("v.pageReference").state.recordTypeId == '01224000000gQUVAA2' ||component.get("v.pageReference").state.recordTypeId == '01224000000gQUV'){
                  componentName = 'c:lscDosNewManualCase';
                  
              }
              
              if(component.get("v.pageReference").state.recordTypeId == '01224000000gQ1NAAU' || component.get("v.pageReference").state.recordTypeId == '01224000000gQ1N'){
                  componentName = 'c:lscCmNewManualCase';
                  
              }
              
              //helper.closeFocusedTab(component, event, helper);
              var evt = $A.get("e.force:navigateToComponent");
              var workspaceAPI = component.find("workspace");
              workspaceAPI.getFocusedTabInfo().
              then(function(response) {
                  var focusedTabId = response.tabId;
                  evt.setParams({
                      componentDef : componentName,
                      componentAttributes: {
                          tabId:focusedTabId
                      }
                  });
                  evt.fire();
              }).then(function(response) {
                  
              })
              .catch(function(error) {
                  console.log(error);
              });
              
          }        
    },
    
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
           
            var focusedTabId = response.tabId;
           
            
            workspaceAPI.closeTab({tabId: focusedTabId});
        }).then(function(tabInfo) {
             
      
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
     closeThisTab : function(component, event, tabId) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({tabId: tabId});
    },
    
      editRecord : function(component, event, cid) {
        
      var editRecordEvent = $A.get("e.force:editRecord");
       // var editRecordEvent = $A.get("e.force:navigateToSObject");
        
      editRecordEvent.setParams({
             "recordId": cid
      });
      editRecordEvent.fire();
   },
    
        navigateToDetailPage : function (component, event, ID) {
            
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": ID
        });
        navEvt.fire();
    },


})