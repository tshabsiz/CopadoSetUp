public class AcmHttpClient {
    private Map<String, String> headers {get; set;}
    private String url { get; set; }
    private String method { get; set;}
    private String body { get; set; }
    
    public AcmHttpClient(Map<String, String> headers, String url, String method, String body) {
        this.headers = headers;
        this.url = url;
        this.method = method;
        this.body = body;
    }
    
    public HttpResponse sendRequest() {
        
         HttpRequest request = new HttpRequest();
       
         // Set api manager url and method
         request.setEndPoint(url); 
         request.setMethod(method);
            
        // Set header
        for(String headerKey : headers.keySet()) {
            request.setHeader(headerKey, headers.get(headerKey));
        }
           
        // Set body
        if(method != 'GET') {
            request.setBody(body);  
        }
            
        Http httpRequest = new Http();
        HttpResponse response = null;
        Integer retry = 0;
        // Try three times to send
        while (retry < 3) {
            retry = retry + 1;
            System.debug('Try number : ' + retry);
            try {
                System.debug('request is : ' + request);
                response = httpRequest.send(request);
                System.debug('response is : ' + response);
                break;
            } catch (CalloutException e) {
                System.debug('Unable to create mitigant on ACM : '+ e);
            }
        }
        return response;
    }
}