/**
 * Created by KyleAlexander on 2018/03/19.
 */

@Istest
public class AgreementClauseList_Cont_test {

    public static testMethod void testAgreementAddClauses() {
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();

        Test.setCurrentPageReference(new PageReference('Page.AgreementClauseList'));
        System.currentPageReference().getParameters().put('id', libraTestData.testAgreement.id);
		
        Agreement__c ag = libraTestData.testAgreement;
        ag.RecordTypeId = Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('ISDA Agreement').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.StandardController(ag);
        AgreementClauseList_Cont testAgreement = new AgreementClauseList_Cont(sc);
        
        List<ClauseWrapper> notAddedClauses = new List<ClauseWrapper>();
        ClauseWrapper testWrapper = new ClauseWrapper(libraTestData.testClause);
        testWrapper.selected = true;
        notAddedClauses.add(testWrapper);
        testAgreement.notAddedClauses = notAddedClauses;
        
        testAgreement.AddClauses();
        
        List<ClauseWrapper> addedClauses = new List<ClauseWrapper>();
        ClauseWrapper testWrapper2 = new ClauseWrapper(libraTestData.testClause);
        testWrapper2.selected = false;
        addedClauses.add(testWrapper2);
        testAgreement.addedClauses = addedClauses;
        
        testAgreement.RemoveClauses();

        testAgreement.amendment = libraTestData.testAmendment;
        testAgreement.amendmentDocument = true;
        testAgreement.SaveAmendment();
        
        ag.Agreement_Status__c = 'Amended';
        update ag;
        sc = new ApexPages.StandardController(ag);
        testAgreement = new AgreementClauseList_Cont(sc);  
    }
}