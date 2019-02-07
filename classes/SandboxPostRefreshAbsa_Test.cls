/*==========================================
@Author : Mabhedle Tonga
@Description : Test class for SandboxPostRefreshAbsa
@Created Date : 2018/04/28
============================================*/
@isTest
public class SandboxPostRefreshAbsa_Test 
{
    @isTest
    static void SandboxPostRefreshAbsaUnitTest() 
    {
        Test.startTest();
        Test.testSandboxPostCopyScript(
            new SandboxPostRefreshAbsa(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();

    }
}