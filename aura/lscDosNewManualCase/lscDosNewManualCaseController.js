({
    doInit  : function(component, event, helper) {
        
        var tabId =  component.get("v.tabId");
        helper.closeThisTab(component, event, tabId);
        helper.showSpinner(component, event, helper);
        var action = component.get("c.GetAccount");
        action.setParams({
            model : '',
            recordId: '',
            recordType: 'digitalOps'
        });
        
        action.setCallback(this, function(response) {
            helper.setFocusedTabLabel(component, 'Digital Ops Cases');
            var state = response.getState();
            
            if (state === "SUCCESS") {   
                
                if(component.get('v.recordEditFormLoaded') === true){
                    helper.hideSpinner(component, event, helper);
                }
                var model = JSON.parse(response.getReturnValue());
                console.log(model);
                var recordTypeId  = model.theCase_r.RecordTypeId;
                component.set('v.recordTypeId', recordTypeId)
                
           
                    component.set('v.isUserSearch', true);
                    component.set('v.OwnerId', model.theCase_r.OwnerId)
            
                
                component.set("v.model", model);
                component.set("v.accountOptions", model.accountOptions_r);
                
            }else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "INCOMPLETE!",
                    "message": response.getReturnValue(),
                    "type":"error"
                });
                
                toastEvent.fire();
                
            }else if (state === "ERROR") {
                
                helper.hideSpinner(component, event, helper);
                
                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": errors[0].message,
                            "type":"error"
                        });
                        
                        toastEvent.fire();
                        
                    }else{
                        
                        var toastEvent = $A.get("e.force:showToast");
                        
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": 'An error ocured',
                            "type":"error"
                        });
                        
                        toastEvent.fire();
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Unknown error",
                        "type":"error"
                    });
                    
                    toastEvent.fire();
                }
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    filterFunction : function(component, event, helper) {
        helper.getSearchResults(component,event)
    },
    
    caseOwnerTypeChanged: function(component, event, helper) {
        var SearchUserBy = component.find("SearchUserBy").get("v.value");
        component.set('v.isUserSearch', SearchUserBy == 'User');
    },
    
    handleAccountLoaded : function (component, event, helper) {
        component.set('v.recordEditFormLoaded', true);
        var status = component.find("Status").get("v.value");
        if(status.includes('Closed')){
            component.set('v.includesClosed', true);
        }
        
        helper.hideSpinner(component, event, helper);
    },
    
    addAccount : function(component, event, helper) {
        
        helper.showSpinner(component, event, helper);
        
        var action = component.get("c.accountSelection");
        
        
        
        console.log(component.get("v.model.accountOptions_r"));
        var Id = component.find("relationships").get("v.value");
        component.set("v.model.qValue_r", '');
        component.set("v.model.relCIF_r", '');
        component.set("v.model.relName_r", '');
        component.set("v.model.relID_r",Id);
        console.log(component.get("v.model"));
        
        action.setParams({
            model : JSON.stringify(component.get("v.model"))
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(state);
            console.log(JSON.parse(response.getReturnValue()));
            
            if (state === "SUCCESS") {
                helper.hideSpinner(component, event, helper);
                
                component.set("v.model", JSON.parse(response.getReturnValue()));
                console.log(component.get("v.model"));
                
               if(component.get("v.model.ResponseMessage_r").length > 0){
                    //alert(component.get("v.model.ResponseMessage_r"))
                    //helper.addShadow(component, event,'relationships');
                    var toastEvent = $A.get("e.force:showToast");
                    
                    toastEvent.setParams({                       
                        "title": "Warning!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        "type":"warning"
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "INCOMPLETE!",
                    "message": response.getReturnValue(),
                    "type":"error"
                });
                
                toastEvent.fire();
                
            }
                else if (state === "ERROR") {
                    helper.hideSpinner(component, event, helper);
                    console.log(state);
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": errors[0].message,
                                "type":"error"
                            });
                            
                            toastEvent.fire();
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": 'An error ocured',
                                "type":"error"
                            });
                            
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Unknown error",
                            "type":"error"
                        });
                        
                        toastEvent.fire();
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    
    viewCifDetails: function(component, event, helper) {
        helper.viewCifDetails(component, event);
    } ,
    
    searchSF: function(component, event, helper) {        
       
        helper.searchSF(component, event,helper);        
            
    },
    
    keyCheck : function(component, event, helper) {
        if(event.which == 13){
            helper.searchSF(component, event,helper);        
            
        }
    },    
    
    newCase : function (component, event, helper) {
        
        var ValidationList = '';
        var formInvalid = false;
        
        var relationshipID;
        var colleague = component.find("Colleague__c").get("v.value");
        
        if(!colleague){
            relationshipID = component.find("relationships").get("v.value");
            if(relationshipID === null || relationshipID === '' || relationshipID ==='None'){
                
                helper.addShadow(component, event,'relationships');
                try{
                    var toastEvent = $A.get("e.force:showToast");
                    
                    toastEvent.setParams({
                        "title": "Missing Relationship!",
                        "message": "Please link a Relationship to this record first",
                        "type":"warning"
                    });
                    formInvalid = true;
                    toastEvent.fire();
                    return;
                }catch(exception){
                    alert('Please link a Relationship to this record first');
                    formInvalid = true;
                }
            }
            else{
                helper.removeShadow(component, event,'relationships');
            }
        }  else{
            helper.removeShadow(component, event,'relationships');
        }
        
        
        var emailSenderName = component.find("Email_Sender_Name__c").get("v.value");
        if(emailSenderName === null || emailSenderName === ''||emailSenderName.length > 255 ){             
            helper.addShadow(component, event,'Email_Sender_Name__c');
            formInvalid = true;
            ValidationList += '*Case Contact Name. \n';
        }else{
            helper.removeShadow(component, event,'Email_Sender_Name__c');
        }
        
        
        
        /*var emailFromAddress = component.find("Email_From_Address__c").get("v.value");        
        if(emailFromAddress === null || emailFromAddress === ''){
            helper.addShadow(component, event,'Email_From_Address__c');
            formInvalid = true;
            ValidationList += '*Case Contact Email. \n';
        }else{
            helper.removeShadow(component, event,'Email_From_Address__c');
        }*/
        
        var status = component.find("Status").get("v.value");
        if(status === null || status === '' || status === '--None--'){           
            helper.addShadow(component, event,'Status');
            formInvalid = true;
            ValidationList += '*Status. \n';
        }else{
            helper.removeShadow(component, event,'Status');
        }
        
        var userType = component.find("User_Type__c").get("v.value");
        var iDVComplete = component.find("ID_V_Complete__c").get("v.value");
        var novoFXReference = component.find("NovoFX_Reference__c").get("v.value");
        var bAPSReference = component.find("BAPS_Reference__c").get("v.value");
        var iDV = component.find("ID_V__c").get("v.value");
        
        
        
        var queue = component.find("Queue__c").get("v.value");
        if(queue === null || queue === '' || queue === '--None--'){            
            helper.addShadow(component, event,'Queue__c');
            formInvalid = true;
            ValidationList += '*Full Team. \n';
        }else{
            helper.removeShadow(component, event,'Queue__c');
        }
        
        var serviceType = component.find("Service_Type__c").get("v.value");
        var serviceCategory, serviceSubCategory;
        if(serviceType === null || serviceType === '' || serviceType === '--None--'){            
            helper.addShadow(component, event,'Service_Type__c');
            formInvalid = true;
            ValidationList += '*Service Type. \n';
        }else{
            helper.removeShadow(component, event,'Service_Type__c');
            
            serviceSubCategory = component.find("Service_Sub_Category__c").get("v.value");
            if(serviceSubCategory === null || serviceSubCategory === '' || serviceSubCategory === '--None--'){            
                helper.addShadow(component, event,'Service_Sub_Category__c');
                formInvalid = true;                 
                ValidationList += '*Service Sub-Category. \n';
            }else{
                helper.removeShadow(component, event,'Service_Sub_Category__c');                
                serviceCategory = component.find("Service_Category__c").get("v.value");
                
                if(serviceCategory === null || serviceCategory === '' || serviceCategory === '--None--'){            
                    helper.addShadow(component, event,'Service_Category__c');
                    formInvalid = true;
                    ValidationList += '*Service Category. \n';
                }else{
                    helper.removeShadow(component, event,'Service_Category__c');
                    
                }
            }
        }
        var responsibleDepartment = component.find("Responsible_Department__c").get("v.value");
        if(responsibleDepartment === null || responsibleDepartment === '' || responsibleDepartment === '--None--'){            
            helper.addShadow(component, event,'Responsible_Department__c');
            formInvalid = true;
            ValidationList += '*Responsible Department. \n';
        }else{
            helper.removeShadow(component, event,'Responsible_Department__c');
        }
        
        var subject = component.find("Subject").get("v.value");        
        if(subject === '' || subject === null ||subject.length > 255){
            helper.addShadow(component, event,'Subject');
            formInvalid = true;
            ValidationList += '*Subject. \n';
        }else{
            helper.removeShadow(component, event,'Subject');
        }
        
        var channel = component.find("Channel__c").get("v.value");        
        if(channel === null || channel === '' || channel === '--None--'){
            channel = null;
        }
        
        var businessHours = component.find("Business_Hours__c").get("v.value");        
        
        var team = component.find("Team__c").get("v.value");        
        if(team === null || team === '' || team === '--None--'){
            helper.addShadow(component, event,'Team__c');
            formInvalid = true;
            ValidationList += '*Team. \n';
        }else{
            helper.removeShadow(component, event,'Team__c');
        }
        
        var teamManager = component.find("Team_Manager__c").get("v.value");        
        if(teamManager === null || teamManager === '' || teamManager === '--None--'){
            helper.addShadow(component, event,'Team_Manager__c');
            formInvalid = true;
            ValidationList += '*Team Manager. \n';
        }else{
            helper.removeShadow(component, event,'Team_Manager__c');
        }
        
        var department = component.find("Department__c").get("v.value");        
        if(department === null || department === '' || department === '--None--'){
            helper.addShadow(component, event,'Department__c');
            formInvalid = true;
            ValidationList += '*Department. \n';
        }else{
            helper.removeShadow(component, event,'Department__c');
        }
        
        var fullDepartment = component.find("Full_Department__c").get("v.value");        
        if(fullDepartment === null || fullDepartment === '' || fullDepartment === '--None--'){
            helper.addShadow(component, event,'Full_Department__c');
            formInvalid = true;
            ValidationList += '*Full Department. \n';
        }else{
            helper.removeShadow(component, event,'Full_Department__c');
        }
        
        
        var origin = component.find("Origin__c").get("v.value");
        if(emailSenderName === null || emailSenderName === ''||emailSenderName.length === 0 ){
            if(origin !== 'Phone' && origin !== 'Telephone' && origin !== 'Swift'){
               ValidationList += '*You must enter a valid email address when the Case Origin selected is NOT Phone or Swift. \n';
                
                helper.addShadow(component, event,'Origin__c');
            }else{
                helper.removeShadow(component, event,'Origin__c');
            }
        }
        
        var emailFromAddress = component.find("Email_From_Address__c").get("v.value"); 
        if(origin !== '--None--' && origin !== '' && origin !== 'Phone' && origin !== 'Telephone' && origin !== 'Swift'){            
            if(emailFromAddress === null || emailFromAddress === ''){
                helper.addShadow(component, event,'Email_From_Address__c');
                formInvalid = true;
                ValidationList += '*Case Contact Email. \n';
            }
            
            ValidationList += '*You must enter a valid email address when the Case Origin selected is NOT Phone or Swift. \n';
            formInvalid = true;
            
        }else{
            helper.removeShadow(component, event,'Origin__c');
            helper.removeShadow(component, event,'Email_From_Address__c');
        }
        
         if(origin === null || origin === '' || origin === '--None--'){
            helper.addShadow(component, event,'Origin__c');
            formInvalid = true;
            ValidationList += '*Origin. \n';
        }else{
            helper.removeShadow(component, event,'Origin__c');
        }
        
        
        var caseOwner = component.get('v.OwnerId')
        if(caseOwner === null || caseOwner === ''||caseOwner.length === 0 ){
            formInvalid = true;
            ValidationList += '*Please add a case owner. \n';
        }
        
        var accountId = relationshipID;        
        var description = component.find("Description").get("v.value"); 
        
        var priority = component.find("Priority").get("v.value");
        
        if(formInvalid === true){
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "title": "Missing Required Information!",
                "message": "\n Please Fill In The Required Fields \n\n"+ValidationList,
                "type":"warning"
            });
            formInvalid = true;
            toastEvent.fire();
            
            return;
        }
        
        scrollTo('Top',0,0);
        helper.showSpinner(component, event, helper);
        
        
        var action = component.get("c.newDigitalOpsCase");
        
        
        var newDigitalOpsCaseModel = {
            'accountId':accountId,
            'id': component.get("v.recordId"),
            'colleague':colleague,
            'emailSenderName':emailSenderName,
            'emailFromAddress':emailFromAddress,
            'status':status,
            'userType':userType,
            'iDVComplete':iDVComplete,
            'iDV':iDV,
            'novoFXReference':novoFXReference,
            'bAPSReference':bAPSReference,
            'queue':queue,
            'subject':subject,
            'description':description,
            'priority':priority,
            'department':department,
            'fullDepartment':fullDepartment,
            'teamManager':teamManager,
            'businessHours':businessHours,
            'team':team,
            'origin':origin,
            'serviceCategory':serviceCategory,
            'serviceSubCategory':serviceSubCategory,
            'serviceType':serviceType,
            'channel':channel,
            'recordTypeId':component.get("v.recordTypeId"), 
            'OwnerId':component.get("v.OwnerId"),
            'relationshipID':relationshipID
        };
        
        
        action.setParams({
            newDigitalOpsCaseModel :JSON.stringify(newDigitalOpsCaseModel) 
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                helper.hideSpinner(component, event, helper);
                
                var model = JSON.parse(response.getReturnValue());
                console.log(model);
                component.set("v.model", model); 
                
                if(component.get("v.model.ResponseMessage_r") != null &&component.get("v.model.ResponseMessage_r").length > 0 &&
                   component.get("v.model.ResponseMessage_r").startsWith("ERROR:")){                    
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "ERROR!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    });
                    
                }else if(component.get("v.model.ResponseMessage_r") != null &&component.get("v.model.ResponseMessage_r").length > 0){                    
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "ERROR!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    });
                    
                }else{
                    
                    var toastEventOk = $A.get("e.force:showToast");
                    
                    toastEventOk.setParams({
                        "title": "Success!",
                        "message": "Case Created",
                        "type":"success"
                    });
                    
                    toastEventOk.fire();
                    
                    if(component.get("v.model.theCase_r.Id.Service_Type__c") !== 'Log Complaint')
                    {
                        //helper.closeFocusedTab(component, event, helper);
                        //helper.navigateToDetailPage(component, event, component.get("v.model.theCase_r.Id"));
                        //helper.editRecord(component, event, component.get("v.model.theCase_r.Id"));      
                        helper.openCaseRecordType(component, event, component.get("v.model.theCase_r.Id"));
                    }
                    else{
                        // helper.closeFocusedTab(component, event, helper);
                        helper.openComplainCases(component, event, component.get("v.model.theCase_r.Id"));
                    }
                    
                }
                
            }else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);               
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "INCOMPLETE",
                    "message": response.getReturnValue(),
                    closeCallback: function() {
                        //alert('You closed the alert!');
                    }
                });
                
            }else if (state === "ERROR") {
                helper.hideSpinner(component, event, helper);
                console.log(state);
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error!",
                            "message": errors[0].message,
                            closeCallback: function() {
                            }
                        });
                        
                    }else{
                        
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error!",
                            "message": "An error ocured",
                            closeCallback: function() {
                            }
                        });
                    }
                } else {                       
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error!",
                        "message": "Unknown error",
                        closeCallback: function() {
                        }
                    });
                }
            }
        });
        
        $A.enqueueAction(action);
        
        
    },
})