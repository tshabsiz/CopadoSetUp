/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist 
 * 
 * */
@Istest
Public class Matter_SpendDocument_Helper_test{
 public static DateTime todaysDate_nextMonth = System.now().addMonths(1);


Public static void Setup1(){
                Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();  
                Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
                Map <String, Schema.RecordTypeInfo> mapLookuoRecordTypes = Lookup__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
                
                Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
                Insert BusinessUnit;
        
          Account   TestLawFirm = new Account
        (
             Name = 'LawFirm1', 
             Type = 'Client',
             Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
             RecordTypeId = mapAccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId()
        );
        insert TestLawFirm; 
        
        
        
                advpm__Matter__c Matter_leg = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Description__c = 'Des',
                Matter_Type__c = 'Complaints',
                Category__c='Action Lines',
                Notes__c = 'Notes',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Legal').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
             );
                Insert Matter_leg;
                
                advpm__Matter__c Matter_lit = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Description__c = 'Des',
                Matter_Type__c = 'Complaints',
                Notes__c = 'Notes',
                Category__c='Action Lines',
                Start_Date__c = date.today(),
                Review_Frequency_days__c ='21',
                RecordTypeId = mapMatterRecordTypes.get('Litigation Matter').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
             );
                Insert Matter_lit;
        
        
      Matter_Spend_Schedule__c  SpendSchedLit1 = new Matter_Spend_Schedule__c
            (
            Total_Spend_Amount__c=1000,
            Vat_Type__c='VAT',
            Matter_Type__c='Litigation',
            Law_Firm__c=TestLawFirm.Id,
            Status__c='Open',
            Litigation_Approver__c=UserInfo.getUserId(),
            Litigation_Approval_Started__c=false
       );    
       Insert SpendSchedLit1; 
      
      Matter_Spend_Schedule__c  SpendSchedLit2 = new Matter_Spend_Schedule__c
            (
            Total_Spend_Amount__c=2050000,
            Vat_Type__c='Non VAT',
            Matter_Type__c='Litigation',
            Law_Firm__c=TestLawFirm.Id,
            Status__c='Open',
            Litigation_Approver__c=UserInfo.getUserId(),
            Litigation_Approval_Started__c=false
       );    
       Insert SpendSchedLit2;
       
       
        Matter_Spend_Schedule__c  SpendSchedLeg1 = new Matter_Spend_Schedule__c
            (
            Total_Spend_Amount__c=1000,
            Vat_Type__c='VAT',
            Matter_Type__c='Litigation',
            Law_Firm__c=TestLawFirm.Id,
            Status__c='Open',
            Litigation_Approver__c=UserInfo.getUserId(),
            Litigation_Approval_Started__c=false
       );    
       Insert SpendSchedLeg1; 
       
       Matter_Spend_Schedule__c  SpendSchedLeg2 = new Matter_Spend_Schedule__c
            (
            Total_Spend_Amount__c=1000,
            Vat_Type__c='Non VAT',
            Matter_Type__c='Litigation',
            Law_Firm__c=TestLawFirm.Id,
            Status__c='Open',
            Litigation_Approver__c=UserInfo.getUserId(),
            Litigation_Approval_Started__c=false
       );    
       Insert SpendSchedLeg2; 
       
       
                
        Matter_Spend_Document__c   SpendLit1 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Matter_Spend_Schedule__c = SpendSchedLit1.id,
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '100',
            BU_Corporate_Code__c = '100',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit1;
        
        Matter_Spend_Document__c   SpendLit2 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Matter_Spend_Schedule__c = SpendSchedLit2.id,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '101',
            BU_Corporate_Code__c = '101',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit2;
        
        Matter_Spend_Document__c   SpendLit3 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
        
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '102',
            BU_Corporate_Code__c = '102',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit3;
        
        Matter_Spend_Document__c   SpendLit4 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '103',
            BU_Corporate_Code__c = '103',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit4;
        
        Matter_Spend_Document__c   SpendLeg1 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '123',
            Matter_Spend_Schedule__c = SpendSchedLeg1.id,
            BU_Corporate_Code__c = '123',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg1;
        
        Matter_Spend_Document__c   SpendLeg2 = new Matter_Spend_Document__c( 
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Total_Amount_Non_VATable__c = 50,
            Matter_Spend_Schedule__c = SpendSchedLeg2.id,
            GL_Account__c = '124',
            BU_Corporate_Code__c = '124',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg2;
        
        
        Matter_Spend_Document__c   SpendLeg3 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '125',
   
            BU_Corporate_Code__c = '125',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg3;
        
        Matter_Spend_Document__c   SpendLeg4 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '126',
            BU_Corporate_Code__c = '126',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg4;
        
         
        Lookup__c look1 = new Lookup__c(RecordTypeId = mapLookuoRecordTypes.get('Litigation User Approval Levels').getRecordTypeId(),User__c=UserInfo.getUserId(),Less_than__c=1800000 , Greater_than__c=0 ,Approval_Group__c='One');
        Insert look1;
        Lookup__c look2 = new Lookup__c(RecordTypeId = mapLookuoRecordTypes.get('Litigation User Approval Levels').getRecordTypeId(),User__c=UserInfo.getUserId(),Less_than__c=5000000 , Greater_than__c=1800000 ,Approval_Group__c='Two');
        Insert look2;
        Lookup__c look3 = new Lookup__c(RecordTypeId = mapLookuoRecordTypes.get('Litigation User Approval Levels').getRecordTypeId(),User__c=UserInfo.getUserId(),Less_than__c=5000000 , Greater_than__c=50000000 ,Approval_Group__c='Three');
        Insert look3;      
            
}

