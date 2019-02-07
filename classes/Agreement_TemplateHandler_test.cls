@Istest
Public Class Agreement_TemplateHandler_test{

Public static void Setup(){
        
        
        
        Map <String, Schema.RecordTypeInfo> caseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        
    Case CaseConvert = new Case();
    
    CaseConvert.RecordTypeId = caseRecordTypes.get('Knowledge Request').getRecordTypeId();
    CaseConvert.subject='Subject';     
    CaseConvert.Description='Subject';
    CaseConvert.SuggestedTags__c='Subject';
    CaseConvert.Jurisdiction__c='South Africa';
    CaseConvert.Status = 'UAT Approved';
      Insert  CaseConvert; 
            
    }
    
    
  public static testmethod void caseconvert(){
         
         Test.StartTest();
         Setup();
         Case CaseConvert = [Select id,subject,status,Description,SuggestedTags__c,Jurisdiction__c from Case limit 1];
      
         PageReference pageRef = Page.CasetoAgreementTemplateConvert;
         pageRef .getParameters().put('id',CaseConvert.id);

         Test.setCurrentPageReference(pageRef);
         Agreement_TemplateHandler TestClass = new Agreement_TemplateHandler();
             
         TestClass.ConvertMattertoTemplate();
          TestClass.Cancel();
         Test.StopTest();
        
          
    }   
    
    
    
}