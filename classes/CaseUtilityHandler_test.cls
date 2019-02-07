@Istest

Public Class CaseUtilityHandler_test{


Public static void Setup(){

             RecordType r = [Select Id, DeveloperName From RecordType Where Name='Knowledge Request'];
              
              /*
              CaseTeamTemplate ct = new CaseTeamTemplate();
               ct.name='Document Automation Team';
              Insert ct;
              */
              
              
              Case NewCase = new Case();
              NewCase.RecordTypeId = r.id;
              NewCase.Status = 'Automation in progress';
              NewCase.Subject = ''; //Legal
              NewCase.Description = '';
              NewCase.SuggestedTags__c = '';
              Insert NewCase;
              
              update NewCase;
              
              Case NewCase2 = new Case();
              NewCase2.RecordTypeId = r.id;
              NewCase2.Status = 'Ready for Review';
              NewCase2.Subject = ''; //Legal
              NewCase2.Description = '';
              NewCase2.SuggestedTags__c = '';
              Insert NewCase2;
              
              Case NewCase3 = new Case();
              NewCase3.RecordTypeId = r.id;
              NewCase3.Status = 'Ready For UAT';
              NewCase3.Subject = ''; //Legal
              NewCase3.Description = '';
              NewCase3.SuggestedTags__c = '';
              Insert NewCase3;
              

}



Public static testmethod void CaseUtilityMethod(){


test.StartTest();
Setup();

test.StopTest();


}


}