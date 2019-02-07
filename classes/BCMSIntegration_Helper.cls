/**
* @author Deloitte 
* @date 2015
*
* @group WebService / Integration
*
* @description methods to establish integration with BCMS
*/
public class BCMSIntegration_Helper {

	public Boolean isCreateSuccess;

	private static final String OPERATION_DONE_BY = 'Salesforce'; 												//constant value to populate field in BCMS of who did the last operation
	private static final String BCMS_PROSPECT_CASE_DEFINITION_ID = '993a9b27-9f1e-4b0a-8384-4bebc0769cd2';		//constant value for creating prospect cases in BCMS for case definiton
	private static final String BCMS_CLIENT_CASE_DEFINITION_ID = 'fe68c2a9-cb12-4eb7-aa1a-de31ed78ccc6';		//constant value for creating client cases in BCMS for case definiton
	private static final String TEST_JSON_RETURN = '{"pickList":[{"value":"1 - MONETARY AUTHORITY","code":1155},{"value":"2 - BANKS","code":1156}, {"value":"11510 - GAME PROPAGATION", "code":"11510"}, {"value":"Foreign Companies", "code":"9"}, {"value":"MARKETS", "code":"1225"}, {"value":"MANAGER", "code":"01"}]}';
	private static final String STATUS = 'Sent to ESP';

	/**
	* @description create case_x object handler
	* @param Id day1Id
	* @return String with error messages
	*/  
	public String createBcmsCase(Id day1Id) {
        WS_BCMS.Case_x caseCreated;
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        String caseBCMSId;
        String emptyFields;									//storing info about required fields that are empty, to be shown to user
        Day_1_Template__c day1template;						//Day1template document to be retrieved and updated with BCSM case Id

        try {
            Day_1_Template__c day1record = bcmsIntH.getDay1Record(day1Id);
            day1template = [SELECT Id, BCMS_Prospect_Id__c, Status__c FROM Day_1_Template__c WHERE Id = :day1Id][0];

            //checking fields if all fields have values
            emptyFields = bcmsIntH.checkValuesForDay1Fields(day1record);                    
            
            if(String.isEmpty(emptyFields)) {
                // creating case in BCMS
                caseCreated = bcmsIntH.saveBCMSCase(day1record);
                //if the case was succesfuly created we need to obtain it's Id
                if (caseCreated != null) {
                    caseBCMSId = caseCreated.Id;
                    day1template.BCMS_Prospect_Id__c = caseBCMSId;
                    Day1template.Status__c = STATUS;
                    //updating BCMS case ID to our object
                    update day1template;
                    System.debug('XXXXXXXXXXXXXXX retreived case Id ' + caseBCMSId);
                }
            } else {
                return emptyFields;

            }   
        } catch(Exception e) {
            System.debug('we were not able to create case ' + e);
            isCreateSuccess = false;
            return 'We were unable to create case <br/>' + e;
        }
        isCreateSuccess = true;
        return 'The case has been created. <br/>There is case Id: ' + caseBCMSId;
    }

	/**
	* @description update case_x object handler
	* @param Id day1Id
	* @return String with error messages
	*/  
	public String updateBcmsCaseHandler(Id day1Id) {
		WS_BCMS.Case_x caseUpdated;
		String caseBCMSId;
		BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();

		try {
			Day_1_Template__c day1record = bcmsIntH.getDay1Record(day1Id);
			caseUpdated = bcmsIntH.updateBCMSCase(day1record);
			if(caseUpdated != null) { 
				caseBCMSId = caseUpdated.Id;
			}	
		} catch (Exception e) {
			System.debug('we were not able to update case ' + e);
        	isCreateSuccess = false;
        	return 'We were unable to update case with Id' + caseBCMSId + '<br/>' + e;
		}
		isCreateSuccess = true;
        return 'The case with Id' + caseBCMSId + ' has been updated.';
	}	

