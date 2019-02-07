/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 10/11/2017 - PG    - Created Class. 
 23/11/2017 - PG 	- Added Handling to upload to box.com.
 17/01/2017 - PG 	- Moved Answer file processing to after request item upserts.
 13/03/2018 - PG 	- Updated to use metadata type.

**/
public class HotDocs_Request_Queue implements Queueable, Database.AllowsCallouts 
{
	private HotDocs_Request__c hotDocsRequest { get; set; }
	private HotDocs_API api { get; set; }
	private Map<String, HotDocs_Request_Item__c> existingRequestItems { get; set; }
	private Map<String, String> existingBoxDocuments { get; set; }
	private Boolean hasAnswerFile { get; set; }
    public static Map <String, Schema.RecordTypeInfo> agreementTemplateRecordTypes = Agreement_Template__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
	
	public HotDocs_Request_Queue(String iHotDocsRequestId)  
	{
		//Blank vars.
		Set<String> jobNames = new Set<String>();		
		existingRequestItems = new Map<String, HotDocs_Request_Item__c>(); 
		existingBoxDocuments = new Map<String, String>();
		hasAnswerFile = false;

		try
		{
	    	//Instantiate API
	    	api = new HotDocs_API();	

	    	//Load hotdocs request and existing items.
			hotDocsRequest = [
				SELECT
					Id, 
					Work_Item_ID__c,
                	Supporting_Agreement__c,
                	Supporting_Agreement__r.Agreement_Template__r.RecordTypeId,
					Agreement__c,
                    Agreement__r.Agreement_Template__r.RecordTypeId,
                    Agreement__r.Master_Agreement_Type__c,
					Attempts__c, 
					(
						SELECT
							Id,
							Type__c,
							Item_ID__c,
							Status__c,
							Box_Document__c
						FROM HotDocs_Request_Items__r 
					)
				FROM HotDocs_Request__c
				WHERE
					Id = :iHotDocsRequestId 
			];

			//Get all existing hotdocs request items for Agreement.
			List<HotDocs_Request_Item__c> agreementRequestItems = new List<HotDocs_Request_Item__c>([
				SELECT
					Id,
					HotDocs_Request__r.Agreement__c,
					Box_Document__c,
					Box_Document__r.Name
				FROM HotDocs_Request_Item__c
				WHERE
					HotDocs_Request__r.Agreement__c = :hotDocsRequest.Agreement__c
					AND Box_Document__c != null
			]);

			//Build up a map of existing document name to box document id.
			for(HotDocs_Request_Item__c requestItem : agreementRequestItems)
			{
				existingBoxDocuments.put(requestItem.Box_Document__r.Name, requestItem.Box_Document__c);
			}

			//Build up a map for easy reference of existing items.
			for(HotDocs_Request_Item__c requestItem : hotDocsRequest.HotDocs_Request_Items__r)
			{
			 	if(requestItem.Type__c == 'Document')
			 	{
			 		existingRequestItems.put(requestItem.Item_ID__c, requestItem);
			 	}

			 	if(requestItem.Type__c == 'Answer File')
			 	{
			 		hasAnswerFile = true;
			 	}
			}

			//Ensure our monitoring job is scheduled.
			List<CronTrigger> cronJobs = new List<CronTrigger>([
				SELECT
					Id,
					CronJobDetail.Name
				FROM CronTrigger
				WHERE
					CronJobDetail.Name LIKE '%HotDocs Request Monitoring%' 
			]);

			//Build set for existing schedule reference.
			for(CronTrigger cronJob : cronJobs)
			{
				jobNames.add(cronJob.CronJobDetail.Name);
			}

			//Monitoring is active and needs to be scheduled every 15 mins.
			if(api.SETTINGS.Enable_Monitoring__c == true && cronJobs.size() != 4) 
			{
				if(!jobNames.contains('HotDocs Request Monitoring - 0'))
				{
					System.schedule('HotDocs Request Monitoring - 0', '0 0 * * * ? ', new HotDocs_Request_Monitoring());
				}

				if(!jobNames.contains('HotDocs Request Monitoring - 15'))
				{
					System.schedule('HotDocs Request Monitoring - 15', '0 15 * * * ? ', new HotDocs_Request_Monitoring());
				} 

				if(!jobNames.contains('HotDocs Request Monitoring - 30'))
				{
					System.schedule('HotDocs Request Monitoring - 30', '0 30 * * * ? ', new HotDocs_Request_Monitoring());
				} 

				if(!jobNames.contains('HotDocs Request Monitoring - 45'))
				{
					System.schedule('HotDocs Request Monitoring - 45', '0 45 * * * ? ', new HotDocs_Request_Monitoring());
				} 
			}
		}
		catch(Exception e)
		{
			DebugLog.create( new DebugLog.Error(e, 'HotDocs_Request_Queue', 'constructor', 'HotDocs Request ID: '+iHotDocsRequestId) );    
		}
	}

