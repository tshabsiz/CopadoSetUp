/**
* @Author       Dino Scarcella
* @Company:     Absa Capital
* @Description: Controller class for ClientPlanACMProductSearch component
* @Date:        2018.04.06
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientEnvironment
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanACMProductSearchController {

    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     getter of all ACM products in JSON
      * @Returns:         String
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
	@RemoteAction
	public static String getAllACMProductsJson() {
      	List<Product_Setting__mdt> products = getAllACMProducts();
      	return JSON.serializePretty(products);
	}

    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     queries all ACM products
      * @Returns:         List<Product_Setting__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
	private static List<Product_Setting__mdt> getAllACMProducts() {
      	return [
      		SELECT 	 Id, ProductName__c
      		FROM 	 Product_Setting__mdt  
      		WHERE 	 ProductSet__c = 'ACMProducts'
            ORDER BY ProductName__c
      	];
	}
}