Public static void Setup2(){
                Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();  
                Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
                Map <String, Schema.RecordTypeInfo> mapLookuoRecordTypes = Lookup__c.sObjectType.getDescribe().getRecordTypeInfosByName();
                
                Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
                Insert BusinessUnit;
        
          Account   TestLawFirm = new Account
        (
             Name = 'LawFirm1', 
             Type = 'Client',
             Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
             RecordTypeId = mapAccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId()
        );
        insert TestLawFirm; 
        
        
        
                advpm__Matter__c Matter_leg = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Description__c = 'Des',
                Matter_Type__c = 'Complaints',
                Category__c='Action Lines',
                Notes__c = 'Notes',
                
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Legal').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
             );
                Insert Matter_leg;
                
                advpm__Matter__c Matter_lit = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Description__c = 'Des',
                Matter_Type__c = 'Complaints',
                Notes__c = 'Notes',
                Category__c='Action Lines',
                Review_Frequency_days__c ='21',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Litigation Matter').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
             );
                Insert Matter_lit;
        
               
        Matter_Spend_Document__c   SpendLit1 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
          
            Total_Amount_Excl_VAT__c = 1750000,
            Total_Amount_Non_VATable__c = 2750000,
            GL_Account__c = '100',
            BU_Corporate_Code__c = '100',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit1;
        
        Matter_Spend_Document__c   SpendLit2 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
        
            Total_Amount_Non_VATable__c = 1750000,
            GL_Account__c = '101',
            BU_Corporate_Code__c = '101',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit2;
        
        Matter_Spend_Document__c   SpendLit3 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
        
            Total_Amount_Excl_VAT__c = 1750000,
            Total_Amount_Non_VATable__c = 2750000,
            GL_Account__c = '102',
            BU_Corporate_Code__c = '102',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit3;
        
        Matter_Spend_Document__c   SpendLit4 = new Matter_Spend_Document__c(
            Matter__c = Matter_lit.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Total_Amount_Non_VATable__c = 2750000,
            GL_Account__c = '103',
            BU_Corporate_Code__c = '103',
            Total_Vat_Amount__c = 12
        );
        insert SpendLit4;
        
        Matter_Spend_Document__c   SpendLeg1 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 100000,
            GL_Account__c = '123',
 
            BU_Corporate_Code__c = '123',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg1;
        
        Matter_Spend_Document__c   SpendLeg2 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Total_Amount_Non_VATable__c = 50,

            GL_Account__c = '124',
            BU_Corporate_Code__c = '124',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg2;
        
        
        Matter_Spend_Document__c   SpendLeg3 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '125',
   
            BU_Corporate_Code__c = '125',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg3;
        
        Matter_Spend_Document__c   SpendLeg4 = new Matter_Spend_Document__c(
            Matter__c = Matter_leg.Id,
            Status__c = 'Pending Approval',
            Law_Firm__c = TestLawFirm.Id,
            Approver__c = UserInfo.getUserId(), 
            Total_Amount_Excl_VAT__c = 0,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '126',
            BU_Corporate_Code__c = '126',
            Total_Vat_Amount__c = 12
        );
        insert SpendLeg4;
        
         
        Lookup__c look1 = new Lookup__c(RecordTypeId = mapLookuoRecordTypes.get('Litigation User Approval Levels').getRecordTypeId(),User__c=UserInfo.getUserId(),Less_than__c=1800000 , Greater_than__c=0 ,Approval_Group__c='One');
        Insert look1;
        Lookup__c look2 = new Lookup__c(RecordTypeId = mapLookuoRecordTypes.get('Litigation User Approval Levels').getRecordTypeId(),User__c=UserInfo.getUserId(),Less_than__c=5000000 , Greater_than__c=1800000 ,Approval_Group__c='Two');
        Insert look2;
        Lookup__c look3 = new Lookup__c(RecordTypeId = mapLookuoRecordTypes.get('Litigation User Approval Levels').getRecordTypeId(),User__c=UserInfo.getUserId(),Less_than__c=5000000 , Greater_than__c=50000000 ,Approval_Group__c='Three');
        Insert look3;      
            
}

