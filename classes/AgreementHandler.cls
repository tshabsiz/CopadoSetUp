Public Class AgreementHandler{


Public String AgreementId;

Public  Agreement__c Agreement {get;set;}
Public Case newCase {get;set;}

Public AgreementHandler(){

    AgreementId = ApexPages.currentPage().getParameters().get('id');
    Agreement = [Select id, Matter_Deal__c,Client_Name__c,name,Agreement_Description__c,ReviewDate__c from Agreement__c where id =: AgreementId];
      
      
      
      
       RecordType rt = [Select id From RecordType where Name= 'Knowledge Request' limit 1];
     
      newCase = new Case();
      newCase.RecordTypeid = rt.id;
      newCase.SuggestedTags__c = 'Executed Agreement';
      newCase.Status = 'New';
      newCase.Subject = Agreement.Name;
      
      
      newCase.Matter__c = Agreement.Matter_Deal__c;
      newCase.AccountId = Agreement.Client_Name__c;
      newCase.Subject = Agreement.name;
      newCase.Description = Agreement.Agreement_Description__c;
        newCase.Previous_Review_Date__c = Agreement.ReviewDate__c;

}


Public pagereference ConvertAgreementtoCase(){   
      Insert newCase;
    
      return new pagereference('/'+newCase.id);
}

Public pagereference Cancel(){   
     
    
      return new pagereference('/'+Agreement.id);
}




}