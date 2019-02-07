({
    onInit : function(component, event, helper) {
    },
    onClick : function(component, event, helper) {
        var id = event.target.dataset.menuItemId;
        if( id ) component.getSuper().navigate(id);
    },
    onRouteChange : function(component, event, helper) {
        // /employees, /bozo, /, etc.
        var pathPrefix = $A.get("$SfdcSite.pathPrefix");
        //console.log("pathPrefix: " + pathPrefix);
        // trying to deal with no community name in the path
        var fullPrefix = (2 > pathPrefix.length)?"":pathPrefix;
        fullPrefix += "/s/";
        //console.log("fullPrefix: " + fullPrefix);
        var pageUrl = window.location.href;
        //console.log("pageUrl: " + pageUrl);
        var pathPosition = pageUrl.indexOf(fullPrefix);
        //console.log("pathPosition: " + pathPosition);
        // that should be the position of the relative path of the page
        var pageRelativePathPosition = pathPosition + fullPrefix.length;
        //console.log("pageRelativePathPosition: " + pageRelativePathPosition);
        var pageRelativePath = pageUrl.substr(pageRelativePathPosition);
        //console.log("pageRelativePath: " + pageRelativePath);
        var pageRelativePathComponents = pageRelativePath.split("/");
        var firstPathComponent = pageRelativePathComponents[0];
        if( "" == firstPathComponent ) helper.highlightMenu(component, "home");
        else if( "recordlist" == firstPathComponent ) helper.highlightMenu(component, pageRelativePathComponents[1]);
        else if( "record" == firstPathComponent ) helper.highlightMenu(component, pageRelativePathComponents[1]);
        else helper.highlightMenu(component, firstPathComponent);
    }
})