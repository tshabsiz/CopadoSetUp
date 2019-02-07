public class NewsletterGroupDetailsAndQuestions {
	@AuraEnabled public Id groupId { get; set; }
    @AuraEnabled public String groupName { get; set; }
    @AuraEnabled public List<NewsletterGroupQuestion> questions { get; set; }
}