({
	doInit : function(cmp, event, helper) {
        helper.getBudgetRevenues(cmp);
        helper.getPotOptys(cmp);
        helper.getOptys(cmp);
    },
    stopPropagation : function(cmp, event, helper) {
    	event.stopPropagation();  
    },
    onProductionListLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("productionList");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("productionListMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onPotOptysLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("potOptys");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("potOptysMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onOptysLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("optys");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("optysMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onAddBRClicked : function(cmp, event, helper) {
        event.stopPropagation();
        helper.showAddBRComponent(cmp);
    },
    onAddPotOptyClicked : function(cmp, event, helper) {
         helper.showAddPotOptyComponent(cmp);
    },
    onAddOptyClicked : function(cmp, event, helper) {
        helper.showAddOptyComponent(cmp);
    },
    onEditBRClicked : function(cmp, event, helper) {
        event.stopPropagation();
        var id = $(event.target).closest('.item').prop('id');
        helper.showEditBRComponent(cmp, id);
    },
    onRemoveBRClicked : function(cmp, event, helper) {
    	var id = $(event.target).closest('.item').prop('id');
        helper.removeBR(cmp, id);
    },
    onEditPotOptyClicked : function(cmp, event, helper) {
        var optyId = $(event.target).closest('.item').prop('id');
        helper.showEditPotOptyComponent(cmp, optyId);
    },
    onBRClicked : function(cmp, event, helper) {
     	var elem = $(event.target).closest('.item').find('.brBody');
        
        if ($(elem).hasClass('toggle')) {
            $(elem).removeClass('toggle');
        } else {
            $(elem).addClass('toggle');
        }
    },
    onPotOptyClicked : function(cmp, event, helper) {
        var elem = $(event.target).closest('.item').find('.potOptyBody');
        
        if ($(elem).hasClass('toggle')) {
            $(elem).removeClass('toggle');
        } else {
            $(elem).addClass('toggle');
        }
    },
    onOptyClicked : function(cmp, event, helper) {
        var elem = $(event.target).closest('.item').find('.optyBody');
        
        if ($(elem).hasClass('toggle')) {
            $(elem).removeClass('toggle');
        } else {
            $(elem).addClass('toggle');
        }
    }
})