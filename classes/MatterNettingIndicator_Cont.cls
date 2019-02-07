public with sharing class MatterNettingIndicator_Cont {
    public advpm__Matter__c matter;
    public MatterNettingIndicator_Cont (ApexPages.StandardController stdController) {
        Id MatterId = ApexPages.currentPage().getParameters().get('id');

        if(MatterId != null){
            matter = [select id, Netting_Complete__c from advpm__Matter__c where id = :MatterId limit 1];

            if(matter.Netting_Complete__c == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING,'Please note that netting is incomplete and needs to be completed.'));
            }
        }
    }
}