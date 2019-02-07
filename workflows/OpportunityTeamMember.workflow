<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_email_to_Accountable_Banker</fullName>
        <description>Notification email to Accountable Banker</description>
        <protected>false</protected>
        <recipients>
            <field>UserId</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Notification_for_Accountable_Banker</template>
    </alerts>
</Workflow>
