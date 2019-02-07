Public Class Agreement_TemplateHandler{


Public String CaseId;

Public  Case  CaseConvert {get;set;}
Public Agreement_Template__c newAgreementTemplate {get;set;}

Public Agreement_TemplateHandler(){

    CaseId = ApexPages.currentPage().getParameters().get('id');
    CaseConvert = [Select id,subject,status,Description,SuggestedTags__c,Jurisdiction__c,Matter__c from Case  where id =: CaseId];

    newAgreementTemplate = new Agreement_Template__c();
    newAgreementTemplate.name = CaseConvert.subject;
    newAgreementTemplate.Description__c = CaseConvert.Description;
    newAgreementTemplate.SuggestedTags__c = CaseConvert.SuggestedTags__c;
    newAgreementTemplate.Jurisdiction__c = CaseConvert.Jurisdiction__c;
}


Public pagereference ConvertMattertoTemplate(){ 

    if(CaseConvert.Status=='UAT Approved'){  
        Insert newAgreementTemplate;

        //This is to default the Product agreements for the advanced search to work
        Product_Agreement__c productAgreement = new Product_Agreement__c();
        productAgreement.Agreement_Template__c = newAgreementTemplate.id;
        productAgreement.Name = newAgreementTemplate.Name;

        //The names are hardcoded and must be changed
        List<Product_Level_2__c> productAgreementList = new List<Product_Level_2__c>([select name from Product_Level_2__c where name = 'Legal Agreement Product' limit 1]);
        List<TMG_Product_Level_3__c> agreementProdGroupingList = new List<TMG_Product_Level_3__c>([select name from TMG_Product_Level_3__c where name = 'Legal Standard Product 3' limit 1]);

        if(productAgreementList.size() > 0 && agreementProdGroupingList.size() > 0) {
            productAgreement.Product__c = productAgreementList.get(0).id;
            productAgreement.TMG_Product_Level_3__c = agreementProdGroupingList.get(0).id;
        }

        insert productAgreement;
        
        CaseConvert.Agreement_Template__c = newAgreementTemplate.id;
        update CaseConvert;

        return new pagereference('/'+newAgreementTemplate.id);
    }
    else{
          return new pagereference('/'+CaseConvert.id);   
    }

}

Public pagereference Cancel(){   
        
      return new pagereference('/'+CaseConvert.id);
}




}