global class Batch_Opportunities_Without_Products implements Schedulable, Database.Batchable<sObject> {
	static List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        return Database.getQueryLocator([SELECT Id,
                                         Name,
                                         Account.Name,
                                         Related_Group_Client__r.Name,
                                         StageName,
                                         Opportunity_Country__c,
                                         CloseDate,
                                         Owner.FirstName,
                                         Owner.LastName,
                                         Owner.Email,
                                         Owner.ManagerId,
                                         Owner.Manager.Email
                                         FROM Opportunity
                                         WHERE StageName NOT IN ('Closed Won','Closed Lost')
                                         AND ProductCount__c = 0
                                         AND Owner.isActive = true
                                         AND RecordType.Name IN ('Private opportunity','Public opportunity')
                                         ORDER BY CloseDate
                                        ]);
    }
    
    global void execute(SchedulableContext sc)
    {
    	Database.executeBatch(new Batch_Opportunities_Without_Products());   
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {   
    	Map<Id, List<OpportunityEmail>> oppEmails = new Map<Id, List<OpportunityEmail>>();
                
        for(Opportunity opp : scope) {
        	String RecipientName = opp.Owner.FirstName + ' ' + opp.Owner.LastName;
            String RecipientEmail = opp.Owner.Email;
            String ManagerEmail = opp.Owner.Manager.Email;
            
          	if (oppEmails.containsKey(opp.OwnerId))
           		oppEmails.get(opp.OwnerId).add(new OpportunityEmail(opp, RecipientName, RecipientEmail, ManagerEmail));
            else
                oppEmails.put(opp.OwnerId, new List<OpportunityEmail>{new OpportunityEmail(opp, RecipientName, RecipientEmail, ManagerEmail)});
        }
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: Label.SalesforceSupportEmail];
        Id OrgWideEmailAddressId = NULL;
		if (owea.size() > 0) {
    		OrgWideEmailAddressId = owea.get(0).Id;
		}
        
        for(Id OwnerId : oppEmails.keySet()) {
        	mailList.add(CreateNewOpportunityEmail(oppEmails.get(OwnerId), OrgWideEmailAddressId));
        }
        
        Messaging.SendEmailResult [] sers = Messaging.sendEmail(mailList, false);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    private static Messaging.SingleEmailMessage CreateNewOpportunityEmail(List<OpportunityEmail> opps, Id OrgWideEmailAddressId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> sendTo = new List<String>();
        if (opps[0].RecipientEmail != NULL) sendTo.add(opps[0].RecipientEmail);
        List<String> ccTo = new List<String>();
        if (opps[0].ManagerEmail != NULL) ccTo.add(opps[0].ManagerEmail);
        
        mail.setToAddresses(sendTo);
        mail.setCcAddresses(ccTo);
    
        mail.setEmailPriority('High');
        if (OrgWideEmailAddressId != NULL) mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
        mail.setReplyTo('noreply@salesforce.com');
        
	    mail.setSubject('Opportunities without Products - ' + DateTime.Now().format('dd MMM yyyy'));
        String body = '<body bgcolor=white lang=EN-US link="#0563C1" vlink="#954F72" style=\'tab-interval:.5in\'>';
        body += '<div class=WordSection1>';
        body += '<p class=MsoNormal><o:p>&nbsp;</o:p></p>';
		body += '<div align=center>';
        body += '<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=500';
 		body += 'style=\'width:375.0pt;mso-cellspacing:0in;mso-yfti-tbllook:1184;mso-padding-alt:';
 		body += '0in 0in 0in 0in\'>';
 		body += '<tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes;height:18.75pt\'>';
  		body += '<td valign=top style=\'background:white;padding:0in 0in 0in 0in;height:18.75pt\'>';
  		body += '<p class=MsoNormal><span style=\'mso-no-proof:yes\'><img width=650 height=215 ';
  		body += 'id="_x0000_i1026" ';
  		body += 'src="https://absa1.my.salesforce.com/servlet/servlet.ImageServer?id=0151p000006VwDP&amp;oid=00D24000000JOMz" ';
  		body += 'alt="https://absa1.my.salesforce.com/servlet/servlet.ImageServer?id=0151p000006VwDP&amp;oid=00D24000000JOMz"></span></p>';
  		body += '</td>';
 		body += '</tr>';
 		body += '<tr style=\'mso-yfti-irow:1\'>';
  		body += '<td valign=top style=\'background:white;padding:0in 0in 0in 0in;bEditID:r2st1;';
  		body += 'bLabel:accent1\'></td>';
        body += '</tr>';
 		body += '<tr style=\'mso-yfti-irow:2;height:225.0pt\'>';
        body += '<td valign=top style=\'background:white;padding:0in 0in 0in 0in;height:225.0pt;';
  		body += 'bEditID:r3st1;bLabel:main\'>';
  		body += '<table class=MsoNormalTable border=0 cellspacing=5 cellpadding=0 width=600';
   		body += 'style=\'width:6.25in;mso-cellspacing:3.7pt;mso-yfti-tbllook:1184;mso-padding-alt:';
   		body += '0in 0in 0in 0in\'>';
   		body += '<tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes;height:37.5pt\'>';
    	body += '<td valign=top style=\'background:white;padding:3.75pt 3.75pt 3.75pt 3.75pt;';
    	body += 'height:37.5pt\'>';
    	body += '<p class=MsoNormal><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black;background:white\'>Dear&nbsp;' + opps[0].opportunity.Owner.FirstName + ',';
    	body += '</span><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black\'><o:p></o:p></span></p>';
    	body += '</td>';
   		body += '</tr>';
   		body += '<tr style=\'mso-yfti-irow:1;height:225.0pt\'>';
    	body += '<td valign=top style=\'background:white;padding:3.75pt 3.75pt 3.75pt 3.75pt;';
    	body += 'height:225.0pt;bEditID:r3st1;bLabel:main\'>';
    	body += '<p class=MsoNormal><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black\'>The following open opportunities do not have products associated to them:<o:p></o:p></span></p>';
        
        body += '<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0';
 		body += 'style=\'border-collapse:collapse;border:none\'>';
 		body += '<tr>';
        body += '<td width=95 valign=top style=\'width:95.75pt;border:solid windowtext 1.0pt;';
        body += 'padding:0in 5.4pt 0in 5.4pt\'>';
        body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
        body += 'normal\'><b><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
        body += 'color:black\'>Name</span></b></p>';
        body += '</td>';
        body += '<td width=95 valign=top style=\'width:95.75pt;border:solid windowtext 1.0pt;';
        body += 'border-left:none;padding:0in 5.4pt 0in 5.4pt\'>';
        body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
        body += 'normal\'><b><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
        body += 'color:black\'>Relationship Name</span></b></p>';
        body += '</td>';
        body += '<td width=95 valign=top style=\'width:95.75pt;border:solid windowtext 1.0pt;';
        body += 'border-left:none;padding:0in 5.4pt 0in 5.4pt\'>';
        body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
        body += 'normal\'><b><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
        body += 'color:black\'>Related Group Client</span></b></p>';
        body += '</td>';
        body += '<td width=65 valign=top style=\'width:65pt;border:solid windowtext 1.0pt;';
        body += 'border-left:none;padding:0in 5.4pt 0in 5.4pt\'>';
        body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
        body += 'normal\'><b><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
        body += 'color:black\'>Stage</span></b></p>';
        body += '</td>';
        body += '<td width=65 valign=top style=\'width:65pt;border:solid windowtext 1.0pt;';
        body += 'border-left:none;padding:0in 5.4pt 0in 5.4pt\'>';
        body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
        body += 'normal\'><b><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
        body += 'color:black\'>Country</span></b></p>';
        body += '</td>';
        body += '<td width=65 valign=top style=\'width:65pt;border:solid windowtext 1.0pt;';
        body += 'border-left:none;padding:0in 5.4pt 0in 5.4pt\'>';
        body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
        body += 'normal\'><b><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
        body += 'color:black\'>Close Date</span></b></p>';
        body += '</td>';
 		body += '</tr>';
        for(OpportunityEmail opp : opps) {
            String OpportunityName = opp.opportunity.Name == NULL ? '&nbsp;' : opp.opportunity.Name;
            String AccountName = opp.opportunity.Account.Name == NULL ? '&nbsp;' : opp.opportunity.Account.Name;
            String RelatedGroupClient = opp.opportunity.Related_Group_Client__r.Name == NULL ? '&nbsp;' : opp.opportunity.Related_Group_Client__r.Name; 
            String StageName = opp.opportunity.StageName == NULL ? '&nbsp;' : opp.opportunity.StageName;
            String OpportunityCountry = opp.opportunity.Opportunity_Country__c == NULL ? '&nbsp;' : opp.opportunity.Opportunity_Country__c;
            String CloseDate = opp.opportunity.CloseDate == NULL ? '&nbsp;' : ((DateTime)opp.opportunity.CloseDate).format('dd MMM yyyy');
            String OppId = opp.Opportunity.Id;
                
            body += '<tr>';
            body += '<td width=95 valign=top style=\'width:95pt;border:solid windowtext 1.0pt;';
            body += 'border-top:none;padding:0in 5.4pt 0in 5.4pt\'>';
            body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
            body += 'normal\'><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
            body += 'color:black\'><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + OppId + '">' + OpportunityName + '</a></span></p>';
            body += '</td>';
            body += '<td width=95 valign=top style=\'width:95pt;border-top:none;border-left:';
            body += 'none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;';
            body += 'padding:0in 5.4pt 0in 5.4pt\'>';
            body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
            body += 'normal\'><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
            body += 'color:black\'>' + AccountName + '</span></p>';
            body += '</td>';
            body += '<td width=95 valign=top style=\'width:95pt;border-top:none;border-left:';
            body += 'none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;';
            body += 'padding:0in 5.4pt 0in 5.4pt\'>';
            body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
            body += 'normal\'><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
            body += 'color:black\'>' + RelatedGroupClient + '</span></p>';
            body += '</td>';
            body += '<td width=65 valign=top style=\'width:65pt;border-top:none;border-left:none;';
            body += 'border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;';
            body += 'padding:0in 5.4pt 0in 5.4pt\'>';
            body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
            body += 'normal\'><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
            body += 'color:black\'>' + StageName + '</span></p>';
            body += '</td>';
            body += '<td width=65 valign=top style=\'width:65pt;border-top:none;border-left:none;';
            body += 'border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;';
            body += 'padding:0in 5.4pt 0in 5.4pt\'>';
            body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
            body += 'normal\'><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
            body += 'color:black\'>' + OpportunityCountry + '</span></p>';
            body += '</td>';
            body += '<td width=65 valign=top style=\'width:65pt;border-top:none;border-left:';
            body += 'none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;';
            body += 'padding:0in 5.4pt 0in 5.4pt\'>';
            body += '<p class=MsoNormal style=\'margin-bottom:0in;margin-bottom:.0001pt;line-height:';
            body += 'normal\'><span style=\'font-size:10.0pt;font-family:"Arial","sans-serif";';
            body += 'color:black\'>' + CloseDate + '</span></p>';
            body += '</td>';
            body += '</tr>';
        }
		body += '</table>';
        
    	body += '<div>';
    	body += '<p class=MsoNormal><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black\'>To stop receiving these emails please add a product to the opportunities listed above.';
    	body += '<o:p></o:p></span></p>';
    	body += '</div>';
    	body += '<div>';
    	body += '<p class=MsoNormal><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black\'><o:p>&nbsp;</o:p></span></p>';
    	body += '</div>';
    	body += '<div>';
    	body += '<p class=MsoNormal><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black\'>Thanks&nbsp;<o:p></o:p></span></p>';
    	body += '</div>';
    	body += '<div>';
    	body += '<p class=MsoNormal><span style=\'font-family:"Arial","sans-serif";';
    	body += 'color:black\'>Salesforce<o:p></o:p></span></p>';
    	body += '</div>';
    	body += '</td>';
   		body += '</tr>';
	  	body += '</table>';
  		body += '</td>';
        body += '</tr>';
 		body += '<tr style=\'mso-yfti-irow:4;height:20.0pt\'>';
  		body += '<td valign=top style=\'background:white;padding:0in 0in 0in 0in;height:20.0pt;';
  		body += 'bEditID:r5st1;bLabel:footer\'>';
  		body += '<p class=MsoNormal><span style=\'mso-no-proof:yes\'><img width=650 height=61 ';
  		body += 'id="_x0000_i1025" ';
  		body += 'src="https://absa1.my.salesforce.com/servlet/servlet.ImageServer?id=0151p000006VkYu&amp;oid=00D24000000JOMz" ';
  		body += 'alt="https://absa1.my.salesforce.com/servlet/servlet.ImageServer?id=0151p000006VkYu&amp;oid=00D24000000JOMz"></span></p>';
  		body += '</td>';
 		body += '</tr>';
 		body += '<tr style=\'mso-yfti-irow:5;mso-yfti-lastrow:yes\'>';
  		body += '<td valign=top style=\'background:white;padding:0in 0in 0in 0in;bEditID:r6st1;';
  		body += 'bLabel:accent3\'></td>';
 		body += '</tr>';
		body += '</table>';
		body += '</div>';
		body += '</div>';
		body += '</body>';
        
        mail.setHtmlBody(body);
        
        return mail;
    }
    
    private class OpportunityEmail {
        private Opportunity opportunity;
        private String RecipientName;
        private String RecipientEmail;
        private String ManagerEmail;
        
        public OpportunityEmail(Opportunity opp, String RcpntName, String RcpntEmail, String MngrEmail) {
            opportunity = opp;
			RecipientName = RcpntName;
            RecipientEmail = RcpntEmail;
            ManagerEmail = MngrEmail;
        }
    }
}