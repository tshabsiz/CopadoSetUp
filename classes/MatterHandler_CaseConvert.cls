/**
 * Author: Sean Parker
*/
Public class MatterHandler_CaseConvert   {

public String MatterId;
public Case MatterCase  { get; set;}
public List<TagSelect> lstTagSelect  { get; set; }
public String VFtag;
public Boolean AddMatter { get; set; }
public List<BoxFiles> LstBoxFiles { get; set; }
public static Boolean convertedMatter;
public String callSuccessFunction { get; set; }

public MatterHandler_CaseConvert(){
    
    String[] lstTag;
    String tags;
    
    //Assign matter id based on page param.
    if(apexpages.currentpage().getparameters().get('Id') !=null){
        MatterId = apexpages.currentpage().getparameters().get('Id');
    }
    
    //New Case
    MatterCase = new Case();      

    //Fetch all "matter content" records for this matter.
    List<Matter_Content__c> lst_Content = new List<Matter_Content__c>([
        Select id,
          Matter__c,
          Content_Id__c,
          Case__c 
        from Matter_Content__c 
        Where Matter__c =: MatterId
    ]);
}

public void filesfromBox() {

    Id matterId = MatterId;
    List<BxdKnowledgeItem> items;
    LstBoxFiles = new List<BoxFiles>();
    
    //Retrieve existing files for matters box folder contents.
    if(!Test.isRunningTest()){
       items = BxdKnowledgeService.getBoxFolderFiles(matterId);
    }
    //Create and add a blank box knowledge item?
    else{
       BxdKnowledgeItem i = new BxdKnowledgeItem('name','description','url','id','parent', null);
       items = new List<BxdKnowledgeItem>(); 
       items.Add(i);
    }
    
    //Iterate over box knowledge folder items and add to list.
    for(BxdKnowledgeItem i:items){
      BoxFiles BoxFile = new BoxFiles();
      BoxFile.fileName  = i.name;
      BoxFile.fileDescription = i.description;
      BoxFile.fileUrl = i.url;
      BoxFile.fileBoxId = i.id;
      BoxFile.fileBoxParent = i.parent;
      BoxFile.Selectfile = false;
      LstBoxFiles.Add(BoxFile);
    }
}    

public PageReference ConvertMatterToCase() {
  
    convertedMatter = true;    
    
    //Set matter on new case.
    MatterCase.Matter__c = MatterId;
    
    //Set case owner to knowledge queue.
    QueueSobject[] QueueID = [SELECT CreatedById,Id,QueueId,SobjectType,queue.Name FROM QueueSobject where queue.Name='Knowledge Request Queue' limit 1];
    MatterCase.OwnerId=QueueID[0].QueueId;
    
    //Set case record type to knowledge request.
    RecordType rt = [Select id From RecordType where Name= 'Knowledge Request' limit 1];
    MatterCase.RecordTypeid = rt.id;    

    //Set the initial case status.
    MatterCase.Status = 'KM In Progress';

    //Insert the new case.
    Insert MatterCase;
      
    //Query all matter content records associated with matter.
    List<Matter_Content__c> lst_Content = new List<Matter_Content__c>([Select id,Matter__c,Case__c from Matter_Content__c Where Matter__c =: MatterId ]);

    //Associate matter content records with the case.
    for(Matter_Content__c c:lst_Content) {
        c.Case__c = MatterCase.id;
    }
       

    lst_Content = new  List<Matter_Content__c>();
    
    //Iterate over box files.
    for(BoxFiles b:LstBoxFiles){
        
        //Select in list in VF page UI.
        if(b.Selectfile) {

            //Build up new matter content item.
            Matter_Content__c Content = new Matter_Content__c();
            Content.Document_Source__c = 'Box';
            Content.Box_Url__c = b.fileUrl;
            Content.Content_Name__c = b.fileName;
            Content.Description__c = b.fileDescription;
            Content.Case__c = MatterCase.id; 
            Content.Box_id__c = b.fileBoxid;
            Content.Box_Parent_Id__c =  b.fileBoxParent;      

            //Add to the matter content list.
            lst_Content.Add(Content);
        }  
    }    

    //Insert box linked matter content.
    insert lst_Content; 
       
    advpm__Matter__c Matter;

    //Requery a milliion field on the matter for PDF inclusion.
    Matter = [Select recordTypeid, recordType.Name,Name,Reputational_Risk__c,advpm__Engagement_Date__c,Cost_Centre__c,
                            Jurisdiction__c,Customer_account_number_policy_number__c,Litigation_Status__c,Client_Branch_code__c,
                            advpm__Description__c,Total_Claim_Percentage__c,Matter_Type__c,Category__c,advpm__Legal_Hold__c,
                            Claim_By_Against_Barclays__c,Reasonably_Possible__c,Approval_Status__c,Probable_For_Approval__c,
                            Financial_Value_Unknown__c,Matter_Value__c,Attainable_litigation_objective__c,Securitization_value__c,
                            Current_Status__c,Notes__c,Previous_current_status__c,Disposition_Type__c,advpm__Projected_Date_Of_Closure__c,
                            Disposition_Description__c,Positive_Outcome_Before_All_Costs__c,Negative_Outcome_Before_All_Costs__c,Costs_Awarded_Against_Barclays__c,
                            Costs_Actually_Recovered__c, Lead_Lawyer_Office__c, Business_Unit_Cluster_Segment__r.Name,Business_Unit_Cluster_Segment__c,advpm__Status__c,
                            Date_of_Closure__c,advpm__Primary_Account__c,advpm__Primary_Contact__c,Owner.Name                           
                             From advpm__Matter__c Where Id=:MatterId limit 1];

       
    if(Test.isRunningTest()){ 
        AddMatter = true;
    }

    //Query return a matter.
    if(AddMatter) {

        PageReference pdf;
        
        if(MatterId != null){                  
            pdf =  Page.MatterToCaseConvertPDF;
        }
        
        //Set page params for PDF generating page.
        pdf.getParameters().put('id',MatterId); 
        pdf.getParameters().put('RecordType',(String) Matter.recordTypeid); 
        pdf.setRedirect(true); 
        
        Blob body; 

        if(Test.isRunningTest()) {
            body = Blob.valueOf('body');
        }
        else
        {   
            //Fetch PDF data from VF Page.
            body = pdf.getContentAsPDF();
        }
        
        //New attachment record.
        Attachment attach = new Attachment();
        attach.Body = body;
        attach.Name = Matter.Name+'.pdf';
        attach.IsPrivate = false;
        attach.ParentId = MatterCase.Id;
        
        //Insert attachement and associate with case. 
        insert attach;
      }

    PageReference pageRef;

    //Get current users profile
    Id userProfId = UserInfo.getProfileId();
    String userProfile = [select Name from profile where id = :userProfId limit 1].Name;

    //Create box items via redirect page.
    pageRef = new PageReference('/apex/CaseRedirectForBox?id='+MatterCase.Id+'&matterId='+MatterId);
    pageRef.setRedirect(true);
    return pageRef;
}
 
public PageReference SubmitCaseToBox() {
            
    String CaseId;

    String matterId = ApexPages.currentPage().getParameters().get('matterId');

    //If there is a case id in the URL params.
    if(apexpages.currentpage().getparameters().get('Id') !=null) {
        
        //Get passed in case id.
        CaseId = apexpages.currentpage().getparameters().get('Id');

        //Get a single attachment that is on the case.
        Attachment[] attach = [Select Body,Name,ParentId From Attachment Where ParentId =: CaseId limit 1];
        
        //Get all matter content assocaite with the case.
        List<Matter_Content__c> lst_Content = new List<Matter_Content__c>([
            SELECT 
                id,
                Box_id__c,
                Box_Parent_Id__c,
                Content_Name__c,
                Description__c,
                Box_Url__c,
                Matter__c,
                Case__c 
            FROM Matter_Content__c 
            WHERE 
                Case__c =: CaseId 
        ]);
        
        List<BxdKnowledgeItem> lstitems = new List<BxdKnowledgeItem>();
        
        //Build up list of knowledge box items on matter content.
        for(Matter_Content__c c : lst_Content) {
           BxdKnowledgeItem items = new  BxdKnowledgeItem(c.Box_id__c, c.Content_Name__c , c.Description__c, c.Box_Url__c,c.Box_Parent_Id__c, null);
           lstitems.Add(items);
        }

        Boolean b;

        if(attach.size() > 0) {
            b =   BxdKnowledgeService.createBoxCaseFolder(CaseId,lstitems,attach[0].Body,attach[0].Name);
        }
        else {
            Blob body;
            body = Blob.valueOf('Null'); 
            b =   BxdKnowledgeService.createBoxCaseFolder(CaseId,lstitems,null,'');
        }
    }

    //Redirect back to matter.
    PageReference pageRef;
    pageRef = new PageReference('/'+matterId);
    return pageRef;
}


    //Wrapper class for selected tags?
    public class TagSelect {        
        public String tags { get; set; }
    }

    //Box file wrapper.
    public class BoxFiles {

        public String fileName { get; set; }
        public String fileDescription { get; set; }
        public String fileUrl { get; set; }
        public String fileBoxid { get; set; }
        public String fileBoxParent { get; set; }
        public Boolean Selectfile { get; set; }
    }

    //Page action to cancel and return to the matter.
    public Pagereference Cancel() {
        PageReference pageRef = new PageReference('/'+MatterId);
        return pageRef;
    }
}