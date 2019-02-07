/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

11/07/2017 - PG     - Created class.
15/09/2017 - PG     - Added "afterUpdate" for logicless trigger.
                    - Added send notification logic to handle "cancelled" notifications.
2017-11-18 - Rudolf Niehaus - CloudSmiths - implement drawdown roll-up calculations
27/01/2017 - TdB	 - 
**/  
public class Drawdown_Helper {
    
    /**
* After Update Trigger Handler
**/
    public static void afterUpdate(List<Drawdown__c> inputNewList, Map<Id, Drawdown__c> inputOldMap)
    {   
        sendNotificationEmails(inputNewList, inputOldMap);
    }
    
    /**
* sendNotificationEmails - Sends emails to notificaiton participants and groups.
**/
    public static void sendNotificationEmails(List<Drawdown__c> inputNewList, Map<Id, Drawdown__c> inputOldMap) 
    {
        //Blank list.
        Set<Id> drawdownIds = new Set<Id>();
        List<Drawdown__c> drawdowns = new List<Drawdown__c>();
        
        //Loop through drawdowns
        for(Drawdown__c drawdown : inputNewList)
        {
            //Has been completed.
            if(inputOldMap.get(drawdown.Id).Supporting_Documentation_Uploaded__c == false && drawdown.Supporting_Documentation_Uploaded__c == true)
            {
                //Add to set.
                drawdownIds.add(drawdown.Id);
            }
            
            //Has been cancelled.
            if(inputOldMap.get(drawdown.Id).Status__c != 'Cancelled' && drawdown.Status__c == 'Cancelled')
            {
                //Add to set.
                drawdownIds.add(drawdown.Id);
            }
        }
        
        //Get any contact for email template.  Never emailed...
        Id randomContactId = [SELECT Id FROM Contact WHERE Email != null LIMIT 1].Id;
        
        //Final list of all email messages for sending.
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        //Get the ids of the email template
        Id publicEmailTempateId     = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Draw_down_Utilization_request_Public'].Id;
        Id privateEmailTempateId    = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Draw_down_Request_Private'].Id;
        
        //Cancelled email templates.
        Id publicCancelEmailTempateId     = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Drawdown_Cancelled_Public'].Id;
        Id privateCancelEmailTempateId    = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Drawdown_Cancelled_Private'].Id;
        
        //Get the fit to lend records and notificiation groups.
        drawdowns = [
            SELECT 
            Id,
            Name,
            Status__c,
            (
                SELECT 
                Id,
                Distribution_Group__c,
                Distribution_Group__r.Name,
                Distribution_Group__r.Email_Address__c,
                Distribution_Group__r.Group_Type__c
                FROM Notification_Groups__r
            ),
            (
                SELECT 
                Id,
                Email_Address__c,
                Participant__c,
                Participant__r.advpm__Role__c
                FROM Notification_Participants__r
            )
            FROM Drawdown__c
            WHERE
            Id IN :drawdownIds
        ];
        
        //Loop through checklists.
        for(Drawdown__c drawdown : drawdowns)
        {
            //Loop through notification groups.
            for(Notification_Group__c notifyGroup : drawdown.Notification_Groups__r)
            {     
                //Group email address.
                List<String> toAddresses = new List<String> { notifyGroup.Distribution_Group__r.Email_Address__c };
                    
                //Single email object.
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setTargetObjectId(randomContactId);
                singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                singleEmail.setToAddresses(toAddresses);
                singleEmail.setWhatId(drawdown.Id);
                
                //Private
                if(notifyGroup.Distribution_Group__r.Group_Type__c == 'Private')
                {
                    if(drawdown.Status__c == 'Cancelled')
                    {
                        singleEmail.setTemplateId(privateCancelEmailTempateId);
                    }
                    else
                    {
                        singleEmail.setTemplateId(privateEmailTempateId);
                    }
                }
                //Public
                else
                {   
                    if(drawdown.Status__c == 'Cancelled')
                    {
                        singleEmail.setTemplateId(publicCancelEmailTempateId);
                    }
                    else
                    {
                        singleEmail.setTemplateId(publicEmailTempateId);
                    } 
                }
                
                //Add to list.
                emailMessages.add(singleEmail); 
            }
            
            //Loop through participant notifications.
            for(Notification_Participant__c notifyParticipant : drawdown.Notification_Participants__r)
            {
                //Group email address.
                List<String> toAddresses = new List<String> { notifyParticipant.Email_Address__c };
                    
                    //Single email object.
                    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setTargetObjectId(randomContactId);
                singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                singleEmail.setToAddresses(toAddresses);
                singleEmail.setWhatId(drawdown.Id);
                
                if(drawdown.Status__c == 'Cancelled')
                {
                    singleEmail.setTemplateId(privateCancelEmailTempateId);
                }
                else
                {
                    singleEmail.setTemplateId(privateEmailTempateId);
                }
                
                //Add to list.
                emailMessages.add(singleEmail);
            }
        }
        
        //Send emails.
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
    }
    
