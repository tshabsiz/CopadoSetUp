@Istest
Public Class AgreementHandler_test{


Public static void Setup(){
    
        Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Map <String, Schema.RecordTypeInfo> caseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Map <String, Schema.RecordTypeInfo> AccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        
        
        Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
        Insert BusinessUnit;
        
        
        
        advpm__Matter__c Matter_lit = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                                                           Standard__c = true,
                                                           advpm__Status__c = 'Open',
                                                           advpm__Type__c='Syndicated',
                                                           Start_Date__c = date.today(),
                                                           RecordTypeId = mapMatterRecordTypes.get('Litigation Matter').getRecordTypeId()
                                                       //    Division__c = 'CIB'
                                                           //   Coverage_Area__c = 'Corporate Banking',
                                                           //   Product_Area__c = 'Corporate Finance'
                                                          );
        Insert Matter_lit;
    
  
  Account Relationship = new Account();
  Relationship.RecordTypeId = AccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId();
  Relationship.Name ='Law 1';
  Relationship.BEE_Status__c = 'Level 1';
  Relationship.BO__c =  '5';
  Relationship.BWO__c = '25';
  Insert Relationship;
  
  
  Product2 Prod = new Product2();
   Prod.name='Prod2'; 
  Insert Prod;
  
  Product_Level_2__c Product_Level = new Product_Level_2__c();
  Product_Level.Active__c = true;
  Product_Level.Product__c = Prod.id;
  Insert Product_Level;
  
  
  
  
  Agreement_Template__c Agreement_Template = new Agreement_Template__c();
  Agreement_Template.name = 'Agreement template name';
  Insert Agreement_Template;
  
  
  Product_Agreement__c Product_Agreement = new Product_Agreement__c();
  Product_Agreement.Agreement_Template__c = Agreement_Template.id;
  Product_Agreement.Product__c = Product_Level.id;
  Insert Product_Agreement;
  
      
  Agreement__c  Agreement = new Agreement__c();  
  Agreement.Matter_Deal__c = Matter_lit.id;
  Agreement.Client_Name__c = Relationship.id;  
  Agreement.name = 'Agreement Name';  
  Agreement.Agreement_Description__c = 'Testing';
  Agreement.ReviewDate__c = system.today();  
  Agreement.Limit__c = 5;
  
 // Agreement_Type__c
  Agreement.Product__c = Product_Level.id;
  
  Insert Agreement;

}



Public static testmethod void RunAgreementHandler(){

    Test.StartTest();
        Setup();
        Agreement__c Agreement;
        Agreement = [Select id, Matter_Deal__c,Client_Name__c,name,Agreement_Description__c,ReviewDate__c from Agreement__c limit 1];
        PageReference pageRef = Page.AgreementToCaseConvert;
        pageRef .getParameters().put('id',Agreement.id);
        
        Test.setCurrentPageReference(pageRef);
       
        AgreementHandler testclass = new  AgreementHandler();
        testclass.ConvertAgreementtoCase();
        testclass.Cancel();
        
    Test.StopTest();



}


}