<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Product_Partner</fullName>
        <description>Alert Product Partner</description>
        <protected>false</protected>
        <recipients>
            <recipient>gerald.katsenga@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peter.chiwandamira@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sifisosiphiwo.shongwe@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/opportunity</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_ProductLevel2_On_OPP</fullName>
        <description>Populates level 2 product names in one field on Opportunity</description>
        <field>ProductLevel2List__c</field>
        <formula>IF(
	ISNULL(Product_Level_2__c),
	Opportunity.ProductLevel2List__c,
	IF(
		LEN(Opportunity.ProductLevel2List__c) = 0,
		Product_Level_2__r.Name,
		IF(CONTAINS(Opportunity.ProductLevel2List__c, (Product_Level_2__r.Name)),
			Opportunity.ProductLevel2List__c, 
			Opportunity.ProductLevel2List__c &amp; &quot; &quot; &amp; (Product_Level_2__r.Name)
		)
	)
)</formula>
        <name>Populate_ProductLevel2_On_OPP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_ProductLevel3_On_OPP</fullName>
        <description>Populates level 3 product names in one field on Opportunity</description>
        <field>ProductLevel3List__c</field>
        <formula>IF(
	ISNULL(Product_Level_3__c),
	Opportunity.ProductLevel3List__c,
	IF(
		LEN(Opportunity.ProductLevel3List__c) = 0,
		Product_Level_3__r.Name,
		IF(CONTAINS(Opportunity.ProductLevel3List__c, (Product_Level_3__r.Name)),
			Opportunity.ProductLevel3List__c, 
			Opportunity.ProductLevel3List__c &amp; &quot; &quot; &amp; (Product_Level_3__r.Name)
		)
	)
)</formula>
        <name>Populate_ProductLevel3_On_OPP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_ProductList_On_OPP</fullName>
        <field>ProductList__c</field>
        <formula>IF(LEN(Opportunity.ProductList__c) = 0, (Product2.Name),
IF(
CONTAINS(Opportunity.ProductList__c, (Product2.Name)),
Opportunity.ProductList__c, Opportunity.ProductList__c &amp; &quot; &quot; &amp; (Product2.Name)))</formula>
        <name>Populate_ProductList_On_OPP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prod_Fam_on_Opp</fullName>
        <field>Product_Family__c</field>
        <formula>IF(NOT(ISBLANK (TEXT(Product2.Family))),
   TEXT(Product2.Family),
   IF(NOT(ISBLANK (TEXT(Product_Level_2__r.Product__r.Family))),
	TEXT(Product_Level_2__r.Product__r.Family),
	IF(NOT(ISBLANK (TEXT(Product_Level_3__r.Product_Level_2__r.Product__r.Family))),
		TEXT(Product_Level_3__r.Product_Level_2__r.Product__r.Family),
		&quot;&quot;
	)
   )
)</formula>
        <name>Update Prod Fam on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Notify Product Owner</fullName>
        <actions>
            <name>Alert_Product_Partner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Product_Name__c</field>
            <operation>equals</operation>
            <value>Cash - Deposits,Cash - Working Capital</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate_ProductList_On_OPP</fullName>
        <actions>
            <name>Populate_ProductList_On_OPP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>populates product list field on OPP with the name of the added product</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Prod Fam on Opp</fullName>
        <actions>
            <name>Update_Prod_Fam_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Product_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
