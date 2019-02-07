/**
*** CHANGE LOG ***
 
 07/06/2018 - TdB    - Add .

**/

trigger SupportingAgreement_Trigger on Supporting_Agreement__c (before insert, before update) {
    
    List<Supporting_Agreement__c> supportingAgreementList = new  List<Supporting_Agreement__c>();
    
    //Before insert/update
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        for(Supporting_Agreement__c eachSupportingAgreement : Trigger.new)
        {
            //Only add CSA Supporting Agreements to the list
            if(eachSupportingAgreement.Supporting_Agreement_Type__c == 'CSA')
            {
                supportingAgreementList.add(eachSupportingAgreement);
            }
        }
        
        //Call agreementTemplateAssignment Class to assign the correct template to the CSA
        if(!supportingAgreementList.isEmpty())
        {
            SupportingAgreement_Helper.agreementTemplateAssignment(supportingAgreementList);
        }
    }
}