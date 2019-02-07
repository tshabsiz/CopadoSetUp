({
    /*
     * Purpose : used to get onload data to display. 
     */
    doInIt : function(component, event, helper) {
        helper.showSpinner(component);
        var caseId = component.get("v.caseId");
        var templateId = component.get("v.templateId");
        
        var param = {
            'caseId' : caseId,
            'templateId' : templateId
        };
        
        helper.callServer(component, 'getCaseQaRecords', param, false, function(resp){
            //console.log('resp',resp);
            if(resp.isSuccess){	
                //debugger;
                var result = resp.objectList ;//caseQaRecord
                component.set('v.caseQalist', result);
                component.set('v.wtotal', result[0].weighting);
                helper.onloadCalculateAgentScore(component);
                if(result[0].caseQaRecord){
                    if(result[0].caseQaRecord.AgentName__c){
                        component.set('v.agentName', result[0].caseQaRecord.AgentName__r.Name);
                    }
                    //component.set('v.agentScore', Math.ceil(result[0].caseQaRecord.AgentScorePer__c));
                }
                helper.hideSpinner(component);
                console.log('caseQalist',component.get('v.caseQalist'));
            }
            else{
                helper.hideSpinner(component);
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
     * Purpose : used to get selected question answer. 
     */
    onRadioButtonClick : function(component, event, helper) {
        var id = event.target.id ;
        var dataset = event.currentTarget.dataset;
        //console.log(value.qid);
        
        var choice = dataset.choice;
        var qId = dataset.qid;
        var sectionIndex = qId.split('-')[0];
        var questionIndex = qId.split('-')[1];
        var checklist = component.get("v.caseQalist");
        var question  = checklist[sectionIndex].questions[questionIndex];
        question.selectedChoice = choice;
        console.log('caseQalist ',component.get("v.caseQalist"));
        helper.calculateScore(component, event);
    },
    
    /*
     * Purpose : To reset all the selected question. 
     */
    resetScore : function(component, event, helper){
        helper.resetScore(component);
    },
    
    /*
     * Purpose : To create or update caseQa record. 
     */
    save : function(component, event, helper){
        helper.showSpinner(component);
        var agentRecord = component.get("v.selectedLookUpRecord");
        //console.log('agentRecord',agentRecord);
        var agentName = component.get("v.agentName");
        console.log('agentName',agentName);
        var agentScore = component.get("v.agentScore");
        var caseQalist = component.get("v.caseQalist");
        var questionList = caseQalist[0].questions ;
        var savedResults='';
        var failedAuditRequirement = false;
        for(var index=0; index < questionList.length; index++){
            savedResults += questionList[index].questionId + '|' + questionList[index].selectedChoice + ';';
            if(questionList[index].isAuditQuestion && questionList[index].selectedChoice == 'No'){
                failedAuditRequirement = true;
            }
        }
        console.log('SavedResults',savedResults); 
        
        if((! $A.util.isEmpty(agentName) && agentName.trim() != '') || agentRecord){
            var caseQa = 
                {
                    SavedResults__c : savedResults,
                    SubmittedBy__c : $A.get("$SObjectType.CurrentUser.Id") ,
                    RelatedCase__c : component.get("v.caseId"),
                    QATemplate__c : component.get("v.templateId"),
                    AgentScore__c : component.get("v.currentScore"),
                    WeightingTotal__c : component.get("v.wtotal") - component.get("v.naCount"),
                    FailedAuditRequirement__c : failedAuditRequirement
                }
            if(agentRecord){
                caseQa.AgentName__c = agentRecord.Id ;
            }
            if(caseQalist[0].caseQaRecord){
                caseQa.Id = caseQalist[0].caseQaRecord.Id ;
            }
            
            var param = {
                caseQa : caseQa                    
                }
            helper.callServer(component, 'updateCaseChecklistRecord', param, false, function(resp){
                //console.log('resp',resp);
                if(resp.isSuccess){	
                    helper.hideSpinner(component);
                    helper.showMsg(component, event, 'Success', 'success', resp.message);
                    helper.closeFocusedTab(component);
                }
                else{
                    helper.hideSpinner(component);
                    console.log('message',resp.message);
                    helper.showMsg(component, event, 'Error', 'error', resp.message);
                } 
            });
        }
        else{
            helper.hideSpinner(component);
            helper.showMsg(component, event, 'Warning', 'warning', 'Please search and add an Agent that you would like to submit this QA form for');
        }
    },
    
})