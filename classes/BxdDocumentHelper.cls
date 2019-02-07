public class BxdDocumentHelper {
    public BoxDocument__c boxDocument {get;set;}
    public String filename {get;set;}
    public String selected {get;set;}
    public String linkedFile {get;set;}
    
    public BxdDocumentHelper(BoxDocument__c boxDocument, String filename){
        this.boxDocument = boxDocument;
        this.filename = filename;
    }
}