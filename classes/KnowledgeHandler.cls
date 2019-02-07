Public class KnowledgeHandler{

Public String Description,Name1,Name2,BusinessUnit,Summary,Type,Category,Notes;
Public String MatterId;
Public advpm__Matter__c Matter {get;set;}
Public Set<String> ContentSelected;
Public Boolean refreshPage {get;set;}


//------Litigation

public String boxEmbedURL {get;set;}

public Boolean showDuplicates {get;set;}
public List<Duplicate> potentialDuplicates {get;set;}
public List<Business_Unit_Claim__c> claims {get;set;}
public List<advpm__Participant__c> participants {get;set;}
public Boolean showBox {get;set;}
Public Boolean showClosure {get;set;}

Public Boolean showCancel {get;set;}
Public Boolean showDocuments {get;set;}
public String boxFolderId { get; set;}


  public List<ContentVersion> ContentVersions {get;set;}
  public List<KnowledgeLibrary> lst_LibraryDisplay {get;set;}
  public List<KnowledgeLibrary> lst_LibrarySelected {get;set;}
  Public String strRecordTypeName {get;set;}
        
    public KnowledgeHandler() {    
    
    }    
    public KnowledgeHandler(ApexPages.StandardController controller) {
       // refreshPage = false;
        Name1='';
        Name2='';
        BusinessUnit='';
        Description='';
        Summary='';
        Type='';
        Category='';
        Notes='';
        showClosure = false;
        //Litigation
        if(potentialDuplicates == null)
            potentialDuplicates = new List<Duplicate>();

        participants = new List<advpm__Participant__c>();
        claims = new List<Business_Unit_Claim__c>();
        addClaim();
        
        showDuplicates = false;
        showBox = false;
        
        lst_LibraryDisplay = new List<KnowledgeLibrary>();
        ContentSelected = new Set<String>();
        
        
        ContentVersions = [select id, Title, Description,Matter_Category__c,Matter_Type__c, FileType, Owner.Name, VersionNumber from ContentVersion];   
        AddtoWrapper();
        
        Matter = new advpm__Matter__c();
        showDocuments = true;
        showCancel = true;
        
        if(apexpages.currentpage().getparameters().get('id') !=null)
        {
            MatterId = apexpages.currentpage().getparameters().get('Id');
            Matter = [Select recordType.Name,Name,Reputational_Risk__c,advpm__Engagement_Date__c,Cost_Centre__c,
                            Jurisdiction__c,Customer_account_number_policy_number__c,Litigation_Status__c,Client_Branch_code__c,
                            advpm__Description__c,Total_Claim_Percentage__c,Matter_Type__c,Category__c,advpm__Legal_Hold__c,
                            Claim_By_Against_Barclays__c,Reasonably_Possible__c,Approval_Status__c,Probable_For_Approval__c,
                            Financial_Value_Unknown__c,Matter_Value__c,Attainable_litigation_objective__c,Securitization_value__c,
                            Current_Status__c,Notes__c,Previous_current_status__c,Disposition_Type__c,advpm__Projected_Date_Of_Closure__c,
                            Disposition_Description__c,Probable_Approved__c ,Positive_Outcome_Before_All_Costs__c,Negative_Outcome_Before_All_Costs__c,Costs_Awarded_Against_Barclays__c,
                            Costs_Actually_Recovered__c,Remote__c , Lead_Lawyer_Office__c, Business_Unit_Cluster_Segment__r.Name,Business_Unit_Cluster_Segment__c,advpm__Status__c,
                            Date_of_Closure__c,TotalDispositionAmount__c,Reputational_Risk_Type__c ,Percentage__c,advpm__Primary_Account__c,advpm__Primary_Contact__c,Owner.Name,
                            Review_Frequency_days__c,Next_Review_Date__c
                             From advpm__Matter__c Where Id=:MatterId limit 1];
          
            strRecordTypeName= Matter.recordType.Name;
            system.debug('**One**'+strRecordTypeName);
            
            Name1=Matter.Name;
            Name2=Matter.Name;
            if(Matter.Business_Unit_Cluster_Segment__r.Name !=null){
                BusinessUnit=Matter.Business_Unit_Cluster_Segment__r.Name;
            }
            
            
            if(Matter.advpm__Description__c !=null){
                Summary=Matter.advpm__Description__c;
            }
            
            
            if(Matter.Matter_Type__c !=null){
                Type=Matter.Matter_Type__c;
            }
            
            if(Matter.Category__c !=null){
                Category=Matter.Category__c;
            }
            
            if(Matter.Notes__c !=null){
                Notes = Matter.Notes__c;
            }
            
            if(strRecordTypeName=='Legal'){
               showDocuments = false;
            }
            
            showClosure = true;
            FullSearch();
        }
        else{ 
    
            Matter = (advpm__Matter__c)controller.getRecord();
            
            
            if (ApexPages.currentPage().getParameters().get('RecordType') == null) {
                
                
                Schema.DescribeSObjectResult describeRequest = Schema.SObjectType.advpm__Matter__c;
                List<Schema.RecordTypeInfo> rtInfos = describeRequest.getRecordTypeInfos();
                
                 
                for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                    // walk through the map to determine the correct record type, this is done with the isAvailable() function
                    if(rtInfo.getName() != 'Master' && rtInfo.isAvailable()) {
                        // below lines will only run one time only
                        System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available, adding it as parameter to the page.');
                        
                        strRecordTypeName = rtInfo.getName();
                        Matter.RecordTypeId= rtInfo.getRecordTypeId();
                        
                    }
                }
                
                }   
            else{
            
                strRecordTypeName=Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosById().get(Matter.RecordTypeId).getName();
            
            }
           if(strRecordTypeName=='Legal'){
           showDocuments = false;
           }
           else{ 
            showDocuments = false;
            showCancel = false;
           } 
        }  
   
   
   
   
    }


 

 
     
  // runs the search with parameters passed via Javascript
  public PageReference runContactSearch() {
 
    Description = Apexpages.currentPage().getParameters().get('Description');
    
    if(strRecordTypeName=='Legal'){
      
      Name1 = Apexpages.currentPage().getParameters().get('Name1');
      BusinessUnit = Apexpages.currentPage().getParameters().get('BusinessUnit');
    }
    
    else{
      Name2 = Apexpages.currentPage().getParameters().get('Name2');
      Summary = Apexpages.currentPage().getParameters().get('Summary');
      Type = Apexpages.currentPage().getParameters().get('Type');
      Category = Apexpages.currentPage().getParameters().get('Category');
      Notes  = Apexpages.currentPage().getParameters().get('Notes');
    
  }
 
 FullSearch();
  
 return null;
 
 }   
   
 
 Public void FullSearch(){
 
   
   String FinalSearch=''; 
 
  if(Description.length()>1){ 
      FinalSearch =  Description;
  }
  if(strRecordTypeName=='Legal'){
      
      
      
      if(Name1.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ Name1;
          }
          else{
              FinalSearch = Name1;
          }
      }
      if(BusinessUnit.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ BusinessUnit;
          }
          else{
              FinalSearch = BusinessUnit;
          }
      }
  }
  else{
      
       
      if(Name2.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ Name2;
          }
          else{
              FinalSearch = Name2;
          }
      } 
     
      if(Summary.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ Summary;
          }
          else{
              FinalSearch = Summary;
          }
      } 
      if(Type.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ Type;
          }
          else{
              FinalSearch = Type;
          }
      } 
      if(Category.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ Category;
          }
          else{
              FinalSearch = Category;
          }
      } 
      if(Notes.length()>1){
          if(FinalSearch.length()>1){
              FinalSearch +=' OR '+ Notes;
          }
          else{
              FinalSearch = Notes;
          }
      } 
  }
   
   
   
   system.Debug('**FinalSearch***'+FinalSearch);
   
   if(FinalSearch.length()>1){
       list<list<sObject>> searchList = [FIND: FinalSearch  IN ALL FIELDS 
                   RETURNING ContentVersion(Title,matter_notes__c,matter_name__c,matter_description__c,Description,Matter_Category__c,Matter_Type__c)];
        
       
       if(lst_LibraryDisplay.size()>0){     
            checkSelected();
        } 
        
       ContentVersions = (ContentVersion[])searchList[0];
        
    }
    else{
        if(lst_LibraryDisplay.size()>0){     
            checkSelected();
        } 
        ContentVersions = [select id, Title, Description,Matter_Category__c,Matter_Type__c, FileType, Owner.Name, VersionNumber from ContentVersion];   
        
    }
   
   AddtoWrapper();
         
    //  runContentVersionsQuery();
     
    
    
    
  }
  
