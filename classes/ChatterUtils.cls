/**
* @author Deloitte 
* @date 2015
*
* @group Chatter
*
* @description Chatter utilities 
*/
public class ChatterUtils {
    static public String TEXT_POST = 'TextPost';
    static public String LINK_POST = 'LinkPost';
    
    /**
    * @description Creates subscription for provided object / user info
    * @param Id userId 
    * @param Id objectToFollowId
    * @return EntitySubscription
    */
    static public EntitySubscription addFollower(Id userId, Id objectToFollowId) {
        EntitySubscription subscription = new EntitySubscription();
        subscription.subscriberId = userId;
        subscription.parentId = objectToFollowId;
        return subscription;
    }

    /**
    * @description Creates chatter feed post
    * @param Id parentId 
    * @param String body
    * @return FeedItem
    */
    static public FeedItem addTextPost(Id parentId, String body) {
        FeedItem feedItem = new FeedItem();
        feedItem.Type = TEXT_POST;
        feedItem.ParentId = parentId;
        feedItem.Body = body;
        return feedItem;
    }
    
    /**
    * @description Creates chatter feed post
    * @param Id parentId 
    * @param String title
    * @param String linkUrl
    * @param String body
    * @return FeedItem
    */
    static public FeedItem addLinkPost(Id parentId, String title, String linkUrl, String body) {
        FeedItem feedItem = new FeedItem();
        feedItem.Type = LINK_POST;
        feedItem.ParentId = parentId;
        feedItem.Title = title;
        feedItem.LinkUrl= linkUrl;
        feedItem.Body = body;
        return feedItem;
    }

    /**
    * @description Creates feed with @Mention in the chatter feed
    * @param Id parentId
    * @param String text
    * @param Id userToMentionId
    */
    public static void createChatterPostWithMention(Id parentId, String text, Id userToMentionId) {
      
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
      
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = text;
        messageInput.messageSegments.add(textSegment);
      
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = userToMentionId;
        messageInput.messageSegments.add(mentionSegment);
      
        ConnectApi.FeedItemInput inputdata = new ConnectApi.FeedItemInput();
        inputdata.body = messageInput;
      
        ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, parentId, inputdata, null); 
    }
    
}