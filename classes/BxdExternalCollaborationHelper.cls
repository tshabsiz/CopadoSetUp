public class BxdExternalCollaborationHelper {
    public String coowner {get;set;}
    public String name {get;set;}
    public String parentFolderId {get;set;}
    public String externalFolderId {get;set;}    
    public List<Collaborator> collaborators {get;set;}
    public box.Toolkit.CollaborationType collaborationType {get;set;}
    //for output usage only
    public String folderId {get;set;}
    
    public BxdExternalCollaborationHelper(String coowner, String name, String parentFolderId, String externalFolderId, List<Collaborator> collaborators, box.Toolkit.CollaborationType collaborationType){
        this.coowner = coowner;
        this.name = name;
        this.parentFolderId = parentFolderId;
        this.externalFolderId = externalFolderId;
        this.collaborators = collaborators;
        this.collaborationType = collaborationType;
    }
    
    /**
	* Wrapper class for external collaboration members
	**/
	public class Collaborator
	{
		public String email { get; set; }
        public String collaborationId { get; set; }

		public Collaborator(String email, String collaborationId)
		{
			this.email = email;
			this.collaborationId = collaborationId;
		}
	}
}