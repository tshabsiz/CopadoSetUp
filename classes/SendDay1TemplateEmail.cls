/**
* @author Deloitte 
* @date 2015
*
* @group Day 1 Template
*
* @description Class which converts the Day 1 Template contents into PDF, collects attachments for object and sends those to group email 
* defined within custom settings
*/
public class SendDay1TemplateEmail {
	private ApexPages.StandardController stdCtrl {get; set;}
	public Day_1_Template__c dayObj {get;set;}
	private String SEND_TO_ADDRESS {get;set;}

	/**
    * @description Constructor
    */
	public SendDay1TemplateEmail(ApexPages.StandardController std)
	{
		Day_1_TemplateCS__c cs = Day_1_TemplateCS__c.getInstance('SendToGroupAddress');
		SEND_TO_ADDRESS = cs.SendToGroupAddress__c;
		stdCtrl = std;
	}

	/**
    * @description Sends the day 1 template object as email
    */
	public void sendDay1TemplateAsEmail() 
	{
		dayObj = [SELECT Id, Createdby.Name, Name, Primary_Legal_Entity__r.Name, Primary_Legal_Entity__r.Owner.Name FROM Day_1_Template__c WHERE Id=:stdCtrl.getId()];
		List<Day_1_Template_GS__c> attObjList = [SELECT Id, Name, Attachment__c, Day_1_Template__c FROM Day_1_Template_GS__c WHERE Day_1_Template__c =: dayObj.Id];

		List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
		for(Day_1_Template_GS__c d1gs : attObjList)
		{
			List<Attachment> atts = [select Name, Body, BodyLength from Attachment where ParentId = :d1gs.Id];
			for (Attachment a : atts)
			{  
				Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
				efa.setFileName(a.Name); 
				efa.setBody(a.Body); 
				fileAttachments.add(efa);
			}
		}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		PageReference pdf = Page.Day1TemplateAsPDF;
		pdf.getParameters().put('id',(String)dayObj.id);
   		pdf.setRedirect(true);

   		Blob content;
   		if (Test.IsRunningTest())
			content = Blob.valueOf('UNIT.TEST');
		else
		    content = pdf.getContent();

   		Messaging.EmailFileAttachment pdfAtt = new Messaging.EmailFileAttachment();
	    pdfAtt.setFileName('Day 1 Template ' + dayObj.Primary_Legal_Entity__r.Name + '.pdf');
	    pdfAtt.setBody(content);
	    fileAttachments.add(pdfAtt);

		mail.setToAddresses(new String[]{SEND_TO_ADDRESS});
		mail.setSenderDisplayName('Salesforce Day1 Template'); 
		mail.setUseSignature(false);
		mail.setBccSender(false);
		mail.setSaveAsActivity(true);
		mail.setPlainTextBody(getEmailTextBody());

		mail.setFileAttachments(fileAttachments);

		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}

	private String getEmailTextBody()
	{
		String body = 'Dear Onboarding Team,\nPlease find Day 1 Template attached for client ' + dayObj.Primary_Legal_Entity__r.Name;
		body += ' for your attention. Submitter\'s name is ' + dayObj.Createdby.Name + ', client owner\'s name ' + dayObj.Primary_Legal_Entity__r.Owner.Name + '.\n';
		body += 'This is an automatically generated email, please do not reply.';
		return body;
	}
}