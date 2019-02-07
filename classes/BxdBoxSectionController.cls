public class BxdBoxSectionController {
    public Id objectId {get; set;}
    public String objectLabel {get; set;}
    public String redirectURL {get; set;}
    public String serviceType {get; set;}
    public Boolean showCreateFolder {get;set;}
    public Boolean shouldRedirect {public get; private set;}
    
    public BxdBoxSectionController(){
        objectId = ApexPages.currentPage().getParameters().get('Id'); 
        serviceType = ApexPages.currentPage().getParameters().get('param'); 
    }
    
    public PageReference CreateFolder(){
        shouldRedirect = true;      
        System.Type t = Type.forName(serviceType);
        BxdServiceInterface boxService = (BxdServiceInterface) t.newInstance();
        boxService.createBoxFolderSync(objectId);
        return null;
    }
    
    public PageReference initSectionRequest(){       
        objectLabel = objectId.getSObjectType().getDescribe().getLabel();
        showCreateFolder = true;
        return null;
    }
    
}