/* This script will insert a modal div in the standard page. The modal will contain a VF page. This file should be located in a static resource. */
var j$ = jQuery.noConflict();
var currentUrl = window.location.href;
var hostIndex = currentUrl.indexOf(window.location.host+'/') + (window.location.host+'/').length;
var callReportId = currentUrl.substring(hostIndex, hostIndex + 15); 
j$(function() {    
    /* Insert the Modal dialog along with the VF as an iframe inside the DIV */
    var style = '.ui-widget-overlay {background: #aaaaaa repeat-x !important; opacity: .3; filter: Alpha(Opacity=30);}';
    style += '.ui-dialog-titlebar { display:none !important; overflow:hidden; }';
    style += '#modalDiv {overflow:hidden; padding:0}';
    j$("head").after('<style type="text/css">' + style + '</style>');

    /* Insert the jQuery style sheets in the Header */
    j$("head").after(
        j$("<link>",{rel:"stylesheet", href:"https://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css"})
    );
    
    j$("body").after(
        j$("<div>",{id:"modalDiv", style:"display:none;"}).append(
            j$("<iframe>",{
                id: "vfFrame",
                src: "/apex/CallReport_Send?id=" + callReportId + '&returnURL=' + currentUrl,
                height: 425,
                width: 650,
                frameBorder: 1
            })
        )
    );

    /* Initialize the Dialog Window */
    j$("#modalDiv").dialog({
        autoOpen: false,
        height: 425,
        width: 650,
        resizable : false,
        modal: true
    });
});