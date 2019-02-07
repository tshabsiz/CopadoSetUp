({
	doInit : function (component, event) {
        alert('We inside v46');
        
        if( (typeof sforce != 'undefined') && sforce && (!!sforce.one) ) {
            sforce.one.navigateToSObject('00124000006CncUAAS'); 
            //sforce.one.navigateToURL("/home/home.jsp");
        }
        else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/apex/BriefingNote",
              "isredirect": "true"
            });
            urlEvent.fire();
        }
        
    }
})