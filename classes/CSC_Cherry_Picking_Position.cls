/**
* Date   : 26-04-2016
* Author : RN - CloudSmiths
* Desc   : Global Glass that returns the position (Number) of the Case in a specific Queue
*-------------------------------------------------------
* Date   : 20170302 - Rudolf Niehaus
* Dec    : Update query by reducing the amount of fields
**/
global class CSC_Cherry_Picking_Position {
    
    global static Integer getCaseQueuePosition(String cid){
        //make sure we work with cases
        if(cid.startsWith('500')){
        
                Case pickedCase = [Select CreatedDate, OwnerId  From Case Where Id = :cid];
                
                list<Case> CaseQueueList = [Select Id From Case Where OwnerId = :pickedCase.OwnerId AND Email_Status__c ='New' AND CreatedDate < :pickedCase.CreatedDate];
                if(CaseQueueList.size() > 0){
                    return (CaseQueueList.size() + 1);
                }else{
                    return 1;
                }
        }else{
            return 0;
        }
        
    }
}