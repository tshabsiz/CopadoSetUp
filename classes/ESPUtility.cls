/*==============================================
 * @CreatedBy   : Mabhedle Tonga 
 * @CreatedDate : 2017-06-09
 * @Description : 
 * =============================================
*/
public class ESPUtility 
{

    public static void sendAccountRequiredFields(Account acc,String X_IBM_Client_Secret,String X_IBM_Client_Id,String BASE_ENDPOINT_ESP,Integer TIMEOUT,String selectedLegelEntity,String selectedContactDetail,Contact con)
    {
        //Tonga MM : For testing Http Callout
        if(Test.isRunningTest())
        {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ESPCreateInstructionResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
        } 
        
        list<FieldNode> clientFields = new list<FieldNode>();
        
        //Tonga MM : Mandatory fields that should always be populated
        clientFields.add(new FieldNode('LegalEntity',selectedLegelEntity,'Legal Entity','string','false','true'));
        clientFields.add(new FieldNode('ClientName',acc.Name,'ClientName','string','false','true'));
        clientFields.add(new FieldNode('IDType',acc.ID_Type__c,'ID Type','string','false','true'));
        clientFields.add(new FieldNode('RegistrationNumber',acc.registration_Number__c,'Registration / Incorporate number','string','false','true'));
        clientFields.add(new FieldNode('SFClientRef',acc.ID,'SFClientRef','string','true','true'));
        clientFields.add(new FieldNode('ContactFullNameAndSurname',con.Name,'Full name and surname','string','false','true'));
        clientFields.add(new FieldNode('ContactSupplyContactDetails',selectedContactDetail,'Which contact details will you be supplying','string','false','true'));
      
        if(!String.isblank(con.MobilePhone))
        {
            clientFields.add(new FieldNode('ContactCellPhoneNumber',con.phone,'Cell phone number','string','false','false'));
        }
        if(!String.isblank(con.Phone))
        {
            clientFields.add(new FieldNode('ContactTelephone',con.MobilePhone,'Telephone number','string','false','false'));
        }
        if(!String.isblank(con.Email))
        {
            clientFields.add(new FieldNode('ContactEmailAddress',con.Email,'Email address','string','false','false'));
        }
        
        String str = JSON.serialize(clientFields);
        
        System.debug(str);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setTimeout(120000);
        req.setEndpoint('https://esb.ext.api.absa.co.za/enterprise-ext/ext/AttestationService/v1.0/ClientInstruction/CreateClientInstruction');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
        req.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        String strBody = '[{"IsReadOnly":null,"IsMandatory":null,"FieldValue":"Testing mabee","FieldKey":"ClientName ","FieldDescription":null,"DataType":null},{"IsReadOnly":null,"IsMandatory":null,"FieldValue":"1234567890","FieldKey":"RegistrationNumber ","FieldDescription":null,"DataType":null},{"IsReadOnly":null,"IsMandatory":null,"FieldValue":"South Africa","FieldKey":"CountryOfIncorporation","FieldDescription":null,"DataType":null},{"IsReadOnly":null,"IsMandatory":null,"FieldValue":"PASSPORT","FieldKey":"IDType","FieldDescription":null,"DataType":null},{"IsReadOnly":null,"IsMandatory":null,"FieldValue":"Individual Client","FieldKey":"ClientGroup","FieldDescription":null,"DataType":null}]';
        
       
        
        
        req.setBody(str);

        System.debug(str);
        HTTPResponse res = h.send(req);
        
        String jsonBody = res.getBody();

        acc.ESP_ID__c = jsonBody.remove('"');
       System.debug(res);
    }
    public class LegalEntity 
    {
        public String Key{get;set;}
		public String Value{get;set;}
    }
    
    public class ContactDetail
    {
        public String Code{get;set;}
        public String Name{get;set;}
	}
    
    public class FieldNode
    {
        public string FieldKey { get; set; }
        public string FieldValue { get; set; }
        public string FieldDescription { get; set; }
        public string DataType { get; set; }
        public string IsReaOnly { get; set; }
        public string IsMandatory { get; set; }

        public FieldNode(String key,String value,String description,String dataType,String isReadOnly,String isMandatory)
        {
            this.FieldKey = key;
            this.FieldValue = value;
            this.FieldDescription = description;
            this.DataType = dataType;
            this.IsReaOnly = isReadOnly;
            this.IsMandatory = isMandatory;
        }
    }
    public class Response
    {
        public String message{get;set;}
        public String stackTrace{get;set;}
    }
}