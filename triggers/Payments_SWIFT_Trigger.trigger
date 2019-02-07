/**
* Date:   2017-07-06
* Author: Rudolf Niehaus - CloudSmiths
* Description: Default trigger for the SWIFT_Message__c object
* **** NOTE ********************************
* SWIFT messages can not be created in bulk 
* as the SWIFT API cannot process bulk JSON records
* *****************************************
**/
trigger Payments_SWIFT_Trigger on SWIFT_Message__c ( before insert, before update, after update ) {

    
    if(trigger.isUpdate){
        if(trigger.isBefore){
           Payments_SWIFT_Trigger_Func.makeReadOnly(trigger.new, trigger.oldMap);
        }else if(trigger.isAfter){
            //SWIFt rect API only handles 1 rec at a time
             if(trigger.new.size() == 1){ 
                 Payments_SWIFT_Trigger_Func.generateSWIFT(trigger.new, trigger.oldMap);
            }
        }
    }else if(trigger.isInsert && trigger.isBefore){
        Payments_SWIFT_Trigger_Func.updateSWIFTMessage(trigger.new);
    }
}