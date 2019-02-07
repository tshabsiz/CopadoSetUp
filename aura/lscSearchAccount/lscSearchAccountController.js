({
    doInit  : function(component, event, helper) {
        
        component.set('v.relationships', {Name:'--None--'});
        
        if(component.get('v.HasAccount')==true)
        {
            if(component.get('v.UserID') == undefined || component.get('v.UserID') == null || component.get('v.UserID') == '')
                return;
            
            component.set('v.found', true);
            component.set('v.searchText',component.get('v.UserID'));
            
            return;
        }
    },
    
    toggleVisibility : function(component, event, helper) {
       //document.getElementById("relationshipList").innerHTML = "";
    },
    getSelectedAccount  : function(component, event, helper) {
        
        
        component.set('v.found', true);
        //console.log(event.target.id)
        component.set('v.SelectedAccount', event.target.id);
        component.set('v.UserName', event.target.innerHTML);
        component.set('v.searchText', event.target.innerHTML);
        document.getElementById("relationshipList").innerHTML = "";
        document.getElementById("relationshipList").style.display = "none";        
        return;
    },
    
    filterFunction : function(component, event, helper) {
        
        if(component.get('v.found')==true)
        {
            component.set('v.found', false);
            return;
        }
        helper.getSearchResults(component,event)
        return;/*
        var timer = component.get('v.timer');
        clearTimeout(timer);
        
        var timer = setTimeout(function(){
            var newlst = [];
            helper.getSearchResults(component,event)
            clearTimeout(timer);
            component.set('v.timer', null);
        }, 300);
        
        component.set('v.timer', timer);
        */
    },
    
    
})