({
	doInit : function(cmp, event, helper) {
		helper.getOptys(cmp);
	},
    moveBack : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        var strategyId = cmp.get("v.strategyId");
        helper.moveBack(planId, strategyId);
    },
    onBeforeLinkOptys : function(cmp, event, helper) {
        
     	var optys = cmp.get("v.optys");
        var optysToLink = [];
        
        for (var i = 0; i < optys.length; i++) {
            if (optys[i].checked) {
                optysToLink.push(optys[i].Id);
            }
        }
        
        var strategyId = cmp.get("v.strategyId");
        if (optysToLink.length > 0) {
            helper.onBeforeLinkOptys(cmp, strategyId, optysToLink);
        }
    },
    onCheck : function (cmp, event, helper) {
        var isChecked;
        var optyId;
        
        var elements = event.source.elements;
        for (var i = 0; i < elements.length; i++) {
            
            var classList = elements[i].classList;
            if (typeof classList !== 'undefined') {
                for (var x = 0; x < classList.length; x++) {
                    
                    var c = classList[x];
                    if (c.indexOf('opty-') > -1) {
                        optyId = c.split('opty-')[1];
                        isChecked = elements[i].checked;
                    }
                }
            }
        }
        
        var optys = cmp.get("v.optys");
        for (var i = 0; i < optys.length; i++) {
            if (optys[i].Id == optyId) {
                optys[i].checked = isChecked;
            }
        }
    }
})