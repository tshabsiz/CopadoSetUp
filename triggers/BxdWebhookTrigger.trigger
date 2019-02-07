trigger BxdWebhookTrigger on BoxWebhookNotification__c (after insert) {
    for (BoxWebhookNotification__c webhook: Trigger.new) {
        BxdLegalQuoteService.notifyLegalQuote(webhook.Id);
    }
}