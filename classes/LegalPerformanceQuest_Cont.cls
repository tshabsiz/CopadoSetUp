/**
 * Created by Kyle Alexander on 2018/02/15.
 */

public with sharing class LegalPerformanceQuest_Cont {
    public Legal_Performance_Questionnaire__c legal_performance_quest {get;set;}

    public Id matterId;

    public LegalPerformanceQuest_Cont (ApexPages.StandardController stdController) {
        legal_performance_quest = (Legal_Performance_Questionnaire__c) stdController.getRecord();
        
        Id lawFirmId = apexpages.currentpage().getparameters().get('lawFirm');
        legal_performance_quest.LawFirm__c = lawFirmId;
        
        matterId = apexpages.currentpage().getparameters().get('matter');
        legal_performance_quest.Matter__c = matterId;
        
        Id msdId = apexpages.currentpage().getparameters().get('msd');
        legal_performance_quest.MatterSpendDocument__c = msdId;
    }

    public PageReference CancelPage() {
        PageReference pf = new PageReference('/' + matterId);
        return pf;
    }

    public PageReference SaveQuestionnaire() {
        insert legal_performance_quest;
        PageReference pr = new PageReference('/' + matterId);
        pr.setRedirect(true);
        return pr;
    }
}