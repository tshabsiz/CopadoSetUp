@istest
Private class  evSiteTemplate_Controller_test 
{
    static testmethod void evSiteTemplate_Controller_test()
    {
        evTestDataGenerator TDG = new evTestDataGenerator();
        
        
        
        PageReference pageRef1 = Page.evTemplateSocial;	
        pageRef1.getParameters().put('delid', TDG.TestDelegate.id);
        Test.setCurrentPageReference(pageRef1);
        evSiteTemplate_Controller ConTest = new evSiteTemplate_Controller();
        
        pageRef1 = Page.evTemplateSocial;	
        pageRef1.getParameters().put('evid', TDG.TestEvent.id);
          pageRef1.getParameters().put('delid', TDG.TestDelegate.id);
        Test.setCurrentPageReference(pageRef1);
        ConTest = new evSiteTemplate_Controller();
    }
    
}