public Class Response {
    @AuraEnabled public String message;
    @AuraEnabled public Boolean success;
    @AuraEnabled public Object data;
    
    public Response(Boolean success, String message, Object data){
        this.success = success;
        this.message = message;
        this.data = data;
    }
}