@isTest(SeeAllData=true)
public class CSC_Utility_Test {

    static testMethod void myUnitTest()
    {
        Test.startTest();
        
        List<Case>Caselist =[Select ID,CaseNumber,Queue__c,Subcategory__c,IsClosed,Service_Type__c,CreatedDate,WIP__c,(SELECT Id 
                                                                                                          FROM WIP_Logs__r 
                                                                                                          where Processed__c =false) 
                                         From case 
                                         where IsClosed =false limit 10];
        
        
        
        CSC_Utility.createWIPFile(caseList);
        
        
        
        List<WIP_Log__c> wipList = [SELECT Id, Case__c, Date_Actioned__c, BRID__c, Team__c, Service_Type_Task__c,
                                        Processed__c,Name,Case__r.CaseNumber,Workout__c
                                        FROM WIP_Log__c 
                                        where Processed__c =false];
        
        CSC_Utility.createWorkoutFile(wipList);
        Test.StopTest();
    }
   
}