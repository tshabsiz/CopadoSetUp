({
    prevClass: ""
	,highlightMenu: function(component, menuEntry) {
		var menu = component.find("menu");
        $A.util.removeClass(menu, this.prevClass);
        $A.util.addClass(menu, menuEntry);
        this.prevClass = menuEntry;
	}
})