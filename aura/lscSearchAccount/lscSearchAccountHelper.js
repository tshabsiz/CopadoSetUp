({
	helperMethod : function(component, event, helper) {
         document.getElementById("relationshipList").style.display = "none";
        component.set('v.searchText', 'value selected');
	}, 
    
    getSearchResults : function(component, event, helper) {
                 var input;
            input = component.find('searchText').get('v.value');
        
        
        
        if(input.length == 0 || input.length == 1){
             component.set('v.SelectedAccount','');
            document.getElementById("relationshipList").style.display = "none"; 
            return;
        }
       
   
        if(input == ''){
            component.set('v.SelectedAccount','');
           document.getElementById("relationshipList").style.display = "block";
           document.getElementById("relationshipList").innerHTML = "";
            return;
        }
        var action = component.get("c.searchUser");
         action.setParams({
             searchKeyWord: input,
             isUserSearch: component.get('v.isUserSearch') 
    });

          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 
            
             var result = JSON.parse(response.getReturnValue());               
               
                document.getElementById("relationshipList").style.display = "block";
                document.getElementById("relationshipList").innerHTML = "";
                var relationships = [];
                result.forEach(function(element) {
                    relationships.push({Name: element.Name});
                    var node = document.createElement("a");
                    node.setAttribute("id", element.Id);
                    var textnode = document.createTextNode(element.Name); 
                    node.appendChild(textnode);
                    document.getElementById("relationshipList").appendChild(node);
                });
               component.set('v.relationships', {Name:'--None--'});
                component.set('v.relationships', relationships);
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                // do something
              console.log(state);
                console.log(response.getReturnValue());
            }
            else if (state === "ERROR") {
                helper.hideSpinner(component, event, helper);
              var errors = response.getError();
              if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
	}, 
})