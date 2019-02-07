//CloudSmiths : RN
//Date: 08/11/2016
//Desc : Clone ContentVersion records related to Cases via the documentLink object and add them as file attchments to the file audit object
//------------------------------------------------------
//Rudolf Niehaus - CloudSmiths
//2017-01-27
//Remove the attachment section and onlt store the link to the DocumentVersion, which is the original email attachment
public class CSC_ContentDocumentLink_Trigger_Func {
    
    
    public static void cloneItems(list<FeedItem> fitems){    
        set<Id> contentDocIds = new set<Id>();
        map<String,String> linkMap = new map<String,String>();
        String pID = '';
        
        for(FeedItem f :fitems){
             pID = f.ParentId;
            //only add files that are related to cases
            if ( pID.startsWith('500') ){  
           		contentDocIds.add(f.RelatedRecordId);
            	linkMap.put(f.RelatedRecordId, f.ParentId);
            }
           
        }
        
        //now loop through the content and create an audit record with a link to the original email attachment in content
        list<CSC_File_Upload_Audit__c> faudit = new list<CSC_File_Upload_Audit__c>();
    
        for(ContentVersion con :[Select Id, ContentDocumentId, Title, VersionData, PathOnClient FROM ContentVersion Where Id IN :contentDocIds]){
           
            CSC_File_Upload_Audit__c fa = new CSC_File_Upload_Audit__c();
            fa.CSC_Support_Case__c = linkMap.get(con.Id);
            fa.File_Name__c = con.PathOnClient;
            fa.DocVersionID__c = con.Id;
            faudit.add(fa);
        }
        
        try{
            insert faudit; 
        }catch(DMLException ex){
            System.debug(ex.getMessage());
        }
        
    }
    
}