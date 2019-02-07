@isTest
public class evManageDelegates_Controller_Test
{
    
    static testMethod void evManageDelegates_Controller_Test()
    {
        
        
        PageReference myVfPage = Page.evManageDelegates;
        Test.setCurrentPage(myVfPage);
        
        evTestDataGenerator TDG =  new evTestDataGenerator();
        
        TDG.TestDelegate.RSVP_Status__c = 'No';
        update TDG.TestDelegate;
        
        system.debug('TDG.TestEvent.id');
        
        ApexPages.currentPage().getParameters().put('id', TDG.TestEvent.id);
        
        Test.startTest();
        
        evManageDelegates_Controller con = new evManageDelegates_Controller();
        
        con.cancel();
        
        con.delegateAList.add(TDG.TestDelegate);
        con.confirmedAlist = string.valueof(TDG.TestDelegate.id);
        con.confirm();
        con.DelegateIDsString = TDG.TestDelegate.id;
        con.delDelegate();
        Test.stopTest();
        
    }
    
}