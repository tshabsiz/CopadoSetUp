({
	showSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner1");
        $A.util.removeClass(spinner, "slds-hide");
         $A.util.addClass(spinner, "slds-show");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("TheSpinner1");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
        
    },
    
      addValidation: function (component, event, helper) {
        var checkselectValidations = document.getElementsByClassName("checkselectValidation");
          for (let i = 0; i < checkselectValidations.length; i++) 
        {
            
            if(checkselectValidations[i].value == '--None--'){
               checkselectValidations[i].classList.add("redborder")
            }else{
                checkselectValidations[i].classList.remove("redborder")
            }
            
        }
          
        var validationFail = false;
        for (let i = 0; i < component.get("v.model.chargeWrapperList").length; i++) 
        {
            var ChargeAccountNo = document.getElementById("ChargeAccountNo_"+i);
            if(ChargeAccountNo.value == ''){
                ChargeAccountNo.classList.add("redborder");
                validationFail = true;
            }else{
                ChargeAccountNo.classList.remove("redborder");
            component.get("v.model.chargeWrapperList")[i].charge.Charge_Account_No__c = ChargeAccountNo.value;
            }
            
            var ChargeAmount = document.getElementById("ChargeAmount_"+i);
            if(ChargeAmount.value == ''){
                ChargeAmount.classList.add("redborder");
                validationFail = true;
            }else{
                ChargeAmount.classList.remove("redborder");
            component.get("v.model.chargeWrapperList")[i].charge.Charge_Amount__c = ChargeAmount.value;
            }
            
           
            var CostCentre = document.getElementById("CostCentre_"+i);
            if(CostCentre.value == ''){
                CostCentre.classList.add("redborder");
                validationFail = true;
            }else{
                CostCentre.classList.remove("redborder");
            component.get("v.model.chargeWrapperList")[i].charge.Cost_Centre__c = CostCentre.value;
            }
            
           
            var CRRef = document.getElementById("CRRef_"+i);
            if(CRRef.value == ''){
                CRRef.classList.add("redborder");
                validationFail = true;
            }else{
                CRRef.classList.remove("redborder");
            component.get("v.model.chargeWrapperList")[i].charge.CR_Ref__c = CRRef.value;
            }
            
         
            var DRRef = document.getElementById("DRRef_"+i);
            if(DRRef.value == ''){
                DRRef.classList.add("redborder");
                validationFail = true;
            }else{
                DRRef.classList.remove("redborder");
            component.get("v.model.chargeWrapperList")[i].charge.DR_Ref__c = DRRef.value;
            }
            
            var EffectiveDate = document.getElementById("EffectiveDate_"+i).value;
          
            if(EffectiveDate == ''||EffectiveDate.includes('d') || EffectiveDate.includes('m')||EffectiveDate.includes('y')){
                document.getElementById("EffectiveDate_"+i).classList.add("redborder");
                validationFail = true;
            }else{
                document.getElementById("EffectiveDate_"+i).classList.remove("redborder");
            component.get("v.model.chargeWrapperList")[i].charge.Effective_Date__c = EffectiveDate;
            }
            
            
        }
          
          return validationFail;
    },
})