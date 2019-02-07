/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Day 1 Template
*
*	10-May-2016 - Mohsin Wadee - US-1089 - In getDefaultDay1Template() method assigned an Client On-Boarding instance
*											as there's now a master-detail to Day 1 Template object.
*/
//@isTest
public class ZZTEST_F_Day1Template {
	public enum Day1TemplateRecordType {DEFAULT_DAY1_TEMPLATE}

    private static ZZTEST_F_Day1Template instance;

    private Integer productCounter;

    private ZZTEST_F_Day1Template() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Day1Template getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Day1Template();
        }
        return instance;
    }

    public Day_1_Template__c getProduct(Day1TemplateRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE) {
                return getDefaultDay1Template(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Day_1_Template__c getInsertedProduct(Day1TemplateRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == Day1TemplateRecordType.DEFAULT_DAY1_TEMPLATE) {
                return getInsertedDefaultDay1Template(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Day_1_Template__c getDefaultDay1Template(ZZTEST_DataContainer dataContainer) {
        
        Day_1_Template__c day1Temp = new Day_1_Template__c();
        day1Temp.Are_Soft_Copies_expected__c = 'Yes';
		day1Temp.Eafsc__c = 'ssssss@hulala.com';
		day1Temp.FCC_Approval_for_MSB_Onboarding__c = 'Yes';
		day1Temp.Group_CIF__c = 'This is CIF Group';
		day1Temp.Guarantor_s__c = 'Yes Please';
		day1Temp.Instant_Account_Number__c = false;
		day1Temp.ISC_Code__c = 0;
		day1Temp.ISC_Description__c = '1 - MONETARY AUTHORITY';
		day1Temp.Is_the_client_a_MSB__c = 'Yes';
		day1Temp.Is_the_client_an_Associated_Party__c = 'Yes';
		day1Temp.Is_the_client_a_NBFI__c = 'Yes';
		day1Temp.Itcaib__c = 'Yes';
		day1Temp.Is_the_client_a_SPV__c = 'Yes';
		day1Temp.Legal_Entity__c = 'Co-Operatives (Surety)';
		day1Temp.Legal_Entity_Type__c = 'Sureties';
        day1Temp.Legal_Entity_Code__c = 117;
		day1Temp.MI_Flag__c = 'CIB ABCap';
        day1Temp.MI_Flag_Code__c = 23;
		day1Temp.Nobbt__c = 'Nature Of Business';
		day1Temp.Ppcwbt__c = 'He needs moneyz';
		day1Temp.SIC_Code__c = 0;
		day1Temp.SIC_Description__c = '11110 - GROWING OF CEREALS AND OTHER CROPS N.E.C.';
		day1Temp.Site_Code__c = 87649083;
		day1Temp.Status__c = 'Draft'; //Sent to ESP
		day1Temp.Submit_Group_Structure__c = 'What ever';
		day1Temp.Itcboap__c = 'Underlying Client';
		day1Temp.Will_interest_rates_and_charges_apply__c = 'Yes';
		day1Temp.Wex4cert__c = 'Yes';
        day1Temp.Dosp_code__c = 45;
        day1Temp.Dosp__c = 'huahuahua';
        //day1Temp.BCMS_Client_Id__c = 'fe68c2a9-cb12-4eb7-aa1a-de31ed78ccc' + String.valueOf(productCounter);

        //define XML for testing purposes
        String xml = ''
                + '<BCMSCase xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                + '<EventMessageType>AttestationRequired</EventMessageType>'
                + '<InstructionID>3490</InstructionID>'
                + '<AttestationResponse></AttestationResponse>'
                + '</BCMSCase>'
                ;

        day1Temp.BCMSXMLData__c = xml;
       
    	ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
    	Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
    	Contact con = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        // Create new Client On-Boarding.
        Client_On_Boarding__c clientOnBoarding = new Client_On_Boarding__c();
        clientOnBoarding.Client_Contact__c = con.Id;
        clientOnBoarding.Responsible_Department__c = 'New to Bank';
        clientOnBoarding.Priority__c = 'High';
        clientOnBoarding.Type__c = 'New to bank on-boarding (NTB)';
        clientOnBoarding.Case_Category__c = 'DAY 1 TEMPLATE';
        clientOnBoarding.Subject__c = 'Day 1 Template Test Client On-Boarding';
        clientOnBoarding.Relationship_Name__c = acc.Id;
        insert clientOnBoarding;
        
        day1Temp.Primary_Legal_Entity__c = acc.Id;
        day1Temp.Primary_Legal_Entity__r = acc;
    	day1Temp.Spccn__c = con.Id;
    	day1Temp.Spccn__r = con;
    	day1Temp.Weec__c = con.Id;
    	day1Temp.Weec__r = con;
        day1Temp.Client_On_Boarding__c = clientOnBoarding.Id;
 
        return day1Temp;
    }

    private Day_1_Template__c getInsertedDefaultDay1Template(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Day_1_Template__c.getSObjectType()).isEmpty()) {
            Day_1_Template__c day1Temp = this.getDefaultDay1Template(dataContainer);
            insert day1Temp;
            dataContainer.put(day1Temp);
            return day1Temp;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Day_1_Template__c.getSobjectType(), null).values()) {
                return (Day_1_Template__c) s;
            }
        }
        return null;
    }
}