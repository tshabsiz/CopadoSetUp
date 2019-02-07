({
    doInit : function(component, event, helper){
    	window.loadPasteImageReader() ;
    },
	attFile : function(component, event, helper){
        
        helper.showSpinner(component);
        
        var btn = component.find('btn');
		var fname = component.find('fname'); 
        var dataURL = window.dataURL;
        var $caseId = component.get("v.recordId")        
        btn.set("v.disabled",true);
        
        //validation        
        if(dataURL == null || dataURL == 'undefine' || dataURL == ''){
            
            alert('Please press ctr+v after you have cliked on the drop zone. The system do not know what you want to save as an attachment');
                        
            if(btn.get("v.disabled")){
                  btn.set("v.disabled",false);
            }            
            helper.hideSpinner(component);  
        }else if(fname == null || fname.get('v.value') == '' || 
                 fname.get('v.value') == null || fname.get('v.value').trim().length == 0){
            //$A.util.addClass(fname, 'border-red');
            
            alert('Please enter filename.');                        
            if(btn.get("v.disabled")){
                  btn.set("v.disabled",false);
            }
            helper.hideSpinner(component);  
        }else{
            
            var base64File = dataURL; 
            var userFileName =  fname.get('v.value');
            
            var action = component.get("c.getClipBoardImage");
            action.setParams({ "base64File" : base64File, "caseID" : $caseId, "fileName" : userFileName});
          
            action.setCallback(this, function(response) {
                
                var state = response.getState();				
                console.log('state : ', state);
                
                if (state === "SUCCESS") {
                    
					var result = response.getReturnValue();                    
					console.log('result : ', result);
                    
					$("#preview").css('background-image', 'none');
					$("#preview").css("box-shadow", "none");
					fname.set("v.value","");
					window.dataURL = '';
                    
                    if(btn.get("v.disabled")){
                          btn.set("v.disabled",false);
                    }
                    
                    helper.hideSpinner(component); 
					
					if(result.success){
						helper.showToast(component, event, 'success', 'Attachments has been created successfully');
					}else{
						helper.showToast(component, event, 'error', result.message);
					}
					
                    //helper.closeFocusedTab(component);                
                    $A.get("e.force:refreshView").fire();
                    
                }else if (state === "INCOMPLETE") {
                    
                    alert('There was an error uploading your image');
                    $("#preview").css('background-image', 'none');
                    $("#preview").css("box-shadow", "none");
                    fname.set("v.value","");        
                    if(btn.get("v.disabled")){
                          btn.set("v.disabled",false);
                    }
                    helper.hideSpinner(component);
                    window.dataURL = '';
                    fname.set("v.value","");
                    
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert('There was an error uploading your image');						
                        }
                    }else{
                        console.log("Unknown error");
                    }
                    
                    $("#preview").css('background-image', 'none');
                    $("#preview").css("box-shadow", "none");
                    fname.set("v.value","");        
                    if(btn.get("v.disabled")){
                          btn.set("v.disabled",false);
                    }
                    helper.hideSpinner(component);
                    window.dataURL = '';
                    cosole.log('dataURL ', dataURL);
                    fname.set("v.value","");
                }
            
            });		  
    
            $A.enqueueAction(action);
        }
    }	      
})