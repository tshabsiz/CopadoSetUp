<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Agent_notified_of_upcoming_Information_Undertaking_7_days_prior_to_Due_Date</fullName>
        <description>Agent notified of upcoming Condition (7 days prior to Due Date)</description>
        <protected>false</protected>
        <recipients>
            <field>Responsible_Person__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Upcoming_Condition_7_Days_Before_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Client_Information_Undertaking_7_days_prior_to_Due_Date</fullName>
        <description>Client - Information Undertaking (7 days prior to Due Date)</description>
        <protected>false</protected>
        <recipients>
            <field>Participant_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Upcoming_Condition_7_Days_Before_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Condition_Due_Email_Alert</fullName>
        <description>Condition Due Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>alison@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/Information_Undertaking_Overdue_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Condition_Precedence_7_Days_before_due_date</fullName>
        <description>Condition Precedence 7 Days before due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Condition_Precedent_7_Days_after_due_date</fullName>
        <description>Condition Precedent 7 Days after due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Condition_Subsequent_7_Days_after_due_date</fullName>
        <description>Condition Subsequent 7 Days after due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Condition_Subsequent_7_Days_before_due_date</fullName>
        <description>Condition Subsequent 7 Days before due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Governance_Check_7_days_after_due_date</fullName>
        <description>Governance Check 7 days after due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Governance_Check_7_days_before_due_date</fullName>
        <description>Governance Check 7 days before due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Information_Undertaking_7_days_after_Due_Date</fullName>
        <description>Information Undertaking 7 days after Due Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Overdue_Financial_Covenants</fullName>
        <description>Overdue Financial Covenants</description>
        <protected>false</protected>
        <recipients>
            <field>Participant_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Overdue_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Upcoming_Financial_Covenants_Notification</fullName>
        <description>Upcoming Financial Covenants Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/Overdue_Financial_Covenants_New</template>
    </alerts>
    <alerts>
        <fullName>overdue_Financial_Covenants_7_days_after_due_date</fullName>
        <description>overdue Financial Covenants 7 days after due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/Financial_Covenants</template>
    </alerts>
    <fieldUpdates>
        <fullName>Breached_Status</fullName>
        <description>The status of a financial covenant condition due is automatically transitioned to breached when the base value and threshold value are not as per the condition</description>
        <field>Status__c</field>
        <literalValue>Breached</literalValue>
        <name>Breached Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Condition_Clause</fullName>
        <field>Clause__c</field>
        <formula>Condition__r.Clause__c</formula>
        <name>Condition Clause</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Fulfilled</fullName>
        <field>Status__c</field>
        <literalValue>Fulfilled</literalValue>
        <name>Field Update Fulfilled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Breached</fullName>
        <field>Status__c</field>
        <literalValue>Breached</literalValue>
        <name>Set Status to Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update_to_Breached</fullName>
        <field>Status__c</field>
        <literalValue>Breached</literalValue>
        <name>Status Update to Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update_to_Fulfilled</fullName>
        <field>Status__c</field>
        <literalValue>Fulfilled</literalValue>
        <name>Status Update to Fulfilled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update_to_Overdue</fullName>
        <field>Status__c</field>
        <literalValue>Overdue</literalValue>
        <name>Status Update to Overdue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Multiples_To_Breach</fullName>
        <field>Status__c</field>
        <literalValue>Breached</literalValue>
        <name>Update Multiples To Breach</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Breach_Percentage</fullName>
        <field>Status__c</field>
        <literalValue>Breached</literalValue>
        <name>Update Status to Breach</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Breached_Ratio</fullName>
        <field>Status__c</field>
        <literalValue>Breached</literalValue>
        <name>Update Status to Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Fulfilled</fullName>
        <field>Status__c</field>
        <literalValue>Fulfilled</literalValue>
        <name>Update Status to Fulfilled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Fulfilled_Percentage</fullName>
        <field>Status__c</field>
        <literalValue>Fulfilled</literalValue>
        <name>Update Status to Fulfilled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Fulfilled_Ratio</fullName>
        <field>Status__c</field>
        <literalValue>Fulfilled</literalValue>
        <name>Update Status to Fulfilled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Overdue_Conditions</fullName>
        <field>Status__c</field>
        <literalValue>Overdue</literalValue>
        <name>Update Status to Overdue on Conditions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Base - Multiple - Breached</fullName>
        <actions>
            <name>Update_Multiples_To_Breach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(NOT(ISBLANK(Actual_Base_Multiple__c )) &amp;&amp; Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;)&amp;&amp;  NOT(Actual_Base_Multiple__c  = Required_Base_Multiple_Num__c ) ,True,   If(NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;) &amp;&amp; NOT(Actual_Base_Multiple__c  &lt;&gt; Required_Base_Multiple_Num__c ) , True,   If(NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;)&amp;&amp; NOT(Actual_Base_Multiple__c  &lt; Required_Base_Multiple_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater than&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Multiple&quot;) &amp;&amp; NOT(Actual_Base_Multiple__c  &gt; Required_Base_Multiple_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Multiple&quot;)&amp;&amp; NOT(Actual_Base_Multiple__c   &lt;= Required_Base_Multiple_Num__c ) , True,  If(NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater or equal&quot; &amp;&amp; ( Threshold_Category_Text__c= &quot;Multiple&quot;)&amp;&amp; NOT(Actual_Base_Multiple__c   &gt;= Required_Base_Multiple_Num__c ) , True, false))))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Multiple - Fulfilled</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(NOT(ISBLANK(Actual_Base_Multiple__c )) &amp;&amp; Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp;  (Threshold_Category_Text__c = &quot;Multiple&quot;) &amp;&amp; (Actual_Base_Multiple__c  = Required_Base_Multiple_Num__c ) ,True,   If(NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;)&amp;&amp;(Actual_Base_Multiple__c  &lt;&gt; Required_Base_Multiple_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;)&amp;&amp; (Actual_Base_Multiple__c  &lt; Required_Base_Multiple_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater than&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Multiple&quot;) &amp;&amp; (Actual_Base_Multiple__c  &gt; Required_Base_Multiple_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;)&amp;&amp; (Actual_Base_Multiple__c   &lt;= Required_Base_Multiple_Num__c ) , True,  If  (NOT(ISBLANK(Actual_Base_Multiple__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater or equal&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Multiple&quot;)&amp;&amp; (Actual_Base_Multiple__c   &gt;= Required_Base_Multiple_Num__c ) , True,False))))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Number - Breached</fullName>
        <actions>
            <name>Status_Update_to_Breached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If (NOT(ISBLANK(Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;)&amp;&amp; NOT(Actual_Base_Number__c = Required_Base_Number__c ) , True, If (NOT(ISBLANK(Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;)&amp;&amp; NOT(Actual_Base_Number__c &lt;&gt; Required_Base_Number__c ) , True, If (NOT(ISBLANK(Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;less than&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;) &amp;&amp;NOT(Actual_Base_Number__c &lt; Required_Base_Number__c ) , True, If (NOT(ISBLANK(Actual_Base_Number__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater than&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;) &amp;&amp; NOT(Actual_Base_Number__c &gt; Required_Base_Number__c ) , True, If (NOT(ISBLANK(Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;) &amp;&amp; NOT(Actual_Base_Number__c &lt;= Required_Base_Number__c ) , True, If (NOT(ISBLANK(Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater or equal&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Number&quot;)&amp;&amp; NOT(Actual_Base_Number__c &gt;= Required_Base_Number__c ) , True, false))))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Number - Fulfilled</fullName>
        <actions>
            <name>Status_Update_to_Fulfilled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(NOT(ISBLANK( Actual_Base_Number__c )) &amp;&amp; Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; (Threshold_Category_Text__c = &quot;Number&quot;) &amp;&amp; ( Actual_Base_Number__c =  Required_Base_Number__c ) ,True, If(NOT(ISBLANK( Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;)&amp;&amp;( Actual_Base_Number__c &lt;&gt;  Required_Base_Number__c ) , True, If (NOT(ISBLANK( Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;)&amp;&amp; ( Actual_Base_Number__c &lt;  Required_Base_Number__c ) , True, If (NOT(ISBLANK( Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater than&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Number&quot;) &amp;&amp; ( Actual_Base_Number__c &gt;  Required_Base_Number__c ) , True, If (NOT(ISBLANK( Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;)&amp;&amp; ( Actual_Base_Number__c &lt;=  Required_Base_Number__c ) , True, If (NOT(ISBLANK( Actual_Base_Number__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater or equal&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Number&quot;)&amp;&amp; ( Actual_Base_Number__c &gt;=  Required_Base_Number__c ) , True,False))))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Percentage - Breached</fullName>
        <actions>
            <name>Update_Status_to_Breach_Percentage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; (  Threshold_Category_Text__c = &quot;Percentage&quot;)&amp;&amp; NOT(Actual_Base_Percentage__c  = Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;)&amp;&amp; NOT(Actual_Base_Percentage__c  &lt;&gt; Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;less than&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;) &amp;&amp;NOT(Actual_Base_Percentage__c  &lt; Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater than&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;) &amp;&amp; NOT(Actual_Base_Percentage__c  &gt; Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;) &amp;&amp; NOT(Actual_Base_Percentage__c   &lt;= Required_Base_Percentage_Num__c ) , True,  If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater or equal&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Percentage&quot;)&amp;&amp; NOT(Actual_Base_Percentage__c   &gt;= Required_Base_Percentage_Num__c ) , True, false))))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Percentage - Fulfilled</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled_Percentage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;)&amp;&amp; (Actual_Base_Percentage__c  = Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp;Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;)&amp;&amp; (Actual_Base_Percentage__c  &lt;&gt; Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;less than&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Percentage&quot;)&amp;&amp; (Actual_Base_Percentage__c  &lt; Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater than&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Percentage&quot;)&amp;&amp; (Actual_Base_Percentage__c  &gt; Required_Base_Percentage_Num__c ) , True,   If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;less or equal&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Percentage&quot;)&amp;&amp; (Actual_Base_Percentage__c   &lt;= Required_Base_Percentage_Num__c ) , True,  If  (NOT(ISBLANK(Actual_Base_Percentage__c ))&amp;&amp; Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater or equal&quot;&amp;&amp; ( Threshold_Category_Text__c = &quot;Percentage&quot;)&amp;&amp; (Actual_Base_Percentage__c   &gt;= Required_Base_Percentage_Num__c ) , True,false))))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Ratio - Breached</fullName>
        <actions>
            <name>Update_Status_to_Breached_Ratio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; ( Threshold_Category_Text__c= &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; NOT(Calculated_Ratio_A__c =  Required_Base_Ratio_Calc__c ) , True,   If (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;not equal to&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0) &amp;&amp; NOT(Calculated_Ratio_A__c &lt;&gt; Required_Base_Ratio_Calc__c), True,    If  (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; NOT(Calculated_Ratio_A__c   &lt; Required_Base_Ratio_Calc__c), True,   If  (Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;greater than&quot; &amp;&amp; ( Threshold_Category_Text__c= &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; NOT(Calculated_Ratio_A__c  &gt; Required_Base_Ratio_Calc__c), True,   If  (Threshold_Type_Text__c = &quot;Base&quot;&amp;&amp;Threshold_Comparator_Text__c = &quot;less or equal&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; NOT(Calculated_Ratio_A__c  &lt;= Required_Base_Ratio_Calc__c ) ,True, false)))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base - Ratio - Fulfilled</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled_Ratio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c =  Required_Base_Ratio_Calc__c ) , True,   If (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;not equal to&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c &lt;&gt; Required_Base_Ratio_Calc__c), True,    If  (Threshold_Type_Text__c = &quot;Base&quot;   &amp;&amp; Threshold_Comparator_Text__c = &quot;less than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c   &lt; Required_Base_Ratio_Calc__c), True,   If  (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c  &gt; Required_Base_Ratio_Calc__c), True,   If  (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot; &amp;&amp; ( Threshold_Category_Text__c= &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c  &lt;= Required_Base_Ratio_Calc__c ) ,True, False )))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Multiple - Breach</fullName>
        <actions>
            <name>Breached_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot; &amp;&amp; Threshold_Category_Text__c= &quot;Multiple&quot; &amp;&amp; NOT(ISBLANK(Actual_Base_Multiple__c)) &amp;&amp; (Actual_Base_Multiple__c  &lt; Required_Base_Range_Multiple_From_Num__c || Actual_Base_Multiple__c &gt;  Required_Base_Range_Multiple_To_Num__c) , True, False )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Multiple - Fulfilled</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot; &amp;&amp; Threshold_Category_Text__c = &quot;Multiple&quot; &amp;&amp; NOT(ISBLANK(Actual_Base_Multiple__c)) &amp;&amp; Actual_Base_Multiple__c  &gt;= Required_Base_Range_Multiple_From_Num__c &amp;&amp; Actual_Base_Multiple__c &lt; Required_Base_Range_Multiple_To_Num__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Number - Breach</fullName>
        <actions>
            <name>Set_Status_to_Breached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot; &amp;&amp; Threshold_Category_Text__c= &quot;Number&quot; &amp;&amp; NOT(ISBLANK(Actual_Base_Number__c)) &amp;&amp; (Actual_Base_Number__c  &lt; Required_Base_Range_Number_From__c || Actual_Base_Number__c &gt;  Required_Base_Range_Number_To__c) , True, False )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Number - Fulfilled</fullName>
        <actions>
            <name>Field_Update_Fulfilled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot; &amp;&amp; Threshold_Category_Text__c = &quot;Number&quot; &amp;&amp; NOT(ISBLANK(Actual_Base_Number__c)) &amp;&amp; Actual_Base_Number__c  &gt;= Required_Base_Range_Number_From__c &amp;&amp; Actual_Base_Number__c &lt; Required_Base_Range_Number_To__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Percentage - Breach</fullName>
        <actions>
            <name>Breached_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot; &amp;&amp; Threshold_Category_Text__c= &quot;Percentage&quot; &amp;&amp; NOT(ISBLANK(Actual_Base_Percentage__c)) &amp;&amp; (Actual_Base_Percentage__c  &lt; Required_Base_Range_Percentage_From_Num__c || Actual_Base_Percentage__c &gt;  Required_Base_Range_Percentage_To_Num__c) , True, False )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Percentage - Fulfilled</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot; &amp;&amp; Threshold_Category_Text__c = &quot;Percentage&quot; &amp;&amp; NOT(ISBLANK(Actual_Base_Percentage__c)) &amp;&amp; Actual_Base_Percentage__c  &gt;= Required_Base_Range_Percentage_From_Num__c &amp;&amp; Actual_Base_Percentage__c &lt; Required_Base_Range_Percentage_To_Num__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Ratio - Breached</fullName>
        <actions>
            <name>Update_Status_to_Breach_Percentage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot;  &amp;&amp; Threshold_Category_Text__c= &quot;Ratio&quot; &amp;&amp; Actual_Base_Range_Ratio_Calc__c &gt; 0 &amp;&amp; Actual_Base_Range_Ratio_Calc__c   &lt; Required_Base_Range_Ratio_Calc__c  || Actual_Base_Range_Ratio_Calc_Two__c  &gt; Required_Base_Range_Ratio_Calc_Two__c ,True,False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Base Range - Ratio - Fulfilment</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled_Ratio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If(Threshold_Type_Text__c = &quot;Base Range&quot;  &amp;&amp; Threshold_Comparator_Text__c = &quot;&quot;&amp;&amp; ( Threshold_Category_Text__c= &quot;Ratio&quot;) &amp;&amp; (Actual_Base_Range_Ratio_Calc__c&gt;0) &amp;&amp;(Actual_Base_Range_Ratio_Calc__c   &gt;= Required_Base_Range_Ratio_Calc__c  ) &amp;&amp; ( Actual_Base_Range_Ratio_Calc_Two__c  &lt;= Required_Base_Range_Ratio_Calc_Two__c  ),True,False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Condition Clause</fullName>
        <actions>
            <name>Condition_Clause</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Mark Conditions Overdue %28AdvoLogix%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Condition_Occurrence__c.Status__c</field>
            <operation>equals</operation>
            <value>In Progress,New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Occurrence__c.Receive_Notifications__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Status should automatically change after due date to &apos;overdue&apos; - only if user hasn&apos;t changed it from new already</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Status_to_Overdue_Conditions</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Notification_for_Conditions_Precedence</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TMG - Overdue %287 Days After%29 - Conditions %28AdvoLogix%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Condition_Occurrence__c.Status__c</field>
            <operation>equals</operation>
            <value>Overdue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Occurrence__c.Receive_Notifications__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>overdue Financial Covenant 7 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Overdue_Financial_Covenants</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>TMG_Agent_I_am_notified_of_overdue_Financial_Covenants_7_days_after_they_became</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TMG - Upcoming %287 Days Before%29 - Conditions %28AdvoLogix%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Condition_Occurrence__c.Status__c</field>
            <operation>equals</operation>
            <value>In Progress,New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Occurrence__c.Receive_Notifications__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Agent - Notified of an upcoming Condition 7 days before it becomes due.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Agent_notified_of_upcoming_Information_Undertaking_7_days_prior_to_Due_Date</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Upcoming_Condition_7_days_before_they_become_due</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TMG- Base - Ratio - Fulfilled</fullName>
        <actions>
            <name>Update_Status_to_Fulfilled_Ratio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>If (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;equals&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c =  Required_Base_Ratio_Calc__c ) , True,   If (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;not equal to&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c &lt;&gt; Required_Base_Ratio_Calc__c), True,    If  (Threshold_Type_Text__c = &quot;Base&quot;   &amp;&amp; Threshold_Comparator_Text__c = &quot;less than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c   &lt; Required_Base_Ratio_Calc__c), True,   If  (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;greater than&quot; &amp;&amp; ( Threshold_Category_Text__c = &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c  &gt; Required_Base_Ratio_Calc__c), True,   If  (Threshold_Type_Text__c = &quot;Base&quot; &amp;&amp; Threshold_Comparator_Text__c = &quot;less or equal&quot; &amp;&amp; ( Threshold_Category_Text__c= &quot;Ratio&quot;) &amp;&amp; (Calculated_Ratio_A__c&gt;0)&amp;&amp; (Calculated_Ratio_A__c  &lt;= Required_Base_Ratio_Calc__c ) ,True, False )))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Agent_notified_of_Financial_Covenant_7_days_prior_to_Due_Date_1</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Agent notified of Financial Covenant (7 days prior to Due Date)</subject>
    </tasks>
    <tasks>
        <fullName>Agent_notified_of_Information_Undertaking_7_days_prior_to_Due_Date</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Agent notified of Information Undertaking (7 days prior to Due Date)</subject>
    </tasks>
    <tasks>
        <fullName>Client_Information_Undertaking_7_days_prior_to_Due_Date</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Client - Information Undertaking (7 days prior to Due Date)</subject>
    </tasks>
    <tasks>
        <fullName>Notification_for_Conditions_Precedence</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Notification for Conditions Precedence</subject>
    </tasks>
    <tasks>
        <fullName>TMG_Agent_I_am_notified_of_overdue_Financial_Covenants_7_days_after_they_became</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>TMG Agent I am notified of overdue Financial Covenants 7 days after they became due</subject>
    </tasks>
    <tasks>
        <fullName>Upcoming_Condition_7_days_before_they_become_due</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Upcoming Condition 7 days before they become due.</subject>
    </tasks>
    <tasks>
        <fullName>Upcoming_Financial_Covenants_Notification</fullName>
        <assignedToType>owner</assignedToType>
        <description>Sent by Automated System Workflow</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Condition_Occurrence__c.Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Upcoming Financial Covenants Notification</subject>
    </tasks>
</Workflow>
