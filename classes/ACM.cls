/**
  * @Author:          Dino Scarcella
  * @Company:         Absa Capital
  * @Description:     Class responsible for all ACM integration
  * History
  * <Date>      <Authors Name>     <Brief Description of Change>
  *------------------------------------------------------------*/
public with sharing class ACM {
	private String BASE_ENDPOINT = '';
	private String OPERATION_FACILITIESFEED = '';
    private String OPERATION_LIMITS = '';
	private Integer SYNC_TIMEOUT = 0;
	private String X_IBM_Client_Id = '';
	private String X_IBM_Client_Secret = '';
	private List<Facility> Facilities_Feed;
    private List<Limits> Limits_Feed;
    public String errorMessage {get;set;}
    
    //constructor
    public ACM() {
        for(Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM Integration_Setting__mdt WHERE DeveloperName IN('BASE_ENDPOINT','OPERATION_FACILITIESFEED','SYNC_TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret','OPERATION_LIMITS')]){
            if (settings.DeveloperName == 'BASE_ENDPOINT') BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_FACILITIESFEED') OPERATION_FACILITIESFEED = settings.Setting__c;
            if (settings.DeveloperName == 'SYNC_TIMEOUT') SYNC_TIMEOUT = integer.valueof(settings.Setting__c);
            if (settings.DeveloperName == 'X_IBM_Client_Id') X_IBM_Client_Id = settings.Setting__c;
            if (settings.DeveloperName == 'X_IBM_Client_Secret') X_IBM_Client_Secret = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_LIMITS') OPERATION_LIMITS = settings.Setting__c;
        }
    }
    
	// Property method for the Ratings which the REST call returns
    public List<Facility> FacilitiesFeed {
      get { return Facilities_Feed; }
      set { Facilities_Feed = value; }
    }
    public List<Limits> LimitsFeed {
      get { return Limits_Feed; }
      set { Limits_Feed = value; }
    }
    
    public List<Facility> RetrieveLimitsFeedSync(String counterpartyid, Boolean useDefaults)
    {        
        if(Test.isRunningTest())
        {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ACMLimitResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
        }
        // Builds the query strings based on the parameters passed to the method
		String QueryString='';
		QueryString = QueryString + '?_useDefaults=' + (useDefaults ? 'true' : 'false');
		List<Facility> facilityList = new List<Facility>();
        
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(BASE_ENDPOINT + OPERATION_LIMITS + QueryString);
		request.setMethod('POST');
		request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
		request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"counterpartyid\":\"' + counterpartyid + '\"}');
		request.setTimeout(120000);
        
		HttpResponse response;
        try {
            response = http.send(request);  
        } catch (Exception e) {
            errorMessage = e.getMessage();
            System.debug('ErrorMessge '+errorMessage);
        }
        
        if (response != null && response.getStatusCode() == 200) {
            try {
                
                LimitsFeed = new List<Limits>(); 
                LimitsFeed = (List<Limits>)JSON.deserialize(response.getBody(), List<Limits>.class);
                System.debug('Break point '+LimitsFeed.size());
                
                for(Limits l :LimitsFeed)
               {
                    Facility f = new Facility();
                    f.EXPIRYDATE = l.EXPIRYDATE;
                    f.FACILITYAMOUNT = Integer.valueOf(l.LIMITAMOUNT);
                    f.FACILITYPRODUCT = l.BANKRISKTAKER;
                    f.FACILITYPRODUCTDESCRIPTION = l.LIMITTYPE;
                    f.LOSSGIVENDEFAULT = l.LOSSGIVENDEFAULT;
                    f.STARTDATE = l.STARTDATE;
                    f.CPTYID = l.CPTYID;
                    f.FACILITYCURRENCY = l.LIMITCURRENCY;
                    f.TENORVALUE = Integer.valueOF(l.TENORVALUE);
                    f.TENORUNIT = l.TENORUNIT;
                    f.MODIFIEDTIMESTAMP = l.MODIFIEDTIMESTAMP;
                    f.MODIFIEDBY = l.MODIFIEDBY;
                   	f.FACILITYID = l.LIMITID;
                   System.debug('f '+f);
                   facilityList.add(f);
                }
                
            } catch (Exception e) {
                System.debug('excpetion '+e.getLineNumber());
                 System.debug('Message Details  '+e.getMessage());
                errorMessage = e.getMessage();
            }
        } else if (response != null && response.getStatusCode() != 200) {
            errorMessage = response.getBody();
        }
        
        if (facilityList.size() > 0) errorMessage = '';
        return facilityList;
    }
    
    // Synchronous method which synchronously calls the Ratings feed with specified parameters
	public List<Facility> RetrieveFacilityFeedSync(String counterpartyid, Boolean useDefaults) {
		// Builds the query strings based on the parameters passed to the method
		String QueryString='';
		QueryString = QueryString + '?_useDefaults=' + (useDefaults ? 'true' : 'false');
		
		List<Facility> FacilityFeed = new List<Facility>();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(BASE_ENDPOINT + OPERATION_FACILITIESFEED + QueryString);
        System.debug('request '+request.getEndpoint());
		request.setMethod('POST');
		request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
		request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{\"counterpartyid\":\"' + counterpartyid + '\"}');
		request.setTimeout(120000);
        
		HttpResponse response;
        try {
                response = http.send(request);
                
            } catch (Exception e) {
                System.debug('exception '+e.getMessage());
                errorMessage = e.getMessage();
            }
        
		if (response != null && response.getStatusCode() == 200) {
			try {
                // Deserialize the list of ItemTypes from the JSON string.
            	FacilityFeed = (List<Facility>)JSON.deserialize(response.getBody(), List<Facility>.class);
                System.debug('FacilitiesFeed size '+FacilityFeed.size());
                FacilityFeed.addAll(RetrieveLimitsFeedSync(counterpartyid,useDefaults));
                System.debug('FacilityFeed '+FacilityFeed.size());
            } catch (Exception e) {                
                errorMessage = e.getMessage();
            }
            
            
        } else if (response != null && response.getStatusCode() != 200) {
            errorMessage = response.getBody();
        }
            
        if (FacilityFeed.size() > 0) errorMessage = '';
        FacilitiesFeed = FacilityFeed;
        return FacilityFeed;
	}
    public class Limits
    {
        public String LIMITID{get;set;}
        public String BANKRISKTAKER{get;set;}
        public String CPTYID{get;set;}
        public String EXPIRYDATE{get;set;}
        
        private String LIMIT_AMOUNT;
        public String LIMITAMOUNT
        {
            get
            {
                if(String.isBlank(LIMIT_AMOUNT))
                {
                    return '0';
                }
                else
                {
                    return LIMIT_AMOUNT; 
                }
         		      
            }
            set
            {
                LIMIT_AMOUNT = value;
            }
        }
            
        public String LIMITCURRENCY{get;set;}
        public String LIMITMEASURE{get;set;}
        public String LIMITTYPE{get;set;}
        public String LOSSGIVENDEFAULT{get;set;}
        public String MATRIX_LIMIT_FLAG{get;set;}
        public String MODIFIEDBY{get;set;}
        public String MODIFIEDTIMESTAMP{get;set;}
        public String STARTDATE{get;set;}
        public String SUSPENDEDINDICATOR{get;set;}
        public String TENORUNIT{get;set;}
        
        private String TENOR_VALUE;
        public String TENORVALUE{
            get
            {
                if(String.isBlank(TENOR_VALUE))
                {
                    return '0';
                }
                else
                {
                    return TENOR_VALUE; 
                }
                
            }
            set
            {
                TENOR_VALUE = value;
            }
        }
        
    }
    
	public class Facility {
		public String FACILITYID {get;set;}
		public String FACILITYPRODUCT {get;set;}
		public String FACILITYPRODUCTDESCRIPTION {get;set;}
		public String FACILITYACTIVE {get;set;}
		public String CPTYID {get;set;}
		public String BANKRISKTAKER {get;set;}
		public Integer TENORVALUE {get;set;}
		public String TENORUNIT {get;set;}
		public String STARTDATE {get;set;}
		public String EXPIRYDATE {get;set;}
		public String FACILITYCURRENCY {get;set;}
		public Integer FACILITYAMOUNT {get;set;}
		public String PARENTFACILITYID {get;set;}
		public String LOSSGIVENDEFAULT {get;set;}
		public String MODIFIEDTIMESTAMP {get;set;}
		public String MODIFIEDBY {get;set;}
		public String ACMUTILIZATIONCURRENCY {get;set;}
		public Double ACMUTILIZATIONAMOUNT {get;set;}
        public DateTime GetModifiedTimeStamp {
            get {
            	if (MODIFIEDTIMESTAMP != NULL && MODIFIEDTIMESTAMP.length() > 14) {
                    try {
                        Integer year = Integer.valueof(MODIFIEDTIMESTAMP.substring(0,4));
                        Integer month = Integer.valueof(MODIFIEDTIMESTAMP.substring(4,6));
                        Integer day = Integer.valueof(MODIFIEDTIMESTAMP.substring(6,8));
                        Integer hour = Integer.valueof(MODIFIEDTIMESTAMP.substring(9,11));
                        Integer minute = Integer.valueof(MODIFIEDTIMESTAMP.substring(11,13));
                        Integer second = Integer.valueof(MODIFIEDTIMESTAMP.substring(13,15));
                        return DateTime.newInstance(year, month, day, hour, minute, second);    
                    } catch (Exception e) {
                        return null;
                    }
            	} else {
            		return null;
        		}    
            }
        }
        public Date GetStartDate {
            get {
            	if (STARTDATE != NULL && STARTDATE.length() > 9) {
                    try {
                        Integer year = Integer.valueof(STARTDATE.substring(0,4));
                        Integer month = Integer.valueof(STARTDATE.substring(5,7));
                        Integer day = Integer.valueof(STARTDATE.substring(8,10));
                        return Date.newInstance(year, month, day);    
                    } catch (Exception e) {
                        return null;
                    }
        		} else {
            		return null;
            	}    
            }    
        }
        public Date GetExpiryDate {
            get {
            	if (EXPIRYDATE != NULL && EXPIRYDATE.length() > 9) {
                    try {
                        Integer year = Integer.valueof(EXPIRYDATE.substring(0,4));
                        Integer month = Integer.valueof(EXPIRYDATE.substring(5,7));
                        Integer day = Integer.valueof(EXPIRYDATE.substring(8,10));
                        return Date.newInstance(year, month, day);    
                    } catch (Exception e) {
                        return null;
                    }
            	} else {
	            	return null;
    	        }    
            }
        }
        public Decimal GetLGD {
            get {
                if (LOSSGIVENDEFAULT != NULL) {
                    try {
                        return Decimal.valueOf(LOSSGIVENDEFAULT);
                    } catch (Exception e) {
            			return null;
        			}
                } else {
                    return null;
                }    
            }
        }
	}
}