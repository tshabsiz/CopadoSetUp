/*
* Purpose : Extension class for Dropzone.
* created by : 
**/
public class lscDropzoneExt {
    /*
*  Purpose :  - get clipboard image
* 			   - Create content record and feedItem	 
*/  	   
    @AuraEnabled
    public static Response getClipBoardImage(String base64File, String caseID, String fileName){
        
        system.debug('caseID :'+ caseID);
        //strip the base64 url prefix (data:image/png;base64,) then decode the base64 URL
        base64File = base64File.substringAfter(',');
        blob fileDataBlob = EncodingUtil.base64Decode(base64File);
        
        ContentWorkspace workspace;
        
        try{
            workspace = [Select Id From ContentWorkspace Where Name = 'CSC Email Files' LIMIT 1];
        }catch(exception ex){
            System.debug('Exception : ' + ex.getMessage());			
        }
        
        if(workspace != null){            
            String verId = createContent(fileDataBlob, workspace.Id, fileName);
            createFeedItem(verId, caseID); 
            return new Response(true, '', null);
        }
        
        return new Response(false, 'No Workspace found', null);
    }
    
    /**
* 	Purpose : Creates a content record
*/
    public static String createContent( Blob fileDataBlob, Id locationID, String fname){
        
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
    
    /**
* 	Purpose : Inserts a Case FeedItem that points to the content version / Blob
*/
    public static void createFeedItem(String contentVersionId, String caseID){
        
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