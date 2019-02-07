/**
* Date   : 2016-12-20
* Author : RN - CloudSmiths
* Desc   : Test class for the ServiceMapping_Trigger and ServiceMapping_Trigger_Methods class
**/
@IsTest(SeeAllData=false)
public class ServiceMapping_Trigger_Test {
    
    public static testMethod void ServiceMappingTest(){
        
        //create test data
        
        CSC_TestDataFactory.testDataSize = 1;
        
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        Test.startTest();
        
            sm.Template_Name_Case_Close__c = 'INVALID_TEMPLATE_NAME';
            
            try{
                update sm;
            }catch(Exception e){
                System.assertEquals('System.DmlException', e.getTypeName());
            }    
    
            sm.Template_Name_Case_Close__c = null;
            sm.Convert_To_RecordType__c = 'INVALID_RECORD_TYPE';
            
            try{
                update sm;
            }catch(Exception e){
                System.assertEquals('System.DmlException', e.getTypeName());
            }    
        
        Test.stopTest();
    }

}