@isTest 
public class evAddEventTeamMembers_Controller_test 
{
    static testMethod void evAddEventTeamMembers_Controller_test()
    {
        evTestDataGenerator TDG = new evTestDataGenerator();
        
        PageReference RSVPPage = Page.evRSVP;
        RSVPPage.getParameters().put('id', TDG.testevent.Id);
        Test.setCurrentPage(RSVPPage); 
        
        evAddEventTeamMembers_Controller con = new  evAddEventTeamMembers_Controller();
        con.AddTeamMemberRow();
        con.removeRow();
        con.CreateTeamMembers();
    }
}