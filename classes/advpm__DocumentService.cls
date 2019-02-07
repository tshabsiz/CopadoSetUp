/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DocumentService {
    global static Boolean isChatterNotification;
    global static Boolean isContent;
    global static Boolean isFile;
    global static Boolean isSaveAllow;
    global DocumentService() {

    }
    global static String parseTemplateBody(Id recordId, Id templateId, String outputFormat) {
        return null;
    }
    @InvocableMethod(label='Create an AdvoDoc' description='Create an AdvoDoc for source record using the AdvoDoc Template provided.')
    global static List<advpm.DocumentService.ResultWrapper> parseTemplate(List<advpm.DocumentService.InputWrapper> IW) {
        return null;
    }
    global static String storeDocument(Id recordId, String templateId) {
        return null;
    }
    global static String storeDocument(Id recordId, String templateId, String type) {
        return null;
    }
    @Future(callout=true)
    global static void storeDocumentAsync(Id recordId, String templateId, String type) {

    }
global class DocumentServiceResponse {
    global Id contentId {
        get;
        set;
    }
    global String result {
        get;
        set;
    }
    global String success {
        get;
        set;
    }
    global DocumentServiceResponse() {

    }
}
global class InputWrapper {
    @InvocableVariable(label='Output Format (PDF or DOCX)' description='Provide desired output format for the document.' required=false)
    global String outputFormat;
    @InvocableVariable(label='Source Record ID' description='Provide source record's Id value for which AdvoDoc will be created from.' required=true)
    global Id recordId;
    @InvocableVariable(label='AdvoDoc Template ID' description='Provide AdvoDoc Template Id value here.' required=true)
    global Id templateId;
    global InputWrapper() {

    }
}
global class ResultWrapper {
    @InvocableVariable(label='AdvoDoc Result Message' required=false)
    global String body;
    @InvocableVariable(label='AdvoDoc Result Status' required=false)
    global String status;
    global ResultWrapper() {

    }
}
}