public static testmethod void MatterSpendoc1(){


    Test.StartTest();
     Setup1();
       
       /* 
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Litigation Matter').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
       */
         Matter_Spend_Document__c  Lit1  = new Matter_Spend_Document__c();
         Lit1  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '100' ];
         Lit1.Status__c = 'Approved';
         Update Lit1;
         
         Matter_Spend_Document__c  Lit2  = new Matter_Spend_Document__c();
         Lit2   = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '101' ];
         Lit2 .Status__c = 'Approved';
         Update Lit2;
         
         Matter_Spend_Document__c  Lit3  = new Matter_Spend_Document__c();
         Lit3  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '102' ];
         Lit3.Status__c = 'Approved';
         Update Lit3;
         
         Matter_Spend_Document__c  Lit4  = new Matter_Spend_Document__c();
         Lit4   = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '103' ];
         Lit4 .Status__c = 'Approved';
         Update Lit4;
         
         Matter_Spend_Document__c  Leg1  = new Matter_Spend_Document__c();
         Leg1  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '123' ];
         Leg1.Status__c = 'Approved';
         Update Leg1;
          
         Matter_Spend_Document__c  Leg2  = new Matter_Spend_Document__c();
         Leg2  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '124' ];
         Leg2.Status__c = 'Approved';
         Update Leg2;
          
         Matter_Spend_Document__c  Leg3  = new Matter_Spend_Document__c();
         Leg3  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '125' ];
         Leg3.Status__c = 'Approved';
         Update Leg1;
          
         Matter_Spend_Document__c  Leg4  = new Matter_Spend_Document__c();
         Leg4  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '126' ];
         Leg4.Status__c = 'Approved';
         Update Leg4;
          
    Test.StopTest();


}
public static testmethod void MatterSpendoc2(){


    Test.StartTest();
     Setup2();
       
       /* 
        advpm__Matter__c Matter_l = new  advpm__Matter__c();
        Matter_l.recordTypeid = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Litigation Matter').getRecordTypeId();
        ApexPages.StandardController sc = new ApexPages.standardController(Matter_l);
        KnowledgeHandlerV2 TestClass = new KnowledgeHandlerV2(sc);
       */
         Matter_Spend_Document__c  Lit1  = new Matter_Spend_Document__c();
         Lit1  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '100' ];
         Lit1.Status__c = 'Approved';
         Update Lit1;
         
         Matter_Spend_Document__c  Lit2  = new Matter_Spend_Document__c();
         Lit2   = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '101' ];
         Lit2 .Status__c = 'Approved';
         Update Lit2;
         
         Matter_Spend_Document__c  Lit3  = new Matter_Spend_Document__c();
         Lit3  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '102' ];
         Lit3.Status__c = 'Approved';
         Update Lit3;
         
         Matter_Spend_Document__c  Lit4  = new Matter_Spend_Document__c();
         Lit4   = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '103' ];
         Lit4 .Status__c = 'Approved';
         Update Lit4;
         
         Matter_Spend_Document__c  Leg1  = new Matter_Spend_Document__c();
         Leg1  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '123' ];
         Leg1.Status__c = 'Approved';
         Update Leg1;
          
         Matter_Spend_Document__c  Leg2  = new Matter_Spend_Document__c();
         Leg2  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '124' ];
         Leg2.Status__c = 'Approved';
         Update Leg2;
          
         Matter_Spend_Document__c  Leg3  = new Matter_Spend_Document__c();
         Leg3  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '125' ];
         Leg3.Status__c = 'Approved';
         Update Leg1;
          
         Matter_Spend_Document__c  Leg4  = new Matter_Spend_Document__c();
         Leg4  = [Select Status__c From  Matter_Spend_Document__c Where GL_Account__c = '126' ];
         Leg4.Status__c = 'Approved';
         Update Leg4;
          
    Test.StopTest();


}
}