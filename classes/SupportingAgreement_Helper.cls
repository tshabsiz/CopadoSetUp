/**
*** CHANGE LOG ***
 
 07/06/2018 - TdB    - Created Class.

**/
public class SupportingAgreement_Helper 
{
	public static void agreementTemplateAssignment(List<Supporting_Agreement__c> inputNewList)
    {
        Map<String, Id> agreementTemplateMap = new Map<String, Id>();
        
        //Agreement Template - Master Record Type Id
        Id masterAgreementTemplateRecTypeId = Schema.SObjectType.Agreement_Template__c.getRecordTypeInfosByName().get('Agreement Template - Master').getRecordTypeId();

        //Get all "Agreement Template - Master" Agreement Templates based on Master Agreemnt Version and Record Type
        //Key = Agreement Type + Template Version
        //Value = Agreement Template Id
        for(Agreement_Template__c eachAgreementTemplate : [SELECT Id, Name, RecordTypeId, Agreement_Type__c, Template_Version__c 
                                                           FROM Agreement_Template__c
                                                           WHERE RecordTypeId = :masterAgreementTemplateRecTypeId
                                                           AND Agreement_Type__c = 'Supporting Agreement'
                                                          ])
        {
            agreementTemplateMap.put(eachAgreementTemplate.Agreement_Type__c + '###' + eachAgreementTemplate.Template_Version__c, eachAgreementTemplate.Id);
        }
        
        //Loop through Supporting Agreemnt and assign Agreement Template (if any) based on Agreement Type and Version
        for(Supporting_Agreement__c eachSupportingAgreement : inputNewList)
        {
            if(agreementTemplateMap.containsKey('Supporting Agreement###' + eachSupportingAgreement.Supporting_Agreement_Type__c))
            {
                eachSupportingAgreement.Agreement_Template__c = agreementTemplateMap.get('Supporting Agreement###' + eachSupportingAgreement.Supporting_Agreement_Type__c);
            }
        }
    }
}