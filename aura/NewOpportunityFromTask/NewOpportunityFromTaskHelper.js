({
	createToastEvent: function(title, message) {
   	  var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
      	"title": title,
        "message": message
      });
      $A.get("e.force:closeQuickAction").fire();
      toastEvent.fire();
   	}
})