({
	getFacility : function(cmp, facilityId) {
		
        var action = cmp.get("c.getFacility");
        action.setParams({ "facilityId" : facilityId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.length == 0) {
                    alert('An error occured during getting data.');
                } else {
                	cmp.set("v.facility", data[0]);
                    cmp.set("v.productId", data[0].Product_Level_3__c);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getMetadata : function(cmp) {
        var helper = this;
        
        var action = cmp.get("c.getFacilityMetadata");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                helper.processCurrencyIsoCodes(cmp, data.currencyIsoCode);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    processCurrencyIsoCodes : function(cmp, data) {
      	var codes = ["ZAR"];
        for (var i = 0; i < data.length; i++) {
            if (data[i] == 'ZAR') continue;
            codes.push(data[i]);
        }
        cmp.set("v.currencyIsoCodeOptions", codes);
    },
    moveBack : function(id) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanFinancials",
            componentAttributes: {planId: id}
        });
        evt.fire();
    },
    addFacility : function(cmp, planId, product, limit, currency, utilisation, bank, isBarclays) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.addFacility");
        action.setParams({ 
            "planId" : planId,
            "product" : product,
            "lim" : limit,
            "curr" : currency,
            "utilisation" : utilisation,
            "bank" : bank,
            "isBarclays" : isBarclays
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during adding facility.');
                } else {
                	helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during adding facility.');
            }
        });
        $A.enqueueAction(action);
    },
    editFacility : function(cmp, planId, facilityId, product, limit, currency, utilisation, bank, isBarclays) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.editFacility");
        action.setParams({ 
            "facilityId" : facilityId,
            "product" : product,
            "lim" : limit,
            "curr" : currency,
            "utilisation" : utilisation,
            "bank" : bank,
            "isBarclays" : isBarclays
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editing facility.');
                } else {
                	helper.moveBack(planId);
                }
				
            } else  {
                console.log(response);
                alert('An error occured during editing facility.');
            }
        });
        $A.enqueueAction(action);
    }
})