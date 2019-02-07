/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_ViewController
*              Tests executed:
*               1 - testJlocGenerateDocument()
*                   Test that Pricing and Returns document can be generated.
*               2 - testJlocSubmitToSecretary()
*                   Test that JLOC can be submitted to Secretary.
*               3 - testJlocRejected()
*                   Test that JLOC can be rejected by Secretary.
*               4 - testJlocSentToCommittee()
*                   Test that JLOC can be sent to Committee by Secretary.
*               5 - testJlocAttendeeVoting()
*                   Test that JLOC Attendee can vote for JLOC.
*               6 - testJlocSecretaryVoting()
*                   Test that Secretary can vote for JLOC.
*               7 - testJlocSharing()
*                   Test redirection to JLOC sharing page.
*				8 - testJlocClone()
*					Test redirection to JLOC clone page (which is the create page)
*               9  - SendToTeamTest()
*                    Test sending Jloc To Team Member
*               10 - testJlocSubmitToSecretaryWithFinancialProjections()
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015  Marta Malinowska   Add testing for JLOC Attendee voting comments
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_JLOC_ViewController {
	public static testMethod void testJlocGenerateDocument() {

            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            Attachment dummyAttachment = new Attachment();
            dummyAttachment.ParentId = jloc.Id;
            dummyAttachment.Name = 'first_test.pdf';
            dummyAttachment.Body = Blob.ValueOf('first test attachment');
            INSERT dummyAttachment;

            jloc.JLOC_Document_ID__c = dummyAttachment.Id;
            UPDATE jloc;
        
            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            controller.generatePdf();

            Test.stopTest();

            //Re-query JLOC
            jloc = [SELECT Id, JLOC_Document_ID__c FROM JLOC__c WHERE Id =:jloc.Id];

            //Verify that the dummy attachment is no longer related to this JLOC
            System.assertNotEquals(dummyAttachment.Id, jloc.JLOC_Document_ID__c, 'This attachment should no longer exist or be linked to the JLOC');

            //Query the new attachment
            Attachment attach = [SELECT Id, Name FROM Attachment WHERE parentId = :jloc.Id];

            //Verify it's attached
            System.assertEquals(attach.Id, jloc.JLOC_Document_ID__c, 'The generated PDF is not linked to the Attachment');
	}

      public static testMethod void testJlocSubmitToSecretary() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        
            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            //Submit to secretary without key fields being set to True
            controller.submitToSecretary();

            //Re-query JLOC
            jloc = [SELECT Id, JLOC_Status__c FROM JLOC__c WHERE Id =:jloc.Id];

            //Verify it's still in Status draft
            System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_DRAFT, 'JLOC should still be in Draft');

            //Update fields
            controller.jloc.Status__c = 'New';
            controller.jloc.CLGD_Consumption__c = 'No';
            controller.jloc.Barclays_Commitment__c = 0;
            controller.jloc.Barclays_Underwriting__c = 0;
            controller.jloc.Barclays_Target_Hold__c = 0;
            controller.jloc.Deal_Presented_To_Deal_Forum__c = true;
            controller.jloc.Go_Approval_From_Deal_Forum_Quorum__c = true;
            controller.jloc.Approved_By_Financial_Crime_Compliance__c = true;
            controller.jloc.Conflict_Clearance_Obtained__c = true;
            controller.jloc.Deal_Team_Polices_Confirmation__c = true;

            controller.submitToSecretary();

            Test.stopTest();

            //Re-query JLOC
            jloc = [SELECT Id, JLOC_Status__c FROM JLOC__c WHERE Id =:jloc.Id];
            System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_SUBMITTED_TO_SECRETARY, 'JLOC should now be in Submitted status');
      }
    public static testMethod void testJlocSubmitToSecretaryWithFinancialProjections() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        
        Attachment dummyAttachment = new Attachment();
        dummyAttachment.ParentId = jloc.Id;
        dummyAttachment.Name = 'FinancialProjections.pdf';
        dummyAttachment.Body = Blob.ValueOf('first test attachment');
        INSERT dummyAttachment;
        
        jloc.Forecast_Not_Available__c = false;
        jloc.Stress_Case_ID__c = dummyAttachment.ID;
        jloc.Banker_Case_ID__c = dummyAttachment.ID;
        jloc.Management_Case_ID__c = dummyAttachment.ID;
        update jloc;
        Test.startTest();
        
        PageReference JLOC_View = Page.JLOC_View;
        Test.setCurrentPage(JLOC_View);
        
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_ViewController controller = new JLOC_ViewController(stc);
        
        //Submit to secretary without key fields being set to True
        controller.submitToSecretary();
        
        //Re-query JLOC
        jloc = [SELECT Id, JLOC_Status__c FROM JLOC__c WHERE Id =:jloc.Id];
        
        //Verify it's still in Status draft
        System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_DRAFT, 'JLOC should still be in Draft');
        
        //Update fields
        controller.jloc.Status__c = 'New';
        controller.jloc.CLGD_Consumption__c = 'No';
        controller.jloc.Barclays_Commitment__c = 0;
        controller.jloc.Barclays_Underwriting__c = 0;
        controller.jloc.Barclays_Target_Hold__c = 0;
        controller.jloc.Deal_Presented_To_Deal_Forum__c = true;
        controller.jloc.Go_Approval_From_Deal_Forum_Quorum__c = true;
        controller.jloc.Approved_By_Financial_Crime_Compliance__c = true;
        controller.jloc.Conflict_Clearance_Obtained__c = true;
        controller.jloc.Deal_Team_Polices_Confirmation__c = true;
        
        controller.submitToSecretary();
        
        Test.stopTest();
        
        //Re-query JLOC
        jloc = [SELECT Id, JLOC_Status__c FROM JLOC__c WHERE Id =:jloc.Id];
        System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_SUBMITTED_TO_SECRETARY, 'JLOC should now be in Submitted status');
    }
    public static testMethod void testJlocRejected() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        
            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            controller.jloc.Status__c = 'New';
            controller.jloc.CLGD_Consumption__c = 'No';
            controller.jloc.Barclays_Commitment__c = 0;
            controller.jloc.Barclays_Underwriting__c = 0;
            controller.jloc.Barclays_Target_Hold__c = 0;
            controller.jloc.Deal_Presented_To_Deal_Forum__c = true;
            controller.jloc.Go_Approval_From_Deal_Forum_Quorum__c = true;
            controller.jloc.Approved_By_Financial_Crime_Compliance__c = true;
            controller.jloc.Conflict_Clearance_Obtained__c = true;
            controller.jloc.Deal_Team_Polices_Confirmation__c = true;

            controller.submitToSecretary();
            jloc = [SELECT Id, JLOC_Status__c, JLOC_Document_ID__c, Pricing_and_Returns_Document_ID__c FROM JLOC__c WHERE Id =:jloc.Id];
            System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_SUBMITTED_TO_SECRETARY, 'Status should be submitted to Secretary');

            try {
                  ProcessInstanceWorkItem workItem = [
                        SELECT      Id, ActorId 
                        FROM        ProcessInstanceWorkItem 
                        WHERE       ProcessInstance.TargetObjectId = :jloc.Id AND ProcessInstance.Status = 'Pending' 
                        LIMIT       1
                  ];

                  User approver = [
                        SELECT      Id, Name 
                        FROM        User 
                        WHERE       Id = :workItem.ActorId
                  ];

                  System.runAs(approver) {
                        stc = new ApexPages.StandardController(jloc);
                        controller = new JLOC_ViewController(stc);
                        controller.reject();
                        jloc = [
                              SELECT      Id, JLOC_Status__c 
                              FROM        JLOC__c 
                              WHERE       Id = :jloc.Id
                        ];

                        System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_DRAFT);
                  }
            } catch(Exception ex) {}

            Test.stopTest();
	}

	public static testMethod void testJlocSentToCommittee() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        
            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            controller.jloc.Status__c = 'New';
            controller.jloc.CLGD_Consumption__c = 'No';
            controller.jloc.Barclays_Commitment__c = 0;
            controller.jloc.Barclays_Underwriting__c = 0;
            controller.jloc.Barclays_Target_Hold__c = 0;
            controller.jloc.Deal_Presented_To_Deal_Forum__c = true;
            controller.jloc.Go_Approval_From_Deal_Forum_Quorum__c = true;
            controller.jloc.Approved_By_Financial_Crime_Compliance__c = true;
            controller.jloc.Conflict_Clearance_Obtained__c = true;
            controller.jloc.Deal_Team_Polices_Confirmation__c = true;

            controller.submitToSecretary();
            jloc = [
                  SELECT      Id, JLOC_Status__c 
                  FROM        JLOC__c 
                  WHERE       Id = :jloc.Id
            ];
            System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_SUBMITTED_TO_SECRETARY);

            PageReference pageRef = controller.sentToCommittee();

            PageReference invitePageRef = Page.JLOC_InviteParticipants;
            invitePageRef.getParameters().put('id', jloc.Id);
            System.assertEquals(invitePageRef.getUrl(), pageRef.getUrl());

            Test.stopTest();
	}

      public static testMethod void testJlocAttendeeVoting() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            jloc.JLOC_Status__c = JLOC_ViewController.STATUS_SENT_TO_COMMITTEE;
            UPDATE jloc;

            //Add Attendee
            INSERT new JLOC_Attendee__c(JLOC__c=jloc.Id,User__c=UserInfo.getUserId(),Group__c='Trade');
        
            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            controller.approve();
            controller.comments = 'Approved';
            controller.jlocAttendeeVote();

            Test.stopTest();

            jloc = [
                  SELECT      Id, JLOC_Status__c 
                  FROM        JLOC__c 
                  WHERE       Id = :jloc.Id
            ];
            System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_APPROVED);
        }

        public static testMethod void testJlocSecretaryVoting() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            jloc.JLOC_Status__c = JLOC_ViewController.STATUS_SENT_TO_COMMITTEE;
            UPDATE jloc;

            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            controller.finalApprove();

            Test.stopTest();

            jloc = [
                  SELECT      Id, JLOC_Status__c 
                  FROM        JLOC__c 
                  WHERE       Id = :jloc.Id
            ];
            System.assertEquals(jloc.JLOC_Status__c, JLOC_ViewController.STATUS_APPROVED);
        }

        public static testMethod void testJlocSharing() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            jloc.JLOC_Status__c = JLOC_ViewController.STATUS_SENT_TO_COMMITTEE;
            UPDATE jloc;

            PageReference sharePageRef = new PageReference('/p/share/CustomObjectSharingDetail');
            sharePageRef.getParameters().put('parentId', jloc.Id);

            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            PageReference pageRef = controller.sharing();

            Test.stopTest();

            System.assertEquals(sharePageRef.getUrl(), pageRef.getUrl());
      }
      
      public static testMethod void testJlocClone() {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

            PageReference CloneJLOCPageRef = new PageReference('/apex/JLOC_CreateNew');
			CloneJLOCPageRef.getParameters().put('CF00N2400000EmGiw_lkid', jloc.Organisation__c);
            CloneJLOCPageRef.getParameters().put('scontrolCaching', '1');
            CloneJLOCPageRef.getParameters().put('retURL', jloc.Id);
            CloneJLOCPageRef.getParameters().put('sfdc.override', '1');
            CloneJLOCPageRef.getParameters().put('JLOCIdToClone', jloc.Id);	
          
            Test.startTest();

            PageReference JLOC_View = Page.JLOC_View;
            Test.setCurrentPage(JLOC_View);

            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_ViewController controller = new JLOC_ViewController(stc);

            PageReference pageRef = controller.cloneJLOC();

            Test.stopTest();

            System.assertEquals(CloneJLOCPageRef.getUrl(), pageRef.getUrl());
      }
    
    
     public static testMethod void TestsendToTeam()
     {
         ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
         ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
         ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
         JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
         
         Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PUBLIC_OPPORTUNITY, dataContainer);
         
         ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
         
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         opp.JLOC__c = jloc.ID;
         update opp;
         OpportunityTeamMember member = new OpportunityTeamMember();
         member.UserId = thisUser.ID;
         member.TeamMemberRole = 'Accountable Banker';
         Member.OpportunityId = opp.ID;
         member.I_confirm_team_member_has_been_cleared__c = true;
         insert Member;
         
         jloc.Opportunity__c  = opp.ID;
         update jloc;
         
         PageReference JLOC_View = Page.JLOC_View;
         Test.setCurrentPage(JLOC_View);
         
         Test.startTest();
         Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
         JLOC_ViewController controller = new JLOC_ViewController(stc); 
         
         controller.generatePdf();
         
         PageReference currentPage  = controller.SendToTeam();
         
        System.assertEquals(currentPage, JLOC_View);
         Test.stopTest();
     }
}