public void checkSelected(){

    for(KnowledgeLibrary d:lst_LibraryDisplay){
        if(d.LibSelect ==  true){
            ContentSelected.Add(d.LibId);
        }
        else if(d.LibSelect ==  false && ContentSelected.contains(d.LibId)){
            ContentSelected.remove(d.LibId);
        }
    }

}  
  

Public void AddtoWrapper(){
    
//    lst_LibrarySelected
    
    lst_LibraryDisplay = new List<KnowledgeLibrary>(); 
    
    
    
    for(ContentVersion v:ContentVersions){
        KnowledgeLibrary lib = new KnowledgeLibrary();
        lib.LibId = v.id;
        lib.LibTitle = v.Title;
        lib.LibMatterCategory = v.Matter_Category__c;
        lib.LibMatterType = v.Matter_Type__c;
        lib.LibDescription = v.Description;
        if(ContentSelected.contains(v.id)){
            lib.LibSelect =  true;
        }
       
        lst_LibraryDisplay.Add(lib);
          
    }
 }
    
 Public Pagereference Save(){
 
        checkSelected();
        ContentVersions = [select id,advpm__Matter__c, Title, Description,Matter_Category__c,Matter_Type__c, FileType, Owner.Name, VersionNumber from ContentVersion Where id in: ContentSelected]; 
        
        Upsert  Matter;
        
        if(strRecordTypeName=='Litigation Matter'){
      /*
            Decimal totalPercentage = 0;
            Boolean hasUnits = false;
            for(Business_Unit_Claim__c claim: claims) {

            if(claim.Business_Unit__c != null) {

                hasUnits = true;

                if(claim.Portion_of_Claim__c != null)
                    totalPercentage += claim.Portion_of_Claim__c;

            }
            
            }
    
            if(totalPercentage != 100 && hasUnits) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claim apportions must add up to 100%'));
                return null;
            } 
        */
                
            saveClaims();
            saveParticipants();
            saveRelations();
            system.debug('**INLIT**');
            if(strRecordTypeName=='Legal'){
          //  boxFolderId = BxdMatterDealService.createBoxFolderSync(Matter.Id);
          if(!Test.isRunningTest()){
              createBoxfolder(Matter.Id);
          }    
            }  
        }
        
        List<Matter_Content__c> lst_Content = new List<Matter_Content__c>();
        for(ContentVersion c:ContentVersions){
            Matter_Content__c Content = new Matter_Content__c();
            Content.Content_Id__c = c.id;
            Content.Matter__c = Matter.id;
            lst_Content.Add(Content);           
        }
    
        Insert lst_Content;
        refreshPage=true;
      
        

        
        
        PageReference pageRef;
        pageRef = new PageReference('/'+Matter.id);
        Return pageRef;
 
 
 }   



