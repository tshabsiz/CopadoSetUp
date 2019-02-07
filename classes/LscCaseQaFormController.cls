/**
* Author: Dreamwares
* Date:   2018-04-30
* Desc:   It is used to craete and update CaseQA Record with related case and TemplateId 
**/
public class LscCaseQaFormController {
    /*
     * Purpose : To get AgentRecord using serch string and object name.
     * Param : 1)searchKeyWord 
     *         2)ObjectName
     */ 
    @AuraEnabled
    public static List < sObject > fetchAgentRecords(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    /*
     * Purpose : To get CaseQa Records onlaod of component using serch caseId and templateId.
     * Param : 1)caseId 
     *         2)templateId 
     */
    @AuraEnabled
    public static ResponseDTO getCaseQaRecords(String caseId, String templateId){
        list<Case_QA__c> currentQA ;
        //String qaId ;
        map<String,String> selectionMap = new  map<String,String>() ;
        
        try{
            //check if there is an existing checklist saved for this template for this case
            currentQA = [Select Id, WeightingTotal__c, SavedResults__c, RelatedCase__c, QATemplate__c,
                         AgentScorePer__c, AgentScore__c, AgentName__c,AgentName__r.Name  
                         From Case_QA__c 
                         Where QATemplate__c = :templateId and RelatedCase__c = :caseId 
                         and SubmittedBy__c = :UserInfo.getUserId()];
            
            if(currentQA.size() > 0){
                //qaId = currentQA[0].Id;
                //get metadata
                if(String.isNotBlank(currentQA[0].SavedResults__c)){
                    selectionMap = getQuestionState(currentQA[0].SavedResults__c) ;
                }
            }
            
            //get the checklist blue print
            list<Case_QA_Template__c> qaBluePrint = [Select Id, QAName__c, BusinessArea__c, WeightingTotal__c, 
                                                     (Select Id, Weighting__c, QAQuestion__c, Heading__c, IsAuditRequirement__c 
                                                      From QA_Questions__r 
                                                      order by Heading__c asc) 
                                                     From Case_QA_Template__c  
                                                     Where Id = :templateId limit 1];
            
            if(qaBluePrint.size() > 0){
                ResponseDTO res ;
                if(currentQA.size() > 0){
                      res =  getQuestionList(qaBluePrint, selectionMap, currentQA[0]);
                }else {
                      res =  getQuestionList(qaBluePrint, selectionMap, null);
                }
               
                return res ;
                
            }else{
                return new ResponseDTO(false, 'There is no checklist template configure with this Id '+ templateId, null) ;
                
            }
        }
        catch(Exception ex){
            return new ResponseDTO(false, ex.getMessage(), null) ;
        }
    }
    
    /*
     * Purpose : To get questions answer maintain map using saveResult field from caseQa record.
     * Param : 1)saveResult  
     */
    private static map<String,String> getQuestionState(String saveResult) {
        map<String,String> selectionMap = new map<String,String>(); 
        list<String> allSaved = saveResult.split(';');
        
        for(String selection :allSaved){
            list<String> res = selection.split('\\|');
            selectionMap.put(res[0],res[1]);
        }
        return selectionMap ;
    }
    
    /*
     * Purpose : To get questions list for displaying question in component.
     * Param : 1)qaBluePrint - used to get question and heading related with template record.
     *         2)selectionMap - used to display maintain state for questions answer.
     *         3)caseQaRecord - used to get Agent related information.  
     */
    private static ResponseDTO getQuestionList(List<Case_QA_Template__c> qaBluePrint, map<String,String> selectionMap, Case_QA__c caseQaRecord) {
        list<FormStructure> wFormStructure = new list<FormStructure>();
        list<FormSelection> wFormSelection = new list<FormSelection>();
        
        Decimal wtotal = qaBluePrint[0].WeightingTotal__c;
        String headingX = '' ;
        String headingY = '' ;
        
        //build the heading with related questions map
        FormSelection fs;
        
        for(Case_QA_Question__c qaQuestion : qaBluePrint[0].QA_Questions__r){
            
            headingX = qaQuestion.Heading__c;
            
            if(selectionMap.containsKey(qaQuestion.Id)){
                fs = new FormSelection(qaQuestion, qaQuestion.Id, selectionMap.get(qaQuestion.Id), qaQuestion.IsAuditRequirement__c);
            }else{             
                fs = new FormSelection(qaQuestion, qaQuestion.Id, 'Yes', qaQuestion.IsAuditRequirement__c);
            }
            
            if(headingX == headingY || headingY == ''){
                wFormSelection.add(fs);                  
            }
            else{
                list<FormSelection> wNewFormSelection = new list<FormSelection>(wFormSelection);
                FormStructure fstr = new FormStructure(caseQaRecord, headingY, wNewFormSelection, wtotal);
                wFormStructure.add(fstr);
                
                wFormSelection.clear();
                wFormSelection.add(fs);
            }
            
            headingY = qaQuestion.Heading__c;
        }
        
        //add last list of questions to the wrapper after we have exite the loop
        FormStructure fstr = new FormStructure(caseQaRecord, headingY, wFormSelection, wtotal);
        wFormStructure.add(fstr);
        
        //default calculation to 100%
        //Integer agentToatal = calculateQA(wFormStructure, qaBluePrint);
        //FormStructure fstr1 = new FormStructure(caseQaRecord, headingY, wFormSelection, agentToatal);
        //wFormStructure.clear() ;
        //wFormStructure.add(fstr1) ;
        return new ResponseDTO(true, 'success', wFormStructure) ;
    }
     
   /* private static integer calculateQA(List<FormStructure> wFormStructure, List<Case_QA_Template__c> qaBluePrint){
        Integer agentTotal ;
        Integer totalAgentScore = 0;
        
        for(FormStructure fstructure : wFormStructure){
            for(FormSelection s : fstructure.questions){
                
                if(s.selectedChoice == 'Yes'){
                    totalAgentScore+= Integer.valueOf(s.question.Weighting__c);  
                }   
            }
        }
        if(qaBluePrint[0].WeightingTotal__c > 0){
            agentTotal = Integer.valueOf(( totalAgentScore / qaBluePrint[0].WeightingTotal__c ) * 100);
        }else{
            agentTotal = 0;
        }
        return agentTotal;
    } */
    
    /*
     * Purpose : To upsert caseQa record.
     * Param : caseQa 
     */
    @AuraEnabled
    public static ResponseDTO updateCaseChecklistRecord(Case_QA__c caseQa){
        //Case_QA__c caseQa = new Case_QA__c();
        try{
            upsert caseQa ;
            System.debug('caseQa '+caseQa);
            return new ResponseDTO(true, 'success', null) ; 
        }
        catch(Exception ex){
            return new ResponseDTO(false, ex.getMessage(), null) ;
        }
    }
    
    /*
     * Purpose : To return the response.
     */
    public class ResponseDTO{
        @AuraEnabled public boolean isSuccess ;
        @AuraEnabled public String message ;
        @AuraEnabled public List<object> objectList;
        
        public ResponseDTO(boolean isSuccess, String message, List<object> objectList){
            this.isSuccess = isSuccess;
            this.message = message;
            this.objectList = objectList;
        }
    }
    
    //NESTED CLASSES
    //Case_Checklist_Template__c wrapper class to keep track of selected questions and to keep the form structure
    public class FormStructure{
        @AuraEnabled public Case_QA__c caseQaRecord ;
        //@AuraEnabled public String qaId ;
        @AuraEnabled public String heading ;
        @AuraEnabled public list<FormSelection> questions ;
        @AuraEnabled public Decimal weighting ;
        
        public FormStructure(Case_QA__c caseQaRecord, String heading, list<FormSelection> questions, Decimal weighting){
            this.caseQaRecord = caseQaRecord ;
            this.heading = heading;
            this.questions = questions;
            this.weighting = weighting ;
        }
    }
    
    /*
     * Purpose : To keep track of selected question and audit question. 
     */
    public class FormSelection{
        
        @AuraEnabled public Case_QA_Question__c question ;
        @AuraEnabled public String questionId ;
        @AuraEnabled public String selectedChoice ;
        @AuraEnabled public Boolean isAuditQuestion ;
        
        public FormSelection(Case_QA_Question__c question, String questionId, String selectedChoice, Boolean isAuditQuestion){
            this.question = question;
            this.questionId = questionId;
            this.isAuditQuestion = isAuditQuestion;
            
            if(selectedChoice == 'Yes'){
                this.selectedChoice = 'Yes';
            }else if(selectedChoice == 'No'){
                this.selectedChoice = 'No';
            } else {
                this.selectedChoice = 'NA';
            }
        }
    }   
    
}