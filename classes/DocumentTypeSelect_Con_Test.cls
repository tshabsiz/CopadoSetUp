@isTest
public class DocumentTypeSelect_Con_Test {
    static testMethod void TestDocumentTypeSelect_Con(){
        //dummy account
        List<Account> accountList = new List<Account>();
        for(Integer i =0 ; i < 200 ; i++){
            accountList.add(new Account(Name='Test'+i));
        }
        //insert account records
        insert accountList;
        Test.startTest();  
        String s1 = DocumentTypeSelect_Con.getData('Account','Name','Id','T');
        List<Account> data1 = (List<Account>) JSON.deserialize(s1, List<Account>.class);
        System.assertEquals(accountList.size(), data1.size());
        DocumentTypeSelect_Con controller = new DocumentTypeSelect_Con();
        controller.setTargetFieldVar(accountList[0].Id);
        System.assertEquals(accountList[0].Id,controller.getTargetFieldVar());
        controller.setCacheField(null);
        Test.stopTest();        
    }
}