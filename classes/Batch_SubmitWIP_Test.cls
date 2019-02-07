@isTest(SeeAllData=true)
public class Batch_SubmitWIP_Test {

    static testMethod void myUnitTest()
    {
        Test.startTest();
        Database.executeBatch(new Batch_SubmitWIP());
        Test.stopTest();
       
    }
     static testmethod void myUnitTestTwo(){
         Test.startTest();
         String sch = '0 0 23 * * ?';
         Batch_SubmitWIP testsche = new Batch_SubmitWIP();
         system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }  
}