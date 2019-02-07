({
    doInit  : function(component, event, helper) {
        
        var tabId =  component.get("v.tabId");
        if(tabId !== null && tabId !== '') 
            helper.closeThisTab(component, event, tabId);
            
        helper.showSpinner(component, event, helper);
        
        var recordId  = component.get("v.recordId");
     
        if(recordId == null || recordId == ''){
            recordId = '';
        }

        if(recordId !== null && recordId !== ''&& !recordId.startsWith('500')){
          
            component.set("v.callReportId", recordId);
            //recordId = null;
            //component.set("v.recordId", recordId);
        }        
        
    
        var action = component.get("c.GetAccount");
        action.setParams({
            model : '',
            recordId: recordId,
            recordType: 'Complaint'
        });
        
       
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
             
                if(recordId !== null && recordId !== ''&& !recordId.startsWith('500')){
                    
                    component.set("v.callReportId", recordId);
                    recordId = null;
                    component.set("v.recordId", recordId);
                }      
                
                 helper.setFocusedTabLabel(component, 'Complains Case');
                
                helper.hideSpinner(component, event, helper);
                if(component.get('v.recordEditFormLoaded') == true){
                    helper.hideSpinner(component, event, helper);
                }
                var model = JSON.parse(response.getReturnValue());
                
                var recordTypeId  = model.theCase_r.RecordTypeId;
                component.set('v.recordTypeId', recordTypeId)
                
                if(model.theCase_r.Owner == null){
                    
                    if(model.caseOwnerName_r != null && model.caseOwnerName_r.caseOwnerName_r != ''){
                        component.set('v.OwnerId', model.theCase_r.OwnerId)
                       
                    }
                    
                    component.set('v.isUserSearch', true);
                }else{
                    component.set('v.isUserSearch', model.theCase_r.Owner.Type == 'User');
                    component.set('v.OwnerId', model.theCase_r.OwnerId)
                }
                 component.set("v.model", model);
                component.set("v.accountOptions", model.accountOptions_r);
                console.log(model)
                
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
    
    
    
    searchSF: function(component, event, helper) {
        helper.searchSF(component, event,helper);        
    },
    
    caseOwnerTypeChanged: function(component, event, helper) {
        var SearchUserBy = component.find("SearchUserBy").get("v.value");
        component.set('v.isUserSearch', SearchUserBy == 'User');
    },
    
    addAccount : function(component, event, helper) {
      
        helper.showSpinner(component, event, helper);
        
        var action = component.get("c.accountSelection");
        
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
    
    statusChanged: function (component, event, helper) {
        var status = component.find("Status").get("v.value");
        
        if(status.includes('Closed')){
            component.addEventHandler("aura:waiting", component.getReference("c.showSpinner"));
            component.addEventHandler("aura:doneWaiting", component.getReference("c.hideSpinner"));
            component.set('v.includesClosed', true);
        }else{
            component.removeEventHandler("aura:waiting", component.getReference("c.showSpinner"));
            component.removeEventHandler("aura:doneWaiting", component.getReference("c.hideSpinner"));
            component.set('v.includesClosed', false);
        }
    },
    
    OpportunityNameRequired : function (component, event, helper) {
        
        if(component.get('v.recordEditFormLoaded') == 'false'){
            return;
        }
        var element = component.find("Opportunity_Name__c").get("v.value");
        
        if((element == null || element === ''||element.length > 255)&& component.find("MNPI__c").get("v.value") === true){    
            helper.addShadow(component, event, 'Opportunity_Name__c')
        }else{
            helper.removeShadow(component, event, 'Opportunity_Name__c')
        }
        
    },
    
    keyCheck : function(component, event, helper) {
        if(event.which == 13){
            helper.searchSF(component, event,helper);        
            
        }
    },    
    
    handleAccountLoaded : function (component, event, helper) {
        component.set('v.recordEditFormLoaded', true);
        var status = component.find("Status").get("v.value");
        if(status.includes('Closed')){
            component.set('v.includesClosed', true);
        }
        
        helper.hideSpinner(component, event, helper);
    },
    
    viewCifDetails: function(component, event, helper) {
        helper.viewCifDetails(component, event);
    } ,
    
    showSpinner: function (component, event, helper) {
        helper.showSpinner(component, event, helper);
    },
    
    hideSpinner: function (component, event, helper) {
        helper.hideSpinner(component, event, helper);
    },
    
    newCase : function (component, event, helper) {

        var ValidationList = '';        
        var formInvalid = false;
        
        var suppressAcknowledgeAlert = component.find("Suppress_Acknowledge_Alert__c").get("v.value");
        
        var status = component.find("Status").get("v.value");
        
        
        
        var desiredAction, 
            actionTaken, 
            rootCause, 
            rootCauseCategory, 
            businessOwnerAction, 
            resolutionDetail, 
            resolvedInFavourOf;
        
        if(status.includes('Closed')){
            desiredAction = component.find("Desired_Action__c").get("v.value"); 
            actionTaken = component.find("Action_Taken__c").get("v.value");
            rootCause = component.find("Root_Cause__c").get("v.value");
            rootCauseCategory = component.find("Root_Cause_Category__c").get("v.value");
            businessOwnerAction = component.find("Business_Owner_Action__c").get("v.value");
            resolutionDetail = component.find("Resolution_Detail__c").get("v.value");
            resolvedInFavourOf = component.find("Resolved_In_Favour_Of__c").get("v.value");
            
            
            if(desiredAction === '--None--' || desiredAction === '' || desiredAction == null){
                helper.addShadow(component, event,'Desired_Action__c');                 
                formInvalid = true;
                ValidationList += '*Desired Action. \n';
            }else{
                helper.removeShadow(component, event,'Desired_Action__c');
            }        
            
            if(rootCauseCategory === '--None--' || rootCauseCategory === '' || rootCauseCategory == null){
                helper.addShadow(component, event,'Root_Cause_Category__c');
                formInvalid = true;
                ValidationList += '*Root Cause Category. \n';
            }else{
                helper.removeShadow(component, event,'Root_Cause_Category__c');
                
                
                if(rootCauseCategory != 'Unknown')
                    if(rootCause === '--None--' || rootCause === '' || rootCause == null){
                        //alert('Please select at least one rootcause')
                        //helper.addShadow(component, event,'Root_Cause__c'); 
                        formInvalid = true;
                        ValidationList += '*Please select at least one rootcause. \n'
                        
                    }else{
                        //helper.removeShadow(component, event,'Root_Cause__c');
                    }
                
            }
            
            
            
            if(actionTaken === '--None--' || actionTaken === '' || actionTaken == null){
                helper.addShadow(component, event,'Action_Taken__c');
                formInvalid = true;
                ValidationList += '*Action Taken. \n';
            }else{
                helper.removeShadow(component, event,'Action_Taken__c');
            }
            
            if(businessOwnerAction === '--None--' || businessOwnerAction === '' || businessOwnerAction == null){
                helper.addShadow(component, event,'Business_Owner_Action__c'); 
                formInvalid = true;
                ValidationList += '*Business Owner Action. \n';
            }else{
                helper.removeShadow(component, event,'Business_Owner_Action__c');
            }
            
            
            if(resolutionDetail === '--None--' || resolutionDetail === '' || resolutionDetail == null){
                helper.addShadow(component, event,'Resolution_Detail__c');
                formInvalid = true;
                ValidationList += '*Resolution Detail. \n';
            }else{
                helper.removeShadow(component, event,'Resolution_Detail__c');
            }
            if(resolvedInFavourOf === '--None--' || resolvedInFavourOf === '' || resolvedInFavourOf == null){
                helper.addShadow(component, event,'Resolved_In_Favour_Of__c');  
                formInvalid = true;
                ValidationList += '*Resolved In Favour Of. \n';
            }else{
                helper.removeShadow(component, event,'Resolved_In_Favour_Of__c');
            }
        }
        
        
      
        
        var relationshipID = component.find("relationships").get("v.value");
        
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
        
        var incidentDate = component.find("Incident_Date__c").get("v.value");
        if(incidentDate == null || incidentDate == ''){             
            helper.addShadow(component, event,'Incident_Date__c');
            formInvalid = true;
            ValidationList += '*Incident Date. \n';
        }else{
            helper.removeShadow(component, event,'Incident_Date__c');
        }
        
        var emailSenderName = component.find("Email_Sender_Name__c").get("v.value");
        if(emailSenderName == null || emailSenderName == ''||emailSenderName.length > 255 ){             
            helper.addShadow(component, event,'Email_Sender_Name__c');
            formInvalid = true;
            ValidationList += '*Case Contact Name. \n';
        }else{
            helper.removeShadow(component, event,'Email_Sender_Name__c');
        }
        
/*        var emailFromAddress = component.find("Email_From_Address__c").get("v.value");        
        if(emailFromAddress === null || emailFromAddress == ''){
            helper.addShadow(component, event,'Email_From_Address__c');
            formInvalid = true;
            ValidationList += '*Case Contact Email. \n';
        }else{
            helper.removeShadow(component, event,'Email_From_Address__c');
        }
        */
        var priority = component.find("Priority").get("v.value");
        if(priority == null || priority == '' || priority == '--None--'){
            helper.addShadow(component, event,'Priority');
            formInvalid = true;
            ValidationList += '*Priority. \n';
        }else{
            helper.removeShadow(component, event,'Priority');
        }
        var origin = component.find("Origin__c").get("v.value");
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
        /*
        var origin = component.find("Origin__c").get("v.value");
        if(origin == null || origin == '' || origin == '--None--'){            
            helper.addShadow(component, event,'Origin__c');
            formInvalid = true;
            ValidationList += '*Origin. \n';
        }else{
            helper.removeShadow(component, event,'Origin__c');
        }*/
        
        var mnpi = component.find("MNPI__c").get("v.value");
        var opportunityName = component.find("Opportunity_Name__c").get("v.value");
        if(mnpi === true){
            if(opportunityName === '' || opportunityName == null ||opportunityName.length > 255 ){
                helper.addShadow(component, event,'Opportunity_Name__c');
                formInvalid = true;
                 ValidationList += '*Opportunity Name. \n';
            }else{
                helper.removeShadow(component, event,'Opportunity_Name__c');
            }
        }
        
        var subject = component.find("Subject").get("v.value");
        
        if(subject === '' || subject == null ||subject.length > 255){
            helper.addShadow(component, event,'Subject');
            formInvalid = true;
            ValidationList += '*Subject. \n';
        }else{
            helper.removeShadow(component, event,'Subject');
        }
        
        var resolvingTeam = component.find("Resolving_Team__c").get("v.value");
        
        if(resolvingTeam == '--None--' || resolvingTeam === '' || resolvingTeam == null){
            helper.addShadow(component, event,'Resolving_Team__c');
            formInvalid = true;
            ValidationList += '*Resolving Team. \n';
        }
        else{
            helper.removeShadow(component, event,'Resolving_Team__c');
        }
        var resolvingArea = component.find("Resolving_Area__c").get("v.value");
        
        if(resolvingArea === '--None--' || resolvingArea === '' || resolvingArea == null){
            helper.addShadow(component, event,'Resolving_Area__c');
            formInvalid = true;
            ValidationList += '*Resolving Area. \n';
        }else{
            helper.removeShadow(component, event,'Resolving_Area__c');
        }
        
        var complaintServiceType = component.find("Complaint_Service_Type__c").get("v.value");
        var complaintServiceSubCategory = component.find("Complaint_Service_Sub_Category__c").get("v.value");
        var complaintServiceCategory = component.find("Complaint_Service_Category__c").get("v.value");
        
        if(complaintServiceType === '--None--' || complaintServiceType === '' || complaintServiceType == null){
            helper.addShadow(component, event,'Complaint_Service_Type__c');
            formInvalid = true;
             ValidationList += '*Complaint Service Type. \n';
        }else if(complaintServiceType !== ''){
            helper.removeShadow(component, event,'Complaint_Service_Type__c');
            if(complaintServiceSubCategory === '--None--' || complaintServiceSubCategory === '' || complaintServiceSubCategory == null){
                helper.addShadow(component, event,'Complaint_Service_Sub_Category__c');
                formInvalid = true;
                 ValidationList += '*Complaint Service Sub-Category. \n';
            }else if(complaintServiceSubCategory !== ''){
                helper.removeShadow(component, event,'Complaint_Service_Sub_Category__c');
                if(complaintServiceCategory === '--None--' || complaintServiceCategory === '' || complaintServiceCategory == null){
                    helper.addShadow(component, event,'Complaint_Service_Category__c');
                    formInvalid = true;
                    ValidationList += '*Complaint Service Category. \n';
                }else helper.removeShadow(component, event,'Complaint_Service_Category__c');
            } 
        }
        var staffError = component.find("Staff_Error__c").get("v.value");
        var staffErrorDescription = component.find("Staff_Error_Description__c").get("v.value");
        var staffMemberName = component.find("Staff_Member_Name__c").get("v.value");
        if(complaintServiceType == 'Staff Related Issues' && (staffError === false || staffErrorDescription == null || staffErrorDescription == '' || staffMemberName == null || staffMemberName == '' ||staffMemberName.length > 255)){
            //alert('You have to complete ALL the fields under the \'Staff Error\' page section, if you have selected \'Staff Related Issues\' as a service type');
            ValidationList += '*You have to complete ALL the fields under the \'Staff Error\' page section, if you have selected \'Staff Related Issues\' as a service type. \n';
            helper.addShadow(component, event,'Staff_Error__c');
            helper.addShadow(component, event,'Staff_Error_Description__c');
            helper.addShadow(component, event,'Staff_Member_Name__c');
            formInvalid = true;
        }else{
            helper.removeShadow(component, event,'Staff_Error__c');
            helper.removeShadow(component, event,'Staff_Error_Description__c');
            helper.removeShadow(component, event,'Staff_Member_Name__c');
        }
    
           var caseOwner = component.get('v.OwnerId')
        if(caseOwner === null || caseOwner === ''||caseOwner.length === 0 ){
            formInvalid = true;
            ValidationList += '*Please add a case owner. \n';
        }
        
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
        var description = component.find("Description").get("v.value");
        var incidentDate = component.find("Incident_Date__c").get("v.value");
        var complaintChannel = component.find("Complaint_Channel__c").get("v.value");
        
        scrollTo('Top',0,0);
        helper.showSpinner(component, event, helper);
        
        
        var action = component.get("c.newComplainCase");
        
        var NewComplainCaseModel = {
            'id': component.get("v.recordId"),
            'accountId': relationshipID,
            'RecordTypeId': component.get('v.recordTypeId'),
            'ownerID':component.get('v.OwnerId'),
            'ownerName':component.get('v.UserName'),
            'emailSenderName':emailSenderName,
            'emailFromAddress':emailFromAddress,             
            'suppressAcknowledgeAlert':suppressAcknowledgeAlert,
            'priority':priority,             
            'status':status,
            'incidentDate':incidentDate,             
            'origin':origin,             
            'subject':subject,             
            'description':description,
            
            'callReportId':component.get('v.callReportId'),
            'complaintServiceCategory':complaintServiceCategory,
            'resolvingArea':resolvingArea,             
            'complaintServiceType':complaintServiceType,
            'resolvingTeam':resolvingTeam,
            
            'complaintServiceSubCategory':complaintServiceSubCategory,
            'complaintChannel':complaintChannel,             
            'staffError':staffError,
            'mnip':mnpi,
            'staffErrorDescription':staffErrorDescription,
            
            'opportunityName':opportunityName,             
            'staffMemberName':staffMemberName,
            
            'actionTaken':status.includes('Closed') ? actionTaken : '',
            'desiredAction':status.includes('Closed') ? desiredAction : '',
            'rootCauseCategory':status.includes('Closed') ? rootCauseCategory: '',            
            'rootCause':status.includes('Closed') ? rootCause: '',
            'businessOwnerAction':status.includes('Closed') ? businessOwnerAction: '',
            'resolutionDetail':status.includes('Closed') ? resolutionDetail: '',
            'resolvedInFavourOf':status.includes('Closed') ? resolvedInFavourOf: ''
        };
        
        console.log(NewComplainCaseModel);
        
        action.setParams({
            newComplainCaseModel :JSON.stringify(NewComplainCaseModel) 
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                helper.hideSpinner(component, event, helper);
                
                var model = JSON.parse(response.getReturnValue());
                
                component.set('v.UserName', model.UserName)
                console.log(model);
                component.set("v.model", model); 
                
                if(component.get("v.model.ResponseMessage_r") !== null && component.get("v.model.ResponseMessage_r").length > 0 &&
                   component.get("v.model.ResponseMessage_r").startsWith("ERROR:")){                    
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "ERROR!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    });
                    
                }else if(component.get("v.model.ResponseMessage_r") !== null && component.get("v.model.ResponseMessage_r").length > 0){                    
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
                    component.set('v.stopExecuting','yes');
                    helper.openCaseRecordType(component, event, component.get("v.model.theCase_r.Id"));
                    
                    //helper.closeFocusedTab(component, event, helper);
                    //helper.navigateToDetailPage(component, event, component.get("v.model.theCase_r.Id"));
                }
                
            }else if (state === "INCOMPLETE") {
                helper.hideSpinner(component, event, helper);
                // do something
                console.log(state);
                console.log(response.getReturnValue());
                
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
                        console.log("Error message: " + errors[0].message);                           
                        
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
                    console.log("Unknown error");
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