/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 24/10/2017 - PG    - Created Class. 
 06/11/2017 - PG 	- Added EMBED api constant.
 09/11/2017 - PG 	- Added request header handling.
 					- Added custom settings utilisation and static block.
 					- Added "clearRequestData" method for after call outs.
 13/03/2017 - PG 	- Added method "setupEnviroment" for new metadata change.

**/ 
public virtual class HotDocs_Service 
{
	/**
	* Properties
	**/
	public final HotDocs_Integration_Setting__mdt SETTINGS;
	public final String API_BASE;
	public final String API_OVERRIDE;
	public final String API_ENDPOINT_HDCS;
	public final String API_ENDPOINT_INTERVIEW;
	public final String API_ENDPOINT_EMBED;
	public final String API_ENDPOINT_IDENTITY;
	public final String API_ENDPOINT_ANSWER;
	public final String API_ENDPOINT_OVERRIDE;
	public final String CLIENT_ID;
	public final String CLIENT_SECRET;
	public final String CLIENT_ID_IBM;
	public final String CLIENT_SECRET_IBM;	

	/**
	* Variables
	**/
	public String endpoint { get; set; }
	public String requestMethod { get; set; }
	public String contentType { get; set; }
	public Map<String, String> requestParameters { get; set; }
	public Map<String, String> requestBody { get; set; }
	public Map<String, String> requestHeaders { get; set; }


	/**
	* Constructor
	**/
	public HotDocs_Service()
	{
		System.debug('### HotDocs_Service : Constructor');

		SETTINGS = setupEnviroment();
		CLIENT_ID = (SETTINGS != null) ? SETTINGS.Client_ID__c : null; 
        CLIENT_SECRET = (SETTINGS != null) ? SETTINGS.Client_Secret__c : null; 
        CLIENT_ID_IBM = (SETTINGS != null) ? SETTINGS.Client_ID_IBM__c : null; 
        CLIENT_SECRET_IBM = (SETTINGS != null) ? SETTINGS.Client_Secret_IBM__c : null; 
        API_BASE = (SETTINGS != null) ? SETTINGS.Endpoint_Base_URL__c : null; 
        API_OVERRIDE = (SETTINGS != null) ? SETTINGS.Interview_Override_URL__c : null; 
        API_ENDPOINT_HDCS = (API_BASE != null) ? API_BASE+'HDSWebAPI/api/hdcs/' : null; 
        API_ENDPOINT_INTERVIEW = (API_BASE != null) ? API_BASE+'HotDocsInterview/api/sessions/' : null; 
        API_ENDPOINT_EMBED = (API_BASE != null) ? API_BASE+'HotDocsEmbeddedOnPremise/' : null;
        API_ENDPOINT_IDENTITY = (API_BASE != null) ? API_BASE+'HotDocsIdentityServer/' : null; 
        API_ENDPOINT_ANSWER = (API_BASE != null) ? API_BASE+'HotDocsAnswers/api/v1/' : null;
        API_ENDPOINT_OVERRIDE = (API_OVERRIDE != null) ? API_OVERRIDE+'HotDocsEmbeddedOnPremise/' : null;  //Used to override interview iframe base URL.  Url access only on LAN.

		//Default Values.
		requestMethod = 'POST';
		requestParameters = new Map<String, String>();
		requestBody = new Map<String, String>();
		requestHeaders = new Map<String, String>(); 
		contentType = 'text/xml';
	}

	/**
	* Used to prime what envirment setting we need to used based on Salesforce org.
	*/
	public static HotDocs_Integration_Setting__mdt setupEnviroment()
	{
		//Detemine which enviroment we in for endpoint selection.
		String salesforceEnviroment = CloudSmiths_Utils.getEnviroment();

		//Metadata type records for settings.
		List<HotDocs_Integration_Setting__mdt> metadataRecords = new List<HotDocs_Integration_Setting__mdt>([
			SELECT 
				Id, 
				DeveloperName, 
				MasterLabel, 
				Label,
				Attempts_Limit__c,
				Client_ID_IBM__c,
				Client_ID__c,
				Client_Secret_IBM__c,
				Client_Secret__c,
				Enable_Monitoring__c,
				Enable_Verbose_Logging__c,
				Endpoint_Base_URL__c,
				Interview_Development_Mode__c,
				Interview_Override_URL__c,
				Keep_Answer_File__c 
			FROM HotDocs_Integration_Setting__mdt
			WHERE
				DeveloperName = :salesforceEnviroment
			LIMIT 1
		]);

		//Make sure we found a record.
		if(!metadataRecords.isEmpty())
		{
			return metadataRecords.get(0);
		}
		else
		{
			return null;
		}
	}

	/**
	* execute - Main method to call web service endpoint.
	**/
	public HttpResponse execute(String rawRequestData)
	{
		System.debug('### HotDocs_Service : execute : START');

		if(SETTINGS == null)
		{
			throw new HotDocs_API_Exception('HotDocs_Service : execute : Unable to find integration settings.');
		}

		//Blank var.
		HttpResponse httpResponse;

		//Http Client
		Http httpBinding = new Http();

		//Http Request
		HttpRequest httpRequest = new HttpRequest();

		//Increase default timeout to 20 seconds.
		httpRequest.setTimeout(20000);
		
		//Method
		httpRequest.setMethod(requestMethod); 

		//Headers
		httpRequest.setHeader('Content-Length', '0');
		httpRequest.setHeader('Content-Type', contentType);
		httpRequest.setHeader('Keep-Alive', 'false');
		httpRequest.setHeader('X-IBM-Client-Id', CLIENT_ID_IBM == null ? '' : CLIENT_ID_IBM);
		httpRequest.setHeader('X-IBM-Client-Secret', CLIENT_SECRET_IBM == null ? '' : CLIENT_SECRET_IBM);

		//Add any custom headers.
		if(!requestHeaders.isEmpty())
		{
			buildRequestHeaders(httpRequest, requestHeaders); 
		}

		//Append URL parameters
		if(!requestParameters.isEmpty())
		{
			endpoint = buildEncodedString(endpoint, requestParameters);
		}

		//Endpoint
		httpRequest.setEndpoint(endpoint);

		//Add raw data to body.
		if(rawRequestData != null)
		{
			//Request body.
			httpRequest.setBody(rawRequestData); 
		}

		//Generate POST body.
		if(rawRequestData == null && !requestBody.isEmpty())
		{
			//Request body.
			httpRequest.setBody(buildEncodedString(requestBody)); 
		}

		try
		{
			//Send the request, and return a response
			httpResponse = httpBinding.send(httpRequest);

			//Return data
			return httpResponse;
		}
		catch(Exception e)
		{
			throw new HotDocs_API_Exception('HotDocs_Service : execute : '+e.getMessage());
		}
		finally
		{
			//Clear request data for next call.
			clearRequestData(); 
		}
	}

	/**
	* execute - Overload: Main method to call web service endpoint. 
	**/
	public HttpResponse execute()
	{
		return execute(null); 
	}

	/**
	* buildEncodedString - Builds up the URl with some additional parameters.
	**/
	public static String buildEncodedString(String startStr, Map<String, String> params) 
	{
		System.debug('### HotDocs_Service : buildEncodedString : START');

		Boolean firstParam = true;
		String encodedString = '';

		for(String key : params.keySet()) 
		{
			if(firstParam == true)
			{
				firstParam = false;

				if(!String.isBlank(startStr))
				{
					encodedString += startStr+'?';
				}

				encodedString += key+'='+EncodingUtil.urlEncode( params.get(key), 'UTF-8');
			}
			else
			{
				encodedString += '&'+key+'='+EncodingUtil.urlEncode( params.get(key), 'UTF-8');
			}
		}

		System.debug('### HotDocs_Service : buildEncodedString : END');

		//Return
		return encodedString;
	}

	/**
	* buildEncodedString - Builds up the URl with some additional parameters.
	**/
	public static String buildEncodedString(Map<String, String> params) 
	{ 
		return buildEncodedString(null, params);
	}

	/**
	* buildRequestHeaders - Builds up the HTTP request headers.
	**/
	public static void buildRequestHeaders(HttpRequest request, Map<String, String> params)
	{
		for(String key : params.keySet())
		{
			request.setHeader(key, params.get(key));
		}
	}

	/**
	* clearRequestData - Used by API to clear data from previous call.
	**/
	public void clearRequestData()
	{
		requestParameters = new Map<String, String>();
		requestBody = new Map<String, String>();
		requestHeaders = new Map<String, String>();
	}

	/**
	* buildAnswerSetJSON - Prepares JSON data for AnswerSet api.
	**/
	public String buildAnswerSetJSON(String title, String description, HotDocs_AnswerSet answerSet)
	{
		System.debug('### HotDocs_Service : buildAnswerSetJSON : START');

		//JSON object.
		JSONGenerator jsonData = JSON.createGenerator(true); 

		//Build JSON.
		jsonData.writeStartObject();
			jsonData.writeStringField('Title', title);
			jsonData.writeStringField('Description', description);
			jsonData.writeStringField('AnswerSetContent', answerSet.getXmlDocument());
		jsonData.writeEndObject(); 

		System.debug('### HotDocs_Service : buildAnswerSetJSON : jsonData : '+jsonData.getAsString());
		System.debug('### HotDocs_Service : buildAnswerSetJSON : END');

		//Default.
		return jsonData.getAsString();
	}

	/**
	* Custom exception handler.
	**/
	public class HotDocs_API_Exception extends Exception {} 
}