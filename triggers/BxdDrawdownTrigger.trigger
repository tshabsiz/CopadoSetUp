trigger BxdDrawdownTrigger on Drawdown__c (after insert) {    
    for (Drawdown__c drawdown : Trigger.new) {
        BxdDrawdownService.createBoxFolder(drawdown.Id);
    }
}