	public void execute(QueueableContext context)
	{
		System.debug('### HotDocs_Request_Queue : execute');

		//Blank vars.
		List<HotDocs_Request_Item__c> requestItems = new List<HotDocs_Request_Item__c>();		
		Map<String, HotDocs_Document> retrievedDocumentsMetadata = new Map<String, HotDocs_Document>();		
		List<BoxDocument__c> newBoxDocuments = new List<BoxDocument__c>();
		Map<String, BoxDocument__c> newRequestBoxDocuments = new Map<String, BoxDocument__c>();
		Set<Id> boxDocumentIds = new Set<Id>();
		String answerXML = '';

		try
		{
			System.debug('### HotDocs_Request_Queue : execute : try ');

			//Fetch work item metadata.
			HotDocs_WorkItem workItem = api.getWorkItemMetadata(hotDocsRequest.Work_Item_ID__c);

			System.debug('### HotDocs_Request_Queue : execute : try : AFTER');

			//Loop over work item documents.
			for(HotDocs_WorkItem.AssembledDocuments assembledDocument : workItem.PrimaryTemplate.AssembledDocuments)
			{	
				//Retrieve document meta data from HotDocs.
				HotDocs_Document documentMeta = api.getDocumentMetadata(hotDocsRequest.Work_Item_ID__c, assembledDocument.DocumentId);
				retrievedDocumentsMetadata.put(assembledDocument.DocumentId, documentMeta);

				//If this is NOT an existing document item.
				if(!existingRequestItems.containsKey(assembledDocument.DocumentId))
				{
					//New Document Request Item.
					HotDocs_Request_Item__c requestItem = new HotDocs_Request_Item__c(
						Item_ID__c = assembledDocument.DocumentId, 
						HotDocs_Request__c = hotDocsRequest.Id, 
						Type__c = 'Document',
						Status__c = 'Queued' 
					);

					//If there is an existing box document with this file name associate the box document.
					if(existingBoxDocuments.containsKey(documentMeta.Title+documentMeta.FileExtension))
					{
						requestItem.Box_Document__c = existingBoxDocuments.get(documentMeta.Title+documentMeta.FileExtension);
					}

					//Add to insert list.
					requestItems.add(requestItem);
				}

				//Existing request item
				if(existingRequestItems.containsKey(assembledDocument.DocumentId))
				{
					//It is not completed yet.
					if(existingRequestItems.get(assembledDocument.DocumentId).Status__c != 'Completed')
					{
						//Add existing list for processing.
						requestItems.add(existingRequestItems.get(assembledDocument.DocumentId));
					}
				}
			}

			//Needed to add answer file if needed.
			Integer answerIndex = requestItems.size();					

			//New answer request item.
			if(hasAnswerFile == false)
			{
				//Fetch answer file content.
				answerXML = api.getAnswerSetXmlFile(workItem.AnswerSetId);

				HotDocs_Request_Item__c answerItem = new HotDocs_Request_Item__c(
					Item_ID__c = workItem.AnswerSetId, 
					HotDocs_Request__c = hotDocsRequest.Id, 
					Type__c = 'Answer File',
					Status__c = 'Completed'
				);			

				//Add to list.
				requestItems.add(answerItem); 
			}

			//Upsert Request Items.
			upsert requestItems;

			//Have we set to store answer file?
			if(api.SETTINGS.Keep_Answer_File__c == true && hasAnswerFile == false) 
			{
				Attachment attachment = new Attachment();
				attachment.Body = Blob.valueOf(answerXML); 
  				attachment.Name = 'Received-AnswerFile.xml';
  				attachment.ParentId = requestItems[answerIndex].Id; 
  				insert attachment;
			}

			//Process after request items, so we can see the XML file if processing fails.
			if(hasAnswerFile == false)
			{
				//Process AnswerXML
				//Libra 
				if(hotDocsRequest.Supporting_Agreement__r.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
                {
                    //CSA
                    if(hotDocsRequest.Supporting_Agreement__c != null)
                    {
                        HotDocs_Helper.processCsaAnswerXML(hotDocsRequest.Supporting_Agreement__c, answerXML);
                    }
                }
				else if(hotDocsRequest.Agreement__r.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
                {
                     //Prime Services
                    if(hotDocsRequest.Agreement__r.Master_Agreement_Type__c == 'Prime Services Agreement')
                    {
                        HotDocs_Helper.processPrimeServicesAnswerXML(hotDocsRequest.Agreement__c, answerXML);
                    }
                    //GMSLA
                    else if(hotDocsRequest.Agreement__r.Master_Agreement_Type__c == 'GMSLA Agreement')
                    {
                        HotDocs_Helper.processGmslaAnswerXML(hotDocsRequest.Agreement__c, answerXML);
                    }
                    //GMRA
                    else if(hotDocsRequest.Agreement__r.Master_Agreement_Type__c == 'GMRA Agreement')
                    {
                        HotDocs_Helper.processGmraAnswerXML(hotDocsRequest.Agreement__c, answerXML);
                    }
                    //ISDA
                    else if(hotDocsRequest.Agreement__r.Master_Agreement_Type__c == 'ISDA Agreement')
                    {
                        HotDocs_Helper.processIsdaAnswerXML(hotDocsRequest.Agreement__c, answerXML);
                    }
                }
                //TMG and LEAP
                else
                {
                    HotDocs_Helper.processAnswerXML(hotDocsRequest.Agreement__c, answerXML);
                }
				
			}

			//Loop over request items for box document processing.
			for(HotDocs_Request_Item__c requestItem : requestItems)
			{
				if(requestItem.Type__c == 'Document')
				{
					if(requestItem.Box_Document__c == null)
					{
						//New Box Document
						BoxDocument__c boxDocument = new BoxDocument__c(
							Name = retrievedDocumentsMetadata.get(requestItem.Item_ID__c).Title + retrievedDocumentsMetadata.get(requestItem.Item_ID__c).FileExtension,
							Agreement__c = hotDocsRequest.Agreement__c,
							PII__c = 'Yes',
							Owner_Type__c = 'Agreement__c'
						);

						//Add to insert list.
						newBoxDocuments.add(boxDocument);

						//Add to reference map for after insert linking.
						newRequestBoxDocuments.put(requestItem.Id, boxDocument);			
					}
					else
					{
						//Add to set for processing.
						boxDocumentIds.add(requestItem.Box_Document__c);  
					}
				}
			}

			//Any new box documents to insert?
			if(!newBoxDocuments.isEmpty())
			{
				insert newBoxDocuments;
			}

			//Update the box document reference on each item.
			for(HotDocs_Request_Item__c requestItem : requestItems)
			{
				//Needs to be associated to box document?
				if(requestItem.Box_Document__c == null && requestItem.Type__c == 'Document' && newRequestBoxDocuments.containsKey(requestItem.Id))
				{
					//Set box id on request.
					requestItem.Box_Document__c = newRequestBoxDocuments.get(requestItem.Id).Id;
					
					//Add to set for processing.
					boxDocumentIds.add(requestItem.Box_Document__c); 
				}
			}

			//Update request items with Box Ids.
			update requestItems;

			//finally call box to upload files.
			for(HotDocs_Request_Item__c requestItem : requestItems)
			{	
				if(requestItem.Type__c == 'Document' && requestItem.Box_Document__c != null)
				{
					//Future call out.
					HotDocs_Helper.retrieveDocument(requestItem.Id);
				}
			}
		}
		catch(Exception e)
		{
			//Mark request as 'Failed'
			hotDocsRequest.Status__c = 'Failed'; 

			//Log Error.
			DebugLog.create( new DebugLog.Error(e, 'HotDocs_Request_Queue', 'execute', 'HotDocs Request ID: '+hotDocsRequest.Id) );
		}
		finally
		{
			//Update the request.
			hotDocsRequest.Job_ID__c = context.getJobId();
			hotDocsRequest.Attempts__c = hotDocsRequest.Attempts__c + 1;
			hotDocsRequest.Last_Attempt__c = DateTime.now();
			update hotDocsRequest;
		}
	}
}