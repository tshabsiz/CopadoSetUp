({
	getMapData : function(cmp) {
        
        var planId = cmp.get("v.planId");
		var action = cmp.get("c.queryCountries");
        action.setParams({ 
            planId : planId
        });

        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                
                cmp.set("v.mapData", data);
                cmp.set("v.mapDataLoaded", true);
                
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
                
                cmp.set("v.mapMetadata", data);
                cmp.set("v.mapMetadataLoaded", true);
                
            } else if (state === "ERROR") {
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    prepareMap : function(mapData, mapMetadata, cmp) {
        cmp.set("v.needsCopy", true);
        var timestamp = cmp.get("v.timestamp");
        
        var html = '<div id="vectorMap" style="height:300px;width:100%;"/>';
        $('#' + timestamp + ' #vectorMapWrapper').html(html);
        
        var mapColors = this.prepareMapColors(mapData, mapMetadata);
        
        var vectorMap = $('#' + timestamp + ' #vectorMap');
        $(vectorMap).vectorMap({ 
            map: 'world_en',
            borderColor: '#818181',
            borderOpacity: 0.2,
            borderWidth: 1,
            enableZoom: false,
            onRegionClick: function(event, code, region) {
                
                for (var i = 0; i < mapData.length; i++) {
                    if (mapData[i].Banking_Country__c == region) {
                        
                        var message = 'You clicked on ' +  mapData[i].Banking_Country__c + 
                            '. Primary bank is ' + mapData[i].Primary_Bank__c +
                            '. Engaged is ' + mapData[i].Engaged__c + '.';
                        alert(message);
                    }
                }
            }
        });
        $(vectorMap).vectorMap('set', 'colors', mapColors);
        
        this.moveRight(cmp);
    },
    prepareMapColors : function(mapData, mapMetadata) {
        var result = {};
        
        for (var i = 0; i < mapData.length; i++) {
            var cp = mapData[i];
            var countryCode = mapMetadata.countriesMap[cp.Banking_Country__c];
            var color = mapMetadata.engagedMap[cp.Engaged__c];
            
            if (typeof countryCode === 'undefined' || typeof color === 'undefined') {
                continue;
            }
            result[countryCode] = color;
        }
        return result;
    },
    showCountryDetailComponent : function(cmp, countryId) {
        
        var planId = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanCountryDetail",
            componentAttributes: {planId: planId, countryId: countryId}
        });
        evt.fire();
    },
    showAddCountryComponent : function(cmp) {
        var planId = cmp.get("v.planId");
        var timestamp = new Date().getTime();
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyCountry",
            componentAttributes: {
                planId: planId, 
                countryId: null,
                engaged: null,
                primaryBank: null,
                timestamp: timestamp
            }
        });
        evt.fire();
    },
    copyMapCoordinates : function(cmp, timestamp) {
        var b = $('#' + timestamp + ' #vectorMap svg').html().substring(0, 100);
        b = b.split('translate(')[1];
        b = b.split(')">')[0];
        b = b.split(', ');
        var oldXValue = Number(b[0]);
        var oldYValue = Number(b[1]);
        
        cmp.set("v.needsCopy", false);
        cmp.set("v.oldX", oldXValue);
        cmp.set("v.oldY", oldYValue);
    },
    moveLeft : function(cmp) {
        var needsCopy = cmp.get("v.needsCopy");
        var timestamp = cmp.get("v.timestamp");
        var oldScale = cmp.get("v.oldScale");
        
        if (needsCopy == true) {
            this.copyMapCoordinates(cmp, timestamp);
        } 
        
        var oldX = cmp.get("v.oldX");
        var oldY = cmp.get("v.oldY");
        oldX = oldX + 20;
        cmp.set("v.oldX", oldX);
        
        $('#' + timestamp + ' #vectorMap g').css('transform', 'translate(' + oldX + 'px,' + oldY + 'px) scale(' + oldScale + ')');
    },
    moveRight : function(cmp) {
        var needsCopy = cmp.get("v.needsCopy");
        var timestamp = cmp.get("v.timestamp");
        var oldScale = cmp.get("v.oldScale");
        
        if (needsCopy == true) {
            this.copyMapCoordinates(cmp, timestamp);
        } 
        
        var oldX = cmp.get("v.oldX");
        var oldY = cmp.get("v.oldY");
        oldX = oldX - 20;
        cmp.set("v.oldX", oldX);
        
        $('#' + timestamp + ' #vectorMap g').css('transform', 'translate(' + oldX + 'px,' + oldY + 'px) scale(' + oldScale + ')');
    },
    moveUp : function(cmp) {
        var needsCopy = cmp.get("v.needsCopy");
        var timestamp = cmp.get("v.timestamp");
        var oldScale = cmp.get("v.oldScale");
        
        if (needsCopy == true) {
            this.copyMapCoordinates(cmp, timestamp);
        } 
        
        var oldX = cmp.get("v.oldX");
        var oldY = cmp.get("v.oldY");
        oldY = oldY + 20;
        cmp.set("v.oldY", oldY);
        
        $('#' + timestamp + ' #vectorMap g').css('transform', 'translate(' + oldX + 'px,' + oldY + 'px) scale(' + oldScale + ')');
    },
    moveDown : function(cmp) {
        var needsCopy = cmp.get("v.needsCopy");
        var timestamp = cmp.get("v.timestamp");
        var oldScale = cmp.get("v.oldScale");
        
        if (needsCopy == true) {
            this.copyMapCoordinates(cmp, timestamp);
        } 
        
        var oldX = cmp.get("v.oldX");
        var oldY = cmp.get("v.oldY");
        oldY = oldY - 20;
        cmp.set("v.oldY", oldY);
        
        $('#' + timestamp + ' #vectorMap g').css('transform', 'translate(' + oldX + 'px,' + oldY + 'px) scale(' + oldScale + ')');
    },
    zoomIn : function(cmp) {
        var needsCopy = cmp.get("v.needsCopy");
        var timestamp = cmp.get("v.timestamp");
        var oldScale = cmp.get("v.oldScale");
        
        if (needsCopy == true) {
            this.copyMapCoordinates(cmp, timestamp);
        } 
        
        var oldX = cmp.get("v.oldX");
        var oldY = cmp.get("v.oldY");
        oldScale = oldScale + 0.1;
        cmp.set("v.oldScale", oldScale);
        
        $('#' + timestamp + ' #vectorMap g').css('transform', 'translate(' + oldX + 'px,' + oldY + 'px) scale(' + oldScale + ')');
    },
    zoomOut : function(cmp) {
        var needsCopy = cmp.get("v.needsCopy");
        var timestamp = cmp.get("v.timestamp");
        var oldScale = cmp.get("v.oldScale");
        
        if (needsCopy == true) {
            this.copyMapCoordinates(cmp, timestamp);
        } 
        
        var oldX = cmp.get("v.oldX");
        var oldY = cmp.get("v.oldY");
        oldScale = oldScale - 0.1;
        cmp.set("v.oldScale", oldScale);
        
        $('#' + timestamp + ' #vectorMap g').css('transform', 'translate(' + oldX + 'px,' + oldY + 'px) scale(' + oldScale + ')');
    }
})