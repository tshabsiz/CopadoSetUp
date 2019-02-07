@Istest
Public class KnowledgeHandlerV2_test{



Public static void Setup(){

                Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
                Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
                Insert BusinessUnit;
        
                advpm__Matter__c Matter_leg = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Description__c = 'Des',
                Matter_Type__c = 'Complaints',
                Category__c='Action Lines',
                Notes__c = 'Notes',
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
                advpm__Description__c = 'Des',
                Matter_Type__c = 'Complaints',
                Notes__c = 'Notes',
                Category__c='Action Lines',
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
              Description='Legal',recordtypeid = rt[0].id,
              ContentUrl = 'http://google.co.za'
            //  Matter_Category__c='Legal',
            //  Matter_Type__c='Legal' 
            );
              Insert ContentVersions; 
              
              RecordType r = [Select Id, DeveloperName From RecordType Where Name='Knowledge Request'];
              
              
              Case NewCase = new Case();
              NewCase.RecordTypeId = r.id;
              NewCase.Status = 'Ready for Review';
              NewCase.Subject = ''; //Legal
              NewCase.Description = '';
              NewCase.SuggestedTags__c = '';
              Insert NewCase;
             
              
}



public static testmethod void MatterKnowledge1(){


    Test.StartTest();
     Setup();
        
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Litigation Matter').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
         
    Test.StopTest();


}

public static testmethod void MatterKnowledge2(){


    Test.StartTest();
     Setup();
      
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Legal').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
         
    Test.StopTest();

}
public static testmethod void MatterKnowledge3(){


    Test.StartTest();
     Setup();
     advpm__Matter__c Matter_lit = [Select id from advpm__Matter__c Where RecordType.Name='Legal' limit 1];
       
        
         PageReference pageRef = Page.MatterKnowledgeDisplayV2;
         pageRef .getParameters().put('id',Matter_lit.id);
         pageRef .getParameters().put('Name1','Legal');
         pageRef .getParameters().put('BusinessUnit','Legal');
         pageRef .getParameters().put('Description','Legal');
         
         Test.setCurrentPageReference(pageRef);
       
       
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
        
        TestClass.runContactSearch();
        
        TestClass.Cancel();
        TestClass.SaveEmbed();
        TestClass.searchDupes();
        TestClass.addParticipant();
        TestClass.createBox();
        TestClass.saveParticipants();
      TestClass.clearFinancial();
      TestClass.claimTypeChange(); 
      
      
      TestClass.Save();
      TestClass.removeParticipant();
      
    Test.StopTest();
         
  

}
 
public static testmethod void MatterKnowledge4(){


    Test.StartTest();
     Setup();
        advpm__Matter__c Matter_lit = [Select id from advpm__Matter__c Where RecordType.Name='Litigation Matter' limit 1];
       
         PageReference pageRef = Page.MatterKnowledgeDisplayV2;
         pageRef .getParameters().put('id',Matter_lit.id);
         pageRef .getParameters().put('Name2','');
         pageRef .getParameters().put('Summary','');
         pageRef .getParameters().put('Type','');
         pageRef .getParameters().put('Category','');
         pageRef .getParameters().put('Notes','');
         pageRef .getParameters().put('Description','Legal');
         
         Test.setCurrentPageReference(pageRef);
       
       
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
        
        /*
        for(KnowledgeHandlerV2.KnowledgeLibrary lib:TestClass.lst_LibraryDisplay){
            lib.LibSelect =  true;
        }
        */
        for(KnowledgeHandlerV2.CaseApproval lib:TestClass.lst_CaseDisplay){
            lib.CasSelect =  true;
        }
        
        
        
        system.debug('*****'+ TestClass.lst_LibraryDisplay);
        
        TestClass.runContactSearch();
        
        
        TestClass.SaveEmbed();
        TestClass.searchDupes();
        TestClass.addParticipant();
        
        
         Profile profile = [Select id from Profile where name = 'Litigation Standard User'];
       // User u = new User (Firstname ='John', Lastname='Doe', Profileid = profile.id);
          User u = [Select id from User Where Profileid =: profile.id Limit 1];       
                
        advpm__Participant__c participant = new advpm__Participant__c(advpm__Staff__c = u.id,advpm__Role__c='Agency');
        
        TestClass.participants.Add(participant);
        
        TestClass.createBox();
        TestClass.saveParticipants();
        TestClass.clearFinancial();
         TestClass.claimTypeChange();
         TestClass.removeClaim();
      
      TestClass.Save();
      
      TestClass.newSave();
    //  KnowledgeHandlerV2.createBoxfolder(Matter_lit.id);
      TestClass.createBox1();
      TestClass.Cancel();
      TestClass.removeParticipant();
        Test.StopTest();

}
    
public static testmethod void MatterKnowledge5(){


    Test.StartTest();
     Setup();
        
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Litigation Matter').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
    
        Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    	TestClass.selectedType = mapParticipantRecordTypes.get('User').getRecordTypeId();
    	TestClass.checkRecordType();
    	TestClass.actionClearParticipantControl();
    	TestClass.selectedType = mapParticipantRecordTypes.get('Contact').getRecordTypeId();
    	TestClass.checkRecordType();
        TestClass.actionClearParticipantControl();
    
    Test.StopTest();
}    
    
    public static testmethod void MatterKnowledge6(){
        
        
        Test.StartTest();
        Setup();
        
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Litigation Matter').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
        		
        Business_Unit__c busUnit = new Business_Unit__c
            (
                Name = 'Test',
                Segment__c = 'Corporate',
                Cluster_Function__c = 'Corporate and Investment Banking (CIB)'
            );
        insert busUnit;
        
        Business_Unit_Claim__c claim = new Business_Unit_Claim__c();
        
        claim.Business_Unit__c = busUnit.id;
        claim.Portion_of_Claim__c = 50;

        TestClass.claims.add(claim);
        TestClass.createBox();
        TestClass.TotalUnitsCalulate();
        
        Business_Unit__c busUnit2 = new Business_Unit__c
            (
                Name = 'Test2',
                Segment__c = 'Corporate',
                Cluster_Function__c = 'Corporate and Investment Banking (CIB)'
            );
        insert busUnit2;
        
        Business_Unit_Claim__c claim2 = new Business_Unit_Claim__c();
        
        claim2.Business_Unit__c = busUnit2.id;
        claim2.Portion_of_Claim__c = 110;

        TestClass.claims.add(claim2);
        TestClass.createBox();
        TestClass.TotalUnitsCalulate();
        
        Test.StopTest();
    }  
}