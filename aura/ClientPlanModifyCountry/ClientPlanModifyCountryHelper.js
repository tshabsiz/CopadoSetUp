({
	getCountryData : function(cmp) {
        
		var countryId = cmp.get("v.countryId");
        var action = cmp.get("c.getCountry");
        action.setParams({ 
            countryId : countryId
        });

        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                console.log(data);
                cmp.set("v.country", data);
                
            } else {
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getMapMetadata : function(cmp) {
        
        var action = cmp.get("c.getMapMetadata");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var dataJson = response.getReturnValue();
                var data = JSON.parse(dataJson);
                data.barclaysPresenceJson = JSON.parse(data.barclaysPresenceJson);
                data.bankingCountriesJson = JSON.parse(data.bankingCountriesJson);
                
                cmp.set("v.mapMetadata", data);
                
            } else {
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    getFieldsMetadata : function(cmp) {
        
        var action = cmp.get("c.getFieldsMetadata");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                cmp.set("v.engagedOptions", data.engaged);
                cmp.set("v.primaryBankOptions", data.primaryBank);
                
            } else {
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    moveBackToDetail : function(planId, countryId) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanCountryDetail",
            componentAttributes: {planId: planId, countryId: countryId}
        });
        evt.fire();
    },
    moveBackToPresence : function(planId) {
        var timestamp = new Date().getTime();
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanPresence",
            componentAttributes: {planId: planId, timestamp: timestamp}
        });
        evt.fire();
    },
    prepareTypeahed : function(timestamp, mapMetadata, selectedCountry) {
        
        var barclaysPresence = mapMetadata.barclaysPresenceJson.pickList;
        var bankingCountryBloodhound = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.whitespace,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            local: mapMetadata.bankingCountriesJson
        });
        
        var elem = $('#' + timestamp + ' #bankingCountryInput');
        $(elem).typeahead({
            hint: true,
            highlight: true,
            minLength: 0
        },{
            name: 'bankingCountryBloodhound',
            source: function(q, sync) {
            	bankingCountryBloodhound.search(q, sync);
            }
        });
        
        if (selectedCountry != null) {
        	$(elem).val(selectedCountry);
        }
    },
    onBeforeEditCountry : function(cmp, planId, countryId, country, engaged, primaryBank) {
        cmp.set("v.showProgressBar", true);
        
        var helper = this;
        var action = cmp.get("c.editCountry");
        action.setParams({ 
            countryId : countryId,
            country: country,
            engaged: engaged,
            primaryBank: primaryBank
        });

        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during editation.');
                } else {
                    helper.moveBackToDetail(planId, countryId);
                }
                
            } else if (state === "ERROR") {
                alert('An error occured during editation.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeAddCountry : function(cmp, planId, country, engaged, primaryBank) {
		cmp.set("v.showProgressBar", true);
        
		var helper = this;
        var action = cmp.get("c.addCountry");
        action.setParams({ 
            planId : planId,
            country: country,
            engaged: engaged,
            primaryBank: primaryBank
        });

        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data) {
                    alert('An error occured during adding country.');
                } else {
                    helper.moveBackToPresence(planId);
                }
                
            } else if (state === "ERROR") {
                alert('An error occured during adding country.');
            }
        });
        $A.enqueueAction(action);        
    }
})