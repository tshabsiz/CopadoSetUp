({
	onMenuClicked : function(cmp) {
		var toShow = cmp.find("headerDropdownMenu");
        $A.util.toggleClass(toShow, "toggle");
	}
})