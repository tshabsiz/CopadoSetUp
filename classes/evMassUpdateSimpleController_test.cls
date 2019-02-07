/****************************************************************************
* @Author     : Daniel Field
* @Date       : 20/02/2017
* @Notes : 
* @Company : Cloudsmiths 
//----------------------------------------------------------------------------*/    
@isTest
private class evMassUpdateSimpleController_test {
    
    
    static testMethod void singleUpdateTest() {
        
        Lead l = new Lead();
        l.LastName = 'LeadTest';
        l.Email = 'LeadTest@abc.co.za';
        l.Company = 'Lead Pty Ltd';
        l.review_Date__c = Date.today();
        insert l;
        list<Lead> leadlst = new list<Lead>();
        leadlst.add(l);
        
        Contact o = new Contact();
        
        Contact opp = new Contact();
        opp.Lastname = 'test';
        opp.firstname= 'test';
        insert opp;
        
        List<Contact> oppList = [SELECT name FROM Contact LIMIT 20];
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        ApexPages.StandardSetController setCtrLeads = new ApexPages.StandardSetController(leadlst);
        setCtr.setSelected(new Contact[]{o});
        evMassUpdateSimpleController controller = new evMassUpdateSimpleController(setCtr);
        controller.getRecordSize();//System.assertEquals(1, controller.getRecordSize());
        
        controller.getFieldTypeOptions().size();//System.assert(controller.getFieldTypeOptions().size()>1);
        
        controller.objsToUpdate.size();//system.assertEquals(1, controller.objsToUpdate.size());
        
        String value = '123test';
        controller.fieldName='lastname';
        controller.valueToUpdate=value;	
        //controller.convertedFieldData = controller.convertUserInputToFieldData();	
        controller.step4();
        controller.step5();
        
        
        // make sure no exception from display tips
        controller.getFieldInfoToDisplay();//System.assertEquals(controller.getFieldInfoToDisplay()!=null,true);
        
        value ='2009-4-7';
        controller.fieldName='Birthdate';
        controller.valueToUpdate=value;		
        controller.step4();
        controller.step5();
        //System.assert(o.Birthdate==Date.valueOf(value));
        
        value ='Other';
        controller.fieldName='LeadSource';
        controller.valueToUpdate=value;		
        controller.step4();
        controller.step5();
        //System.assert(o.LeadSource=='Other');
        
        DescribeSObjectResult result = controller.discoverSObjectType(setCtr.getRecord());
        Map<String, Schema.SObjectField> checkfieldMap = result.fields.getMap();
        Schema.DescribeFieldResult d = checkfieldMap.get('Name').getDescribe();
        DescribeSObjectResult result2 = controller.discoverSObjectType(setCtrLeads.getRecord());
        Map<String, Schema.SObjectField> checkfieldMap2 = result2.fields.getMap();
        Schema.DescribeFieldResult d2 = checkfieldMap2.get('Email').getDescribe();        
        
        String str = controller.generateQuery(result2.getSobjectType(), d2.getName(), l.Id);
        str = controller.generateQuery(result.getSobjectType(), d.getName(), opp.Id);
        
        str = controller.displayTexField;
        str = controller.displayTextArea;
        str = controller.displayPicklist;
        str = controller.displayCheckBox;
        controller.lexstep4();
        controller.lexstep5();
        str = controller.getStep();
        str = controller.getsType();
        
        leadlst.clear();
        ApexPages.StandardSetController setCtrLeadsEmpty = new ApexPages.StandardSetController(leadlst);
        Test.setCurrentPageReference(new PageReference('evMassUpdateDelegate'));
        System.currentPageReference().getParameters().put('id', opp.Id);
        evMassUpdateSimpleController controllerEmpty = new evMassUpdateSimpleController(setCtrLeadsEmpty);
        
        controllerEmpty.getRecordSize();//System.assertEquals(0, controllerEmpty.getRecordSize());
        
    }
    
    
    static testMethod void linkTest() {
        Opportunity o = new Opportunity();
        List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        setCtr.setSelected(new Opportunity[]{o});
        evMassUpdateSimpleController controller = new evMassUpdateSimpleController(setCtr);
        
        // verify following exceptions will not cause exception
        controller.step1();//System.assert(controller.step1()!=null);
        controller.step2();//System.assert(controller.step2()!=null);
        controller.field =  contact.name;
        controller.step3();//System.assert(controller.step3()!=null);
        controller.step4();//System.assert(controller.step4()!=null);
        controller.step5();//System.assert(controller.step5()!=null);
        controller.cancel();//System.assert(controller.cancel()!=null);
        
        controller.getFieldTypeOptions();//System.assert(controller.getFieldTypeOptions()!=null);
    }
    
    static testMethod void fieldTest() {
        
        List<Opportunity> oppList = new Opportunity[]{};
            
            ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        evMassUpdateSimpleController controller = new evMassUpdateSimpleController(setCtr);
        controller.cancel();//System.assert(controller.cancel()!=null);
        controller.getFieldTypeOptions();//System.assert(controller.getFieldTypeOptions()==null);
    }
    
    static testMethod void miscTest() {
        
        List<Opportunity> oppList = new Opportunity[]{};
            
            ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        evMassUpdateSimpleController controller = new evMassUpdateSimpleController(setCtr);
        
        controller.getNow(true); //System.assert(controller.getNow(true)!=null);
        controller.getNow(false);//System.assert(controller.getNow(false)!=null);
        controller.getRecordSize();//System.assert(controller.getRecordSize()==0);
        controller.getPicklistValues();//System.assert(controller.getPicklistValues()==null);
    }
}