//---------------EMbedded page update

Public Pagereference SaveEmbed(){
 
        checkSelected();
        ContentVersions = [select id,advpm__Matter__c, Title, Description,Matter_Category__c,Matter_Type__c, FileType, Owner.Name, VersionNumber from ContentVersion Where id in: ContentSelected]; 
        
        
        List<Matter_Content__c> lst_Content = new List<Matter_Content__c>();
        for(ContentVersion c:ContentVersions){
            Matter_Content__c Content = new Matter_Content__c();
            Content.Content_Id__c = c.id;
            Content.Matter__c = Matter.id;
            lst_Content.Add(Content);           
        }
    
        Insert lst_Content;
        refreshPage=true;
      
        
        Return null;
 
 
 }   


//------------Litigation override methods

public PageReference searchDupes() {

        if(String.isBlank(Matter.Name)){

            showDuplicates = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Potential duplicates cannot be determined without a name!'));
        
        }
        else {

            String likeToken = String.format('%{0}%', new List<String>{Matter.Name});
            List<advpm__Matter__c> queryResult = [SELECT Id, Name, OwnerId, advpm__Description__c, Business_Unit_Cluster_Segment__c FROM advpm__Matter__c WHERE Name LIKE :likeToken];

            for(advpm__Matter__c res: queryResult) 
                potentialDuplicates.add(new Duplicate(res));

            showDuplicates = true;

        }

        return null;
    }
