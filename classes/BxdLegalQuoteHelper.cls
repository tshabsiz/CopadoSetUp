public class BxdLegalQuoteHelper {
    public String quoteUrl {get;set;}
    public String lawFirmLink {get;set;}
    public String webhhookId {get;set;}
    public String quoteFolderId {get;set;}
    public Boolean quoteFolderExists {get;set;}
    
    public BxdLegalQuoteHelper(String quoteFolderId, Boolean quoteFolderExists){
        this.quoteFolderId = quoteFolderId;
        this.quoteFolderExists = quoteFolderExists;
    }
    
    public BxdLegalQuoteHelper(String quoteUrl, String lawFirmLink, String webhhookId){
        this.quoteUrl = quoteUrl;
        this.lawFirmLink = lawFirmLink;
        this.webhhookId = webhhookId;
    }
}