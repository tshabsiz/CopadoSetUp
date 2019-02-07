/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 06/11/2017 - PG    - Created Class. 
 09/11/2017 - PG 	- Added custom exception throws.
 					- Updated to use custom setting variables.
 10/11/2017 - PG 	- Added "getWorkItemDocument" method.
 					- Added "getDocumentMetadata" method.
 					- Added "getWorkItemMetadata" method.  
 27/11/2017 - PG 	- Moved "HotDocs_API_Exception" to HotDocs_Service class.
 21/02/2017 - PG 	- Added "createAnswerSetOverlay" method for overlaying answers.

**/ 
public class HotDocs_API extends HotDocs_Service 
{
	private String access_token; 
	private String sessionId;

	/**
	* Get a access token from web service.
	**/
	public HttpResponse createToken() 
	{
		System.debug('### HotDocs_API : createToken : START');

		//Session endpoint.
		endpoint = API_ENDPOINT_IDENTITY+'core/connect/token';
		requestMethod = 'POST';
		contentType = 'application/x-www-form-urlencoded';

		//Request body
		requestBody.put('grant_type','client_credentials');
		requestBody.put('scope','TemplateHubAPI TemplateHubPermissionsAPI AnswersHubAPI UserAdminAPI TemplateHubTenancyResolver');
		requestBody.put('client_id', CLIENT_ID);
		requestBody.put('client_secret', CLIENT_SECRET);

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(null) : HotDocs_MockResponse.getResponse('createToken'); 

		if(response.getStatusCode() == 200) 
		{
			//JSON Data
			Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

			if(jsonData.get('access_token') != null)
			{
				access_token = (String)jsonData.get('access_token');
			}
			else
			{
				throw new HotDocs_API_Exception('HotDocs_API_Exception : createToken : '+(String)jsonData.get('error'));
			}
		}
		else
		{
			throw new HotDocs_API_Exception('HotDocs_API_Exception : createToken : '+response.getStatusCode()+' : '+response.getStatus());
		}		

		System.debug('### HotDocs_API : createToken : END');

		//Default return
		return response;  
	}

	/**
	* Get a session for interview from web service.
	**/
	public HttpResponse createSession(String hotDocsPackageId, String answerSetId) 
	{
		System.debug('### HotDocs_API : createSession : START'); 

		//Needs a token.
		if(access_token == null)
		{
			createToken();
		}

		//Session endpoint.
		endpoint = API_ENDPOINT_EMBED.contains('esb') ? API_ENDPOINT_EMBED+'establish/session' : API_ENDPOINT_EMBED+'Session/CreateSession';
		requestMethod = 'POST';

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//URL parameters
		requestParameters.put('templateId', hotDocsPackageId); 
		requestParameters.put('answersetId', answerSetId); 

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(null) : HotDocs_MockResponse.getResponse('createSession'); 

		if(response.getStatusCode() == 200)
		{
			//Set session id.
			sessionId = response.getBody().replace('"','');
		}
		else
		{
			throw new HotDocs_API_Exception('HotDocs_API_Exception : createSession : '+response.getStatusCode()+' : '+response.getStatus());
		}		 

		System.debug('### HotDocs_API : createSession : END');

		//Default return
		return response;   
	}

	/**
	* Returns the iframe URL for an interview for a template.
	**/
	public String getInterviewUrl(String hotDocsPackageId, String answerSetId)
	{
		System.debug('### HotDocs_API : getInterviewUrl : START');

		//We need the session before hand.
		if(sessionId == null)
		{
			createSession(hotDocsPackageId, answerSetId);
		}

		//Clear request data, even though we did not make a call out.
		clearRequestData();

		//Session endpoint.
		endpoint = API_ENDPOINT_EMBED.contains('esb') ? API_ENDPOINT_OVERRIDE+'Interview' : API_ENDPOINT_EMBED+'Interview';  

		//URL parameters
		requestParameters.put('sessionId', sessionId); 

		System.debug('### HotDocs_API : getInterviewUrl : END');

		//Default return.
		return buildEncodedString(endpoint, requestParameters); 

	}

	/**
	* Creates an answer set and returns its ID.
	**/
	public String createAnswerSet(String title, String description, HotDocs_AnswerSet answerSet)
	{
		System.debug('### HotDocs_API : createAnswerSet : START'); 

		String answerSetId;

		//Needs a token.
		if(access_token == null)
		{
			createToken();
		}

		//Session endpoint.
		endpoint = API_ENDPOINT_ANSWER+'answerSet/answerXml'; 
		requestMethod = 'POST';
		contentType = 'application/json';

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//Build JSON AnswerSet Data
		String jsonData = buildAnswerSetJSON(title, description, answerSet);

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(jsonData) : HotDocs_MockResponse.getResponse('createAnswerSet'); 

		if(response.getStatusCode() == 200)
		{
			//JSON Data
			Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

			if(jsonResponse.get('Id') != null)
			{
				answerSetId = (String)jsonResponse.get('Id');
			}
			else
			{
				throw new HotDocs_API_Exception('HotDocs_API : createAnswerSet : '+(String)jsonResponse.get('Message'));
			}			
		}
		else
		{
			throw new HotDocs_API_Exception('HotDocs_API : createAnswerSet : '+response.getStatusCode()+' : '+response.getStatus());
		}

		System.debug('### HotDocs_API : createAnswerSet : END'); 

		//Default
		return answerSetId;  
	}

