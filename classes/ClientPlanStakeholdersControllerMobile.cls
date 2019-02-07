/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanStakeholders Lightning component.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   none
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public without sharing class ClientPlanStakeholdersControllerMobile {

    @AuraEnabled
    public static String getStakeholders(String planId) {

        List<ChartItem> items = new List<ChartItem>();

        for (Client_Plan_Relationship__c apr: 
                [SELECT Id, Contact__c, Reports_to__c, Contact__r.Name, Contact__r.Job_Role__c, 
                    Contact__r.Job_Title__c, Comment__c, Client_Strength__c,
                    (
                        SELECT Id, Barclays_Contact_User__r.Name, Strength_of_Relationship__c, Primary_Contact__c 
                        FROM Client_Plan_Relationship_Items__r
                    )
                 FROM Client_Plan_Relationship__c
                 WHERE Client_Plan__c = :planId]) {
                
            ChartItem ci = new ChartItem();
            ci.id = apr.Contact__c;
            ci.aprId = apr.Id;
            ci.parent = apr.Reports_to__c;
            ci.title = apr.Contact__r.Name;
            ci.jobRole = getString(apr.Contact__r.Job_Role__c);
            ci.jobTitle = getString(apr.Contact__r.Job_Title__c);
            ci.clientStrength = String.isNotBlank(apr.Client_Strength__c) ? apr.Client_Strength__c : '1';
            ci.comment = getString(apr.Comment__c);
            ci.barclaysContacts = new List<BarclaysContact>();

            for(Client_Plan_Relationship_Item__c cpri : apr.Client_Plan_Relationship_Items__r){
                BarclaysContact bc = new BarclaysContact();
                bc.id = cpri.Id;
                bc.name = String.isNotBlank(cpri.Barclays_Contact_User__c) ? cpri.Barclays_Contact_User__r.Name : '';
                bc.clientStrength = getString(cpri.Strength_of_Relationship__c);
                bc.primary = cpri.Primary_Contact__c;
                ci.barclaysContacts.add(bc);
            }
            items.add(ci);
        }
        return JSON.serialize(items);
    }

    private static String getString(String s){
        if(String.isBlank(s)) {
            return '';
        } else {
            return s;
        }
    }

    private class ChartItem {
        String id;
        String aprId;
        String parent;
        String title;
        String jobRole;
        String jobTitle;
        String clientStrength;
        String comment;
        List<BarclaysContact> barclaysContacts;
    }

    private class BarclaysContact {
        String id;
        String name;
        String clientStrength;
        Boolean primary;
    }

}