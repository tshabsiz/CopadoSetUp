/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for KnowYourColleagueController class
*/
@isTest
public class ZZTEST_KnowYourColleagueController {

    static testMethod void testGetAllChallengeQuestions() {
        KnowYourColleagueController.getAllChallengeQuestions('');
    }
    
    static testMethod void testSetQuestionAsMine() {
    ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select ID from user where ID =:userinfo.getUserId()];
        System.runAs(user1)
        {
            ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        Challenge_Question__c cq = new Challenge_Question__c();
        cq.Description__c = 'asdf';
        insert cq;
        
        KnowYourColleagueController.setQuestionAsMine(cq.Id, u1.Id);
        }
        
    }
    
    static testMethod void testAddAnswer() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select ID from User where ID =:UserInfo.getUserId()];
        
        System.runAs(User1)
        {
            ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
            User u1 = userFactory.getBarclaysStandardUser();
            
            Challenge_Question__c cq = new Challenge_Question__c();
            cq.Description__c = 'asdf';
            insert cq;
            
            User_Question__c uq = new User_Question__c();
            uq.Questioner__c = u1.Id;
            uq.Challenge_Question__c = cq.Id;
            insert uq;
            
            KnowYourColleagueController.addAnswer('', uq.Id, '');
        }
        
    }
    
    static testMethod void testSearchUser() {
        KnowYourColleagueController.searchUser('mar');
    }
    
    static testMethod void testSetAnswerData() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select ID from User where id=:userInfo.getUserId()];
        
        
        System.runAs(user1)
        {
            	ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        Challenge_Question__c cq = new Challenge_Question__c();
        cq.Description__c = 'asdf';
        insert cq;
    
        User_Question__c uq = new User_Question__c();
        uq.Questioner__c = u1.Id;
        uq.Challenge_Question__c = cq.Id;
        insert uq;
        
        Possible_Answer__c pa = new Possible_Answer__c();
        pa.Description__c = 'asdf';
        pa.Question__c = uq.Id;
        insert pa;
    
        KnowYourColleagueController.setAnswerData(pa.Id, false);
        }
        
    }
    
    static testMethod void testGetUserQuestion() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1  = [Select ID from User where ID =:UserInfo.getuserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        Challenge_Question__c cq = new Challenge_Question__c();
        cq.Description__c = 'asdf';
        insert cq;
    
        User_Question__c uq = new User_Question__c();
        uq.Questioner__c = u1.Id;
        uq.Challenge_Question__c = cq.Id;
        insert uq;
        
        Possible_Answer__c pa = new Possible_Answer__c();
        pa.Description__c = 'asdf';
        pa.Question__c = uq.Id;
        insert pa;
        
        Possible_Answer__c pa1 = new Possible_Answer__c();
        pa1.Description__c = 'asdff';
        pa1.Question__c = uq.Id;
        insert pa1;
        
        Possible_Answer__c pa2 = new Possible_Answer__c();
        pa2.Description__c = 'asdfff';
        pa2.Question__c = uq.Id;
        insert pa2;
        
        KnowYourColleagueController.getUserQuestion(u1.Id);
        }
        
    }
    
}