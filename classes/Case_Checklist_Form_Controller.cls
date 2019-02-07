/**
* 2017-07-19 - Rudolf Niehaus - CloudSmiths
* Controller for the visualforce page Case_Checklist_Form 
* The controller and page dynamically renders a checlist form based on the 
* agents selection form a console Case quick action. The blue print for the form is stored in a 
* custom object and unique per business area
**/

public class Case_Checklist_Form_Controller {
    
    public class questionWrapper
    {
        public String question {get;set;}
        public String actionDate  {get;set;}
        
     	public questionWrapper(String question,String actionDate)
        {
            this.question = question;
            this.actionDate = actionDate;
        }
    }
    private list<Case_Checklist_Template__c> bluePrint;
    public String templateId {get;set;}
    public String caseId {get;set;}
    public String metaData {get;set;}
    public String chkListId {get;set;}
    public list<FormStructure> wFormStructure {get;set;}
    public boolean makeReadOnly {get;set;}
    private String recId = '';
    public Boolean showDate{get;set;}
    
    public Case_Checklist_Form_Controller(){
        
         map<String,questionWrapper> selectionMap = new map<String,questionWrapper>();
         makeReadOnly = false;
        
        //get page parameters
        if(ApexPages.currentPage().getParameters().get('Id') != null){
            caseId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(ApexPages.currentPage().getParameters().get('templateId') != null){
            templateId = ApexPages.currentPage().getParameters().get('templateId');
        }
        if(ApexPages.currentPage().getParameters().get('readOnly') != null){
            String x = ApexPages.currentPage().getParameters().get('readOnly');
            if(x=='1'){
                makeReadOnly=true;
            }
            
        }
        
        if(CaseChecklistTriggerhandler_Functions.getValidHubs().contains(CaseChecklistTriggerhandler_Functions.getUserById(UserInfo.getUserId()).Hub__c))
        {
            showDate = true;
        }
        if(ApexPages.currentPage().getParameters().get('recId') != null){
            recId = ApexPages.currentPage().getParameters().get('recId');
        }
        
        list<Case_Checklist__c> currentChkList = new list<Case_Checklist__c>();
        
        if(String.isBlank(recId)){
            //check if there is an existing checklist saved for this template for this case
            currentChkList = [Select Id, Name, SubmittedBy__c, ValidatedBy__c, DateSubmitted__c, DateValidated__c, 
                              Validate__c, SavedResults__c, RelatedCase__c, ChecklistTemplate__c 
                              From Case_Checklist__c 
                              Where ChecklistTemplate__c = :templateId and 
                              RelatedCase__c = :caseId and SubmittedBy__c = :UserInfo.getUserId()];
            
        }else{
            //Get actual checklist record
            currentChkList = [Select Id, Name, SubmittedBy__c, ValidatedBy__c, DateSubmitted__c, DateValidated__c, 
                              Validate__c, SavedResults__c, RelatedCase__c, ChecklistTemplate__c  
                              From Case_Checklist__c  
                              Where Id = :recId];   
        }
        
        
        if(currentChkList.size() > 0){
           
            chkListId = currentChkList[0].Id;
            
            //get metadata
            if(String.isNotBlank(currentChkList[0].SavedResults__c)){
                
                System.debug(currentChkList[0].SavedResults__c);
                list<String> allSaved = currentChkList[0].SavedResults__c.split(';');
           
                for(String selection :allSaved){
                   
                    list<String> res = selection.split('\\|');
                    
                    if(res.size()==2)
                    {
                        selectionMap.put(res[0],new questionWrapper(res[1],''));
                    }
                    if(res.size()==3)
                    {
                        selectionMap.put(res[0], new questionWrapper(res[1],res[2]));
                    }
                    
                    
                    
                }
            }
            
            
        }else{
            chkListId = '';
        }
        
        //get the checklist blue print
        bluePrint = [Select Id, BusinessArea__c, ChecklistName__c,
                     (Select Id, Heading__c, Question__c From Case_Checklist_Questions__r order by Heading__c asc) 
                     From Case_Checklist_Template__c 
                     Where Id = :templateId limit 1];
        
        if(bluePrint.size() > 0){
            
            String headingX = '';
            String headingY = '';
            headingX.hashCode();
            list<String> questions = new list<String>();
            list<FormSelection> wFormSelection = new list<FormSelection>();
            wFormStructure = new list<FormStructure>();
            
            //build the heading with related questions map
            FormSelection fs;
           
            for(Case_Checklist_Question__c q :bluePrint[0].Case_Checklist_Questions__r){

                headingX = q.Heading__c;
               
                if(selectionMap.containsKey(q.Id)){
                    fs = new FormSelection(q.Question__c, q.Id, selectionMap.get(q.Id).question,selectionMap.get(q.Id).actionDate);
                }else{             
                    fs = new FormSelection(q.Question__c, q.Id, '','');
                }
     
                if(headingX == headingY || headingY == ''){
                    wFormSelection.add(fs);                  
                }else{
                    
                    list<FormSelection> wNewFormSelection = new list<FormSelection>(wFormSelection);
                    FormStructure fstr = new FormStructure(headingY,wNewFormSelection);
                    wFormStructure.add(fstr);

                    wFormSelection.clear();
                    wFormSelection.add(fs);
                }
                
                headingY = q.Heading__c;
            }
            
            //add last list of questions to the wrapper after we have exite the loop
            FormStructure fstr = new FormStructure(headingY, wFormSelection);
            wFormStructure.add(fstr);
            
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no checklist template configure with this Id ; ' + templateId));
        }
    }
    
    
    public PageReference updateChecklist(){
        list<Case_Checklist__c> chkLists = [Select Id, Name, SavedResults__c, SubmittedBy__c  From Case_Checklist__c Where RelatedCase__c = :caseId];
        return null; 
    }

    //NESTED CLASSES
    //Case_Checklist_Template__c wrapper class to keep track of selected questions and to keep the form structure
    public class FormStructure{
        
        public String heading {get;set;}
        public list<FormSelection> questions {get;set;}
        
        public FormStructure(  String heading, list<FormSelection> questions ){
            this.heading = heading;
            this.questions = questions;
        }
    }
    public class FormSelection{
        
        public String question {get;set;}
        public String questionId {get;set;}
        public String IsChecked {get;set;}
        public String IsCheckedYes {get;set;}
        public String IsCheckedNo {get;set;}
        public String IsCheckedNA {get;set;}
        public String actionDate {get;set;}
        
        public FormSelection(String question, String questionId, String IsChecked,String actionDate){
            this.question = question;
            this.questionId = questionId;
            
            this.actionDate = actionDate;
            
                
            
            System.debug(actionDate);
            if(IsChecked == 'Yes'){
                this.IsCheckedYes = 'checked';
            }else if(IsChecked == 'No'){
                this.IsCheckedNo = 'checked';
            }else if(IsChecked == 'NA'){
                this.IsCheckedNA = 'checked';
            }else{
                this.IsCheckedYes = '';
                this.IsCheckedNo = '';
                this.IsCheckedNA = '';
            }
        }
    }   
}