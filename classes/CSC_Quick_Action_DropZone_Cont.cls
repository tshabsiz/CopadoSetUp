/**
* Date   : 2017-05-24
* Author : Rudolf Niehaus - CloudSmiths
* Desc   : Controller add a new feed item for images pulled from teh clipboard vai a quick action in the console
**/
global class CSC_Quick_Action_DropZone_Cont {
   
    public CSC_Quick_Action_DropZone_Cont(ApexPages.StandardController controller){ }
    
    @remoteAction
    global static PageReference getClipBoardImage(String base64File, String caseID, String fileName){
        
        //strip the base64 url prefix (data:image/png;base64,) then decode the base64 URL
        base64File = base64File.substringAfter(',');
        blob fileDataBlob = EncodingUtil.base64Decode(base64File);
        
        list<ContentWorkspace> ws = [Select Id From ContentWorkspace Where Name = 'CSC Email Files'];
        
        if(ws.size() > 0){
            
            String verId = createContent(fileDataBlob, ws[0].Id, fileName);
            createFeedItem(verId, caseID);
            
        }else{
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no content folder to store this file, please contact your system admin'));
            
            return null;
        }  
        
        return null;
    }
    
    global static String createContent( Blob fileDataBlob, Id locationID, String fname){
        
        fname = fname.trim();
        ContentVersion cv = new ContentVersion();
        cv.title = fname + '.png';
        cv.versionData = fileDataBlob;
        cv.pathOnClient = fname + '.png';
        cv.FirstPublishLocationId = locationID;
        
        String newId = '';
        
        try{
            
            Database.SaveResult srList = Database.insert(cv , false);
            
            if (srList.isSuccess()) {
                newId = srList.getId();
            }else {
                // Operation failed, so get all errors                
                for(Database.Error err : srList.getErrors()) {
                    CSC_AuditTrailLog.logException(new DMLException(), 'New', 'Error', 'CSC_Quick_Action_DropZone_Cont', 'createContent', 
                                                   'There was an error inserting a ContentVersion record\n ' + err.getMessage());
                }
            }
        }catch(DMLException ex){
            System.debug('Adding content error');
            System.debug(ex.getMessage()); 
        } 
        
        return newId;
    }
    
    //This method inserts a Case FeedItem that points to the content version / Blob
    global static void createFeedItem(String contentVersionId, String caseID){

        FeedItem post = new FeedItem();
        post.ParentId = caseID;
        post.Body = 'CSC Case related content';
        post.RelatedRecordId = contentVersionId;
        post.Type = 'ContentPost';

        try{
            insert post; 
        }catch(DMLException ex){
            CSC_AuditTrailLog.logException(ex , 'New', 'Error', 'CSC_Quick_Action_DropZone_Cont', 'createFeedItem', 
                                                   'There was an error inserting a Feed Item record\n ' + ex.getMessage());
        } 
    }

}