({
	doInit : function(cmp, event, helper) {
		helper.getStrategies(cmp, null);
	},
    searchStrategies : function(cmp, event, helper) {
        var name = event.source.elements[0].value;
        name = name.trim();
        
        if (name.length > 0) {
        	helper.getStrategies(cmp, name);
        } else {
            helper.getStrategies(cmp, null);
        }
    },
    doneRendering : function(cmp, event, helper) {
        
        var timestamp = cmp.get("v.timestamp");
        if (typeof timestamp !== 'undefined') {
            
            var check = function(cmp, helper) {
                if (typeof $ === 'undefined') {
                    setTimeout(check(cmp, helper), 1000); 
                } else {
                    
                    var itemsCount = $('#' + timestamp + ' .strategyItem').length;
                    if (itemsCount > 0) {
                        
                        $('#' + timestamp + ' .strategyItem').click( function() {
                            var strategyId = $(this).prop('id');
                            helper.showStrategyDetail(cmp, strategyId);
                        });
                    }
                }
            }
            check(cmp, helper);
        }
        
    },
    onAddStrategyButtonClicked : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
    	helper.showAddStrategyComponent(planId);
    }
})