/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate : 2017-05-31
@Description : Helper class for Batch_SendOpportunityEmailAlert
@Test Class : Batch_SendOpportunityEmailAlert_Test
------------------------------------------------------*/
public class SendOpportunityEmailAlert_Function 
{
    // Tonga MM : Sendout emails to opportunity owner or owners and their line manager in the parameter list
    public static void sendWarningEmail(List<Opportunity> oppList, String templatID,boolean isEscalated)
    {
        try
        {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = :Label.lblSupportUserName limit 1];
            for(Opportunity currentOpp : OppList)
            {
                List<String> recipient =new List<String>();
                
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                
                msg.setTargetObjectId(currentOpp.ownerID);
                msg.setTreatTargetObjectAsRecipient(true);
                msg.setReplyTo(owea[0].Address);
				msg.setOrgWideEmailAddressId(owea[0].ID);
                msg.setTemplateId(templatID);
                msg.setWhatId(currentOpp.ID);
                
                if(isEscalated)
                {
                    if(!String.isblank(currentOpp.Owner.Manager.Email)){
                        String[] ccAddresses = new String[] {currentOpp.Owner.Manager.Email};
                            msg.setCCAddresses(ccAddresses);
                    }
                }
                
                
                msg.setSaveAsActivity(false);
                
                mails.add(msg);
            }
            Messaging.sendEmail(mails);
            System.debug('Email Sent');
        }
        catch(Exception exc)
        {
            system.debug('Exception '+exc.getMessage());
        }
    }
    public static void sendWarningEmailProductPartner(List<Opportunity> oppList, String templatID,boolean isEscalated)
    {
        try
        {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = :Label.lblSupportUserName limit 1];
            for(Opportunity currentOpp : OppList)
            {
                List<String> recipient =new List<String>();
                
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                
                msg.setTargetObjectId(currentOpp.ProductPartner__c);
                msg.setTreatTargetObjectAsRecipient(true);
                msg.setReplyTo(owea[0].Address);
				msg.setOrgWideEmailAddressId(owea[0].ID);
                msg.setTemplateId(templatID);
                msg.setWhatId(currentOpp.ID);
                
                if(isEscalated)
                {
                    if(!String.isblank(currentOpp.ProductPartner__r.Manager.Email)){
                        String[] ccAddresses = new String[] {currentOpp.ProductPartner__r.Manager.Email};
                            msg.setCCAddresses(ccAddresses);
                    }
                }
                msg.setSaveAsActivity(false);
                
                mails.add(msg);
            }
            Messaging.sendEmail(mails);
        }
        catch(Exception exc)
        {
            System.debug('Failure '+exc.getMessage());
        }
    }
}