/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanProductSearch desktop and mobile components
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientEnvironment
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*15.2.2016      Svata Sejkora   adding modifications to allow editing and deleting of Financial Information
*05.5.2016		Caro Reinecke	only return active products
*------------------------------------------------------------*/
public class ClientPlanProductSearchController {

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of all products
      * @Returns:         List<Product_Level_3__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
	@AuraEnabled
	public static List<Product_Level_3__c> getAllProductsMobile() {
      	return getAllProducts();
	}

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of all products in JSON
      * @Returns:         String
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
	@RemoteAction
	public static String getAllProductsJson() {
      	List<Product_Level_3__c> products = getAllProducts();
      	return JSON.serializePretty(products);
	}

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries all products
      * @Returns:         List<Product_Level_3__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
	private static List<Product_Level_3__c> getAllProducts() {
      	return [
      		SELECT 	Id, Name, Product_Level_2__r.Name, Product_Level_2__r.Product__r.Name
      		FROM 	Product_Level_3__c  
      		WHERE 	Product_Level_2__r.Product__r.isActive = True AND Active__c = TRUE
      	];
	}

	/* Get all Products in JSON including the lvl1 and lvl2 Record IDs */
	@RemoteAction
	public static String getAllProductsCompleteJson() {
      	List<Product_Level_3__c> products = [
      		SELECT  Id, Name, Product_Level_2__r.Id, Product_Level_2__r.Name, Product_Level_2__r.Product__r.Id, Product_Level_2__r.Product__r.Name
      		FROM    Product_Level_3__c
      		WHERE   Product_Level_2__r.Product__r.isActive = True AND Active__c = TRUE
      	];

      	return JSON.serializePretty(products);
	}
}