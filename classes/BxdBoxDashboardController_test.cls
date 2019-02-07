@IsTest
public class BxdBoxDashboardController_test {
    
    // This test method should give 100% coverage
    static testMethod void testClearData(){
        //Folder Details test records
        box__Folder_Details__c folderDetail = new box__Folder_Details__c(Name='Deals', box__FolderId__c='34530569786',box__Folder_Name__c='TestFolderName1');
        box__Folder_Details__c folderDetail2 = new box__Folder_Details__c(Name='Cases', box__FolderId__c='12345678906',box__Folder_Name__c='TestFolderName2');
        
        List<box__Folder_Details__c> folderDetails = new List<box__Folder_Details__c>();
        
        folderDetails.add(folderDetail);
        folderDetails.add(folderDetail2);
        
        insert folderDetails;
        
        //Box Frup test records
        box__FRUP__c boxFrup = new box__FRUP__c(box__Object_Name__c='Matter__c',box__Folder_ID__c='34530569786',box__Box_user__c='123445');
        box__FRUP__c boxFrup2 = new box__FRUP__c(box__Object_Name__c='Deal__c',box__Folder_ID__c='12345678906',box__Box_user__c='544321');
        
        List<box__FRUP__c> frupList = new List<box__FRUP__c>();
        
        frupList.add(boxFrup);
        frupList.add(boxFrup2);
        
        insert frupList;
        
        //Custom Frup test records
        Custom_FRUP__c customFrup = new Custom_FRUP__c(Name='s029847783',CustomKey__c='s094784832 - Deals',FolderId__c='98765432123',ParentFolderId__c='10231234567');
        Custom_FRUP__c customFrup2 = new Custom_FRUP__c(Name='s370932972',CustomKey__c='s784938492 - Cases',FolderId__c='23123456789',ParentFolderId__c='76543213201');
        
        List<Custom_FRUP__c> customFrupList = new  List<Custom_FRUP__c>();
        
		customFrupList.add(customFrup);    
        customFrupList.add(customFrup2);   
        
        insert customFrupList;
        
        //Calling the actual method
        BxdBoxDashboardController dashboard = new BxdBoxDashboardController();
        dashboard.clearData();
        
        
    }
}