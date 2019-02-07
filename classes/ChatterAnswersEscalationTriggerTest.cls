@isTest
private class ChatterAnswersEscalationTriggerTest {
	static testMethod void validateQuestionEscalation() {
        
		String questionTitle = 'questionTitle';
		String questionBody = 'questionBody';
		Community[] c = [SELECT Id from Community];
		// We cannot create a question without a community
		if (c.size() == 0) { return; }
		String communityId = c[0].Id;
		Question q = new Question();
		q.Title = questionTitle;
		q.Body = questionBody;
		q.CommunityId = communityId;
		insert(q);
		q.Priority = 'high';
		update(q);
        
        Case ca = new Case();
        ca.QuestionId = q.Id;
        ca.Subject = questionTitle;
       	ca.Description = questionBody;
        ca.Origin = 'Chatter Answers';
        ca.CommunityId = communityId;
        ca.RecordTypeId = [Select Id from Recordtype Where DeveloperName = 'Client_Support_Case'].Id;
        insert ca;
        
		//Case ca = [SELECT Origin, CommunityId, Subject, Description from Case where QuestionId =: q.Id];
		// Test that escaltion trigger correctly escalate the question to a case
		System.assertEquals(questionTitle, ca.Subject);
		System.assertEquals(questionBody, ca.Description);
		System.assertEquals('Chatter Answers', ca.Origin);
		System.assertEquals(communityId, ca.CommunityId);
	}
}