    /**
	* @description create document in BCMS handler
	* @param Id attachId
	* @param String caseId / BCMS Case Id
	* @return String with error messages
	*/  
	public String createBcmsDocument(Id attachId, String caseId, Id day1Id) {
        List<BCMSDocumentWrapper> documentsWrapper;   										//list of documents to be created
        WS_BCMS.Document docCreated;       													//returned document that was saved				
        List<BCMSDocumentIdPairing__c> pairings = new List<BCMSDocumentIdPairing__c>();		//paring of the SF doc and BCMS doc
        BCMSDocumentIdPairing__c pair = new BCMSDocumentIdPairing__c();			
                
        try {
        	BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
	        documentsWrapper = bcmsIntH.createDocument(attachId, caseId);
	        //if documents list is not empty we will create document in BCMS
	        System.debug('XXXXXXXXXXXXXXX wrapper' + documentsWrapper);
	        if(!documentsWrapper.isEmpty()) {
	        	for (BCMSDocumentWrapper doc : documentsWrapper) {
	            	docCreated = bcmsIntH.saveBCMSDocument(doc.documentToCreate);
	            	System.debug('XXXXXXXXXXXXXXX doc' + doc);
	            	System.debug('XXXXXXXXXXXXXXX doccreated' + docCreated);
	            	pair.BCMSDocumentId__c = docCreated.Id;
	            	pair.SFDocumentId__c = doc.attachmentId;
	            	pair.Day1Id__c = day1Id;
	            	pairings.add(pair);
	        	}
	        	insert pairings;
	        	System.debug('XXXXXXXXXXXXXXX what I am about to save?' + pairings);	
	        }
	    } catch(Exception e) {
	    	System.debug('we were not able to create docs ' + e);
	    	isCreateSuccess = false;
            return 'We were unable to create docs <br/>' + e;
	    }
	    isCreateSuccess = true;
        return 'The document has been created. <br/>There is document Id: ' + docCreated.Id;
    }                

	/**
	* @description create case_x object in BCMS
	* @param Day_1_Template__c day1data
	* @return case that was created
	*/  
	public WS_BCMS.Case_x saveBCMSCase(Day_1_Template__c day1data) {
		
		//not using try catch here as the methods calling this one should have it (reason is for easier exception manipulation)
		WS_BCMS.BCMS wsBCMS = new WS_BCMS.BCMS(); 	        //initialize the BCMS class within WS_BCMS class
		WS_BCMS.Case_x createdCase; 						//returned created case from BCMS			
		createdCase = wsBCMS.CreateCase(createCase_x(day1data), OPERATION_DONE_BY);
		return createdCase;
	}

	/**
	* @description update case_x object in BCMS
	* @param Day_1_Template__c day1data
	* @return case that was updated
	*/  
	public WS_BCMS.Case_x updateBCMSCase(Day_1_Template__c day1data) {
		
		//not using try catch here as the methods calling this one should have it (reason is for easier exception manipulation)
		WS_BCMS.BCMS wsBCMS = new WS_BCMS.BCMS(); 	        //initialize the BCMS class within WS_BCMS class
		WS_BCMS.Case_x updatedCase; 						//returned created case from BCMS			
		updatedCase = wsBCMS.CreateCase(createCaseUpdate(day1data), OPERATION_DONE_BY);
		return updatedCase;
	}

	/**
	* @description create document object in BCMS
	* @param WS_BCMS.Document document
	* @return response / info that document was created
	*/ 
	public WS_BCMS.Document saveBCMSDocument(WS_BCMS.Document document) {

		//not using try catch here as the methods calling this one should have it (reason is for easier exception manipulation)
		WS_BCMS.BCMS wsBCMS = new WS_BCMS.BCMS(); 									//initialize the BCMS class within WS_BCMS class
		WS_BCMS.Document createdDocument = new WS_BCMS.Document();					//returned created doc from BCMS	

		createdDocument = wsBCMS.CreateDocument(document, OPERATION_DONE_BY);

		return createdDocument;
	}

	/**
	* @description parse BCMS XML so that user can see and edit values
	* @param String xmlAttachement base64 encoded XML
	* @return map with values keys = nod names, values = nod values
	*/ 
  	public static Map<String,String> parseBCMSAtestationXML(String xmlAttachement){

  		Dom.Document domDoc = new Dom.Document();
  		Map<String,String> parsedXMLMap = new Map<String,String>();

        // Check general integrity of provided XML
        try {
            domDoc.load(xmlAttachement);
        } catch (Exception e) {
            System.debug('Provided XML is impossible to parse. Exception details:' + e.getMessage() + ' ' + e.getLineNumber());
        }

        Dom.XMLNode root = domDoc.getRootElement();
        //System.debug('XXXXXXXXXXXXXXX root' + root);
        Dom.XmlNode[] items = root.getChildElements();

        for(Integer i = 0; i < items.size(); i ++) {
        	parsedXMLMap.put(items[i].getName(), items[i].getText());
        	//system.debug('XXXXXXXXXXXXXXX within forcycle' + items[i].getName() + ' ' + items[i].getText());
        }
        System.debug('XXXXXXXXXXXXXXX map' + parsedXMLMap);
        return parsedXMLMap;
  	}

