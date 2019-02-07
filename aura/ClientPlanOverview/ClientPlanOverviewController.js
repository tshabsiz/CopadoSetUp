({
	doInit : function(cmp, event, helper) {
        
        cmp.set("v.showPlaceholder", false);
        cmp.set("v.uploadImage", false);
        helper.getClientPlan(cmp, event, helper);
        helper.getClientScores(cmp, event, helper);
        
        cmp.set("v.organogramScale", 1.0);
        
    },
    afterScriptsLoaded : function(cmp, event, helper) {
        helper.onBeforePrepareOrganogram(cmp, event, helper);
        cmp.set("v.oldX", 0);
        cmp.set("v.oldY", 0);
    },
    onAfterRendering : function(cmp, event, helper) {
        helper.fixNewLinesInScores();
    },
    stopPropagation : function(cmp, event, helper) {
        event.stopPropagation();  
    },
    onClientOverviewLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("clientOverview");
        $A.util.toggleClass(toShow, "toggle");
        
        toShow = cmp.find("clientOverviewMenu");
        $A.util.toggleClass(toShow, "toggle");
    },
    onCompanyOrganogramLabelClicked : function(cmp, event, helper) {
        var toShow = cmp.find("companyOrganogram");
        $A.util.toggleClass(toShow, "toggle");
    },
    onEditSectorRTClicked : function(cmp, event, helper) {
        helper.showEditClientOverviewComponent(cmp, true);
    },
    onEditClientRTClicked : function(cmp, event, helper) {
    	helper.showEditClientOverviewComponent(cmp, false);
	},
    onAddStrengthClicked : function(cmp, event, helper) {
    	helper.showAddClientScoreComponent(cmp, helper.strength);
    },
    onAddWeaknessClicked : function(cmp, event, helper) {
        helper.showAddClientScoreComponent(cmp, helper.weakness);
    },
    onAddOpportunityClicked : function(cmp, event, helper) {
        helper.showAddClientScoreComponent(cmp, helper.opportunity);
    },
    onAddThreatClicked : function(cmp, event, helper) {
        helper.showAddClientScoreComponent(cmp, helper.threat);
    },
    onEditStrengthClicked : function(cmp, event, helper) {
        var scoreId = event.srcElement.id;
        helper.onEditScoreClicked(cmp, scoreId, helper.strength);
    },
    onEditWeaknessClicked : function(cmp, event, helper) {
        var scoreId = event.srcElement.id;
        helper.onEditScoreClicked(cmp, scoreId, helper.weakness);
    },
    onEditOpportunityClicked : function(cmp, event, helper) {
        var scoreId = event.srcElement.id;
        helper.onEditScoreClicked(cmp, scoreId, helper.opportunity);
    },
    onEditThreatClicked : function(cmp, event, helper) {
        var scoreId = event.srcElement.id;
        helper.onEditScoreClicked(cmp, scoreId, helper.threat);
    },
    onRemoveScoreClicked : function(cmp, event, helper) {
        var scoreId = event.srcElement.id;
        helper.onRemoveScoreClicked(cmp, scoreId);
    },
    moveDiagramUp : function(cmp, event, helper) {
        console.log(event);
        var top = cmp.get("v.oldY");
        top = top - 40;
        cmp.set("v.oldY", top);
        
        $('.placeholder').each( function() {
            $(this).css('top', top);
        });
    },
    moveDiagramDown : function(cmp, event, helper) {
        var top = cmp.get("v.oldY");
        top = top + 40;
        cmp.set("v.oldY", top);
        
        $('.placeholder').each( function() {
            $(this).css('top', top);
        });
    },
    moveDiagramLeft : function(cmp, event, helper) {
        var left = cmp.get("v.oldX");
        left = left - 40;
        cmp.set("v.oldX", left);
        
        $('.placeholder').each( function() {
            $(this).css('left', left);
        });
    },
    moveDiagramRight : function(cmp, event, helper) {
    	var left = cmp.get("v.oldX");
        left = left + 40;
        cmp.set("v.oldX", left);
        
        $('.placeholder').each( function() {
            $(this).css('left', left);
        });
    },
    zoomIn : function(cmp, event, helper) {
        var scale = cmp.get('v.organogramScale');
        scale += 0.1;
        cmp.set('v.organogramScale', scale);
        
        var scaleString = 'scale(' + scale + ',' + scale + ')';
        $('.placeholder').each( function() {
            $(this).css('transform', scaleString);
        });
    },
    zoomOut : function(cmp, event, helper) {
        var scale = cmp.get('v.organogramScale');
        scale -= 0.1;
        cmp.set('v.organogramScale', scale);
        
        var scaleString = 'scale(' + scale + ',' + scale + ')';
        $('.placeholder').each( function() {
            $(this).css('transform', scaleString);
        });
    },
    update : function (cmp, event, helper) {
        $('#diagram').remove();
    },
    onBeforeDeleteImage : function(cmp, event, helper) {
        var imageId = cmp.get("v.imageId");
        helper.onBeforeDeleteImage(imageId, cmp);
    },
    onBeforeCreateHierarchy : function(cmp, event, helper) {
        var planId = cmp.get("v.planId");
        helper.onBeforeCreateHierarchy(planId);
    },
    showImageUpload : function(cmp, event, helper) {
        cmp.set("v.uploadImage", true);
    },
    onBeforeUploadImage : function(cmp, event, helper) {
        helper.onBeforeUploadImage(cmp);
    }
})