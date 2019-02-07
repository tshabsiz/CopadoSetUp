@isTest
public class AcmCollateralSchedule_test {
    public static testmethod void AcmCollateralSchedule_test() {
      Test.startTest();
      AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
      Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
      String jobId = System.schedule('test Acm Report Collateral Schedule','0 7 * * * ?', new AcmCollateralSchedule());
      Test.stopTest();
    }
    
    public static testmethod void AcmBatchJob_test() {
      Test.startTest();
      AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
      Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
      String batchId = System.scheduleBatch(new AcmBatchJob(), 'Salesforce ACM Collateral Integration', 1, 100);
      Test.stopTest();
    }
}