/**
* Date   : 2017-01-04
* Author : RN - CloudSmiths
* Desc   : Default Attachment trigger
* Update History:
* 2017-10-19 - RN - CloudSmiths - Block fit to lend attachments ther than the system generated att
* 2017-03-28 - Patrick - BSG - Adds Code to upload signed Documents from Docusign to Box
**/
trigger Attachment_Trigger on Attachment (before insert, after insert,before delete) {
    
    if(trigger.isBefore){
        if(trigger.isDelete){
            Attachment_Trigger_Methods.preventDeletion(trigger.old);
        }else if(trigger.isInsert){
            Attachment_Trigger_Methods.blockFTLAtt(trigger.new);
        }
    } else if(trigger.isAfter && trigger.isInsert) {
        UploadDocusignLogic.UploadDocumentToBox(Trigger.new);
    }
}