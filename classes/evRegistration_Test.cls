@isTest
public class evRegistration_Test 
{
    static testMethod void evUtility_Class_test()
    {
        evTestDataGenerator TDG = new evTestDataGenerator();
        
        evRegistration.GetContact(TDG.TestContact.id);
        
        evRegistration.GetDelegate(TDG.TestDelegate.id);
        evRegistration.GetEvent(TDG.TestEvent.id);
        
        try
        {
            evRegistration.GetCustomMetadata('tets');
        }
        catch(exception e)
        {
            
        }
    }
}