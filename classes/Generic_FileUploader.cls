public class Generic_FileUploader { 
  
    //COMPONENT ATTRIBUTES
    public String sObjectId { get; set; }
    public String saveUrl { get; set; } 
    public String buttonClass { get; set; } 
    public String submitButtonValue { get; set; }
  
    //FILE ATTACHMENT
    public Attachment attachment 
    {
        get {      
            if(attachment == null) 
            {
                attachment = new Attachment();
            }
            return attachment;
        }
        set;
    }
    
    //EXISTING ATTACHMENTS
    public List<Attachment> getExistingAttachments() 
    {        
        return [SELECT Id, Name FROM Attachment WHERE ParentId =:sObjectId];
    }
    
    //EXISTING ATTACHMENTS SIZE
    public Integer getExistingAttachmentsSize() 
    {        
        return getExistingAttachments().size();
    }
  
    //ADD FILE - ACTION
    public PageReference addFile() {
            
        System.debug('### addFile : Start');
        System.debug('### addFile : attachment :'+attachment); 
        System.debug('### addFile : attachment : Name :'+attachment.Name); 
        System.debug('### addFile : attachment : BodyLength :'+attachment.BodyLength); 
        
        if(attachment.BodyLength > 2097152) 
        {
            System.debug('### addFile : attachment size check:');
            attachment = new Attachment(); //Clear Attachment Data For View State
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You may not upload a file that is bigger than 2 MB'));    
        }
        else if(attachment.Name == null) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a file in Step 1.')); 
        }
        else 
        {
            System.debug('### addFile : sObjectId :'+sObjectId);
            
            try {
                
                String fileName = attachment.Name;
                System.debug('### fileName : '+fileName);
                
                //Truncate The File Name.   Must not exceed 80 Characters.  This is a SFDC limitation
                if(fileName.length() > 80)
                {
                    fileName = fileName.left(80);
                }
                else
                {
                    fileName = attachment.Name;
                }
                
                attachment.ParentId = sObjectId;
                attachment.Name = fileName;
                
                //Insert attachment file.
                insert attachment;
            }
            catch(Exception e) 
            {
                System.debug('### addFile : catch : e :'+e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error uploading the file.   Please try again. (Error:'+e.getMessage()+' Line Number: '+e.getLineNumber()+')'));
            }
            finally 
            {
                System.debug('### addFile : catch : finally'); 
                attachment = new Attachment(); //Clear Attachment Data For View State
            }
            
        }
        
        System.debug('### addFile : End');
        return null;
    }
    
    //FINISH BUTTON - ACTION
    public PageReference finish() 
    {        
        PageReference pageRef = new PageReference(saveUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
}