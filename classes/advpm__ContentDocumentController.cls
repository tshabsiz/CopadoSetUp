/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ContentDocumentController {
    @RemoteAction
    global static void createContentDocumentLinks(String recordIds, String RecordId) {

    }
    @RemoteAction
    global static void deleteDocument(String selecteddocumentId) {

    }
    @RemoteAction
    global static List<advpm.ContentDocumentController.LibraryOptionWrapper> getLibraries(String jsonMap) {
        return null;
    }
    @RemoteAction
    global static advpm.ContentDocumentController.SharingListWrapper getSharingStatus(String selecteddocumentId) {
        return null;
    }
    @RemoteAction
    global static List<advpm.ContentDocumentController.versionWrapper> getallVersion(String selecteddocumentId) {
        return null;
    }
    @RemoteAction
    global static advpm.ContentDocumentController.ContentDocumentWrapper getdocumentList(String recordId) {
        return null;
    }
    @RemoteAction
    global static void makePrivate(String selecteddocumentId) {

    }
    @RemoteAction
    global static void publishWithLibraries(String selectedLibraries, String selecteddocumentId) {

    }
    @RemoteAction
    global static void restrictAccess(String selecteddocumentId) {

    }
    @RemoteAction
    global static void savePanelSortingState(String sortColumn, String sortDirection) {

    }
    @RemoteAction
    global static void setAccess(String selecteddocumentId) {

    }
    @RemoteAction
    global static void updateAccess(String shareStatus, String selecteddocumentId, String relatedMatter, String RecordId) {

    }
global class ContentDocumentWrapper {
}
global class LibraryOptionWrapper {
}
global class SharingListWrapper {
}
global class versionWrapper implements System.Comparable {
}
}
