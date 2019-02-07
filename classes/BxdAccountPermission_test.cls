@isTest
public class BxdAccountPermission_test {
    public static testMethod void TestAccountPermissionController()
	{
        BXDtesclassdata.setupFolder();
		Account TestAccount = new Account
            (
                Name ='test',
                Type = 'Client'
            );
        Insert TestAccount; 
		ApexPages.StandardController sc = new ApexPages.standardController(TestAccount);
		BxdAccountPermission page = new BxdAccountPermission(sc);

		//Main method.
		PageReference actionView = page.actionViewRoute();
        system.assert(actionView != null);
	}
}