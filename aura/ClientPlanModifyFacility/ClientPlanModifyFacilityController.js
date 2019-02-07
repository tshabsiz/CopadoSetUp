({
	doInit : function(cmp, event, helper) {
        cmp.set("v.doDoneRendering", true);
        
        var facilityId = cmp.get("v.facilityId");
        if (facilityId != null) {
            helper.getFacility(cmp, facilityId);
        }
        helper.getMetadata(cmp);
	},
    doneRendering : function(cmp, event, helper) {
		var doDoneRendering = cmp.get("v.doDoneRendering");
        var currencyIsoCodeOptions = cmp.get("v.currencyIsoCodeOptions");
        var facility = cmp.get("v.facility");
        var facilityId = cmp.get("v.facilityId");
        
        //edit
        if (doDoneRendering && typeof facility !== 'undefined' && facilityId != null) {
            cmp.set("v.doDoneRendering", false);
            
        	cmp.find("currency").set("v.value", facility.CurrencyIsoCode);
            
        //add
        } else if (doDoneRendering && typeof currencyIsoCodeOptions !== 'undefined' && facilityId == null) {
            cmp.set("v.doDoneRendering", false);
            
            cmp.find("currency").set("v.value", 'ZAR');
        }
        
	},
    moveBack : function(cmp, event, helper) {
        var id = cmp.get("v.planId");
        helper.moveBack(id);
    },
    onBeforeSave : function(cmp, event, helper) {
        //product
        var product = cmp.get("v.productId");
        if (typeof product === 'undefined') {
            product = null;
        }
        
        //limit
        var limit = cmp.find("limit").get("v.value");
        if (typeof limit === 'undefined' || limit === '') {
            limit = 0;
        }
        
        if (limit != null && isNaN(parseFloat(limit))) {
            var limitError = cmp.find("limitError");
        	$A.util.toggleClass(limitError, "toggle");
            return;
        }
        
        //currency
        var currency = cmp.find("currency").get("v.value");
        currency = currency == 'undefined' ? null : currency;
        
        var isBarclays = cmp.get("v.isBarclays");
        var utilisation = null;
        var bank = null;
        
        if (isBarclays) {
            //utilisation
            utilisation = cmp.find("utilisation").get("v.value");
            if (typeof utilisation === 'undefined' || utilisation === '') {
                utilisation = 0;
            }
            
            if (utilisation != null && isNaN(parseFloat(utilisation))) {
                var utilisationError = cmp.find("utilisationError");
                $A.util.toggleClass(utilisationError, "toggle");
                return;
            }
            
        } else {
            //bank
            bank = cmp.find("bank").get("v.value");
        }
        
        var facilityId = cmp.get("v.facilityId");
        var planId = cmp.get("v.planId");
        
        if (facilityId == null) {
            helper.addFacility(cmp, planId, product, limit, currency, utilisation, bank, isBarclays);
        } else {
            helper.editFacility(cmp, planId, facilityId, product, limit, currency, utilisation, bank, isBarclays);
        }
    },
    onProductSelected : function(cmp, event, helper) {
    	var productId = event.getParam("productId");
        cmp.set("v.productId", productId);
	}
})