	/**
	* @description parse BCMS XML and update specified node
	* @param String xmlAttachement base64 encoded XML
	* @param Boolean nodeText
	* @param String nodeToChange
	* @return String updatexml
	*/ 
  	public static String updateBCMSXMLNode(String xmlAttachement, String nodeText, String nodeToChange){  	

		Dom.Document domDoc = new Dom.Document();
		String updatedXml;

        // Check general integrity of provided XML
        try {
            domDoc.load(xmlAttachement);
        } catch (Exception e) {
            System.debug('Provided XML is impossible to parse. Exception details:' + e.getMessage() + ' ' + e.getLineNumber());
        }

        Dom.XMLNode root = domDoc.getRootElement();
        //System.debug('XXXXXXXXXXXXXXX root' + root);
        //Dom.XmlNode[] items = root.getChildElements();

        Dom.XmlNode nodeToUpdate = root.getChildElement(nodeToChange, null);

        String textToReplace = nodeToUpdate.getText();
        String nodeNameStart = '<' + nodeToChange + '>';
        String nodeNameExit = '</' + nodeToChange + '>';
 
        updatedXml = xmlAttachement.replace(nodeNameStart + textToReplace + nodeNameExit, nodeNameStart + nodeText + nodeNameExit);

        System.debug('XXXXXXXXXXXXXXX' + updatedXml);
        return updatedXml;
    }      		

    /**
	* @description retreive JSON string from static resource
	* @param String zipFile
	* @param String fileName
	* @param String extension 
	* @param String resourceName
	* @return String with JSON values for picklist
	*/  
	public static String returnJSONString(String zipFile, String fileName, String extension, String resourceName) {

		String fileString;
		StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name =:resourceName LIMIT 1];
		String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + zipFile + '/' + fileName + '.' + extension;
		
		PageReference file = new PageReference(srPath);				
		try {
			fileString = file.getContent().toString();
		} catch(Exception e) {
			System.Debug('Provided parameteres are not valid ' + e);
		}

