Public Class CaseConvertHandler{


Public ContentVersion KnowledgeContent {get;set;}
Public List<ContentWorkspace> Library {get;set;}
Public String LibrarySelect {get;set;}
Public List<SelectOption> LibraryOptions {get;set;}
Public List<BoxFiles> LstBoxFiles {get;set;}
Public List<BxdKnowledgeItem> lstitem;
Public String CaseID;


Public CaseConvertHandler(){
   CaseID  =  apexpages.currentpage().getparameters().get('id');
    
   
    Case casecontent = new Case();
    casecontent = [Select id,Matter__c,Description,SuggestedTags__c,Subject,SuggestedLibrary__c From Case where id=:CaseID];
   
    KnowledgeContent = new ContentVersion(); 
    KnowledgeContent.advpm__Matter__c = casecontent.Matter__c;
    KnowledgeContent.Description =  casecontent.Description;
    KnowledgeContent.TagCsv = casecontent.SuggestedTags__c;
    KnowledgeContent.Title = casecontent.Subject;
   
    
    Library = [SELECT Id,Name FROM ContentWorkspace Where IsRestrictLinkedContentTypes=:false];
    
    LibraryOptions = new List<SelectOption>();
    
    LibraryOptions.add(new SelectOption('','-None-'));
    for(ContentWorkspace  l:Library){
        if(casecontent.SuggestedLibrary__c == 'Articles'){
            LibrarySelect = l.id ; 
        }          
        LibraryOptions.add(new SelectOption(l.id,l.name));
    }
          
          
          
           if (!Test.isRunningTest())
           {                
              //  lstitem = BxdKnowledgeService.getBoxFolderContents(CaseID);
                lstitem  = BxdKnowledgeService.getBoxFolderFiles(CaseID);
           }
           else
           {                 
               Blob Content = Blob.toPDF('Dummy File for testing');
               BxdKnowledgeItem i = new BxdKnowledgeItem ('156778', 'Scrubbed File', 'Box File', 'http://box.com', '1679867981', null);
               lstitem = new List<BxdKnowledgeItem>();
               lstitem.Add(i);
           }
    
    LstBoxFiles = new List<BoxFiles>();
     
            for(BxdKnowledgeItem i:lstitem){
                  BoxFiles BoxFile = new BoxFiles();
                  BoxFile.fileName  = i.name; 
                  BoxFile.fileDescription = casecontent.Description;
                  BoxFile.fileTags = casecontent.SuggestedTags__c;
                  BoxFile.fileUrl = i.url;
                  BoxFile.fileBoxId = i.id;
               //   BoxFile.fileContent = i.content;
                  BoxFile.fileBoxParent = i.parent;
                  BoxFile.Selectfile = false;
                  LstBoxFiles.Add(BoxFile);
            }
    
}

Public Pagereference Cancel(){
    
   return new  pagereference ('/'+ CaseID);
    

}

Public Pagereference ConvertContent(){

       
        if(LibrarySelect =='' || LibrarySelect ==null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select a library'));
                return null;
        } 
       
       /*
       String userId = userinfo.getuserid();
       
       ContentDocumentLink[] DocLink = [SELECT ContentDocumentId,LinkedEntityId,Visibility FROM ContentDocumentLink Where LinkedEntityId =: userId];
      
       Set <String> Set_perm = new Set<String>();
       for(ContentDocumentLink cl:DocLink){
           Set_perm.add(cl.LinkedEntityId);
       }
       
       if(!Set_perm.Contains(LibrarySelect)){           
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You dont have permission to add content to Library'));
                return null;
       }
      */
      
            
       List<ContentVersion> lstKnowledgeContent = new List<ContentVersion>();
            
        Set<String> Set_AddContent = new Set<String>(); 
        Map<String,String> Map_Tags = new Map<String,String>();
        Map<String,String> Map_Desc = new Map<String,String>();
            
        for(BoxFiles b:LstBoxFiles){
          if(b.Selectfile){
                /*
                ContentVersion Content = new ContentVersion();               
                Content.FirstPublishLocationId = LibrarySelect;
                Content.PathonClient = b.fileName +'.pdf';
                Content.advpm__Matter__c = KnowledgeContent.advpm__Matter__c;
                Content.VersionData = b.fileContent;                             
                lstKnowledgeContent.Add(Content);
               
                Content.Description = b.fileDescription;
                Content.TagCsv = b.fileTags;
                */
                Map_Tags.Put(b.fileBoxId,b.fileTags);
                 Map_Desc.Put(b.fileBoxId,b.fileDescription);
                
              Set_AddContent.Add(b.fileBoxId);   
          }
        } 
        
        if(Set_AddContent.Size()==0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select a file'));
                return null;
        } 
        
        
        if (!Test.isRunningTest())
           {                
               lstitem = BxdKnowledgeService.getBoxFolderContents(CaseID);
           }
           else
           {                 
               Blob Content = Blob.toPDF('Dummy File for testing');
               BxdKnowledgeItem i = new BxdKnowledgeItem ('156778', 'Scrubbed File', 'Box File', 'http://box.com', '1679867981', null);
               lstitem = new List<BxdKnowledgeItem>();
               lstitem.Add(i);
           }
        
         RecordType[] rt = [SELECT id,Name,SobjectType FROM RecordType where SobjectType ='ContentVersion' AND Name = 'Legal Content'];
      
         
        for(BxdKnowledgeItem i:lstitem){
            if(Set_AddContent.contains(i.id)){
                ContentVersion Content = new ContentVersion();               
                Content.FirstPublishLocationId = LibrarySelect;
                Content.PathonClient = i.name;
                Content.advpm__Matter__c = KnowledgeContent.advpm__Matter__c;
                Content.Description = Map_Desc.get(i.id);
                Content.TagCsv = Map_Tags.get(i.id);
                Content.VersionData = i.Content;
                if(rt.size()>0){
                    Content.recordTypeid = rt[0].id;
                }                        
                lstKnowledgeContent.Add(Content);
             }
          }     
             
       
        
        
      try{
      
        Insert  lstKnowledgeContent;  
      }
      catch (Exception e){
      
        //   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e ));
                return null;
      }  
        
    //    ContentVersion cv = [select ContentDocumentId from ContentVersion where Id =: KnowledgeContent.Id]; 

      //  ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = UserInfo.getOrganizationId(),Visibility = 'AllUsers', ContentDocumentId = cv.ContentDocumentId, ShareType = 'C'); 
       // insert cl;
       
         
     //   ContentVersion[] Documents = [SELECT Title,ContentDocumentId FROM ContentVersion WHERE id = :KnowledgeContent.Id];
        
        // Adding library
     //    
     //   ContentDocument[] ContentDoc =[SELECT ParentId FROM ContentDocument Where id=:Documents[0].ContentDocumentId];
       // ContentDoc[0].ParentId = LibrarySelect;
        
     //   update ContentDoc;
        
        
        return new pagereference('/'+LibrarySelect);

}

Public Class BoxFiles{

Public String fileName {get;set;}
Public String fileDescription {get;set;}
Public String fileUrl {get;set;}
Public String fileBoxid {get;set;}
Public String fileTags {get;set;}
Public String fileBoxParent {get;set;}
Private Blob fileContent;
Public Boolean Selectfile {get;set;}

}


}