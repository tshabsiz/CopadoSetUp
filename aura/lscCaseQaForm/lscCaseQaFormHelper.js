({
    //currentScore : null,
    //naCount : null,
    /*
     * Purpose : To call server method. 
     */
	callServer : function(component, apexMethod, params, cacheable, callback) {
       var method = "c." + apexMethod;
       var action = component.get(method);
       
       if(params) {
           action.setParams(params);
       }
       
       if(cacheable) {
           action.setStorable();
       }
       
       action.setCallback(this, function(response) {
           var state = response.getState();
           
           if(state === "SUCCESS") {
               console.log('resp1',response.getReturnValue());
               callback.call(this, response.getReturnValue());
           } else if(state === "ERROR") {
               this.hideSpinner(component);
               this.handleActionFailedState( response.getError());
           }
       });
       
       $A.enqueueAction(action);
   },
   
    /*
     * Purpose : To handle state error. 
     */
    handleActionFailedState : function(errors) {
       var errorTxt;
        console.log('errors',errors);
       if(errors) {
           var errorMsgs = [];
           for(var index in errors) {
               errorMsgs.push(errors[index].message);
           }            
           errorTxt = errorMsgs.join('<br/>');
       } else {
           errorTxt = 'Something went wrong!';
       }
       console.log('\n errorTxt:', errorTxt);
       this.showMsg(component, event, 'Error', 'error', errorTxt);
    },
    
  /*
   * Purpose : To show message. 
   */ 
   showMsg : function(component, event, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },
    
    /*
     * Purpose : used to close focus tab. 
     */
    closeFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    /*
     * Purpose : used to calculate agentScore after click on radio button. 
     */
    calculateScore : function(component, event){
        var wtotal = component.get("v.wtotal");
        console.log('wtotal',wtotal);
        var radios = document.getElementsByTagName('input');
        console.log('radios',radios);
        var currentScore = 0;
        var yesCount = 0;
        var naCount = 0;
        var totalWithOutNA = 0
        var auditQ = false;
        
        for(var i=0; radios[i]; ++i){
             //console.log('in for');
            if(radios[i].type == 'radio'){
                 //console.log('in if radio');
                if(radios[i].checked){
                     //console.log('in if cheked');
                    //calculate the current score total 
                   if(radios[i].value == 'Yes'){
                        console.log('In yes');
                       yesCount = parseInt(yesCount) + parseInt(radios[i].placeholder);
                   }else if(radios[i].value == 'NA'){
                       console.log('In NA');
                       naCount = parseInt(naCount) + parseInt(radios[i].placeholder); 
                   }else if(radios[i].value == 'No'){
                       console.log('In No');
                       //check if this is a NO for an Audit question. Then the agent scores zero for the comoplete QA
                       var searchStr = radios[i].id;
                       if(searchStr.indexOf('true') >= 0){
                           console.log('In searchStr');
                           auditQ = true;
                       }
                   }
                }
            }
        }
        
        currentScore = parseInt(yesCount);
        
        if(!auditQ){
            totalWithOutNA = (parseInt(wtotal) - parseInt(naCount));
        }
        
        var agentScore = Math.ceil(this.percent(currentScore, totalWithOutNA)) ; 
        component.set("v.agentScore",agentScore);
        console.log('agentScore',agentScore);
        component.set("v.currentScore",currentScore);
        component.set("v.naCount",naCount);
     
    },
    
    /*
     * Purpose : To reset all selected question. 
     */
    resetScore : function(component){
        var wtotal = component.get("v.wtotal");
        var currentScore = 0;
        var totalWithOutNA = 0;
        
       /* var radios = document.getElementsByTagName('input');
    
        for(var i=0; radios[i]; ++i){
            if(radios[i].type == 'radio'){
                if(radios[i].value == 'Yes'){
                    radios[i].checked = true;
                    currentScore = parseInt(currentScore) + parseInt(radios[i].placeholder);
                }
            }
        } */
        
        var checklists = component.get("v.caseQalist");
        checklists[0].questions.forEach(function(questionObj){
            questionObj.selectedChoice = 'Yes';
            currentScore += parseInt(questionObj.question.Weighting__c);
        });
        component.set("v.caseQalist",checklists);
    
        var agentScore = Math.ceil(this.percent(currentScore, wtotal)) ;
        component.set("v.agentScore",agentScore);
        component.set("v.currentScore",currentScore);
        
    },
    
    /*
     * Purpose : used to get agentScore value onload. 
     */
    onloadCalculateAgentScore : function(component){
        var checklists = component.get("v.caseQalist");
        var currentScore = 0;
        var yesCount = 0;
        var naCount = 0;
        var wtotal = component.get("v.wtotal");
        var totalWithOutNA = 0;
        var auditQA = false;
        
        var checklists = component.get("v.caseQalist");
        checklists[0].questions.forEach(function(questionObj){
            if(questionObj.selectedChoice == 'Yes'){
                yesCount += parseInt(questionObj.question.Weighting__c);
            }else if(questionObj.selectedChoice == 'NA'){
                naCount += parseInt(questionObj.question.Weighting__c);
            }else if(questionObj.selectedChoice == 'No'){
                if(questionObj.isAuditQuestion){
                    auditQA = true; 
                }
            }
        }); 
        
        currentScore = parseInt(yesCount); 
        
        if(!auditQA){
            totalWithOutNA = (parseInt(wtotal) - parseInt(naCount));
        }
        
        var agentScore = Math.ceil(this.percent(currentScore, totalWithOutNA)); 
        component.set('v.agentScore', agentScore);
        component.set("v.currentScore",currentScore);
        component.set("v.naCount",naCount);
    },
    
    /*
     * Purpose : used to calculate percentage of agentScore. 
     */
    percent : function(topVal, btmVal) {
        if(parseInt(btmVal) > 0){
             return ( ( parseInt(topVal) / parseInt(btmVal) ) * 100 );
        }else{
            return 0;
        }
    },
    
    /*
     * Purpose : used to show spinner. 
     */
    showSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    /*
     * Purpose : used to hide spinner. 
     */
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
})