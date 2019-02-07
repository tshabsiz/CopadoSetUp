({
    /*
     * Purpose : used to get onload data to display. 
     */
	doInIt : function(component, event, helper) {
		var caseId = component.get("v.caseId");
        var templateId = component.get("v.templateId");
        
        var param = {};
        param.caseId = caseId ;
        param.templateId = templateId ;
        
        helper.callServer(component, 'getCaseChecklistRecords', param, false, function(resp){
            //console.log('resp',resp);
            if(resp.isSuccess){	
                component.set('v.caseChecklist', resp.objectList);
            }
            else{
                console.log('message',resp.message);
                helper.showMsg(component, event, 'Error', 'error', resp.message);
            } 
        });
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: templateId
            });
        })
        .catch(function(error) {
            console.log(error);
        });   
        
	},
    
    /*
     * Purpose : used to calculate agent score after click on radio button. 
     */
    onRadioButtonClick : function(component, event, helper) {
        var id = event.target.id ;
        var dataset = event.currentTarget.dataset;
        //console.log(value.qid);
       
        var choice = dataset.choice;
        var qId = dataset.qid;
        var sectionIndex = qId.split('-')[0];
        var questionIndex = qId.split('-')[1];
        var checklist = component.get("v.caseChecklist");
        var question  = checklist[sectionIndex].questions[questionIndex];
        question.selectedChoice = choice;
        console.log('avc',component.get("v.caseChecklist"));
    },
    
    /*
     * Purpose : used to create or update Case checklist record. 
     */
    save : function(component, event, helper){
        var caseId = component.get("v.caseId");
        var templateId = component.get("v.templateId");
        var caseChecklist = component.get("v.caseChecklist");
        var questionList = caseChecklist[0].questions ;
        var savedResults='';
        for(var index=0; index < questionList.length; index++){
            savedResults += questionList[index].questionId + '|' + questionList[index].selectedChoice + ';';
        }
        console.log('SavedResults',savedResults);        
        
        var param = {};
        param.id = caseChecklist[0].chkListId ;
        param.templateId = templateId ;
        param.savedResults = savedResults ;
        param.caseId = caseId ;
        
        helper.callServer(component, 'updateCaseChecklistRecord', param, false, function(resp){
            //console.log('resp',resp);
            if(resp.isSuccess){	
                helper.showMsg(component, event, 'Success', 'success', resp.message);
                helper.closeFocusedTab(component);
            }
            else{
                helper.showMsg(component, event, 'Error', 'error', resp.message);
                console.log('message',resp.message);
            } 
            
        });        
    },
    
    /*
     * Purpose : this function automatic call by aura:waiting event. 
     */   
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    /*
     * Purpose : this function automatic call by aura:donewaiting event. 
     */ 
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    
})