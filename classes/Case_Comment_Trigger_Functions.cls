/**
* 20170502
* Rudolf Niehaus - CloudSmiths
* Default Case Comment trigger helper class
* UPDATES:
* 20170502: Rudolf Niehaus - CloudSmiths : Reset updated case indicator flag when a user adds a new case comment 
* 2017-05-16: Rudolf Niehaus - CloudSmiths : Add first and last comment on the reporting fields of the related Case.
* 2017-06-21: Rudolf Niehaus - CloudSmiths : Fix SELF_REFERENCE_FROM_TRIGGER error - Use Future Class with some creative thinking :-)
**/
global class Case_Comment_Trigger_Functions {
    
    public Case_Comment_Trigger_Functions(){}
    
    public static void resetCaseFlags(list<CaseComment> newComments){
        
        set<Id> caseIds = new set<Id>();
        
        for(CaseComment cmt : newComments){   
            caseIds.add(cmt.ParentId);
        }
        
        list<Case> lstRelatedCases = new list<Case>();
        list<Case> lstCommentCases = new list<Case>();
        map<Id, String> firstCom = new map<Id, String>();
        map<Id, String> lastCom = new map<Id, String>();
        
        for(Case c :[Select Id, hHasClientUpdate__c, First_Case_Comment__c, Last_Case_Comment__c, 
                     (Select CommentBody, CreatedDate From CaseComments order by CreatedDate asc) from Case where Id IN :caseIds]){
                         
                         //reset flag that indicates client feedback to a Case
                         if(c.hHasClientUpdate__c){
                             c.hHasClientUpdate__c = false;
                             lstRelatedCases.add(c);
                         }
                         
                         //Update first and last comment fields on the Case
                         if(c.CaseComments.size() > 0){
                             if(c.CaseComments.size() == 1){
                                 if(String.isBlank(c.First_Case_Comment__c)){
                                 	c.First_Case_Comment__c = c.CaseComments[0].CommentBody;
                                 }
                             }else if (c.CaseComments.size() > 1){
                                 
                                 if(String.isBlank(c.First_Case_Comment__c)){
                                     c.First_Case_Comment__c = c.CaseComments[0].CommentBody;
                                 }
                                 
                                 c.Last_Case_Comment__c = c.CaseComments[(c.CaseComments.size() - 1)].CommentBody;
                             }   
                             
                               firstCom.put(c.Id, c.First_Case_Comment__c);
                               lastCom.put(c.Id, c.Last_Case_Comment__c);
                              //lstCommentCases.add(c);
                         }                               
                         
                     }
        try{
            if(lstRelatedCases.size() > 0){ update lstRelatedCases; }
        }catch (DMLException e){
            CSC_AuditTrailLog.logException(e,  'New', 'Warning', 'Case_Comment_Trigge_Functions', 'resetCaseFlags', 'Unable to reset the updated case indicator flag after a new case comment was added');  
        }
        
        //**Comment this out as it creates a SELF_REFERENCE_FROM_TRIGGER error when a user add a Case 
        //**comment at the same time he close a Case from the quick action
        //try{
        //    if(lstCommentCases.size() > 0){ update lstCommentCases; }
        //}catch (DMLException e){
        //    CSC_AuditTrailLog.logException(e,  'New', 'Warning', 'Case_Comment_Trigge_Functions', 'resetCaseFlags', 'Unable to update First and Last comment fields on the Case');  
       // }
        
        //RN - FUTURE CALL to fix the SELF_REFERENCE_FROM_TRIGGER error
        updateCases(caseIds, firstCom, lastCom);
       
    }
    
    @future
    public static void updateCases(set<Id> ids, map<Id, String> firstC, map<Id, String> lastC){
    	
        list<Case> casesUpdate = new list<Case>();   
        
        for(Case c :[Select Id, First_Case_Comment__c, Last_Case_Comment__c From Case Where Id IN :ids]){
           
            if(firstC.containsKey(c.Id)){
                 c.First_Case_Comment__c = firstC.get(c.Id);
            }
            if(lastC.containsKey(c.Id)){
                 c.Last_Case_Comment__c = lastC.get(c.Id);
            }
            casesUpdate.add(c);
        }
        
        try{
            if(casesUpdate.size() > 0){ update casesUpdate; }
        }catch (DMLException e){
            CSC_AuditTrailLog.logException(e,  'New', 'Warning', 'Case_Comment_Trigge_Functions', 'resetCaseFlags', 'Unable to update First and Last comment fields on the Case');  
        }
        
    }
}