/**
* Date   : 2017-01-04
* Author : RN - CloudSmiths
* Desc   : Helper class for the default attachment trigger
          1 - preventDeletion(list<Attachment>)
          Block deletion for any complaints case attachment
* Update History:
* 2017-10-19 - RN - CloudSmiths AUS - Block fit to lend attachments ther than the system generated att
**/
public class Attachment_Trigger_Methods {

    public static void preventDeletion(list<Attachment> attlst){
        
        set<Id> parentIds = new set<Id>();
        
        //add parent id's of object type Case to a set
        for(Attachment att :attlst){
            String pid = att.ParentId;
            if(pid.startsWith('500')){
                parentIds.add(att.ParentId);
            }
        }
        
       //get all related Case parents into a map
        map<Id, Case> caseMap = new map<Id, Case>([Select Id, RecordType.DeveloperName From Case Where Id IN :parentIds]);
        
        //block deletion for each complaints case attachment
        for(Attachment att :attlst){
            
            String pid = att.ParentId;
            if(pid.startsWith('500')){
            
                if(caseMap.get(att.ParentId).RecordType.DeveloperName == 'Complaint'){
                    att.addError('You cannot delete a Complaint Case attachment');
                }
            }
        }
    }
    
    //RN - Block Fit to Lend attachmenst being added by users
    String sObjName = '';
    public static void blockFTLAtt(list<Attachment> attlst){
        for(Attachment att :attlst){
            Id pid = att.ParentId;
            if(String.isNotBlank(pid)){
                if(pid.getSObjectType().getDescribe().getName() == 'Fit_To_Lend_Checklist__c'){
                    if(att.Description != 'System Generated'){
                        att.addError('You are not allowed to add any additional attachments to this Fit To Lend record'); 
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
}