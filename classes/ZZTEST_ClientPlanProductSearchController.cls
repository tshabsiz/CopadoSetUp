/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanProductSearchController
*                 Tests executed:
*                 1 - testGetAllProductsMobile()
*                   Tests getter of all products
*                 2 - testGetAllProductsJson()
*                   Tests getter of all products in JSON
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanProductSearchController {

    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
    }

    static testMethod void testGetAllProductsMobile() {
        List<Product_Level_3__c> prods = [
            SELECT Id, Name, Product_Level_2__r.Name, Product_Level_2__r.Product__r.Name
            FROM Product_Level_3__c
        ];

        List<Product_Level_3__c> result = ClientPlanProductSearchController.getAllProductsMobile();
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(prods[0], result[0]);
    }

    static testMethod void testGetAllProductsJson() {
        List<Product_Level_3__c> prods = [
            SELECT Id, Name, Product_Level_2__r.Name, Product_Level_2__r.Product__r.Name
            FROM Product_Level_3__c
        ];
        String prodsJson = JSON.serializePretty(prods);

        String result = ClientPlanProductSearchController.getAllProductsJson();
        System.assertEquals(prodsJson, result);
    }

    static testMethod void testGetAllProductsCompleteJson() {
        List<Product_Level_3__c> prods = [
            SELECT  Id, Name, Product_Level_2__r.Id, Product_Level_2__r.Name, Product_Level_2__r.Product__r.Id, Product_Level_2__r.Product__r.Name
            FROM    Product_Level_3__c
            WHERE   Product_Level_2__r.Product__r.isActive = True AND Active__c = TRUE
        ];
        String prodsJson = JSON.serializePretty(prods);

        String result = ClientPlanProductSearchController.getAllProductsCompleteJson();
        System.assertEquals(prodsJson, result);
    }
}