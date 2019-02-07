/**
* 2017-07-18 - Rudolf Niehaus - CloudSmiths
* Controller for the quick action VF page Case_QuickAction_QA
* Lists all the avalable checklist and QA options per the business area of the running user
**/

public class Case_QuickAction_QA_Ext {
    
    private Case qaCase;
    private list<User> runningUser;
    public list<Case_Checklist_Template__c> tempNames {get;set;}
    public list<Case_QA_Template__c> qaTempNames {get;set;}
    
    public Case_QuickAction_QA_Ext(ApexPages.StandardController controller){ 
        qaCase = (Case)controller.getRecord();
        runningUser = [Select Hub__c From User Where Id = :UserInfo.getUserId()];
    }
    
    public list<Case_Checklist_Template__c> getTemplateNames(){
        
        tempNames = [Select Id, ChecklistName__c From Case_Checklist_Template__c Where BusinessArea__c = :runningUser[0].Hub__c];
        
        if(tempNames.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no checklist templates for the user: ' + UserInfo.getUserName()));
        }
    
        return tempNames;
    }
    public list<Case_QA_Template__c> getQATemplateNames(){
        
        qaTempNames = [Select Id, QAName__c From Case_QA_Template__c Where BusinessArea__c = :runningUser[0].Hub__c];
        
        if(qaTempNames.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no QA templates for the user: ' + UserInfo.getUserName()));
        }
        
        return qaTempNames;
    }
}