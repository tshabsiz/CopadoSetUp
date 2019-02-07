({
	onCustomSelectClicked : function (cmp, event, helper) {
        var toShow = cmp.find("customSelectOptions");
        $A.util.toggleClass(toShow, "toggle");
    },
    onOptionClicked : function (cmp, event, helper) {
        var target = $(event.target);
     	var value = $(target).text();
        $(target).closest('.customSelectWrapper').find('#customSelectValue').text(value);
        
        var evt = cmp.getEvent("SelectLightningEvent");
        evt.setParams({
            "value": value
        });
        evt.fire();  
    }
})