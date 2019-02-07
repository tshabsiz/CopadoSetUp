({
    doInit : function(cmp, event, helper) {
        cmp.set("v.filteredData", []);
    	helper.loadProducts(cmp);
    },
	searchProducts : function(cmp, event, helper) {
        
		var allProducts = cmp.get('v.allProducts');
        if (typeof allProducts === 'undefined') {
            alert('Products are not loaded!');
            
        } else {
            var timestamp = cmp.get("v.timestamp");
            var timestampElem = document.getElementById("" + timestamp);
            var term = timestampElem.getElementsByClassName("searchProductsInput")[0].value;
            
            helper.searchProducts(cmp, term, allProducts);
        }
	},
    onProductClicked : function(cmp, event, helper) {
        var trElem = $(event.target).closest('.product');
     	var productId = $(trElem).prop('id');
        var productName = $(trElem).find('.productLvl3Name').text().trim();
        
        cmp.set("v.selectedProductId", productId);
        cmp.set("v.filteredData", []);
        
        var timestamp = cmp.get("v.timestamp");
        var timestampElem = document.getElementById("" + timestamp);
        timestampElem.getElementsByClassName("searchProductsInput")[0].value = productName;
        
        helper.triggerEvent(cmp, productId);
    }
})