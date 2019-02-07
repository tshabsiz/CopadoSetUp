@isTest
public class BxdDocumentTreeView_test {
    @isTest static void testDeal() {
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));
        
        BoxDocumentViewHelper_test.createAccountDeal();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.DealId;

        PageReference RelatedListView = new PageReference('/apex/BxdDocuments?Id=' + BxdOwnerId);
        Test.setCurrentPage(RelatedListView);
        
        Test.startTest();
        BxdDocumentTreeView treeView = new  BxdDocumentTreeView();
        Test.stopTest();
    }
    
    @isTest static void testAccount() {        
        BoxDocumentViewHelper_test.createAccountDeal();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.AccountId;
        
        PageReference RelatedListView = new PageReference('/apex/BxdDocuments?Id=' + BxdOwnerId);
        Test.setCurrentPage(RelatedListView);

        Test.startTest();
        BxdDocumentTreeView treeView = new  BxdDocumentTreeView();
        Test.stopTest();
    }
    
    @isTest static void testAggrement() {        
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createAgreement();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.AgreementId;

        PageReference RelatedListView = new PageReference('/apex/BxdDocuments?Id=' + BxdOwnerId);
        Test.setCurrentPage(RelatedListView);

        Test.startTest();
        BxdDocumentTreeView treeView = new  BxdDocumentTreeView();
        Test.stopTest();
    }
    
    @isTest static void testCondition() {        
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createAgreement();
        BoxDocumentViewHelper_test.createCondition();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.ConditionId;

        PageReference RelatedListView = new PageReference('/apex/BxdDocuments?Id=' + BxdOwnerId);
        Test.setCurrentPage(RelatedListView);

        Test.startTest();
        BxdDocumentTreeView treeView = new  BxdDocumentTreeView();
        Test.stopTest();
    }
}