public class BxdCollaborationRequest {
    public Id parentId {get; set;}
    public Id recordId {get; set;}
    public String email {get; set;}
    public String boxUserId {get; set;}
    public String folderId {get; set;}
    public String folderName {get; set;}
    public box.Toolkit.CollaborationType collabType {get; set;}
    private static BxdCollaborationRequest request = null;
   
    private BxdCollaborationRequest(){
        
    }
    
    public static BxdCollaborationRequest getRequest(){
        if(request == null) request = new BxdCollaborationRequest();
        return request;
    }
}