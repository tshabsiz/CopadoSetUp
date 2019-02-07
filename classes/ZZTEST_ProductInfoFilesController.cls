/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
*
* @group Unit Tests
*
* @description Unit Tests for the class which returns all the files for categories and sub categories
*                   Tests executed:
*                   1 - testGetFiles()
*                       Tests the retrieval of files to show on the Product Info Files VF page
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private class ZZTEST_ProductInfoFilesController {
    @isTest
    static void testGetFiles() {
    	//controller initialization
        PageReference ProductInfoFilesPage = Page.ProductInfoFiles;
        Test.setCurrentPage(ProductInfoFilesPage);
        ProductInfoFilesController ctrl = new ProductInfoFilesController();
        
        //get sub categories and selected categories
        List<SelectOption> subcatoptions = ctrl.SubCategories;
        String toplevelcat = ctrl.SelectedTopLevelCategory;
        String subcat = ctrl.SelectedSubCategory;
        
        //assert that the subcat is not selected
        System.AssertEquals('--SELECT--', subcat);
        
        //get files when nothing is selected
        ctrl.getFiles();
        
        // insert a new top level category
        Barclays_SA__Category__c cat = new Barclays_SA__Category__c();
        cat.Name = 'Accounts';
        insert cat;
        
        //get top level categories into selectoption
        List<SelectOption> catoptions = ctrl.TopLevelCategories;
        
        //set the selected top level category to the one we just inserted
        ctrl.SelectedTopLevelCategory = cat.Id;
        
        //create a new junction between newly created category and a document with an ID
        Barclays_SA__Cat_Content_Junction__c junction = new Barclays_SA__Cat_Content_Junction__c();
        junction.Barclays_SA__Category__c = cat.Id; 
        junction.Barclays_SA__ContentId__c = '069250000004ewJAAQ';
        insert junction;
        
        //get files when top level category is selected
        ctrl.getFiles();
        List<ContentWorkspaceDoc> Files = ctrl.Files;
        
        //assert that no files were returned
        System.AssertEquals(0, Files.size());
    }
}