/**
  * @Author:          Dino Scarcella
  * @Company:         Absa Capital
  * @Description:     Class responsible for all SPEAR integration
  * History
  * <Date>      <Authors Name>     <Brief Description of Change>
  *------------------------------------------------------------*/
public with sharing class SPEAR {
	private String BASE_ENDPOINT = '';
	private String OPERATION_RATINGSFEED = '';
	private Integer SYNC_TIMEOUT = 0;
	private String X_IBM_Client_Id = '';
	private String X_IBM_Client_Secret = '';
	private List<Rating> Ratings_Feed;
    
    //constructor
    public SPEAR() {
        for(SPEAR_Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM SPEAR_Integration_Setting__mdt WHERE DeveloperName IN('BASE_ENDPOINT','OPERATION_RATINGSFEED','SYNC_TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret')]){
            if (settings.DeveloperName == 'BASE_ENDPOINT') BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_RATINGSFEED') OPERATION_RATINGSFEED = settings.Setting__c;
            if (settings.DeveloperName == 'SYNC_TIMEOUT') SYNC_TIMEOUT = integer.valueof(settings.Setting__c);
            if (settings.DeveloperName == 'X_IBM_Client_Id') X_IBM_Client_Id = settings.Setting__c;
            if (settings.DeveloperName == 'X_IBM_Client_Secret') X_IBM_Client_Secret = settings.Setting__c;
        }
    }
    
	// Property method for the Ratings which the REST call returns
    public List<Rating> RatingsFeed {
      get { return Ratings_Feed; }
      set { Ratings_Feed = value; }
    }
    
    // Synchronous method which synchronously calls the Ratings feed with specified parameters
	public List<Rating> RetrieveRatingFeedSync(String obligorSdsId, String from_date, String to_date, Boolean includeAgencyRatings) {
		// Builds the query strings based on the parameters passed to the method
		String QueryString='';
		if (obligorSdsId != '') QueryString = QueryString + '?obligorSdsId=' + obligorSdsId;
		if (from_date != '') QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'from=' + from_date;
		if (to_date != '') QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'to=' + to_date;
		if (includeAgencyRatings) QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'include=AgencyRatings';
		
		List<Rating> RatingFeed = new List<Rating>();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(BASE_ENDPOINT + OPERATION_RATINGSFEED + QueryString);
		request.setMethod('GET');
		request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
		request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
		request.setTimeout(SYNC_TIMEOUT);
		HttpResponse response = http.send(request);
		
		if (response.getStatusCode() == 200) {
			try {
				// Deserialize the list of ItemTypes from the JSON string.
            	RatingFeed = (List<Rating>)JSON.deserialize(response.getBody().replace('"Date":','"RatingDate":'), List<Rating>.class);
			} catch (Exception e) {
            	RatingFeed.Add(new Rating());
            }
		}
            
        if (RatingFeed.size() > 0) RatingsFeed = RatingFeed; 
        else RatingFeed.Add(new Rating());
        return RatingFeed;
	}

	public class Rating {
		public Integer RatingId {get;set;}
		public String ObligorSdsId {get;set;}
		public String GroupSdsId {get;set;}
		public String ObligorName {get;set;}
		public String SanctioningUnit {get;set;}
		public String ModelName {get;set;}
		public String ModelVersion {get;set;}
		public String Source {get;set;}
		public String Comment {get;set;}
		public String CompletedOn {get;set;}
		public String CountryCap {get;set;}
		public String CountryOfAssets {get;set;}
		public String CountryOfIncorporation {get;set;}
		public Double TTCPDYear1 {get;set;}
		public Double PITPDYear1 {get;set;}
		public Double PITPDYear2 {get;set;}
		public Double PITPDYear3 {get;set;}
		public Double PITPDYear4 {get;set;}
		public Double PITPDYear5 {get;set;}
		public Integer TTCDGYear1 {get;set;}
		public Integer PITDGYear1 {get;set;}
		public Integer PITDGYear2 {get;set;}
		public Integer PITDGYear3 {get;set;}
		public Integer PITDGYear4 {get;set;}
		public Integer PITDGYear5 {get;set;}
		public AgencyRating[] AgencyRatings;
	}

	public class AgencyRating {
		public String AgencyName {get;set;}
		public String Type {get;set;}
		public String RatingDate {get;set;} //Can't use Date as Date is a reserved word, will need to modify JSON returned if we want this field as JSON.deserialize won't pick it up
		public String Grade {get;set;}
	}
}