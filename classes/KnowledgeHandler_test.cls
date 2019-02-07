@Istest
Public class KnowledgeHandler_test{



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
                
             ContentVersion   ContentVersions = new ContentVersion(
              Title='Legal', 
              Description='Legal',
              ContentUrl = 'http://google.co.za'
            //  Matter_Category__c='Legal',
            //  Matter_Type__c='Legal' 
            );
              Insert ContentVersions; 
}



public static testmethod void MatterKnowledge1(){


    Test.StartTest();
     Setup();
        
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Litigation Matter').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandler TestClass = new KnowledgeHandler(sc);
         
    Test.StopTest();


}

public static testmethod void MatterKnowledge2(){


    Test.StartTest();
     Setup();
      
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Legal').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandler TestClass = new KnowledgeHandler(sc);
         
    Test.StopTest();

}
public static testmethod void MatterKnowledge3(){


    Test.StartTest();
     Setup();
     advpm__Matter__c Matter_lit = [Select id from advpm__Matter__c Where RecordType.Name='Legal' limit 1];
       
        
         PageReference pageRef = Page.MatterKnowledgeDisplay;
         pageRef .getParameters().put('id',Matter_lit.id);
         pageRef .getParameters().put('Name1','Legal');
         pageRef .getParameters().put('BusinessUnit','Legal');
         pageRef .getParameters().put('Description','Legal');
         
         Test.setCurrentPageReference(pageRef);
       
       
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
        KnowledgeHandler TestClass = new KnowledgeHandler(sc);
        
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
       
         PageReference pageRef = Page.MatterKnowledgeDisplay;
         pageRef .getParameters().put('id',Matter_lit.id);
         pageRef .getParameters().put('Name2','Legal');
         pageRef .getParameters().put('Summary','Legal');
         pageRef .getParameters().put('Type','Legal');
         pageRef .getParameters().put('Category','Legal');
         pageRef .getParameters().put('Notes','Legal');
         pageRef .getParameters().put('Description','Legal');
         
         Test.setCurrentPageReference(pageRef);
       
       
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
        KnowledgeHandler TestClass = new KnowledgeHandler(sc);
        
        for(KnowledgeHandler.KnowledgeLibrary lib:TestClass.lst_LibraryDisplay){
            lib.LibSelect =  true;
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
      TestClass.Cancel();
      TestClass.removeParticipant();
       
    Test.StopTest();

}
}