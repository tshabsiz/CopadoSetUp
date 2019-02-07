/*==========================================
@Author : Mabhedle Tonga
@Description : For post refresh run this class to setup test Data
@Created Date : 2018/04/28
============================================*/
global class SandboxPostRefreshAbsa implements SandboxPostCopy
{
	global void runApexClass(SandboxContext context)
    {
        new SandboxPostRefreshTestData(); 
    }   
}