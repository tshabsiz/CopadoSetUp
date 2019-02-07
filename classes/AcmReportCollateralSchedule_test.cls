@istest
public class AcmReportCollateralSchedule_test {
    public static testmethod void AcmReportCollateralSchedule_test() {
      Test.startTest();
      AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
      Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
     
      String jobId = System.schedule('test Acm Report Collateral Schedule','0 7 * * * ?', new AcmReportCollateralSchedule());
      Test.stopTest();
    }
}