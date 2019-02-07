/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Toolkit {
    global String mostRecentError {
        get;
    }
    global Toolkit() {

    }
    global void commitChanges() {

    }
    global String createCollaboration(String folderId, String boxUserId, String emailAddress, box.Toolkit.CollaborationType collabType, String accessToken) {
        return null;
    }
    global String createCollaborationOnRecord(Id userId, Id recordId, box.Toolkit.CollaborationType collabType, Boolean optCreateFolder) {
        return null;
    }
    global String createFileFromAttachment(Attachment att, String fileNameOverride, String folderIdOverride, String accessToken) {
        return null;
    }
    global String createFolder(String folderName, String parentFolderId, String accessToken) {
        return null;
    }
    global box__FRUP__c createFolderAssociation(Id recordId, String folderId) {
        return null;
    }
    global String createFolderForRecordId(Id recordId, String folderNameOverride, Boolean optCreateRootFolder) {
        return null;
    }
    global String createObjectFolderForRecordId(Id recordId) {
        return null;
    }
    global Boolean deleteCollaboration(String collabId, String accessToken) {
        return null;
    }
    global static Boolean deleteServiceUserAssociation() {
        return null;
    }
    global static Boolean deleteUserAssociation(Id salesforceUserId) {
        return null;
    }
    global Boolean editCollaboration(String collabId, box.Toolkit.CollaborationType collabType, String accessToken) {
        return null;
    }
    global List<box__FRUP__c> getFolderAssociationsByRecordId(Id recordId) {
        return null;
    }
    global String getFolderIdByRecordId(Id recordId) {
        return null;
    }
    global System.PageReference getFolderUrl(Id recordId, Boolean isMobileContext) {
        return null;
    }
    global String getObjectFolderByRecordId(Id recordId) {
        return null;
    }
    global Id getRecordIdByFolderId(String folderId) {
        return null;
    }
    global String getRootFolderId() {
        return null;
    }
    global System.PageReference getUrlForFolder(Id recordId) {
        return null;
    }
    global Boolean moveFolder(String folderId, String newParentFolderId, String accessToken) {
        return null;
    }
    global System.HttpResponse sendRequest(System.HttpRequest request) {
        return null;
    }
global class BoxApiException extends Exception {
}
global enum CollaborationType {COOWNER, EDITOR, OWNER, PREVIEWER, PREVIEWERUPLOADER, UPLOADER, VIEWER, VIEWERUPLOADER}
}
