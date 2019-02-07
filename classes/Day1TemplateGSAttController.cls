/**
* @author Deloitte 
* @date 2015
*
* @group Day 1 Template
*
* @description Class for handling custom attachments for Day 1 Template class
*/
public  class Day1TemplateGSAttController {
    
    public String selectedType {get;set;}
    public Boolean selectedAwesomeness {get;set;}
    public String description {get;set;}
    private Day_1_Template__c day1template {get;set;} 
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    
    /**
    * @description Controller
    */
    public Day1TemplateGSAttController(ApexPages.StandardController controller) { 
        this.day1template = (Day_1_Template__c)controller.getRecord();
    }   
    
    // creates a new Day_1_Template_GS__c record
    private Database.SaveResult saveCustomAttachment() {
        Day_1_Template_GS__c obj = new Day_1_Template_GS__c();
        obj.Day_1_Template__c = day1template.Id; 
        // fill out cust obj fields
        return Database.insert(obj);
    }
    
    // create an actual Attachment record with the Day_1_Template_GS__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = parentId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
    
    /**
    * @description Creates new group structure object along with document for day 1 template 
    * @return PageReference
    */
    /**
    * Upload process is:
    *  1. Insert new Day_1_Template_GS__c record
    *  2. Insert new Attachment with the new Day_1_Template_GS__c record as parent
    *  3. Update the Day_1_Template_GS__c record with the ID of the new Attachment
    **/
    public PageReference processUpload() {
        try {
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));            
                return null;
            } else {
                // update the custom attachment record with some attachment info
                Day_1_Template_GS__c customAttachment = [select id from Day_1_Template_GS__c where id = :customAttachmentResult.getId()];
                customAttachment.name = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                update customAttachment;
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        
        return new PageReference('/'+day1template.Id);
    }
    
    /**
    * @description Back, unsurprisingly, makes things go back
    * @return PageReference
    */
    public PageReference back() {
        return new PageReference('/'+day1template.Id);
    }     
 
}