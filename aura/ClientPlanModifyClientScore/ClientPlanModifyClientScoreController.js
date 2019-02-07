({
	onAfterRendering : function(cmp, event, helper) {
        helper.prepareScoreAreaBullets(cmp);
	},
    moveBack : function(cmp, event, helper) {
        var id = cmp.get("v.planId");
        helper.moveBack(id);
    },
    onBeforeModifyScore : function(cmp, event, helper) {
        var uniqueKey = cmp.get("v.uniqueKey");
        var name = $('#nameInput' + '.' + uniqueKey).val().trim();
        var proceed = helper.hasContent(name);
        
        if (proceed) {
            var description = $('.area' + uniqueKey).val();
            var isEdit = cmp.get("v.isEdit");
            
            if (isEdit) {
                var scoreId = cmp.get("v.scoreId");
                helper.editScore(scoreId, name, description, cmp);
            } else {
            	helper.addScore(name, description, cmp);    
            }
            
        } else {
            $('#nameElem').addClass('slds-has-error');
            $('#nameError').show();
        }
    }
})