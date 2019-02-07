/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 20/08/2017 - PG    - Created Class. 

**/ 
@isTest
public class Matter_Deal_Override_Test 
{
    public static testMethod void testOverrideController() 
    {
        Test.startTest();

        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //Set Id Null for insert.
        testDataClass.TestMatter.Id = null;
        
        //Set page reference
        PageReference pageRef = Page.Matter_Deal_Override;
        Test.setCurrentPage(pageRef);
        
        //St VF page
        ApexPages.StandardController stdController = new ApexPages.StandardController(testDataClass.TestMatter);
        Matter_Deal_Override extController = new Matter_Deal_Override(stdController);
        extController.initialiseLists();
        
        //Set Product Area
        extController.objectRecord.TMG_Product_Level_1__c = testDataClass.TestProductLevel1.id;
        extController.objectRecord.TMG_Product_Level_2__c = testDataClass.TestProductLevel2.id;
        extController.objectRecord.TMG_Product_Level_3__c = testDataClass.TestProductLevel3.id;
        
        //Populate Products List.
        extController.coverageAreaSelected = testDataClass.TestProductLevel1.id;
        extController.productAreaSelected = testDataClass.TestProductLevel2.id;
        extController.selectedProduct = testDataClass.TestProductLevel3.id;
        extController.actionClearProduct();
        extController.actionClearCoverageArea();
        extController.actionClearProductArea();
        
        //Set Product Area again.
        extController.objectRecord.TMG_Product_Level_2__c = testDataClass.TestProductLevel2.id;
        
        //Populate Products List.
        extController.actionClearProduct();
        extController.actionClearCoverageArea();
        extController.actionClearProductArea();
        
        //Return products list.
        extController.getProducts();
        extController.getCoverageArea();
        extController.getProductArea();
        
        //Save record
        extController.actionSave();
        
        Test.stopTest();
    }
}