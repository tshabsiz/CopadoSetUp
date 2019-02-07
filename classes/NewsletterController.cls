public class NewsletterController {
    public NewsletterDetails newsletterDetails { get; set; }
    public String newsletterId { get; }

    // the groups to get Chatter posts from
    static List<CollaborationGroup> chatterGroups;
    static String imagesBaseUrl;
    static String linksBaseUrl;
    static String communityName;
    static String folderName;
    static Id orgId;
    static Id networkId;

    /**************************************************************
     *  
     **************************************************************/
    public static NewsletterGroupQuestion buildQuestionFromFeedElement(ConnectApi.FeedElement feedElement, boolean preparingNewsletter) {
        ConnectApi.FeedItem item = (ConnectApi.FeedItem)feedElement;
        NewsletterGroupQuestion question = new NewsletterGroupQuestion();                    
        question.id = feedElement.Id;
        question.title = feedElement.capabilities.questionAndAnswers.questionTitle;
        NewsletterController.getQuestionPictureAndBody(feedElement.body, question, preparingNewsletter);
        question.createdDate = feedElement.createdDate;
        return question;
    }

	/**************************************************************
     *  
     **************************************************************/
    public static List<CollaborationGroup> getChatterGroups() {
        return NewsletterController.chatterGroups;
    }

	/**************************************************************
     *  
     **************************************************************/
    public static Id getNetworkId() {
        return NewsletterController.networkId;
    }

	/**************************************************************
     *  
     **************************************************************/
    public static void getSettings() {
        List<Newsletter_Employee_Setting__mdt > settings = [SELECT Id, Label, Value__c FROM Newsletter_Employee_Setting__mdt ORDER BY Label ASC];
    	List<String> groupsNames = new List<String>();
        NewsletterController.orgId = UserInfo.getOrganizationId();
        integer settingsCount = 0;

        for(Newsletter_Employee_Setting__mdt setting: settings) {
            if( setting.Label.startsWith('Chatter Group')) {
                groupsNames.add(setting.Value__c);
                continue;
            }

            if( 'Links Base Url' == setting.Label ) {
                NewsletterController.linksBaseUrl = setting.Value__c;
                settingsCount++;
                continue;
            }

            if( 'Images Base Url' == setting.Label ) {
                NewsletterController.imagesBaseUrl = setting.Value__c;
                settingsCount++;
                continue;
            }
            
            if( 'Community Name' == setting.Label ) {
                NewsletterController.communityName = setting.Value__c;
                settingsCount++;
		        List<Network> community = [SELECT Id FROM Network WHERE Name = :NewsletterController.communityName LIMIT 1];
        		// The "Employees" community must exist
                if( 1 != community.size() ) throw new AuraHandledException('Community ' + NewsletterController.communityName + ' not found.');
                NewsletterController.networkId = community[0].Id;
                continue;
            }

            if( 'Folder Name' == setting.Label ) {
                NewsletterController.folderName = setting.Value__c;
                settingsCount++;
                continue;
            }
            
        }

      	// take the small photo url to default in case the posts don't have photo (not dealt with)
        NewsletterController.chatterGroups = [SELECT Id, Name, SmallPhotoUrl FROM CollaborationGroup WHERE Name IN :groupsNames AND NetworkId =: NewsletterController.networkId];
        if( NewsletterController.chatterGroups.isEmpty() ) throw new AuraHandledException('Could not retrieve the news groups, please contact your administrator.');
        if( 4 != settingsCount ) throw new AuraHandledException('Could not retrieve all the settings, please contact your administrator.');
    }

	/**************************************************************
     *  
     **************************************************************/
    // We let the author aggregate Chatter Posts in the Newsletter, from selected groups
    @AuraEnabled
    public static NewsletterDetails getNewsletterDetailsAndPostsUsed(String newsletterId, boolean preparingNewsletter) {
        // retrieve all the settings which are org specific
        NewsletterController.getSettings();
        Date searchFrom, searchTo;

        NewsletterDetails newsletterDetails = NewsletterController.getNewsletterDetails(newsletterId);
        // if creation, search until today
        if( '' == newsletterId ) searchTo = Date.today();
        else {
            // defines the oldest date to display questions from. If newsletter already sent, search until its date
            if( newsletterDetails.newsletter.Sent__c ) searchTo = newsletterDetails.newsletter.Date__c;
            // if not sent, search until today
            else searchTo = Date.today();            
        }
        // search until the same day does not work, since you compare 00:00 and the datetime of a post, always >
        searchTo.addDays(1);
        
        // retrieve the previous sent newsletter details, to only list posts that were created AFTER it
        Newsletter__c[] previousSentNewsletters = [
            SELECT Id, Date__c, (SELECT Id, Chatter_Post_Id__c FROM Newsletter_News__r)
            FROM Newsletter__c
            WHERE Date__c < :searchTo
            AND Sent__c = true
            ORDER BY Date__c DESC
            LIMIT 1
        ];

        Newsletter__c previousSentNewsletter = null;
        List<Newsletter_news__c> previousSentNewsletterNews = null;
        
        // define how far to search from
        if( previousSentNewsletters.isEmpty() ) {
			// if no previous newsletter?
            searchFrom = Date.today();
            // search N months in the past
            searchFrom = searchFrom.addMonths(-3);
        } else {
            // otherwise search until the previous newsletter
            previousSentNewsletter = previousSentNewsletters[0];
            searchFrom = previousSentNewsletter.Date__c;
        }

        newsletterDetails.groupsDetailsAndQuestions = new List<NewsletterGroupDetailsAndQuestions>();
        NewsletterGroupDetailsAndQuestions groupDetailsAndQuestions;
        List<NewsletterGroupQuestion> questions;
        NewsletterGroupQuestion question;

        for(CollaborationGroup chatterGroup : NewsletterController.chatterGroups) {
            groupDetailsAndQuestions = new NewsletterGroupDetailsAndQuestions();
            groupDetailsAndQuestions.groupId = chatterGroup.Id;
            groupDetailsAndQuestions.groupName = chatterGroup.Name;
            groupDetailsAndQuestions.questions = new List<NewsletterGroupQuestion>();
/*
             System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> NewsletterController.getNetworkId()= ' + NewsletterController.getNetworkId()
                         + ', chatterGroup.Name= ' + chatterGroup.Name
                         + 'chatterGroup.Id= ' + chatterGroup.Id);
*/
            // "enable" test
            ConnectApi.FeedElementPage feedElementPage;
            if( Test.isRunningTest() ) {
                NewsletterControllerTest.mockFeedElementPage(chatterGroup.Id);
            }
            /*
             * Redo with simple SOQL? SELECT Body,CreatedDate,Id,LikeCount,ParentId,Title FROM FeedItem WHERE Type = 'QuestionPost' AND ParentId = '0F95E0000008gGzSAI'
             * All is easy, maybe even easier to do, especially getting the Likes count, but we should have an html tag stripping solution...
             **/
            
            feedElementPage = 
                // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_ChatterFeeds_static_methods.htm#apex_ConnectAPI_ChatterFeeds_static_methods
                // getFeedElementsFromFeed(communityId, feedType, subjectId, pageParam, pageSize, sortParam)
                // theoretically speaking, we should page through all the posts. Practically speaking, it is not needed until there are less than 100 posts a month in each group
                // which should be ok until year 3000
                ConnectApi.ChatterFeeds.getFeedElementsFromFeed(NewsletterController.getNetworkId(),
                                                                  ConnectApi.FeedType.Record,
                                                                  chatterGroup.Id,
                                                                  null,
                                                                  100,
                                                                  ConnectApi.FeedSortOrder.CreatedDateDesc
                                                                 );
			// Null? (happens in test, not sure if it can happen for real) Skip
            if( null == feedElementPage ) continue;
            if( null == feedElementPage.elements ) continue;

            // Optionally, go through all page (.nextPageToken != null), but 100 elements by group between two newsletter seems fine to me
            for( ConnectApi.FeedElement feedElement : feedElementPage.elements ) {
                // if it's not a question, skip it
                if( null == feedElement.capabilities.questionAndAnswers ) continue;
                // Skip too recent posts
                if( feedElement.createdDate > searchTo.addDays(1) ) continue;
                // Exit on the first Chatter post older than the last newsletter sent
                if( feedElement.createdDate < searchFrom.addDays(1) ) break;
                // build the working object and set flag if question is selected to be included in the newsletter
                question = NewsletterController.buildQuestionFromFeedElement(feedElement, preparingNewsletter);
                question.isSelected = newsletterDetails.selectedQuestionsIds.contains(question.id);
                // if post has no picture, use the group picture CAN'T WORK, the picture is not publice :-(
                // use static resource instead
                //if( null == question.pictureUrl ) question.pictureUrl = chatterGroup.SmallPhotoUrl;
                groupDetailsAndQuestions.questions.add(question);
            }

            // stop paging through posts if done
            newsletterDetails.groupsDetailsAndQuestions.add(groupDetailsAndQuestions);
        }

        return newsletterDetails;
    }
    
    /**************************************************************
     *  
     **************************************************************/
    public static NewsletterDetails getNewsletterDetails(String newsletterId) {
        NewsletterDetails newsletterDetails = new NewsletterDetails();
        newsletterDetails.selectedQuestionsIds = new List<Id>();
        if( '' == newsletterId ) return newsletterDetails;

        // proper newsletter details
        newsletterDetails.newsletter = [SELECT Id, Name, Date__c, Distribution_list_1__c, Distribution_list_2__c, Distribution_list_3__c, Editorial__c, Sent__c FROM Newsletter__c WHERE Id = :newsletterId LIMIT 1];
        // newsletter stored selected chatter questions
		List<Newsletter_news__c> selectedQuestions = [SELECT Id, Chatter_Post_Id__c FROM Newsletter_news__c WHERE Newsletter__c =: newsletterId];
        
        // create a list of selected questions Ids to be able to do a contains() on the Id later
        for(Newsletter_news__c selectedQuestion: selectedQuestions) newsletterDetails.selectedQuestionsIds.add(selectedQuestion.Chatter_Post_Id__c);
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + newsletterDetails.selectedQuestionsIds);

        return newsletterDetails;
    }

    /**************************************************************
     * 
     **************************************************************/
    public static String getPictureUrl(ConnectApi.MessageBodyInput body, boolean preparingNewsletter) {
        Id pictureId = null;
        // make a list of all the mentioned users id
        for( ConnectApi.MessageSegmentInput segment : body.messageSegments ) {
            if( segment instanceof ConnectApi.InlineImageSegmentInput ) {
                pictureId = ((ConnectApi.InlineImageSegmentInput)segment).fileId;
                break;
            }
        }
        if( null == pictureId ) return '';

		List<ContentVersion> cvs = [SELECT Id, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId = :pictureId LIMIT 1];
        if( cvs.isEmpty() ) return '';

        ContentVersion cv = cvs[0];
    	// Since webmails block inline images (gmail, outlook, etc.), the proper solution is:
		// 1) get the thumbnail version of the picture: DOES NOT WORK, "System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out"
			// HttpResponse pictureResponse = NewsletterController.getThumbnailFromUri('/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + cv.Id); //&operationContext=CHATTER&contentId=05T5E000001SiX9&page=0';
		// 2) store it as a publicly available document (CODE NOT TESTED)
        List<Document> documents = [SELECT Id FROM Document WHERE Name = :pictureId LIMIT 1];
        Document d;

        if( documents.isEmpty() ) {
            // if we are preparing the newsletter, we may be creating the documents for the first time, no problem
	        if( preparingNewsletter ) {
		        d = new Document();
            // but if we are sending the newsletter, we can't (DML) insert the documents, plus they should be there already!
            } else throw new AuraHandledException('Could not retrieve the pictures for the newsletter, please contact your administrator.'); 
        } else d = documents[0];

        if( preparingNewsletter ) {
			d.body = cv.VersionData;//pictureResponse.getBodyAsBlob();
			d.Type = cv.FileExtension;
			d.contentType = 'image/' + cv.FileExtension; //pictureResponse.getHeader('Content-Type');
			d.IsPublic = true;
			Folder f = [SELECT Id FROM Folder WHERE Name = :NewsletterController.folderName LIMIT 1];
			d.FolderId = f.Id;
			d.Name = pictureId;
			//d.Url = ;
			upsert d;
        }
        return NewsletterController.imagesBaseUrl + 'servlet/servlet.ImageServer?id=' + d.Id + '&oid=' + NewsletterController.orgId;
//    	return 'data:image/' + cv.FileExtension + ';base64,' + EncodingUtil.base64Encode(cv.VersionData);
//    	return 'data:' + pictureResponse.getHeader('Content-Type') + ';base64,' + EncodingUtil.base64Encode(pictureResponse.getBodyAsBlob());
	}
    
    /**************************************************************
     *  
     **************************************************************/
    public static void getQuestionPictureAndBody(ConnectApi.FeedBody body, NewsletterGroupQuestion question, boolean preparingNewsletter) {
        if( null == body ) {
            question.body = null;
            question.pictureUrl = null;
            return;
        }

        // simplistic version just getting rid of image "tags".
        // More powerful version would, for example: replace mentions by bold names, show images...
        Pattern removeImageTagsPattern = Pattern.compile('\\[Image: [^]]+\\]');
        // just get rid of image "tags" for now.
        question.body = removeImageTagsPattern.matcher(body.text).replaceAll('');
        ConnectApi.FeedItemInput input = ConnectApiHelper.createFeedItemInputFromBody(body);
        question.pictureUrl = NewsletterController.getPictureUrl(input.body, preparingNewsletter);
    }

	/**************************************************************
     *  
     **************************************************************/
    public static Id getTemplateId() {
        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE Name = 'Newsletter Employee community' LIMIT 1];
        if( templates.isEmpty() ) return null;
        return templates[0].Id;
    }

	/**************************************************************
     * salesforce_pages_developers_guide page 215 
     * 
     **************************************************************/
