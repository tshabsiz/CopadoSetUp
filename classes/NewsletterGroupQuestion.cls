public class NewsletterGroupQuestion {
	@AuraEnabled public Id id { get; set; }
	@AuraEnabled public String title { get; set; }
    @AuraEnabled public String pictureUrl { get; set; }
    @AuraEnabled public String body  { get; set; }
    @AuraEnabled public Boolean isSelected  { get; set; }
    @AuraEnabled public Datetime createdDate  { get; set; }    
}