public PageReference addClaim() {
        claims.add(new Business_Unit_Claim__c());
        return null;
    }
 public PageReference removeClaim() {

        Integer endList = claims.size() - 1;

        if(endList > 0)
            claims.remove(endList);

        return null;

    }
     
 public PageReference addParticipant() {
        participants.add(new advpm__Participant__c());
        return null;
    }   
  public PageReference removeParticipant() {

        participants.remove(participants.size() - 1);
        return null;

    }   
 public class Duplicate {

        public advpm__Matter__c matter {get;set;}
        public Boolean isRelated {get;set;}

        public Duplicate(advpm__Matter__c potentialDuplicate) {
            this.matter = potentialDuplicate;
            this.isRelated = false;
        }

    }

@future (callout=true)
public static void createBoxfolder(Id Matterid){

    String boxFolderId = BxdMatterDealService.createBoxFolderSync(Matterid);
}


public void newSave() {

       if(Matter.Id == null)
            insert Matter;
         else 
            update Matter;       

    }

public PageReference createBox1() {
      
      /*
      if(Required){
              system.debug('****MMMM***'+Matter.advpm__Description__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'All Business Units,Claim By/Against Barclays,Category,Matter Type, Matter Summary,Litigation Status,Cost Centre are required fields '));
                  return null;
      }
       
        
        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }
        //boxFolderId 
         if(strRecordTypeName!='Legal' && Matter.id !=null){
            
         }
      */  
        
        boxEmbedURL= BxdMatterDealService.createBoxFolderSync(Matter.Id);
        system.debug('****boxEmbedURL***'+boxEmbedURL);
        showBox = true;
        return null;

    }
    


    Public Pagereference Cancel(){
       if(strRecordTypeName!='Legal' && Matter.id !=null){
           Delete  Matter;
       }
        PageReference pageRef = new PageReference('/a3A/o');
        Return pageRef;
    }

Public Boolean Required;

