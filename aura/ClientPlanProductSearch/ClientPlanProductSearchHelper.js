({
	loadProducts : function(cmp) {
		
        var action = cmp.get("c.getAllProductsMobile");
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data.length == 0) {
                    alert('No products found!');
                } else {
                	cmp.set("v.allProducts", data);
                }
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    searchProducts : function(cmp, term, allProducts) {
        var filteredData = [];
        term = term.trim();
        
        if (term != '') {
            var searchData = eval("/" + term + "/gi");
        
            $.each(allProducts, function (i, v) {
                if (v.Name.search(new RegExp(searchData)) != -1) {
                    filteredData.push(v);
                }
            });
        } else {
            this.triggerEvent(cmp, null);
        }
        cmp.set("v.filteredData", filteredData);
    },
    triggerEvent : function(cmp, productId) {
        var evt = cmp.getEvent("ProductSearchEvent");
        evt.setParams({
            "productId": productId
        });
        evt.fire();
    }
})