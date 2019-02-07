public abstract class BxdPolicyHandler {
    private static BxdIntegrationConnection boxConnection;
    private static BoxPlatformApiConnection api;
    public static final String LEGAL_HOLD_POLICY = 'legal_hold_policies';
    public static final String LEGAL_HOLD_POLICY_ID = 'legal_hold_policies/{0}';
    public static final String POLICY_ASSIGNMENT = 'legal_hold_policy_assignments';
    public static final String POLICY_ASSIGNMENT_ID = 'legal_hold_policy_assignments/{0}';
    
    /**
    * BxdPolicyHandler  - construct the policy handler and connect to the box api as the service account
	**/
    public BxdPolicyHandler(Boolean connect) {
        boxConnection = BxdIntegrationConnection.getInstance();
        if(connect){
            api = boxConnection.getBoxApi();
        }
    }
    
    /**
    * createPolicyAssignment - used to crete a policy assignment by calling createOnBox below, instantiate an assignment with passed arguments
	**/
    public BxdLegalHoldAssignment createPolicyAssignment(String policyId, String resourceId, String typeName) {
        BxdLegalHoldAssignment assignment = new BxdLegalHoldAssignment();
        assignment.policy_id = policyId;
        assignment.assign_to.id = resourceId;
        assignment.assign_to.type = typeName;
        return BxdLegalHoldAssignment.parse(createOnBox(BxdLegalHoldAssignment.getJsonString(assignment), POLICY_ASSIGNMENT).getJsonString());
    }
    
    public BxdLegalHoldAssignment deletePolicyAssignment(String assignmentId) {       
        return BxdLegalHoldAssignment.parse(deleteOnBox(assignmentId, POLICY_ASSIGNMENT_ID).getJsonString());
    }
    
    public BoxGenericJsonObject createOnBox(String jsonObject, String endpointURL) {
        String url = api.baseUrl + String.format(endpointURL, new String[] {});
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_POST);
        request.setTimeout(api.getTimeout());
        request.addJsonContentTypeHeader();
        request.setBody(jsonObject);
        BoxGenericJsonObject response = boxConnection.sendBoxRequest(request);
        return response;
    }
    
    public BoxGenericJsonObject deleteOnBox(String id, String endpointURL) {
        String url = api.baseUrl + String.format(endpointURL, new String[] { id });
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_DELETE);
        request.setTimeout(api.getTimeout());
        request.addJsonContentTypeHeader();
        BoxGenericJsonObject response = boxConnection.sendBoxRequest(request);
        return response;
    }
}