public without sharing class JLOC2Controller {
    private Id jlocId;
    private String joinParam;
    private String initializationParam;
    private JLOC__c jloc;

    public Boolean isVisible { get; set; }
    public String stateId { get; set; }
    public String flowId { get; set; }
    public String tenantId { get; set; }

    public JLOC2Controller(ApexPages.StandardController stdController) {
        //Get ManyWho Settings
        ManyWho_Settings__c mwSettings = ManyWho_Settings__c.getInstance('jloc');

        // Grab out the tenant identifer
        tenantId = mwSettings.Tenant__c;

        //Get Current Page Parameters that need a bit more logic
        jlocId = ApexPages.currentPage().getParameters().get('id');
        joinParam = ApexPages.currentPage().getParameters().get('join');
        initializationParam = ApexPages.currentPage().getParameters().get('initialization');

        if (String.isNotBlank(jlocId)) {
            // If click on Edit/View JLOC
            jloc = [SELECT Id, ManyWho_Join_URL__c FROM JLOC__c WHERE Id = :jlocId];
            stateId = jloc.ManyWho_Join_URL__c.split('join=')[1];
        } else {
            // If click on New JLOC
            flowId = mwSettings.FlowId__c;
        }

        //Set Visibility
        isVisible = true;
        if(initializationParam == 'false' && String.isNotBlank(joinParam)){
            String mwJoinUrl = '%'+joinParam;
            try{
                jloc = [SELECT Id FROM JLOC__c WHERE ManyWho_Join_URL__c LIKE :mwJoinUrl];
                UserRecordAccess recordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId = :jloc.Id AND UserId = :UserInfo.getUserId()];
                if(recordAccess.HasReadAccess){
                    isVisible = true;
                } else{
                    isVisible = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.errMsg_JlocInsufficientPrivileges));
                }
            } catch(QueryException ex){
                System.debug(ex);
            }
        }
    }
}