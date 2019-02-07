//CloudSmiths : RN
//Date: 08/11/2016
//Desc : Default ContentDocumentLink Trigger
//---------------------------------------------------------------------
//Rudolf Niehaus - CloudSmiths
//Date 2017-01-27
//Comment all code out - move functionallity to the feedItem Trigger to limit SOQL queries
//---------------------------------------------------------------------------

trigger CSC_ContentDocumentLink_Trigger on ContentDocumentLink (after insert) {
/**
    String pID = '';
    list<ContentDocumentLink> caseRelatedItems = new list<ContentDocumentLink>();
	
    if(trigger.isAfter && trigger.isInsert){
       CSC_ContentDocumentLink_Trigger_Func.cloneItems(trigger.new);
    }
**/
}