public PageReference createBox() {
        
        /*
        if(strRecordTypeName!='Legal'){ 
        
          if(Matter.Cost_Centre__c==null ||
            Matter.Litigation_Status__c==null ||
            Matter.advpm__Description__c==null ||
            Matter.Matter_Type__c==null ||
            Matter.Category__c==null ||
            Matter.Claim_By_Against_Barclays__c==null
            ){
                Required = true;
                
                return null;
             }
           else{
               Required = false;
           }
           for(Business_Unit_Claim__c  c:claims){
               
               if(c.Business_Unit__c ==null){
                   Required = true;
                  
                   return null;
               }
              else{
                   Required = false;
              }

           
           } 
            
         }   
        */
        
        Upsert  Matter;
        System.debug('### createBox : Matter.Id : '+Matter.Id);
        
        
     // Sean Added 9/11 -----------------------
        
            Decimal totalPercentage = 0;
            Boolean hasUnits = false;
            for(Business_Unit_Claim__c claim: claims) {

            if(claim.Business_Unit__c != null) {

                hasUnits = true;

                if(claim.Portion_of_Claim__c != null)
                    totalPercentage += claim.Portion_of_Claim__c;

            }
            
            }
            
          
            
            if(totalPercentage != 100 && hasUnits) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claim apportions must add up to 100%'));
                return null;
            } 
        
        //
        
        Set<Id> userIds = new Set<Id>();
        List<advpm__Participant__c> toSave = new List<advpm__Participant__c>();
        for(advpm__Participant__c part: participants) {
            if(part.advpm__Staff__c != null) {

                part.advpm__Matter__c = Matter.Id;
                userIds.add(part.advpm__Staff__c);
                toSave.add(part);

            }
        }
         Map<Id, User> participantUsersMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]);
        for(advpm__Participant__c part: toSave) {
            system.debug('**UName**'+participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation'));
            if(!participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'All participants must be Litigation users'));
               // part.advpm__Staff__c.addError('User is not a Litigation user');
               return null;
            }
        }
       
       //----------------------- 
        
        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }

   //     boxFolderId = BxdMatterDealService.createBoxFolderSync(Matter.Id);
  // createBoxfolder(Matter.Id);
        showBox = true;
        showCancel = true;
        showDocuments = false;
        return null;

    }

 private void saveClaims() {

        if(ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<Business_Unit_Claim__c> toSave = new List<Business_Unit_Claim__c>();        

        for(Business_Unit_Claim__c claim: claims) {
            if(claim.Business_Unit__c != null) {

                claim.Matter__c = Matter.Id;
                toSave.add(claim);

            }
        }

        if(toSave.size() != 0) {            

            upsert toSave;
            toSave.clear();
                            
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Must have business unit'));
        }

    }
    
 public void saveParticipants() {

        if(ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<advpm__Participant__c> toSave = new List<advpm__Participant__c>();
        Set<Id> userIds = new Set<Id>();

        for(advpm__Participant__c part: participants) {
            if(part.advpm__Staff__c != null) {

                part.advpm__Matter__c = Matter.Id;
                userIds.add(part.advpm__Staff__c);
                toSave.add(part);

            }
        }

        Map<Id, User> participantUsersMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]);

        for(advpm__Participant__c part: toSave) {
            system.debug('**UName**'+participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation'));
            if(!participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'All participants must be Litigation users'));
                part.advpm__Staff__c.addError('User is not a Litigation user');
            }
        }

        if(ApexPages.getMessages().isEmpty()) {
            upsert toSave;
            toSave.clear();
        }

    }   
private void saveRelations() {
        
        system.Debug('***DUP**'+potentialDuplicates);
        
        if(potentialDuplicates == null)
            return;
        
         system.Debug('***DUP2**'+ApexPages.getMessages());
       
       /* 
        if(ApexPages.getMessages().isEmpty() == false) {
            return;
        }
        */
        
        system.Debug('***DUP3**');
        
        List<Matter_Relation__c> toInsert = new List<Matter_Relation__c>();

        for(Duplicate dup: potentialDuplicates){
            system.debug('***ISDUP3333**');
            if(dup.isRelated){
                system.debug('***ISDUP**');
                toInsert.add(new Matter_Relation__c(Matter1__c = Matter.Id, Matter2__c = dup.matter.Id, Name = dup.matter.Name));
            }
        }
        Database.SaveResult[] results = Database.Insert(toInsert, false);

        //TODO
        //for(Database.SaveResult res: results)
        //    if(!res.isSuccess())
        //        for(Database.Error err: res.getErrors())
        //            if(!err.getMessage().contains('DUPLICATE_VALUE'))
        //                throw err;

    }
 
 public PageReference clearFinancial() {

        Matter.Reasonably_Possible__c = null;
        Matter.Probable_For_Approval__c = null;
        Matter.Securitization_value__c = null;

        return null;

    }
 
 public PageReference claimTypeChange() {

        if(Matter.Claim_By_Against_Barclays__c == 'Claim By Barclays') {

            Matter.Probable_Approved__c = Matter.Probable_For_Approval__c;
            Matter.Probable_For_Approval__c = null;

        }
        else if(Matter.Claim_By_Against_Barclays__c == 'Claim Against Barclays') {

            Matter.Probable_For_Approval__c = Matter.Probable_Approved__c;
            Matter.Probable_Approved__c = null;

        } 

        return null;

    }

//----------------------------------------Convert Matter to Case for Knowledge

Public Class KnowledgeLibrary{

    Public string LibId {get;set;}
    Public string LibTitle{get;set;}
    Public string LibDescription{get;set;}
    Public string LibMatterCategory{get;set;}
    Public string LibMatterType{get;set;}
    Public boolean LibSelect  {get;set;}
    
}


//




}