trigger CaseTrigger2 on Case (before update, before insert) {

if(trigger.isbefore){
    if(trigger.isupdate){
        CaseUtilityHandler.AddMembers(Trigger.new);
        CaseUtilityHandler.AddLegalTeam(Trigger.new);
    }
    CaseUtilityHandler.checklawyer(Trigger.new);
    CaseUtilityHandler.ApprovalUAT(Trigger.new);
}



}