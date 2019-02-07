({
	doInit : function(cmp, event, helper) {
		helper.getClientPlan(cmp);
        helper.getClientFinancials(cmp);
        helper.getFacilitiesAndSecurity(cmp);
	},
    stopPropagation : function(cmp, event, helper) {
    	event.stopPropagation();  
    },
    onClientRatingLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("clientRating");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("clientRatingMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onClientFinancialsLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("clientFinancials");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("clientFinancialsMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onFacilitiesLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("facilities");
        $A.util.toggleClass(toShow, "toggle");
    },
    onFinancialsClicked : function(cmp, event, helper) {
     	var elem = $(event.target).closest('.item').find('.financialsBody');
        
        if ($(elem).hasClass('toggle')) {
            $(elem).removeClass('toggle');
        } else {
            $(elem).addClass('toggle');
        }
    },
    onEditClientRatingClicked : function(cmp, event, helper) {
      	helper.showEditClientRatingComponent(cmp);  
    },
    onFacilityClicked : function(cmp, event, helper) {
        var elem = $(event.target).closest('.item').find('.facilityBody');
        
        if ($(elem).hasClass('toggle')) {
            $(elem).removeClass('toggle');
        } else {
            $(elem).addClass('toggle');
        }
    },
    onAddAbsaFacilityClicked : function(cmp, event, helper) {
        helper.showModifyAbsaFacilityComponent(cmp, null, true);
    },
    onEditAbsaFacilityClicked : function(cmp, event, helper) {
        var facilityId = $(event.target).closest('.item').prop('id');
        helper.showModifyAbsaFacilityComponent(cmp, facilityId, true);
    },
    onAddOtherFacilityClicked : function(cmp, event, helper) {
        helper.showModifyAbsaFacilityComponent(cmp, null, false);
    },
    onEditOtherFacilityClicked : function(cmp, event, helper) {
        var facilityId = $(event.target).closest('.item').prop('id');
        helper.showModifyAbsaFacilityComponent(cmp, facilityId, false);
    },
    onAddSecurityClicked : function(cmp, event, helper) {
        helper.showModifySecurityComponent(cmp, null);
    },
    onEditSecurityClicked : function(cmp, event, helper) {
        var securityId = $(event.target).closest('.item').prop('id');
        helper.showModifySecurityComponent(cmp, securityId);
    },
    onAddFinancialsClicked : function(cmp, event, helper) {
      	helper.showModifyFinancialsComponent(cmp, null);
    },
    onEditFinancialsClicked : function(cmp, event, helper) {
     	var financialsId = $(event.target).closest('.item').prop('id');
        helper.showModifyFinancialsComponent(cmp, financialsId);
    },
    onRemoveFinancialsClicked : function(cmp, event, helper) {
        var financialsId = $(event.target).closest('.item').prop('id');
        helper.removeFinancials(cmp, financialsId);
    }
})