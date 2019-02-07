/**
* Date   : 2016-08-11
* Author : RN - CloudSmiths
* Desc   : Prevent users from deleting email messages from Cases
**/
trigger CSC_EmailMessage_Trigger on EmailMessage (before delete) {
   
    String pID = '';
    for(EmailMessage em :trigger.old){
        pID = em.ParentId;
        if (pID.startsWith('500')){         
            em.adderror('Email Messages related to Support Cases cannot be Deleted.' + 
                        'If you have any questions, please contact you Salesforce Administrator. Thank you.');         
        }
    }
}