	/**
	* Apparently this overlays new XML over an existing answerset.
	**/
	public void createAnswerSetOverlay(String answerSetId, String title, String description, HotDocs_AnswerSet answerSet)
	{
		System.debug('### HotDocs_API : createAnswerSetOverlay : START');

		//Needs a token.
		if(access_token == null)
		{
			createToken();
		}

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//Session endpoint.
		endpoint = API_ENDPOINT_ANSWER+'answerSet/'+answerSetId+'/version/answerXml';
		requestMethod = 'POST';
		contentType = 'application/json';

		//Build JSON AnswerSet Data
		String jsonData = buildAnswerSetJSON(title, description, answerSet);

		//Call web service.
		//HttpResponse response = execute(jsonData);
		HttpResponse response = (!Test.isRunningTest()) ? execute(jsonData) : HotDocs_MockResponse.getResponse('createAnswerSetOverlay'); 

		if(response.getStatusCode() != 200)
		{
			throw new HotDocs_API_Exception('HotDocs_API : createAnswerSetOverlay : '+response.getStatusCode()+' : '+response.getStatus());
		}	

		System.debug('### HotDocs_API : createAnswerSetOverlay : END'); 
	}

	/**
	* Gets the work item details as an object.
	**/
	public HotDocs_WorkItem getWorkItemMetadata(String workItemId)
	{
		System.debug('### HotDocs_API : getWorkItemMetadata : START');

		//Blank var.
		HotDocs_WorkItem workItem;

		//Needs a token.
		if(access_token == null)
		{
			createToken();
		}

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//Session endpoint.
		endpoint = API_ENDPOINT_ANSWER+'workitems/'+workItemId;
		requestMethod = 'GET';

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(null) : HotDocs_MockResponse.getResponse('getWorkItemMetadata'); 

		if(response.getStatusCode() == 200)
		{
			//Deserialise to Object.
			try 
			{
				workItem = HotDocs_WorkItem.parse(response.getBody()); 
			}
			catch(Exception e)
			{
				throw new HotDocs_API_Exception('HotDocs_API : getWorkItemMetadata : '+e.getMessage());
			}
		}
		else
		{
			throw new HotDocs_API_Exception('HotDocs_API : getWorkItemMetadata : '+response.getStatusCode()+' : '+response.getStatus());
		}	
		
		System.debug('### HotDocs_API : getWorkItemMetadata : END');

		//Default
		return workItem; 
	}

	/**
	* Gets the metadata for a specific document.
	**/
	public HotDocs_Document getDocumentMetadata(String workItemId, String documentId)
	{	
		System.debug('### HotDocs_API : getDocumentMetadata : START');

		//Blank var.
		HotDocs_Document documentItem;

		//Needs a token.
		if(access_token == null)
		{
			createToken();
		}

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//Session endpoint.
		endpoint = API_ENDPOINT_ANSWER+'workitems/'+workItemId+'/documents/'+documentId+'/metadata';
		requestMethod = 'GET';

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(null) : HotDocs_MockResponse.getResponse('getDocumentMetadata');

		if(response.getStatusCode() != 200) 
		{
			throw new HotDocs_API_Exception('HotDocs_API : getDocumentMetadata : '+response.getStatusCode()+' : '+response.getStatus());
		}		

		try 
		{
			//Deserialise to Object.
			documentItem = HotDocs_Document.parse(response.getBody());
		}
		catch(Exception e)
		{
			throw new HotDocs_API_Exception('HotDocs_API : getDocumentMetadata : '+e.getMessage() );
		}

		System.debug('### HotDocs_API : getDocumentMetadata : END');

		//Default return.
		return documentItem;		
	}

	/**
	* Gets the work item details as an object.
	**/
	public Blob getWorkItemDocument(String workItemId, String documentId)
	{
		System.debug('### HotDocs_API : getWorkItemDocument : START');

		//Fetch metadata for the document.
		HotDocs_Document docMeta = getDocumentMetadata(workItemId, documentId);

		//Needs a token.
		if(access_token == null)
		{
			createToken(); 
		}

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//Session endpoint.
		endpoint = API_ENDPOINT_ANSWER+'workitems/'+workItemId+'/documents/'+documentId;
		requestMethod = 'GET';

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(null) : HotDocs_MockResponse.getResponse('getWorkItemDocument');

		if(response.getStatusCode() != 200)
		{
			throw new HotDocs_API_Exception('HotDocs_API : getWorkItemDocument : '+response.getStatusCode()+' : '+response.getStatus());
		}
		
		//Get file binary data
		Blob fileBody = response.getBodyAsBlob();

		System.debug('### HotDocs_API : getWorkItemDocument : END');

		//Default return. 
		return fileBody;
	}

	/**
	* Retrieve an answer XML file for a workitem.
	**/
	public String getAnswerSetXmlFile(String answerSetId)  
	{
		System.debug('### HotDocs_API : getAnswerSetXmlFile : START');

		//Needs a token.
		if(access_token == null)
		{
			createToken();
		}

		//Request Headers
		requestHeaders.put('Authorization', 'Bearer '+access_token);

		//Session endpoint.
		endpoint = API_ENDPOINT_ANSWER+'answerSet/'+answerSetId+'/versions/live/answerXml';
		requestMethod = 'GET';

		//Call web service.
		HttpResponse response = (!Test.isRunningTest()) ? execute(null) : HotDocs_MockResponse.getResponse('getAnswerSetXmlFile');

		if(response.getStatusCode() == 200)
		{
			return response.getBody();
		}
		else
		{
			throw new HotDocs_API_Exception('HotDocs_API : getAnswerSetXmlFile : '+response.getStatusCode()+' : '+response.getStatus());
		}		

		System.debug('### HotDocs_API : getAnswerSetXmlFile : END'); 

		//default.
		return null; 
	} 
}