public with sharing class ProductSelection_Helper {
	//Map of ProductLvl3ID -> ProductLvl3Object
	private Map<Id, Product_Level_3__c> allProductsMap;

	public ProductSelection_Helper() {
		this.queryAllProducts();
	}

	private void queryAllProducts() {
        List<Product_Level_3__c> products = [
            SELECT  Id, Name, Product_Level_2__c, Product_Level_2__r.Product__c
            FROM    Product_Level_3__c
            WHERE   Product_Level_2__c != null AND Product_Level_2__r.Product__c != null
        ];
        
        this.allProductsMap = new Map<Id, Product_Level_3__c>(products);
    }

    //Helper function to retrieve parent product for the Product specific by 
    //- #1 the level of the product parameter
    //- #2 the ID of the product parameter
    public Id getProductParent(Integer productLevel, Id productId) {
        if(productLevel == 1) {
            //There is no parent
            return null;
        } else if(productLevel == 2) {
            //Find the first lvl3 entry with this lvl2 - then return the corresponding lvl1
            for(Product_Level_3__c lvl3 : this.allProductsMap.values()) {
                if(lvl3.Product_Level_2__c == productId) {
                    return lvl3.Product_Level_2__r.Product__c;
                }
            }
        } else if(productLevel == 3) {
            //Directly pull this lvl3 from the map and return it's lvl2
            return this.allProductsMap.get(productId).Product_Level_2__c;
        } 

        //If we're still here
        throw new ProductSelectionException('Unable to find parentProduct for [ProductLevel: ' + productLevel + ', ProductID: ' + productId);
    }

    public class ProductSelectionException extends Exception {}
}