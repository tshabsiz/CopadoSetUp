/**
* 2017-08-17 - Rudolf Niehaus - CloudSmiths
* Controller for the visualforce page Case_QA_Form 
* The controller and page dynamically renders a qa form based on the 
* managers selection from a console Case quick action. The blue print for the form is stored in a 
* custom object and unique per business area
* 2017-08-24 - Rudolf Niehau - Remove peer review from the VF page and std page layouts, but keep the code
                               in this controller. I have a feeling CSC is going to use this in future again.
**/
public class Case_QA_Form_Controller {
    
    private list<Case_QA_Template__c> qaBluePrint;
    public String wtotal {get;set;}
    public String templateId {get;set;}
    public String agentId {get;set;}
    public String agentName {get;set;}
    public String caseId {get;set;}
    public String metaData {get;set;}
    public String qaId {get;set;}
    public list<FormStructure> wFormStructure {get;set;}
    public Decimal agentTotal {get;set;}
    public Decimal peerTotal {get;set;}
    public boolean makeReadOnly {get;set;}
    public String currentAgentName {get;set;}
    private String qaMode = '';
    
    public Case_QA_Form_Controller(){
        

         map<String,String> selectionMap = new map<String,String>();
         makeReadOnly = false;
         currentAgentName = 'No Agent';        
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
        //
        if(ApexPages.currentPage().getParameters().get('qaMode') != null){
            templateId = ApexPages.currentPage().getParameters().get('qaMode');
        }
        //check if there is an existing checklist saved for this template for this case
        list<Case_QA__c> currentQA = [Select Id, WeightingTotal__c, SavedResults__c, RelatedCase__c, QATemplate__c,
                                      AgentScorePer__c, AgentScore__c, AgentName__c,AgentName__r.Name  
                                      From Case_QA__c 
                                      Where QATemplate__c = :templateId and RelatedCase__c = :caseId 
                                      and SubmittedBy__c = :UserInfo.getUserId()];
        if(currentQA.size() > 0){
            
            qaId = currentQA[0].Id;
            currentAgentName = currentQA[0].AgentName__r.Name;
            
            //get metadata
            if(String.isNotBlank(currentQA[0].SavedResults__c)){
                
                list<String> allSaved = currentQA[0].SavedResults__c.split(';');
           
                for(String selection :allSaved){
                   
                    list<String> res = selection.split('\\|');
                    
                    selectionMap.put(res[0],res[1]);
                    
                }
            }
        }else{
            qaId = '';
        }
        
        //get the QA blue print
        qaBluePrint = [Select Id, QAName__c, BusinessArea__c, WeightingTotal__c, 
                     (Select Id, Weighting__c, QAQuestion__c, Heading__c, IsAuditRequirement__c From QA_Questions__r order by Heading__c asc) 
                     From Case_QA_Template__c  
                     Where Id = :templateId limit 1];
        
        if(qaBluePrint.size() > 0){
            wtotal = String.valueOf(qaBluePrint[0].WeightingTotal__c);
            String headingX = '';
            String headingY = '';
            headingX.hashCode();
            list<String> questions = new list<String>();
            list<FormSelection> wFormSelection = new list<FormSelection>();
            wFormStructure = new list<FormStructure>();
            
            //build the heading with related questions map
            FormSelection fs;
           
            for(Case_QA_Question__c q :qaBluePrint[0].QA_Questions__r){

                headingX = q.Heading__c;
               
                if(selectionMap.containsKey(q.Id)){
                    fs = new FormSelection(q, q.Id, selectionMap.get(q.Id), q.IsAuditRequirement__c);
                }else{             
                    fs = new FormSelection(q, q.Id, 'Yes', q.IsAuditRequirement__c);
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
            
            //default calculation to 100%
            calculateQA();
            
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no QA template configure with this Id : ' + templateId));
        }    
    }
    
    public void calculateQA(){
        
        Integer totalAgentScore = 0;

        for(FormStructure fs :wFormStructure){
            for(FormSelection s :fs.questions){
                
                if(s.IsCheckedYes == 'checked'){
                    totalAgentScore+= Integer.valueOf(s.question.Weighting__c); 
                }   
            }
        }
        if(qaBluePrint[0].WeightingTotal__c > 0){
            agentTotal = ( totalAgentScore / qaBluePrint[0].WeightingTotal__c ) * 100;
        }else{
            agentTotal = 0;
        }
        

        //return null;
    }
    
    //NESTED CLASSES
    //Case_QA_Template__c wrapper class to keep track of values entered
    public class FormStructure{
        
        public String heading {get;set;}
        public list<FormSelection> questions {get;set;}

        public FormStructure(String heading, list<FormSelection> questions){
            this.heading = heading;
            this.questions = questions;
        }
    }
    
    public class FormSelection{
        
        public Case_QA_Question__c question {get;set;}
        public String questionId {get;set;}
        public Boolean isAuditQuestion {get;set;}
        public String IsChecked {get;set;}
        public String IsCheckedYes {get;set;}
        public String IsCheckedNo {get;set;}
        public String IsCheckedNA {get;set;}
        
        public FormSelection(Case_QA_Question__c question, String questionId, String IsChecked, Boolean isAudit ){
            this.question = question;
            this.questionId = questionId;
            this.isAuditQuestion = isAudit;
            
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