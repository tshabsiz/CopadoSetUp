({
    doInit  : function(component, event, helper) {
        
        var tabId =  component.get("v.tabId");
        helper.closeThisTab(component, event, tabId);
        helper.showSpinner(component, event, helper);
        var action = component.get("c.GetAccount");
        action.setParams({
            model : '',
            recordId: '',
            recordType: 'cscManual'
        });
        
        action.setCallback(this, function(response) {
             helper.setFocusedTabLabel(component, 'CSC Manual Cases');
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                if(component.get('v.recordEditFormLoaded') === true){
                    helper.hideSpinner(component, event, helper);
                }
                
                var model = JSON.parse(response.getReturnValue());
                console.log(model);
                
                component.set('v.OwnerId', model.theCase_r.OwnerId);
                component.set('v.RecordTypeId', model.theCase_r.RecordTypeId)               
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
    
    viewCifDetails: function(component, event, helper) {
       helper.viewCifDetails(component, event);
    } ,
    searchSF: function(component, event, helper) {        
        helper.searchSF(component, event,helper);        
    },
    
    handleAccountLoaded : function (component, event, helper) {
        component.set('v.recordEditFormLoaded', true);        
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
                     mode: 'sticky',
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
                                 mode: 'sticky',
                                "title": "Error!",
                                "message": errors[0].message,
                                "type":"error"
                            });
                            
                            toastEvent.fire();
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 mode: 'sticky',
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
                             mode: 'sticky',
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
    
  
    serviceTypeChange : function (component, event, helper) {
        var serviceType = component.find("Service_Type__c").get("v.value");
        if(serviceType !== null && serviceType !== '' && serviceType !== '--None--' && (component.get('v.model.UDFServiceTypes_r').indexOf(serviceType) > -1)){
            
            if(component.get('v.showUdf') === false)
                helper.showSpinner(component, event, helper);
            
            component.set('v.showUdf', true)
            //component.set('v.showCharges', true)
        }else{
            component.set('v.showUdf', false)
            //component.set('v.showCharges', false)
        }
        
        
        if(serviceType !== null && serviceType !== '' && serviceType !== '--None--' && (component.get('v.model.ChargesServiceTypes_r').indexOf(serviceType) > -1)){
            
            if(component.get('v.showCharges') === false)
                helper.showSpinner(component, event, helper);  
            
            //component.set('v.showUdf', true)
            component.set('v.showCharges', true)
        }else{
            //component.set('v.showUdf', false)
            component.set('v.showCharges', false)
        }
    },
    
    channelChanged: function (component, event, helper) {
        
        var Department__c = component.find('Queue__c').get("v.options")
       
      //alert(component.find('Queue__c').get("v.value"))
      
        console.log("Department__c");
        console.log(Department__c);
        console.log("Department__c");
        /*if (Department__c.length >= 2) 
        {
            	component.find("Department__c").set("v.value", Department__c[1]);
           }*/
        
    },
    
    doRefreshPage: function (component, event, helper){
   
        //helper.closeFocusedTab(component, event, helper);
    },
    newCase : function (component, event, helper) {
        
        var ValidationList = '';
        var formInvalid = false;
        var relationshipID = component.find('relationships').get("v.value");
        //var relationshipID = document.getElementsByName('relationships')[0].value;
        
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
        
        var emailSenderName = component.find("Email_Sender_Name__c").get("v.value");
        if(emailSenderName === null || emailSenderName === ''||emailSenderName.length > 255 ){             
            helper.addShadow(component, event,'Email_Sender_Name__c');
            formInvalid = true;
            ValidationList += '*Case Contact Name. \n';
        }else{
            helper.removeShadow(component, event,'Email_Sender_Name__c');
        }
        
       
       
       
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
            
            
            serviceCategory = component.find("Service_Category__c").get("v.value");
            if(serviceCategory === null || serviceCategory === '' || serviceCategory === '--None--'){            
                helper.addShadow(component, event,'Service_Category__c');
                formInvalid = true;
                ValidationList += '*Service Category. \n';
            }else{
                helper.removeShadow(component, event,'Service_Category__c');
                
                
                serviceSubCategory = component.find("Service_Sub_Category__c").get("v.value");
                if(serviceSubCategory === null || serviceSubCategory === '' || serviceSubCategory === '--None--'){            
                    helper.addShadow(component, event,'Service_Sub_Category__c');
                    formInvalid = true;
                    ValidationList += '*Service Sub-Category. \n';
                }else{
                    helper.removeShadow(component, event,'Service_Sub_Category__c');
                }
            }
        }
        var channel = component.find("Channel__c").get("v.value");
        if(channel === null || channel === '' || channel === '--None--'){            
            helper.addShadow(component, event,'Channel__c');
            formInvalid = true;
            ValidationList += '*Channel. \n';
        }else{
            helper.removeShadow(component, event,'Channel__c');
        }
        
        
        //check this
        var reasonforCancellation = component.find("Reason_for_Cancellation__c").get("v.value");
        /*if(reasonforCancellation == null || reasonforCancellation == '' || reasonforCancellation == '--None--'){            
            helper.addShadow(component, event,'Reason_for_Cancellation__c');
            formInvalid = true;
        }else{
                 helper.removeShadow(component, event,'Reason_for_Cancellation__c');
            }
        */
        var requests = component.find("Number_of_Requests__c").get("v.value");
        if(requests === null || requests === '' || requests === '0' || requests === 0 || requests < 0 ){
            
            ValidationList += '*Client Number of Requests should be greter than 0. \n';
            helper.addShadow(component, event,'Number_of_Requests__c');
            formInvalid = true;
            ValidationList += '*Number of Requests. \n';
        }else{
            helper.removeShadow(component, event,'Number_of_Requests__c');
        }
        
        var subject = component.find("Subject").get("v.value");        
        if(subject === '' || subject === null ||subject.length > 255){
            helper.addShadow(component, event,'Subject');
            formInvalid = true;
             ValidationList += '*Subject. \n';
        }else{
            helper.removeShadow(component, event,'Subject');
        }
        
        var businessHours = component.find("Business_Hours__c").get("v.value");        
        if(businessHours === null || businessHours === '' || businessHours === '--None--'){
            helper.addShadow(component, event,'Business_Hours__c');
            formInvalid = true;
            ValidationList += '*Business Hours. \n';
        }else{
            helper.removeShadow(component, event,'Business_Hours__c');
        }
        
        var team = component.find("Team__c").get("v.value");        
        if(team === null || team === '' || team === '--None--'){
            helper.addShadow(component, event,'Team__c');
            formInvalid = true;
            ValidationList += '*Team. \n';
        }else{
            helper.removeShadow(component, event,'Team__c');
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
        if(origin !== '--None--' && origin !== '' && origin !== 'Phone' && origin !== 'Telephone' && origin !== 'Swift' && origin != 'Email'){            
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
        
        var contactConfirmedWith = null, 
            clientContactTelNo = null, 
            dateConfirmed = null, 
            clientAbsaAccountNumber = null, 
            clientIDNumberMandateAUTH = null, 
            clientSignatureMandateSIGV = null, 
            amountVerifiedandApproved = null, 
            indemnityVerified = null, 
            disclaimerReadtoClient = null, 
            rSCConfirmsFunds = null,
            duplicationsChecked = null, 
            typeofTransferAuthorised = null, 
            verifyClientAccountNumberDebit = null, 
            paymentAuthPaperMandate = null, 
            thirdPartyPaymentProcessed = null, 
            wip = null,
            pop = null,
            beneficiaryName = null,
            beneficiaryAccNoandBank = null,
            beneficiaryACBorBranchCode = null; 
        
        
        if(serviceType !== null && serviceType !== '' && serviceType !== '--None--'&& (component.get('v.model.UDFServiceTypes_r').indexOf(serviceType) > -1)){
            
            contactConfirmedWith = component.find("ContactConfirmedWith__c").get("v.value");
            clientContactTelNo = component.find("ClientContactTelNo__c").get("v.value");
            dateConfirmed = component.find("DateConfirmed__c").get("v.value");
            clientAbsaAccountNumber = component.find("ClientAbsaAccountNumber__c").get("v.value");
            clientIDNumberMandateAUTH = component.find("ClientIDNumberMandateAUTH__c").get("v.value");
            clientSignatureMandateSIGV = component.find("ClientSignatureMandateSIGV__c").get("v.value");
            amountVerifiedandApproved = component.find("AmountVerifiedandApproved__c").get("v.value");
            indemnityVerified = component.find("IndemnityVerified__c").get("v.value");
            disclaimerReadtoClient = component.find("DisclaimerReadtoClient__c").get("v.value");
            rSCConfirmsFunds = component.find("RSCConfirmsFunds__c").get("v.value");
            duplicationsChecked = component.find("DuplicationsChecked__c").get("v.value");
            typeofTransferAuthorised = component.find("TypeofTransferAuthorised__c").get("v.value");// 
            verifyClientAccountNumberDebit = component.find("VerifyClientAccountNumberDebit__c").get("v.value");
            paymentAuthPaperMandate = component.find("PaymentAuthPaperMandate__c").get("v.value");
            thirdPartyPaymentProcessed = component.find("ThirdPartyPaymentProcessed__c").get("v.value");
            wip = component.find("WIP__c").get("v.value");
            
            beneficiaryName = component.find("BeneficiaryName__c").get("v.value");
            beneficiaryAccNoandBank = component.find("BeneficiaryAccNoandBank__c").get("v.value");
            beneficiaryACBorBranchCode = component.find("BeneficiaryACBorBranchCode__c").get("v.value");
            pop = component.find("POP__c").get("v.value");
            
            
            if(contactConfirmedWith === null || contactConfirmedWith === ''){
                helper.addShadow(component, event,'ContactConfirmedWith__c');
                formInvalid = true;
                ValidationList += '*Contact Confirmed With. \n';
            }else{
                helper.removeShadow(component, event,'ContactConfirmedWith__c');
            }
            
            
            
            if(clientContactTelNo === null || clientContactTelNo === '' || clientContactTelNo.length > 255 ){
                helper.addShadow(component, event,'ClientContactTelNo__c');
                formInvalid = true;
                ValidationList += '*Client Contact Tel No. \n';
            }else{
                helper.removeShadow(component, event,'ClientContactTelNo__c');
            }
            
            
            
            if(dateConfirmed === null || dateConfirmed === '' || dateConfirmed.length > 255 ){
                helper.addShadow(component, event,'DateConfirmed__c');
                formInvalid = true;
                ValidationList += '*Date Confirmed. \n';
            }else{
                helper.removeShadow(component, event,'DateConfirmed__c');
            }
            
            if(clientAbsaAccountNumber === null || clientAbsaAccountNumber === '' || clientAbsaAccountNumber.length > 255 ){
                helper.addShadow(component, event,'ClientAbsaAccountNumber__c');
                formInvalid = true;
                ValidationList += '*Client Absa Account Number. \n';
            }else{
                helper.removeShadow(component, event,'ClientAbsaAccountNumber__c');
            }
            
            if(clientIDNumberMandateAUTH === null || clientIDNumberMandateAUTH === '' || clientIDNumberMandateAUTH.length > 255 ){
                helper.addShadow(component, event,'ClientIDNumberMandateAUTH__c');
                formInvalid = true;
                ValidationList += '*Client ID Number Mandate AUTH. \n';
            }else{
                helper.removeShadow(component, event,'ClientIDNumberMandateAUTH__c');
            }
            
            
            
            if(clientSignatureMandateSIGV === null || clientSignatureMandateSIGV === '' || clientSignatureMandateSIGV.length > 255 ){
                helper.addShadow(component, event,'ClientSignatureMandateSIGV__c');
                formInvalid = true;
                ValidationList += '*Client Signature Mandate SIGV. \n';
            }else{
                helper.removeShadow(component, event,'ClientSignatureMandateSIGV__c');
            }
            
            if(amountVerifiedandApproved === null || amountVerifiedandApproved === '' || amountVerifiedandApproved.length > 255 ){
                helper.addShadow(component, event,'AmountVerifiedandApproved__c');
                formInvalid = true;
                ValidationList += '*Amount Verified and Approved. \n';
            }else{
                helper.removeShadow(component, event,'AmountVerifiedandApproved__c');
            }
            
            if(indemnityVerified === null || indemnityVerified === '' || indemnityVerified.length > 255 ){
                helper.addShadow(component, event,'IndemnityVerified__c');
                formInvalid = true;
                ValidationList += '*Indemnity Verified. \n';
            }else{
                helper.removeShadow(component, event,'IndemnityVerified__c');
            }
            
            if(disclaimerReadtoClient === null || disclaimerReadtoClient === '' || disclaimerReadtoClient.length > 255 ){
                helper.addShadow(component, event,'DisclaimerReadtoClient__c');
                formInvalid = true;
                 ValidationList += '*Disclaimer Read to Client. \n';
            }else{
                helper.removeShadow(component, event,'DisclaimerReadtoClient__c');
            }
            
            if(rSCConfirmsFunds === null || rSCConfirmsFunds === '' || rSCConfirmsFunds.length > 255 ){
                helper.addShadow(component, event,'RSCConfirmsFunds__c');
                formInvalid = true;
                ValidationList += '*RSC Confirms Funds. \n';
            }else{
                helper.removeShadow(component, event,'RSCConfirmsFunds__c');
            }
            
            if(duplicationsChecked === null || duplicationsChecked === '' || duplicationsChecked.length > 255 ){
                helper.addShadow(component, event,'DuplicationsChecked__c');
                formInvalid = true;
                ValidationList += '*Duplications Checked. \n';
            }else{
                helper.removeShadow(component, event,'DuplicationsChecked__c');
            }
            
            if(typeofTransferAuthorised === null || typeofTransferAuthorised === '' || typeofTransferAuthorised.length > 255 ){
                helper.addShadow(component, event,'TypeofTransferAuthorised__c');
                formInvalid = true;
                ValidationList += '*Type of Transfer Authorised. \n';
            }else{
                helper.removeShadow(component, event,'TypeofTransferAuthorised__c');
            }
            
            if(verifyClientAccountNumberDebit === null || verifyClientAccountNumberDebit === '' || verifyClientAccountNumberDebit.length > 255 ){
                helper.addShadow(component, event,'VerifyClientAccountNumberDebit__c');
                formInvalid = true;
                 ValidationList += '*Verify Client Account Number Debit. \n';
            }else{
                helper.removeShadow(component, event,'VerifyClientAccountNumberDebit__c');
            }
            
            if(paymentAuthPaperMandate === null || paymentAuthPaperMandate === '' || paymentAuthPaperMandate.length > 255 ){
                helper.addShadow(component, event,'PaymentAuthPaperMandate__c');
                formInvalid = true;
                ValidationList += '*Payment Auth Paper Mandate. \n';
            }else{
                helper.removeShadow(component, event,'PaymentAuthPaperMandate__c');
            }
            
            if(thirdPartyPaymentProcessed === null || thirdPartyPaymentProcessed === '' || thirdPartyPaymentProcessed.length > 255 ){
                helper.addShadow(component, event,'ThirdPartyPaymentProcessed__c');
                formInvalid = true;
                ValidationList += '*Third Party Payment Processed. \n';
            }else{
                helper.removeShadow(component, event,'ThirdPartyPaymentProcessed__c');
            }
            
            
            
            if(wip === null || wip === '' || wip.length > 255 ){
                helper.addShadow(component, event,'WIP__c');
                formInvalid = true;
                ValidationList += '*WIP. \n';
            }else{
                helper.removeShadow(component, event,'WIP__c');
            }
            
        }// if(serviceType == null || serviceType == '' || serviceType == '--None--'){
        
        var chargeAmount = null,
            cRRef = null,
            chargeAccountNo = null,
            transactionCode = null,
            corpCode = null,
            costCentre = null,
            dRRef = null,
            effectiveDate = null,
            cRAccountNo = null;
        
        if(serviceType !== null && serviceType !== '' && serviceType !== '--None--'&& (component.get('v.model.ChargesServiceTypes_r').indexOf(serviceType) > -1)){
            
         chargeAmount = component.find("ChargeAmount__c").get("v.value");
            cRRef = component.find("CRRef__c").get("v.value");
            
            
         /*   if(chargeAmount === null || chargeAmount === '' ||chargeAmount.length > 255 ){
                helper.addShadow(component, event,'ChargeAmount__c');
                formInvalid = true;
                ValidationList += '*Charge Amount. \n';
            }else{
                helper.removeShadow(component, event,'ChargeAmount__c');
            }
            
            if(cRRef === null || cRRef === '' ||cRRef.length > 255 ){
                helper.addShadow(component, event,'CRRef__c');
                formInvalid = true;
                ValidationList += '*CRRef. \n';
            }else{
                helper.removeShadow(component, event,'CRRef__c');
            } */
            
            
            chargeAccountNo = component.find("ChargeAccountNo__c").get("v.value");
            transactionCode = component.find("TransactionCode__c").get("v.value");
            corpCode = component.find("CorpCode__c").get("v.value");
            costCentre = component.find("Cost_Centre__c").get("v.value");
            dRRef = component.find("DRRef__c").get("v.value");
            effectiveDate = component.find("EffectiveDate__c").get("v.value")
            cRAccountNo = component.find("CRAccountNo__c").get("v.value")
             
             
        } 
        
        
        
        var accountId = relationshipID;        
        var description = component.find("Description").get("v.value"); 
        
        var priority = component.find("Priority").get("v.value");
        var urgent = component.find("Urgent__c").get("v.value");
        
        var teamManager = component.find("Team_Manager__c").get("v.value");
        //var hWasEmailToCaseAction = component.find("hWasEmailToCaseAction__c").get("v.value");
        
        reasonforCancellation = 
            (component.find("Reason_for_Cancellation__c").get("v.value") !== null &&component.find("Reason_for_Cancellation__c").get("v.value")!== '')?
            component.find("Reason_for_Cancellation__c").get("v.value"):'';
        
        
        
        
        
        if(formInvalid === true){
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "title": "Missing Required Information!",
                "message": "\n Please Fill In The Required Fields \n\n"+ValidationList,
                "type":"warning"
            });
            formInvalid = false;
            toastEvent.fire();
            
            return;
        }
        
        scrollTo('Top',0,0);
        helper.showSpinner(component, event, helper);
        
        
        var action = component.get("c.newManualCase");
        
        
        
        var NewManualCaseModel = {
            'id': component.get("v.recordId"),
            'contactConfirmedWith': contactConfirmedWith,
            'clientContactTelNo': clientContactTelNo,
            'dateConfirmed':dateConfirmed,
            'clientAbsaAccountNumber':clientAbsaAccountNumber,
            'clientIDNumberMandateAUTH':clientIDNumberMandateAUTH,
            'clientSignatureMandateSIGV':clientSignatureMandateSIGV,             
            'beneficiaryName':beneficiaryName,
            'amountVerifiedandApproved':amountVerifiedandApproved,             
            'beneficiaryAccNoandBank':beneficiaryAccNoandBank,
            'beneficiaryACBorBranchCode':beneficiaryACBorBranchCode,             
            'indemnityVerified':indemnityVerified,             
            'disclaimerReadtoClient':disclaimerReadtoClient,             
            'rSCConfirmsFunds':rSCConfirmsFunds,             
            'duplicationsChecked':duplicationsChecked,
            'typeofTransferAuthorised':typeofTransferAuthorised,             
            'verifyClientAccountNumberDebit':verifyClientAccountNumberDebit,
            'paymentAuthPaperMandate':paymentAuthPaperMandate,
            'thirdPartyPaymentProcessed':thirdPartyPaymentProcessed,             
            'wip':wip,
            'pop':pop,                  
            'chargeAccountNo':chargeAccountNo,
            'transactionCode':transactionCode,
            'costCentre':costCentre,             
            'corpCode':corpCode,             
            'dRRef':dRRef,
            'cRRef':cRRef,                
            'effectiveDate':effectiveDate,                
            'cRAccountNo':cRAccountNo,                
            'emailSenderName':emailSenderName,
            'emailFromAddress':emailFromAddress,
            'queue':queue,
            'subject':subject,
            'description':description,
            'priority':priority,
            'urgent':urgent, 
            'accountId':accountId,
            'accountNumber': component.get("v.model.qType_r") === 'accountNumber'?(component.find("regId").get('v.value')).trim():'',
            'department':department,
            'fullDepartment':fullDepartment,
            'teamManager':teamManager,
            'businessHours':businessHours,
            'team':team,
            'origin':origin,
            'serviceCategory':serviceCategory,
            'serviceSubCategory':serviceSubCategory,
            'serviceType':serviceType,
            'requests':requests,
            'channel':channel,
            'hWasEmailToCaseAction':true,
            'reasonforCancellation':reasonforCancellation !== null && reasonforCancellation !== '--None--' && reasonforCancellation !== ''?reasonforCancellation:null,
            'recordTypeId':component.get("v.RecordTypeId"), 
            'OwnerId':component.get("v.OwnerId"),
            'relationshipID':relationshipID
        };
        
        console.log(NewManualCaseModel);
        
        action.setParams({
            newManualCaseModel :JSON.stringify(NewManualCaseModel) 
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                helper.hideSpinner(component, event, helper);
                
                var model = JSON.parse(response.getReturnValue());
                
                //component.set('v.UserName', model.UserName)
                console.log(model);
                component.set("v.model", model); 
                //component.set("v.model", model);
                //component.set("v.accountOptions", model.accountOptions_r);
                
                if(component.get("v.model.ResponseMessage_r") !== null &&component.get("v.model.ResponseMessage_r").length > 0 &&
                   component.get("v.model.ResponseMessage_r").startsWith("ERROR:")){                    
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "ERROR!",
                        "message": component.get("v.model.ResponseMessage_r"),
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    });
                    
                }else if(component.get("v.model.ResponseMessage_r") !== null &&component.get("v.model.ResponseMessage_r").length > 0){                    
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
                   
                    if(component.get("v.model.theCase_r.Service_Type__c") !== 'Log Complaint')
                    {
                         //helper.closeFocusedTab(component, event, helper);
                      // helper.navigateToDetailPage(component, event, component.get("v.model.theCase_r.Id")); 
                        //var tabId = helper.getFocusedTab(component, event, helper);
                        // alert('tab :'+tabId);
                      helper.openCaseRecordType(component, event, component.get("v.model.theCase_r.Id"));
                        
                        //helper.editRecord(component, event, component.get("v.model.theCase_r.Id"));
                         //helper.closeFocusedTab(component, event, helper);
                    }
                    else{
                        
                         //helper.closeFocusedTab(component, event, helper);
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
    
    keyCheck : function(component, event, helper) {
        if(event.which == 13){
          helper.searchSF(component, event,helper);        
          
        }
    },
})