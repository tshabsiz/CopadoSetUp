@Istest
Public class CaseConvertHandler_test   {
    
    
    
    Public static void Setup(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];    
        System.runAs (thisUser) {     
            //     ContentWorkspace Library = new ContentWorkspace(); 
            //     Library.Name = 'Library';
            //    Insert Library;
        } 
        Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Map <String, Schema.RecordTypeInfo> caseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName(); 
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
        
        
        RecordType[] rt = [SELECT id,Name,SobjectType FROM RecordType where SobjectType ='ContentVersion' AND Name = 'Legal Content'];
        
        
        ContentVersion   ContentVersions = new ContentVersion(
            Title='Legal', 
            Description='Legal',
            ContentUrl = 'http://google.co.za',RecordTypeId=rt[0].id
            //  Matter_Category__c='Legal',
            //  Matter_Type__c='Legal' 
        );
        insert ContentVersions; 
        
        Matter_Content__c Content = new Matter_Content__c(
            Matter__c =Matter_lit.id,
            Content_Id__c =ContentVersions.id
        );
        insert Content;
        
        Case casecontent = new Case(
            Matter__c=Matter_lit.id,Description='Desc',
            SuggestedTags__c='Tag1',
            Subject='Subject',
            SuggestedLibrary__c='Precedent',
            Division__c = 'CIB',
            Business_Area__c = 'Banking',
            RecordTypeId = caseRecordTypes.get('Knowledge Request').getRecordTypeId()
        );
        insert casecontent;             
    }
    
    
    public static testmethod void caseconvert()
    {         
        Test.StartTest();
        
        Setup();
        Case c = [Select id from Case limit 1];
        
        PageReference pageRef = Page.CasetoContent;
        pageRef .getParameters().put('id',c.id);
        Test.setCurrentPageReference(pageRef);         
        
        CaseConvertHandler TestClass = new CaseConvertHandler();
        
        List<ContentWorkspace> Libraries = [SELECT Id,Name FROM ContentWorkspace Limit 1];
        
        if(Libraries.size() > 0) {
            ContentWorkspace Library = Libraries.get(0);
            TestClass.LibrarySelect = Library.id;
            
            for(CaseConvertHandler.BoxFiles b:TestClass.LstBoxFiles)
            {
                b.Selectfile = true;
            }
            
        }
        
        TestClass.ConvertContent();
        TestClass.Cancel();    
        
        Test.StopTest();   
    }
}