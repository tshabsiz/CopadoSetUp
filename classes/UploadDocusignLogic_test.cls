@isTest
public class UploadDocusignLogic_test {
    public static testmethod void UploadSignedDocumentToBox_test() {
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(acmCollateralTestData.TestDocusignAttachment);
        UploadDocusignLogic.UploadDocumentToBox(attachments);
        Test.stopTest();
    }
}