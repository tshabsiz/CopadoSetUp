({
	doInit : function(cmp, event, helper) {
		
        cmp.set("v.createTypeahed", true);
        var countryId = cmp.get("v.countryId");
        if (countryId != null) {
            helper.getCountryData(cmp, countryId);
        }
        helper.getMapMetadata(cmp);
        helper.getFieldsMetadata(cmp);
	},
    doneRendering : function(cmp, event, helper) {
     	
        var createTypeahed = cmp.get("v.createTypeahed");
        if (createTypeahed) {
            
            var country = cmp.get("v.country");
            var countryId = cmp.get("v.countryId");
            
            if (countryId == null && typeof cmp.find("engaged") !== 'undefined' && typeof cmp.find("primaryBank") !== 'undefined') {
                cmp.find("engaged").set("v.value", 'Primary Bank');
                cmp.find("primaryBank").set("v.value", 'Barclays');
                
            } else if (typeof country !== 'undefined') {
                cmp.find("engaged").set("v.value", cmp.get("v.engaged"));
                cmp.find("primaryBank").set("v.value", cmp.get("v.primaryBank"));
            }
            
            var mapMetadata = cmp.get("v.mapMetadata");
            var timestamp = cmp.get("v.timestamp");
            if (typeof mapMetadata !== 'undefined') {
                
                if (countryId != null && typeof country === 'undefined') {
                    return;
                }
                
                var selectedCountry = countryId == null ? null : country.Banking_Country__c;
                var check = function(timestamp, mapMetadata, selectedCountry) {
                    
                    if (typeof $ === 'undefined' && !!$.prototype.typeahead) {
                        setTimeout(check(timestamp, mapMetadata, selectedCountry), 1000);
                    } else {
                        cmp.set("v.createTypeahed", false);
                        helper.prepareTypeahed(timestamp, mapMetadata, selectedCountry);
                    }
                }
                check(timestamp, mapMetadata, selectedCountry);
            }
        }
    },
    moveBack : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var countryId = cmp.get("v.countryId");
        
        if (countryId != null) {
        	helper.moveBackToDetail(planId, countryId);
        } else {
            helper.moveBackToPresence(planId);
        }
    },
    onBeforeModifyCountry : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var countryId = cmp.get("v.countryId");
        var timestamp = cmp.get("v.timestamp");
        
        var country = $('#' + timestamp + ' #bankingCountryInput').val().trim();
        if (country.length == 0) {
            var bankingCountryError = cmp.find("bankingCountryError");
        	$A.util.toggleClass(bankingCountryError, "toggle");
            return;
        }
        
        var engaged = cmp.find("engaged").get("v.value");
        var primaryBank = cmp.find("primaryBank").get("v.value");
        
        if (countryId != null) {
        	helper.onBeforeEditCountry(cmp, planId, countryId, country, engaged, primaryBank);
        } else {
            helper.onBeforeAddCountry(cmp, planId, country, engaged, primaryBank);
        }
    }
})