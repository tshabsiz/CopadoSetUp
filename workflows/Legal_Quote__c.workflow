<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LEAP_BAGL_Legal_Document_received_as_part_of_quote_request</fullName>
        <description>LEAP - BAGL Legal – Document received as part of quote request</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Document_received_as_part_of_quote_request</template>
    </alerts>
    <alerts>
        <fullName>LEAP_BAGL_Legal_Law_Firm_Quote_Rejection</fullName>
        <description>LEAP - BAGL Legal - Law Firm Quote Rejection</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Law_firm_rejection_notification</template>
    </alerts>
    <alerts>
        <fullName>LEAP_BAGL_Legal_Request_for_Service_Notification</fullName>
        <description>LEAP - BAGL Legal Request for Service Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Request_for_Service</template>
    </alerts>
    <alerts>
        <fullName>LEAP_BAGL_Legal_Supplier_Has_Uploaded_Document_to_invoice_Folder</fullName>
        <description>LEAP - BAGL Legal – Supplier Has Uploaded Document to invoice Folder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Supplier_Has_Uploaded_Document_to_invoice_Folder</template>
    </alerts>
    <alerts>
        <fullName>Send_Quote_Request_to_Law_Firm</fullName>
        <description>Send Quote Request to Law Firm</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Request2_for_Quotation_Law_Firm</template>
    </alerts>
    <fieldUpdates>
        <fullName>Mark_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Mark Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Mark Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Requested</fullName>
        <field>Status__c</field>
        <literalValue>Requested</literalValue>
        <name>Mark Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Marked_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Mark Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Marked_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Mark Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LEAP - BAGL Legal - Law firm rejection</fullName>
        <actions>
            <name>LEAP_BAGL_Legal_Law_Firm_Quote_Rejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legal Quote,Litigation Quote,Off Panel Quote</value>
        </criteriaItems>
        <description>1/12/17 (MS) - Send lawfirm notification to advise them that they have not been selected.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Instruct Law Firm to Commence Work</fullName>
        <actions>
            <name>LEAP_BAGL_Legal_Request_for_Service_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote__c.Request_for_Service__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send a notification with the instruction to commence work to the lawfirm once the quotation has been approved.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notication for Document received as part of quote request</fullName>
        <actions>
            <name>LEAP_BAGL_Legal_Document_received_as_part_of_quote_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote__c.Quote_Recieved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Send Quote Request To Law Firm</fullName>
        <actions>
            <name>Send_Quote_Request_to_Law_Firm</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote_Request__c.Box_Quote_Request_Link__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Supplier Has Uploaded Document to invoice Folder</fullName>
        <actions>
            <name>LEAP_BAGL_Legal_Supplier_Has_Uploaded_Document_to_invoice_Folder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote__c.InvoiceReceived__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
