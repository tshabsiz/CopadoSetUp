/**
* @Author:        Dino Scarcella
* @Company:       ABSA Capital
* @Description:   Unit Tests for ClientPlanACMProductSearchController
*                 Tests executed:
*                 1 - testGetAllACMProductsJson()
*                   Tests getter of all products in JSON
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ACMProductSearchController {
	static testMethod void testGetAllACMProductsJson() {
        List<Product_Setting__mdt> prods = [
            SELECT 	 Id, ProductName__c
      		FROM 	 Product_Setting__mdt  
      		WHERE 	 ProductSet__c = 'ACMProducts'
            ORDER BY ProductName__c
        ];
        String prodsJson = JSON.serializePretty(prods);

        String result = ClientPlanACMProductSearchController.getAllACMProductsJson();
        System.assertEquals(prodsJson, result);
    }
}