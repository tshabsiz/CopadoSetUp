({
    doInit : function(cmp, event, helper) {
        cmp.set("v.oldX", 0);
        cmp.set("v.oldY", 0);
        cmp.set("v.oldScale", 1);
        cmp.set("v.mapDataLoaded", false);
        cmp.set("v.mapCreated", false);
        helper.getMapData(cmp);
        helper.getMapMetadata(cmp);
    },
    doneRendering : function(cmp, event, helper) {
        var mapData = cmp.get("v.mapData");
        var mapMetadata = cmp.get("v.mapMetadata");
        var mapCreated = cmp.get("v.mapCreated");
        
        if (typeof mapData !== 'undefined' && typeof mapMetadata !== 'undefined' && mapCreated == false) {
              
            cmp.set("v.mapCreated", true);
            
            var check = function(mapData, mapMetadata, cmp, helper) {                
                if (typeof $ === 'undefined' && !!$.prototype.vectorMap) {
                    setTimeout(check(mapData, mapMetadata, cmp, helper), 1000);
                } else {
                    helper.prepareMap(mapData, mapMetadata, cmp);
                }
            }
            check(mapData, mapMetadata, cmp, helper);
        }
    },
    update : function (cmp, event, helper) {
        var timestamp = cmp.get("v.timestamp");
        $('#' + timestamp + ' #diagram').remove();
    },
    moveLeft : function(cmp, event, helper) {
        helper.moveLeft(cmp);
    },
    moveRight : function(cmp, event, helper) {
        helper.moveRight(cmp);
    },
    moveUp : function(cmp, event, helper) {
        helper.moveUp(cmp);
    },
    moveDown : function(cmp, event, helper) {
        helper.moveDown(cmp);
    },
    zoomIn : function(cmp, event, helper) {
        helper.zoomIn(cmp);
    },
    zoomOut : function(cmp, event, helper) {
        helper.zoomOut(cmp);
    },
    onMapLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("map");
        $A.util.toggleClass(toShow, "toggle");
    },
    onCountriesListLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("countriesList");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("countriesListMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onCountryClicked : function(cmp, event, helper) {
        var countryId = $(event.target).closest('.item').prop('id');
        helper.showCountryDetailComponent(cmp, countryId);
    },
    onAddCountryClicked : function(cmp, event, helper) {
        helper.showAddCountryComponent(cmp);
    },
    stopPropagation : function(cmp, event, helper) {
    	event.stopPropagation();  
    }
})