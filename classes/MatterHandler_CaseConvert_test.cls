@Istest
Public class MatterHandler_CaseConvert_test   {
    
    
    
    Public static void Setup(){

                Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
                Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
                Insert BusinessUnit;
        
                advpm__Matter__c Matter_leg = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Legal').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support', 
                Product_Area__c = 'Legal Standard Product' 
             );
                Insert Matter_leg;
                
                advpm__Matter__c Matter_lit = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Litigation Matter').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
             );
                Insert Matter_lit;
                
             ContentVersion   ContentVersions = new ContentVersion(
              Title='Legal', 
              Description='Legal',
              ContentUrl = 'http://google.co.za'
            //  Matter_Category__c='Legal',
            //  Matter_Type__c='Legal' 
            );
              Insert ContentVersions; 
              
            Matter_Content__c Content = new Matter_Content__c(
             Matter__c =Matter_lit.id,
             Content_Id__c =ContentVersions.id 
             );
             Insert Content;
          
              
}
    
    
    public static testmethod void caseconvert(){
         
         Test.StartTest();
         Setup();
         advpm__Matter__c Matter_lit = [Select id from advpm__Matter__c Where RecordType.Name='Litigation Matter' limit 1];
       
         PageReference pageRef = Page.MatterToCaseConvert;
         pageRef .getParameters().put('id',Matter_lit.id);

         Test.setCurrentPageReference(pageRef);
        // ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
         MatterHandler_CaseConvert TestClass = new MatterHandler_CaseConvert();
         TestClass.filesfromBox();
         
         for(MatterHandler_CaseConvert.BoxFiles b:TestClass.LstBoxFiles){
             b.Selectfile = true;
         }
         system.debug('***XXX**'+TestClass.LstBoxFiles);
         
          TestClass.MatterCase.LegalDivision__c='CIB';    
          TestClass.ConvertMatterToCase();
          TestClass.AddMatter = true; 
          
          Case c = [Select id from Case limit 1];
          
          
          pageRef .getParameters().put('id',c.id);

          Test.setCurrentPageReference(pageRef);
          
          TestClass.SubmitCaseToBox();
    }



}