    //RN - CloudSmiths - Roll-up drawdowns on the lowest level
    public static void rollUpCalculation(list<Drawdown__c> newDrawdowns){
        
        set<Id> facilityIds = new set<Id>();
        set<Id> ficilityTrancheIds = new set<Id>();
        set<Id> agreementIds = new set<Id>();
        map<Id, Decimal> mapFTDrawAmountTotal = new map<Id, Decimal>();
        map<Id, Decimal> mapFDrawAmountTotal = new map<Id, Decimal>();
        map<Id, Decimal> mapAgreeDrawAmountTotal = new map<Id, Decimal>();
        
        for(Drawdown__c draw :newDrawdowns){
            
            //get related parent ids and add to sets
            Id pidF = draw.Facility__c;
            Id pidFT = draw.Facility_Tranche__c;
            Id pidAgreement = draw.Agreement__c;
            
            //Get all drawdowns for this agreement in order to update the Deal total limit balance
            if(String.isNotBlank(pidAgreement) && String.isBlank(pidF) && String.isBlank(pidFT)){
                if(pidAgreement.getSObjectType().getDescribe().getName() == 'Agreement__c'){
                   agreementIds.add(pidAgreement);
                }
            //drawdown only linked to a Facility
            }else if(String.isNotBlank(pidF) && String.isBlank(pidFT)){
                if(pidF.getSObjectType().getDescribe().getName() == 'Facility__c'){
                   facilityIds.add(pidF);
                }
            }else if(String.isNotBlank(pidFT)){
                if(pidFT.getSObjectType().getDescribe().getName() == 'Facility_Tranche__c'){
                   ficilityTrancheIds.add(pidFT);
                }
            } 
        }
        
        //roll-up and calculate all drawdowns for each parent, calculation on the lowest level
        //Facility Tranche
        Decimal ficilityTrancheTotal = 0.0;
        list<Facility_Tranche__c> updateFTList = new list<Facility_Tranche__c>();
        
        if(ficilityTrancheIds.size() > 0){
                        
            for(Facility_Tranche__c ft :[Select Id, Tranche_Limit__c, TrancheLimitBalance__c, (Select Advance_Amount__c From Drawdowns__r Where Status__c != 'Cancelled') 
                                         From Facility_Tranche__c 
                                         Where Id IN :ficilityTrancheIds]){
               
               for(Drawdown__c rollDraws :ft.Drawdowns__r){
                   ficilityTrancheTotal+= rollDraws.Advance_Amount__c;                   
               }
                                       
               mapFTDrawAmountTotal.put(ft.Id, ficilityTrancheTotal);
               //reset                              
               ficilityTrancheTotal = 0.0; 
               
           }
            
            //loop through the relevent FT's and add the new drawdown amount, we have to do this as some FT's might not have existing
            //drawdowns so we cannot add this new amounts in the joined loop as we might never enter the loop for some FT's
            ficilityTrancheTotal = 0.0;
            for(Facility_Tranche__c ft :[Select Id, Tranche_Limit__c, TrancheLimitBalance__c From Facility_Tranche__c Where Id IN :ficilityTrancheIds]){
               
                //add new drawdown amount                            
               ficilityTrancheTotal = (mapFTDrawAmountTotal.get(ft.Id));
                
               if(ft.Tranche_Limit__c != null){
                   ft.TrancheLimitBalance__c = (ft.Tranche_Limit__c - ficilityTrancheTotal);
                   updateFTList.add(ft);
               }
            }
        }  
        
        try{
            if(updateFTList.size() > 0){
                update updateFTList; 
            }
        }catch(DMLException ex){
            System.debug('There was an error updating the Facility Tranche with a new limit balance->Drawdown_Helper->rollUpCalculation()->update updateFTList');
            System.debug(ex.getMessage()); 
        }
        
         //Facility
        Decimal ficilityTotal = 0.0;
        list<Facility__c> updateFicilityList = new list<Facility__c>();
        
        if(facilityIds.size() > 0){
                        
            for(Facility__c f :[Select Id, Facility_Limit__c, FacilityLimitBalance__c, (Select Advance_Amount__c From Drawdowns__r Where Status__c != 'Cancelled') 
                                         From Facility__c 
                                         Where Id IN :facilityIds]){
               
               for(Drawdown__c rollDraws :f.Drawdowns__r){
                 ficilityTotal+= rollDraws.Advance_Amount__c;                   
               }
                                       
               mapFDrawAmountTotal.put(f.Id, ficilityTotal);
               //reset                              
               ficilityTotal = 0.0;
           }
            
            //loop through the relevent Facility and add the new drawdown amount, we have to do this as some facilities might not have existing
            //drawdowns so we cannot add this new amounts in the joined loop as we might never enter the loop for some Facilities
            ficilityTotal = 0.0;
            for(Facility__c f :[Select Id, Facility_Limit__c, FacilityLimitBalance__c From Facility__c Where Id IN :facilityIds]){
               //add new drawdown amount                            
               ficilityTotal = (mapFDrawAmountTotal.get(f.Id));
                
                if(f.Facility_Limit__c != null){
                   f.FacilityLimitBalance__c = (f.Facility_Limit__c - ficilityTotal);
                   updateFicilityList.add(f);
                }
            }
        }  
       
        try{
            if(updateFicilityList.size() > 0){
                update updateFicilityList; 
            }
        }catch(DMLException ex){
            System.debug('There was an error updating the Facility with a new limit balance->Drawdown_Helper->rollUpCalculation()->update updateFicilityList');
            System.debug(ex.getMessage()); 
        }
        
        //Now roll-up all drawdowns for all agreements and update the Deal / Matter with the limit balance
        Decimal agreeTotal = 0.0;
        set<Id> dealIds = new set<Id>();
        
        for(Agreement__c agr :[Select Matter_Deal__c, Limit__c, (Select Advance_Amount__c From Drawdowns__r Where Status__c != 'Cancelled') From Agreement__c 
                              Where Id IN :agreementIds]){
            
            if(agr.Drawdowns__r != null)
            {
                for(Drawdown__c rollDraws :agr.Drawdowns__r){
                 agreeTotal+= rollDraws.Advance_Amount__c;                   
           		}
            }
                                  
            //get new draw amount and add to total, then add to map for deal update
            if(agr.Limit__c != null){
                mapAgreeDrawAmountTotal.put(agr.Matter_Deal__c, (agr.Limit__c - agreeTotal));
                dealIds.add(agr.Matter_Deal__c);
            }

            //reset total counter
            agreeTotal = 0.0;
            
        }
        
        //Update deals for all agreements with total balance
        list<advpm__Matter__c> updateDealList = new list<advpm__Matter__c>();
        
        for(advpm__Matter__c deal :[Select Id From advpm__Matter__c Where Id IN :dealIds]){
            if(mapAgreeDrawAmountTotal.containsKey(deal.Id)){
                deal.TotalLimitBalance__c = mapAgreeDrawAmountTotal.get(deal.Id);
                updateDealList.add(deal);
            } 
        }
        
        if(updateDealList.size() > 0){
            try{
                update updateDealList;
            }catch(DMLException ex){
                System.debug('There was an error updating the Deal/Matter with a new limit balance->Drawdown_Helper->rollUpCalculation()->update updateDealList');
                System.debug(ex.getMessage()); 
            }
        }
    }
    
}