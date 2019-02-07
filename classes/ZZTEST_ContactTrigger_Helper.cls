/**
* @Author:        Svata Sejkora
* @Company:       Deloitte
* @Description:   Unit Tests for ContactTrigger_Helper
*                   Tests executed:
*                   1 - testCreationOfContactAssociation()
*                       Checks that Contact Association record is created
*                   2 - testCreationOfContactAssociationBulk()
*                       Checks that Contact Association record creation is bulkified
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 13.10.2015    Svata Sejkora   Class created, added first 3 test methods to test ContactTrigger_Helper class
* 23.11.2015    Svata Sejkora   Removed method testing creation of role without existing first name of contact, there is validation rule requiring first name
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public class ZZTEST_ContactTrigger_Helper {
        
        @isTest
        public static void testCreatContactOnRG() {
                
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
                ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;

                Test.startTest();
                         Contact con = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
                Test.stopTest();

                System.assert(con.ID!=null);
        }
}