@IsTest(SeeAllData=true)
public class NewsletterControllerTest {
    
    @IsTest(SeeAllData=true)
    static void testGetNewsletterDetailsAndPostsUsed() {
        NewsLetterController.getSettings();
        // check that the 3 Chatter groups exist
        List<CollaborationGroup> groups = NewsLetterController.getChatterGroups();
        
        /* actually, can't use ConnectApiHelper, because it does not create questions
Id communityId = NewsletterController.getNetworkId();
ConnectApiHelper.postFeedItemWithRichText(communityId,
groups[0].Id,
'Have you seen this gorgeous view?'
);

ConnectApiHelper.postFeedItemWithRichText(communityId,
groups[0].Id,
'Have you seen this gorgeous view?'
);
*/
        
        // Create a sent newsletter for the sake of code coverage
        Newsletter__c newsletter1, newsletter2;
        newsletter2 = new Newsletter__c();
        newsletter2.Name = 'Test title 2';
        newsletter2.Date__c = Date.today().addDays(2);
        newsletter2.Editorial__c = 'Lorem ipsum 2';
        insert newsletter2;
        
        NewsletterController nc = new NewsletterController();
        nc.setNewsletterId(newsletter2.Id);
        nc.getLinksBaseUrl();
        NewsletterDetails newsletterDetails = nc.newsletterDetails;
        String newsletterId = nc.newsletterId;
        newsletterDetails = NewsletterController.getNewsletterDetailsAndPostsUsed(newsletter2.Id, true);
        
        newsletter1 = new Newsletter__c();
        newsletter1.Name = 'Test title 1';
        newsletter1.Date__c = Date.today().addDays(-30);
        newsletter1.Editorial__c = 'Lorem ipsum 1';
        newsletter1.Sent__c = true;
        insert newsletter1;
        
        newsletterDetails = NewsletterController.getNewsletterDetailsAndPostsUsed(newsletter2.Id, true);
        newsletterDetails.selectedQuestionsIds = new List<Id>();
        newsletterDetails.selectedQuestionsIds.add('0D55E00000EyiKvSAJ');
        NewsletterController.saveSelectedQuestionsIds(newsletter2.Id, newsletterDetails.selectedQuestionsIds);
        NewsletterController.sendNewsletterServer(newsletter2.Id, '');
        
        
        
        /*
Boolean exceptionThrown = false;
try {
ConnectApiHelper.postFeedItemWithMentions(null, 'me', '{001x00000000D7m}'); // not a group or user id
}
catch (ConnectApi.ConnectApiException e) {
System.assertEquals('Only user and group IDs may be used in inline mentions.', e.getMessage());
exceptionThrown = true;
}
System.assert(exceptionThrown);
*/
    }
    
    @IsTest(SeeAllData=true)
    static void testWrappers() {
        NewsletterDetails nd = new NewsletterDetails();
        nd.newsletter = new Newsletter__c();
        nd.selectedQuestionsIds = new List<Id>();
        NewsletterGroupDetailsAndQuestions ngdaq = new NewsletterGroupDetailsAndQuestions();
        ngdaq.groupId = null;
        ngdaq.groupName = 'Bozo';
        List<NewsletterGroupQuestion> ngqs = new List<NewsletterGroupQuestion>();
        NewsletterGroupQuestion ngq = new NewsletterGroupQuestion();
        ngq.id = null;
        ngq.title = 'Test';
        ngq.pictureUrl = 'test';
        ngq.body = 'test';
        ngq.isSelected = false;
        ngq.createdDate = Date.today();
        ngdaq.questions = ngqs;
        nd.groupsDetailsAndQuestions = new List<NewsletterGroupDetailsAndQuestions>();
        nd.groupsDetailsAndQuestions.add(ngdaq);
    }
    
    public static void mockFeedElementPage(Id chatterGroupId) {                    
        ConnectApi.FeedElementPage feedElementPage = new ConnectApi.FeedElementPage();
        ConnectApi.TextSegment textSegment = new ConnectApi.TextSegment();
        textSegment.text = 'This is my test question with a picture. ';
        ConnectApi.InlineImageSegment inlineImageSegment = new ConnectApi.InlineImageSegment();
        //                inlineImageSegment.fileDetails  = new ConnectApi.ContentImageFileDetails();
        inlineImageSegment.thumbnails = new ConnectApi.FilePreviewCollection();
        inlineImageSegment.thumbnails.fileId = '069B0000000q7hi';
        
        //inlineImageSegment.fileId = '069B0000000q7hi';
        
        ConnectApi.FeedElement feedElement = new ConnectApi.FeedItem();
        feedElement.capabilities = new ConnectApi.FeedElementCapabilities();
        feedElement.capabilities.questionAndAnswers = new ConnectApi.QuestionAndAnswersCapability();
        feedElement.capabilities.questionAndAnswers.questionTitle = 'Test question 1';
        feedElement.body = new ConnectApi.FeedBody();
        feedElement.body.messageSegments = new List<ConnectApi.MessageSegment>();
        feedElement.body.messageSegments.add(textSegment);
        feedElement.body.messageSegments.add(inlineImageSegment);
        feedElement.body.text = 'This is my test question with a picture.';
        feedElementPage.elements = new List<ConnectApi.FeedElement>();
        feedElementPage.elements.add(feedElement);
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed (NewsletterController.getNetworkId(),
                                                                ConnectApi.FeedType.Record,
                                                                chatterGroupId,
                                                                null,
                                                                100,
                                                                ConnectApi.FeedSortOrder.CreatedDateDesc,
                                                                feedElementPage
                                                               );
    }
    
}