		if(Test.isRunningTest()) {
			String testString = TEST_JSON_RETURN;
			return testString;		
		} else {
			return fileString;
		}
	}

	/**
	* @description parse JSON to Map so we can use values for getting picklist codes
	* @param String picklistJSON
	* @return map with value code
	*/ 
	public static Map<String,String> returnPicklistMap(String picklistJSON) {

		Map<String,String> valueToCodeMap = new Map<String,String>();
		Map<String, Object> m = new Map<String, String>();

		try {
			m = (Map<String, Object>)JSON.deserializeUntyped(picklistJSON);
			List<Object> myList = (List<Object>)m.get('pickList');
			
			for(Object o : myList) {
			    valueToCodeMap.put(String.valueOf(((Map<String, Object>)o).get('value')), String.valueOf(((Map<String, Object>)o).get('code')));
			}
		} catch (Exception e){
			System.Debug('JSON string provided is not valid ' + e);
		}
		System.Debug('XXXXXXXXXXXXXXX test  ' + valueToCodeMap);
		return valueToCodeMap;
    }


	/**
	* @description retreive all documents from a single case
	* @param String Id - Id of the case
	* @return list of Ids of returned documents
	*/  
	public List<String> returnCaseDocs(String id) {
		
		WS_BCMS.BCMS wsBCMS = new WS_BCMS.BCMS(); 									//initialize the BCMS class within WS_BCMS class
		List<WS_BCMS.Document> retrievedDocs = new List<WS_BCMS.Document>();
		List<String> docIds = new List<String>();

		try {
			retrievedDocs = wsBCMS.GetDocumentsForCase(id, OPERATION_DONE_BY);
		} catch(Exception e) {
			System.debug('we were not able to retrieve Documents ' + e);
		}

		if (!retrievedDocs.isEmpty()) {
			for (WS_BCMS.Document docs : retrievedDocs) {
				docIds.add(docs.Id);
			}
		}
		return docIds;
	}

    /**
	* @description create case_x object to be passed to BCMS WS
	* @param Day_1_Template__c day1data
	* @return case_x populated with data
	*/    
	public WS_BCMS.Case_x createCase_x(Day_1_Template__c day1data) {

		String generatedXML = getXmlForBCMSService(day1data);

		//convert XML string to Blob so we can decode it in base64
		Blob blobXml = Blob.valueOf(generatedXML);
		//convert blob to base64
		String base64encodedXml = EncodingUtil.base64Encode(blobXml);	

		WS_BCMS.Case_x caseToCreate = new WS_BCMS.Case_x();
			caseToCreate.Id = ''; 																			//String, shall be empty, BCMS is generating this value
	        caseToCreate.ParentId = ''; 																	//String, Parent case ID 
	        caseToCreate.ReferenceNumber = day1data.Id; 													//String
	        caseToCreate.DefinitionId = BCMS_PROSPECT_CASE_DEFINITION_ID; 									//String definition ID
	        caseToCreate.DefinitionVersion = 1; 															//Integer
	        caseToCreate.Password = ''; 																	//String, ???
	        caseToCreate.Data = base64encodedXml; 															//String (XML) encoded into base64
	        caseToCreate.Status = 'Open'; 																	//String
	        caseToCreate.Created = System.now();															//DateTime
	        caseToCreate.Updated = System.now(); 															//DateTime
        	//caseToCreate.DisplayName; 																	//String
        	//caseToCreate.FreeTextTag; 																	//String
		return caseToCreate;
	} 

    /**
	* @description create case_x object to be passed to BCMS WS to update existing case
	* @param Day_1_Template__c day1data
	* @return case_x populated with data
	*/    
	public WS_BCMS.Case_x createCaseUpdate(Day_1_Template__c day1data) {
		
		String bcmsCaseId = day1data.BCMS_Client_Id__c;
		String updatedXML = day1data.BCMSXMLData__c;
		Blob blobXml = Blob.valueOf(updatedXML);
		String base64encodedXml = EncodingUtil.base64Encode(blobXml);

		WS_BCMS.Case_x caseToUpdate = new WS_BCMS.Case_x();
			caseToUpdate.Id = bcmsCaseId;
			caseToUpdate.DefinitionId = BCMS_CLIENT_CASE_DEFINITION_ID;
			caseToUpdate.DefinitionVersion = 1;
			caseToUpdate.Data = base64encodedXml;
			caseToUpdate.Updated = System.now();
		return caseToUpdate;	
	}	

	/**
	* @description create document object to be passed to BCMS WS
	* @param Id attachId
	* @param String caseId
	* @return document populated with data
	*/    
	public List<BCMSDocumentWrapper> createDocument(Id attachId, String caseId) {
		
		List<Attachment> attachments = getDay1Attachments(attachId);

		List<BCMSDocumentWrapper> documentsToCreate = new List<BCMSDocumentWrapper>();
		for (Attachment attachment : attachments) {
			WS_BCMS.Document documentToCreate = new WS_BCMS.Document();
				documentToCreate.Id = ''; 													//String, shall be empty, BCMS is generating this value
				documentToCreate.DefinitionId = 'B2D3445E-E494-4ABF-A577-1B59CC1298CA'; 	//String document type definition ID
		        documentToCreate.CaseId  = String.valueOf(caseId); 							//String, Case ID
		        documentToCreate.ContentType  = 'Jpeg'; 									//String type of document jpg, pdf, doc
		        documentToCreate.Name  = String.valueOf(attachment.Name);					//String, name of the document
		        documentToCreate.Description  = String.valueOf(attachment.Description); 	//String description
		        documentToCreate.Data =  EncodingUtil.base64Encode(attachment.Body);		//String file to be send
		        documentToCreate.ArchiveType = 'NotArchived';								//String Can't be empty
		        documentToCreate.ArchiveId = '';											//String
		        documentToCreate.Status = 'Unknown'; 										//String
		        documentToCreate.Created = System.now();									//DateTime
		        documentToCreate.Updated = System.now(); 									//DateTime
		        documentToCreate.DocumentReasonId = '';										//String
        	BCMSDocumentWrapper wrapper = new BCMSDocumentWrapper();
        	wrapper.attachmentId = attachment.Id;
        	wrapper.documentToCreate = documentToCreate;
        	documentsToCreate.add(wrapper);
        }												
		return documentsToCreate;	
	}

	/**
	* @description gets the attached documents to the day one template
	* @param Id id - either day1Id or attachment Id
	* @return attached document
	*/   	
	public List<Attachment> getDay1Attachments(Id id) {
		List<Attachment> attachments = new List<Attachment>();
		String objName = id.getSObjectType().getDescribe().getName();
		if (objName == 'Attachment') {
			attachments = [SELECT Id, 
								   Name, 
								   Description, 
								   ContentType, 
								   Body 
							FROM Attachment 
							WHERE Id = :id];
		} else {
			attachments = [SELECT Id, 
								   Name, 
								   Description, 
								   ContentType, 
								   Body 
							FROM Attachment 
							WHERE ParentId = :id];
		}					
	    return attachments;
	}

	/**
	* @description gets the pairings for certain day1 record
	* @param Id day1Id
	* @return List<BCMSDocumentIdPairing__c> pairings
	*/
	public List<BCMSDocumentIdPairing__c> getDocPairing(Id day1Id) {
		List<BCMSDocumentIdPairing__c> pairings = new List<BCMSDocumentIdPairing__c>();
		pairings = [SELECT Id, BCMSDocumentId__c, SFDocumentId__c FROM BCMSDocumentIdPairing__c WHERE Day1Id__c =:day1Id];

		return pairings;
	}  	

	/**
	* @description gets the day1template record
	* @param Id day1Id
	* @return one day1template record
	*/
	public Day_1_Template__c getDay1Record(Id day1Id) {
		Day_1_Template__c day1Template = [SELECT Id,
												 Are_Soft_Copies_expected__c,
												 Contact__c,
												 Cdosp__c,
												 Dosp__c,
												 Dosp_code__c,
												 Eafsc__c,
												 Eaosp__c,
												 FCC_Approval_for_MSB_Onboarding__c,
												 Group_CIF__c,
												 Group_Name__c,
												 Guarantor_s__c,
												 Hota__c,
												 Instant_Account_Number__c,
												 ISC_Code__c,
												 ISC_Description__c,
												 Is_the_client_a_MSB__c,
												 Is_the_client_an_Associated_Party__c,
												 Is_the_client_a_NBFI__c,
												 Itcaib__c,
												 Is_the_client_a_SPV__c,
												 Legal_Entity__c,
												 Legal_Entity_Type__c,
												 MI_Flag__c,
												 MI_Flag_Code__c,
												 Nobbt__c,
												 Pcpoeg__c,
												 Primary_Client_s_address__c,
												 Primary_Legal_Entity__c,
												 Ppcwbt__c,
												 Registration_Number__c,
												 SIC_Code__c,
												 SIC_Description__c,
												 Site_Code__c,
												 Status__c,
												 Spccn__c,
												 Submit_Group_Structure__c,
												 Itcboap__c,
												 Weec__c,
												 Who_is_the_MD_CEO__c,
												 Will_interest_rates_and_charges_apply__c,
												 Wex4cert__c,
												 Primary_Legal_Entity__r.Name,
												 spccn__r.FirstName,
												 spccn__r.LastName,
												 spccn__r.Phone,
												 spccn__r.Email,
												 Primary_Legal_Entity__r.BillingStreet,
												 Primary_Legal_Entity__r.BillingCity,
												 Primary_Legal_Entity__r.BillingPostalCode,
												 Primary_Legal_Entity__r.BillingCountry,
												 BCMS_Prospect_Id__c,
												 Legal_Entity_Code__c,
												 BCMSXMLData__c,
												 BCMS_Client_Id__c
										  FROM Day_1_Template__c 
										  WHERE Id =:day1Id LIMIT 1];
		System.debug('XXXXXXXXXX day1TemplateData ' + day1Template);
	    return day1Template;
	}

	/**
	* @description retreive case_x object to be shown to user
	* @param String referenceId referenceId of the case we would like to retreive, it is a day1templateId that we have used as a referenceId
	* @return case_x populated with data
	*/  
	public WS_BCMS.Case_x retreiveCaseByReferenceNumber(String referenceId) {
		
		WS_BCMS.BCMS wsBCMS = new WS_BCMS.BCMS(); 	//initialize the BCMS class within WS_BCMS class
		WS_BCMS.Case_x retrievedCase = new WS_BCMS.Case_x();

		try {
			retrievedCase = wsBCMS.GetCaseByReferenceNumber(referenceId, OPERATION_DONE_BY);
		} catch(Exception e) {
			System.debug('we were not able to retrieve Case ' + e);
		}	

		return retrievedCase;
	}

	/**
	* @description check if the necessary fields have values, if they don't return list of such fields
	* @param Day_1_Template__c day1data
	* @return List<String> wiht names of fields that needs to be populated
	*/  
	public String checkValuesForDay1Fields (Day_1_Template__c day1data) {
		
		String emptyFields = '';							//returning value

		String objectName = 'Day_1_Template__c';

		//getting a list of field names
		List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
		String objectLabel = describeSobjectsResult[0].getLabel();
		Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();

		if(String.isEmpty(day1data.Registration_Number__c)) {
			emptyFields += ('Please fill in ' + allFields.get('Registration_Number__c').getDescribe().getLabel() + ' on Organisation <br/>');
		}

		if(String.isEmpty(day1data.spccn__r.FirstName)) {
			emptyFields += ('Please fill in Contact\'s first name on contact Record <br/>');
		}

		if(String.isEmpty(day1data.spccn__r.Phone)) {
			emptyFields += ('Please fill in Contact\'s phone on contact Record <br/>');
		}

		if(String.isEmpty(day1data.spccn__r.Email)) {
			emptyFields += ('Please fill in Contact\'s email on contact Record <br/>');
		}

		if(String.isEmpty(day1data.Primary_Legal_Entity__r.BillingStreet)) {
			emptyFields += ('Please fill in Primary Leagal Entity\'s billing street on Organisation <br/>');
		}
		if(String.isEmpty(day1data.Primary_Legal_Entity__r.BillingCity)) {
			emptyFields += ('Please fill in Primary Leagal Entity\'s billing city on Organisation <br/>');
		}
		if(String.isEmpty(day1data.Primary_Legal_Entity__r.BillingPostalCode)) {
			emptyFields += ('Please fill in Primary Leagal Entity\'s billing postal code on Organisation <br/>');
		}
		if(String.isEmpty(day1data.Primary_Legal_Entity__r.BillingCountry)) {
			emptyFields += ('Please fill in Primary Leagal Entity\'s billing country on Organisation <br/>');
		}
		if(String.isEmpty(day1data.SIC_Description__c)) {
			emptyFields += ('Please fill in SIC Description on Onboarding page <br/>');
		}
		if(String.isEmpty(day1data.ISC_Description__c)) {
			emptyFields += ('Please fill in ISC Description on Onboarding page <br/>');
		}
		if(String.isEmpty(day1data.Legal_Entity__c)) {
			emptyFields += ('Please fill in Legal Entity on Onboarding page <br/>');
		}
		if(String.isEmpty(day1data.Dosp__c)) {
			emptyFields += ('Please fill in Designation of Strategic Person on Onboarding page <br/>');
		}
		if(String.isEmpty(day1data.MI_Flag__c)) {
			emptyFields += ('Please fill in MI Flag on Onboarding page <br/>');
		}
		
		
		return emptyFields;
	}	

	/**
	* @description create XML for BCMS case creation
	* @param Day_1_Template__c day1data
	* @return String with XML populated
	*/  
	public String getXmlForBCMSService(Day_1_Template__c day1data) {

		String groupName = '';
		if(day1data.Pcpoeg__c == 'No') {
			groupName = '';
		} else {
			groupName = day1data.Group_Name__c;
		}

		XmlStreamWriter xmlW = new XmlStreamWriter();
		//xmlW.writeStartDocument('utf-8','1.0');
			xmlW.writeStartElement(null,'SalesForceCase', null);
				//xmlW.writeStartElement(null,'ClientDetail',null);
					xmlW.writeStartElement(null,'LegalEntity',null);
						xmlW.writeCharacters(String.ValueOf(day1data.Legal_Entity_Code__c));
					xmlW.writeEndElement(); //Close LegalEntity
					xmlW.writeStartElement(null,'RegistrationNumber',null);
						xmlW.writeCharacters(day1data.Registration_Number__c);							
					xmlW.writeEndElement(); //Close RegistrationNumber
					xmlW.writeStartElement(null,'ClientName',null);
						xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.Name);
					xmlW.writeEndElement(); //Close ClientName
					xmlW.writeStartElement(null,'PrimaryExistingGroup',null);
						xmlW.writeCharacters(day1data.Pcpoeg__c);
					xmlW.writeEndElement(); //Close PrimaryExistingGroup
					xmlW.writeStartElement(null,'ExistingGroupName',null);
						xmlW.writeCharacters(groupName);
					xmlW.writeEndElement(); //Close ExistingGroupName
					xmlW.writeStartElement(null,'NatureofClient',null);
						xmlW.writeCharacters(day1data.Nobbt__c);
					xmlW.writeEndElement(); //Close NatureofClient
					xmlW.writeStartElement(null,'Excemption4',null);
						xmlW.writeCharacters(day1data.Wex4cert__c);
					xmlW.writeEndElement(); //Close Excemption4
					xmlW.writeStartElement(null,'RelatedPartyRole',null);
						xmlW.writeCharacters(day1data.Itcboap__c);
					xmlW.writeEndElement(); //Close RelatedPartyRole
					xmlW.writeStartElement(null,'AuthorityToAct',null);
						xmlW.writeCharacters('');
					xmlW.writeEndElement(); //Close AuthorityToAct
					xmlW.writeStartElement(null,'Guarantors',null);
						xmlW.writeCharacters(day1data.Guarantor_s__c);
					xmlW.writeEndElement(); //Close Guarantors
					xmlW.writeStartElement(null,'SPV',null);
						xmlW.writeCharacters(day1data.Is_the_client_a_SPV__c);
					xmlW.writeEndElement(); //Close SPV
					xmlW.writeStartElement(null,'IntroducerBroker',null);
						xmlW.writeCharacters(day1data.Itcaib__c);
					xmlW.writeEndElement(); //Close IntroducerBroker
					xmlW.writeStartElement(null,'AssociatedParty',null);
						xmlW.writeCharacters(day1data.Is_the_client_an_Associated_Party__c);
					xmlW.writeEndElement(); //Close AssociatedParty
					xmlW.writeStartElement(null,'MSB',null);
						xmlW.writeCharacters(day1data.Is_the_client_a_MSB__c);
					xmlW.writeEndElement(); //Close MSB
					xmlW.writeStartElement(null,'SpecialRates',null);
						xmlW.writeCharacters(day1data.Will_interest_rates_and_charges_apply__c);
					xmlW.writeEndElement(); //Close SpecialRates
					xmlW.writeStartElement(null,'MIFlag',null);
						xmlW.writeCharacters(String.valueOf(day1data.MI_Flag_Code__c));
					xmlW.writeEndElement(); //Close MIFlag
					xmlW.writeStartElement(null,'ISCDescription',null);
						xmlW.writeCharacters(day1data.ISC_Description__c);
					xmlW.writeEndElement(); //Close ISCDescription
					xmlW.writeStartElement(null,'ISCCode',null);
						xmlW.writeCharacters(String.valueOf(day1data.ISC_Code__c));
					xmlW.writeEndElement(); //Close ISCCode
					xmlW.writeStartElement(null,'SICDescription',null);
						xmlW.writeCharacters(day1data.SIC_Description__c);
					xmlW.writeEndElement(); //Close SICDescription
					xmlW.writeStartElement(null,'SICCode',null);
						xmlW.writeCharacters(String.valueOf(day1data.SIC_Code__c));
					xmlW.writeEndElement(); //Close SICCode
					xmlW.writeStartElement(null,'SiteCode',null);
						xmlW.writeCharacters(String.valueOf(day1data.Site_Code__c));
					xmlW.writeEndElement(); //Close SiteCode
					xmlW.writeStartElement(null,'FullName',null);
						xmlW.writeCharacters(day1data.spccn__r.FirstName + ' ' + day1data.spccn__r.LastName);
					xmlW.writeEndElement(); //Close FirstName
					xmlW.writeStartElement(null,'Designation',null);
						xmlW.writeCharacters(String.valueOf(day1data.Dosp_code__c));
					xmlW.writeEndElement(); //Close Designation
					xmlW.writeStartElement(null,'TelephoneNumber',null);
						xmlW.writeCharacters(day1data.spccn__r.Phone);
					xmlW.writeEndElement(); //Close TelephoneNumber
					xmlW.writeStartElement(null,'EmailAddress',null);
						xmlW.writeCharacters(day1data.spccn__r.Email);
					xmlW.writeEndElement(); //Close EmailAddress
					xmlW.writeStartElement(null,'AddresLine1',null);
						xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingStreet);
					xmlW.writeEndElement(); //Close AddresLine1
					xmlW.writeStartElement(null,'AddressLine2',null);
						xmlW.writeCharacters('');
					xmlW.writeEndElement(); //Close AddressLine2
					xmlW.writeStartElement(null,'Suburb',null);
						xmlW.writeCharacters('');
					xmlW.writeEndElement(); //Close Suburb
					xmlW.writeStartElement(null,'Town',null);
						xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCity);
					xmlW.writeEndElement(); //Close Town
					xmlW.writeStartElement(null,'PostalCode',null);
						xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingPostalCode);
					xmlW.writeEndElement(); //Close PostalCode
					xmlW.writeStartElement(null,'Country',null);
						xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCountry);
					xmlW.writeEndElement(); //Close Country
				//xmlW.writeEndElement(); //Close ClientDetail

				/*xmlW.writeStartElement(null,'ContactPerson',null);
					xmlW.writeStartElement(null,'FullName',null);
						xmlW.writeCharacters(day1data.spccn__r.FirstName + ' ' + day1data.spccn__r.LastName);
					xmlW.writeEndElement(); //Close FirstName
					xmlW.writeStartElement(null,'Designation',null);
						xmlW.writeCharacters('');
					xmlW.writeEndElement(); //Close Designation
					xmlW.writeStartElement(null,'TelephoneNumber',null);
						xmlW.writeCharacters(day1data.spccn__r.Phone);
					xmlW.writeEndElement(); //Close TelephoneNumber
					xmlW.writeStartElement(null,'EmailAddress',null);
						xmlW.writeCharacters(day1data.spccn__r.Email);
					xmlW.writeEndElement(); //Close EmailAddress
				xmlW.writeEndElement(); //Close ContactPerson

				xmlW.writeStartElement(null,'Address',null);
					xmlW.writeStartElement(null,'HeadOffice',null);
						xmlW.writeStartElement(null,'AddresLine1',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingStreet);
						xmlW.writeEndElement(); //Close AddresLine1
						xmlW.writeStartElement(null,'AddressLine2',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close AddressLine2
						xmlW.writeStartElement(null,'Suburb',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close Suburb
						xmlW.writeStartElement(null,'Town',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCity);
						xmlW.writeEndElement(); //Close Town
						xmlW.writeStartElement(null,'PostalCode',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingPostalCode);
						xmlW.writeEndElement(); //Close PostalCode
						xmlW.writeStartElement(null,'Country',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCountry);
						xmlW.writeEndElement(); //Close Country
					xmlW.writeEndElement(); //Close HeadOffice

					xmlW.writeStartElement(null,'Business',null);
						xmlW.writeStartElement(null,'AddresLine1',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingStreet);
						xmlW.writeEndElement(); //Close AddresLine1
						xmlW.writeStartElement(null,'AddressLine2',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close AddressLine2
						xmlW.writeStartElement(null,'Suburb',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close Suburb
						xmlW.writeStartElement(null,'Town',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCity);
						xmlW.writeEndElement(); //Close Town
						xmlW.writeStartElement(null,'PostalCode',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingPostalCode);
						xmlW.writeEndElement(); //Close PostalCode
						xmlW.writeStartElement(null,'Country',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCountry);
						xmlW.writeEndElement(); //Close Country
					xmlW.writeEndElement(); //Close Business

					xmlW.writeStartElement(null,'Registered',null);
						xmlW.writeStartElement(null,'AddresLine1',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingStreet);
						xmlW.writeEndElement(); //Close AddresLine1
						xmlW.writeStartElement(null,'AddressLine2',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close AddressLine2
						xmlW.writeStartElement(null,'Suburb',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close Suburb
						xmlW.writeStartElement(null,'Town',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCity);
						xmlW.writeEndElement(); //Close Town
						xmlW.writeStartElement(null,'PostalCode',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingPostalCode);
						xmlW.writeEndElement(); //Close PostalCode
						xmlW.writeStartElement(null,'Country',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCountry);
						xmlW.writeEndElement(); //Close Country
					xmlW.writeEndElement(); //Close Registered

					xmlW.writeStartElement(null,'Postal',null);
						xmlW.writeStartElement(null,'AddresLine1',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingStreet);
						xmlW.writeEndElement(); //Close AddresLine1
						xmlW.writeStartElement(null,'AddressLine2',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close AddressLine2
						xmlW.writeStartElement(null,'Suburb',null);
							xmlW.writeCharacters('');
						xmlW.writeEndElement(); //Close Suburb
						xmlW.writeStartElement(null,'Town',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCity);
						xmlW.writeEndElement(); //Close Town
						xmlW.writeStartElement(null,'PostalCode',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingPostalCode);
						xmlW.writeEndElement(); //Close PostalCode
						xmlW.writeStartElement(null,'Country',null);
							xmlW.writeCharacters(day1data.Primary_Legal_Entity__r.BillingCountry);
						xmlW.writeEndElement(); //Close Country
					xmlW.writeEndElement(); //Close Postal

				xmlW.writeEndElement(); //Close Address*/

			xmlW.writeEndElement(); //Close SalesForceCase
		//xmlW.writeEndDocument(); //Close XML document

		String xmlStringxmlRes = xmlW.getXmlString();
		System.debug('The XML :'+ xmlStringxmlRes);     
		xmlW.close();

		return xmlStringxmlRes;
	}

/**
	* @description a wrapper used to pass SF attachment ID to the method handling the BCMS doc creation, so we can create a link between 2 docs
	* @param no param used
	* @return no return
	*/  
	@TestVisible
	private class BCMSDocumentWrapper{
		public WS_BCMS.Document documentToCreate;
		public Id attachmentId;
	} 	
}