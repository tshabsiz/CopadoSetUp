//CloudSmiths : RN
//Date: 2017-01-27
//Desc : Default FeedItem Trigger
//---------------------------------------------------------------------
trigger FeedItem_Trigger on FeedItem (after insert) {

    if(trigger.isAfter && trigger.isInsert){
       CSC_ContentDocumentLink_Trigger_Func.cloneItems(trigger.new);
    }
    
}