/*
	public static HttpResponse getThumbnailFromUri(String url) {
        // Be sure to authorize the endpoint in Setup > Security Controls > Remote Site Settings
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://barclaysafrica--comm.cs84.my.salesforce.com' + url);
        req.setMethod('GET');
        Http binding = new Http();
        HttpResponse res = binding.send(req);
        //Blob image = res.getBodyAsBlob();
        //return image;
        return res;
        // return 'data:'+res.getHeader('Content-Type')+';base64,'+EncodingUtil.base64Encode(image);
    }
*/
    /**************************************************************
     *  
     **************************************************************/
    @AuraEnabled
    public static void saveSelectedQuestionsIds(String newsletterId, List<String> questionsIds) {
        //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + questionsIds);
        // remove all previously selected questions for this newsletter
        delete [SELECT Id FROM Newsletter_news__c WHERE Newsletter__c =: newsletterId];
        //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + 'delete done');
        Newsletter_news__c[] newsList = new List<Newsletter_news__c>();
        Newsletter_news__c news;

        for(String questionId : questionsIds) {
            news = new Newsletter_news__c();
            news.Chatter_Post_Id__c = questionId;
            //news.Chatter_Group_Id__c = groupId;
            news.Newsletter__c = newsletterId;
            newsList.add(news);
        }
        insert newsList;
/**/
    }

    /**************************************************************
     * salesforce_pages_developers_guide page 198 
     * 
     **************************************************************/
    @AuraEnabled
    public static void sendNewsletterServer(String newsletterId, String networkUrl) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // use template: Newsletter Employee community 
        Id templateId = NewsletterController.getTemplateId();
		if( null == templateId ) throw new AuraHandledException('Could not retrieve the Newsletter template, please contact your administrator.');
        mail.setTemplateId(templateId);
        // recipient is the current user
        mail.setTargetObjectId(UserInfo.getUserId());
        // the related to object, here the newsletter
        mail.setWhatId(newsletterId);
        // must be false when sending to a user
        mail.setSaveAsActivity(false);
//        mail.setBccAddresses(new List<String>{'marc.bourlon@gmail.com','marc@bourlon.com'});
/*
 *  we could use a vf page as a preview
 *          PageReference pr = Page.VisualforceQuotePDF;
            pr.getParameters().put('id', quote.id);
            Blob content = pr.getContent();
 */         
        if( !Test.isRunningTest() ) {
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug(r);
        }
            
        // Mark the newsletter as sent
        Newsletter__c newsletter = [SELECT Id FROM Newsletter__c WHERE Id = :newsletterId LIMIT 1];
        newsletter.Sent__c = true;
        update newsletter;
    }

	/**************************************************************
     * salesforce_pages_developers_guide page 215 
     * 
     **************************************************************/
    public NewsletterController() {
        NewsletterController.getSettings();
    }

    public String getLinksBaseUrl() {
		return NewsletterController.linksBaseUrl;
    }

    /**************************************************************
     * 
     **************************************************************/
    public void setNewsletterId(String newsletterId) {
        this.newsletterDetails = NewsletterController.getNewsletterDetailsAndPostsUsed(newsletterId, false);
    }

}