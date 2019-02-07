public abstract class BxdMetadataHandler {    
    private static BxdIntegrationConnection boxConnection;
    private static BoxPlatformApiConnection api;
    public static final String FOLDER_METADATA_URL_TEMPLATE = 'folders/{0}/metadata/{1}/{2}';
    public static final String FILE_METADATA_URL_TEMPLATE = 'files/{0}/metadata/{1}/{2}';
    
    /**
    * BxdMetadataHandler - constructs the class and enable connection to box, initialize the api
	**/
    public BxdMetadataHandler(Boolean connect) {
        boxConnection = BxdIntegrationConnection.getInstance();
        if(connect){
            api = boxConnection.getBoxApi();
        }
    }
    
    /**
    * createFileMetadata - calls createMetadata with passed arguments 
	**/
    public BxdMetadata createFileMetadata(String resourceId, String templateName, BxdMetadata metadata) {
        String scope = BxdMetadata.scopeBasedOnType(templateName);
        return this.createMetadata(resourceId, FILE_METADATA_URL_TEMPLATE, templateName, scope, metadata);
    }
    
    /**
    * createMetadata - this method creates a new BxdMetadata instance by sending a box request to the box api
	**/
    public BxdMetadata createMetadata(String resourceId, String templateURL, String templateName, String scope, BxdMetadata metadata) {
        String url = api.baseUrl + String.format(templateURL, new String[] {resourceId, scope, templateName});
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_POST);
        request.setTimeout(api.getTimeout());
        request.addJsonContentTypeHeader();
        request.setBody(metadata.toString());
        BoxGenericJsonObject response = boxConnection.sendBoxRequest(request);
        system.debug(response);
        return new BxdMetadata(response);
    }
}