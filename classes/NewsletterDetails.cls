public class NewsletterDetails {
	@AuraEnabled public Newsletter__c newsletter { get; set; }
	@AuraEnabled public List<Id> selectedQuestionsIds { get; set; }
    @AuraEnabled public List<NewsletterGroupDetailsAndQuestions> groupsDetailsAndQuestions { get; set; }
}