@isTest (seeAllData=false)
private without sharing class evRSVP_Controller_Test 
{
    public class MyException extends Exception {}     
    
    static testMethod void BHA_RSVP_Controller_test() 
    {
        
        
        //test yes
        
        evTestDataGenerator TDG = new evTestDataGenerator();
        
        PageReference RSVPPage = Page.evRSVP;
        RSVPPage.getParameters().put('delid', TDG.testDelegate.Id);
        RSVPPage.getParameters().put('rsvp', 'Yes');
        Test.setCurrentPage(RSVPPage); 
        
        evRSVP_Controller  RSVPCon =  new evRSVP_Controller();
        RSVPCon.HandleResponse();
        
        //test no        
        
        TDG.testDelegate.RSVP_Status__c = 'No';
        RSVPPage = Page.evRSVP;
        RSVPPage.getParameters().put('delid', TDG.testDelegate.Id);
        RSVPPage.getParameters().put('rsvp', 'No');
        Test.setCurrentPage(RSVPPage); 
        
        RSVPCon =  new evRSVP_Controller(); 
        RSVPCon.HandleResponse();
        
        //test maybe
        
        TDG.testDelegate.RSVP_Status__c = 'Maybe';
        RSVPPage = Page.evRSVP;
        RSVPPage.getParameters().put('delid', TDG.testDelegate.Id); 
        RSVPPage.getParameters().put('rsvp', 'Maybe');
        Test.setCurrentPage(RSVPPage); 
        
        RSVPCon =  new evRSVP_Controller();
        RSVPCon.HandleResponse();
        
        //test no parems 
        
        TDG.testDelegate.RSVP_Status__c = '';
        RSVPPage = Page.evRSVP;
        RSVPPage.getParameters().put('delid', TDG.testDelegate.Id);
        Test.setCurrentPage(RSVPPage); 
        
        RSVPCon =  new evRSVP_Controller();
        try//put this in a try catch as the handled error causes the test class to fail
        {
            RSVPCon.HandleResponse();
        }
        Catch(exception e)
        {
            //do nothing
        }
        
        
        
        //test bad parems
        
        TDG.testDelegate.RSVP_Status__c = 'Thinking about it xyz';        
        RSVPPage = Page.evRSVP;
        RSVPPage.getParameters().put('delid', TDG.testDelegate.Id);
        RSVPPage.getParameters().put('rsvp', 'Thinking about it xyz'); 
        Test.setCurrentPage(RSVPPage); 
        
        RSVPCon =  new evRSVP_Controller();
        try//put this in a try catch as the handled error causes the test class to fail
        {
            RSVPCon.HandleResponse();
        }
        Catch(exception e)
        {
            //do nothing
        }
        
        //RSVPCon.thisDelegate.firstname__c                             = 'newTestFirst';
        //RSVPCon.thisDelegate.lastname__c                              = 'TestLast';
        RSVPCon.thisDelegate.mobile__c                              = '085 555 5555';
        RSVPCon.thisDelegate.title__c                               = 'Analyst';
        RSVPCon.thisDelegate.Phone__c                               = '011 555 5555';
        RSVPCon.thisDelegate.id__C                                  = '6512016787653';
        RSVPCon.thisDelegate.Salutation__c                          = 'mr.';
        RSVPCon.thisDelegate.Industry__c                            = 'IT';
        RSVPCon.thisDelegate.email__c                               = 'newsomeone@somewhere.com';
        RSVPCon.thisDelegate.Event_Visit_Reason__c                  = 'newFood';
        RSVPCon.thisDelegate.Lead_Source__c                         = 'Website';
        RSVPCon.thisDelegate.Company__c                             = 'Test';
        RSVPCon.thisDelegate.Gender__c                              = 'Test';
        //RSVPCon.thisDelegate.Nationality__c                         = 'South Africa';
        RSVPCon.thisDelegate.Dietary_Requirement__c                 = 'Test';        
        RSVPCon.thisDelegate.Emergency_Contact_Name__c              = 'Test';
        RSVPCon.thisDelegate.Emergency_Contact_Relationship__c      = 'Test';
        RSVPCon.thisDelegate.Emergency_Contact_Tel__c               = 'Test';   
        RSVPCon.thisDelegate.Main_Member_Name__c                    = 'Test';            
        RSVPCon.thisDelegate.Medical_Aid_Name__c                    = 'Test';            
        RSVPCon.thisDelegate.Medical_Aid_No__c                      = 'Test';                                   
        RSVPCon.thisDelegate.Medical_Conditions__c                  = 'Test';            
        RSVPCon.thisDelegate.Address__c                             = 'Test';                    
        RSVPCon.thisDelegate.Postal_Code__c                         = 'Test';            
        //RSVPCon.thisDelegate.Type_of_Identification__c              = 'Passport';              
        RSVPCon.thisDelegate.Availibility__C                        = 'Test';            
        RSVPCon.thisDelegate.Accessibility__C                       = 'Test';
        RSVPCon.thisDelegate.age__C                                 = 1;
        
        RSVPCon.ConfirmAccept();
        RSVPCon.accept1                                             = true;
        RSVPCon.ConfirmAccept();
        
        //RSVPCon.decline();
        RSVPCon.CancelAccept();
        //RSVPCon.thisDelegate.RSVP_Status__c = 'Pending Declined';
        update RSVPCon.thisDelegate;
        RSVPCon.CancelDecline();
        //RSVPCon.thisDelegate.RSVP_Status__c = 'Pending Accepted';
        update RSVPCon.thisDelegate;
        RSVPCon.CancelDecline();
        RSVPCon.getErrorsLevel1();
        RSVPCon.getHasErrorsLevel1(); 
        RSVPCon.GetCompanyOrIndividualBookingTypes();
        RSVPCon.getCurrencyOptions();
        RSVPCon.getDelegateTypes();
        RSVPCon.getDietOptions();
        RSVPCon.getEventGenderTypes();
        RSVPCon.getEventIndustryTypes();
        RSVPCon.getIdentificationTypes();
        
        delegate__c testDel = new delegate__c();
        
        RSVPCon.listOfPartnerDelegates.add(testDel);
        RSVPCon.InsertPartnerDelegates();
        
        testDel.Last_Name__c = 'test';
        testDel.First_Name__c  = 'test';
        testDel.Email__c = 'test@test.com';
        testDel.Partner_Type__c = 'Partner';
        testDel.Dietary_Requirement__c = 'None';
        
        RSVPCon.listOfPartnerDelegates.Clear();
        RSVPCon.listOfPartnerDelegates.add(testDel);
        try
        {
        RSVPCon.InsertPartnerDelegates();  
        } 
        catch(exception e)
        {}
    }    
}