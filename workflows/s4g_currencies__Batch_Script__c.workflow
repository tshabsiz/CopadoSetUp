<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>s4g_currencies__Update_Batch_Script_name</fullName>
        <field>Name</field>
        <formula>&quot;update currencys &quot; + Text(Today())</formula>
        <name>Update Batch Script name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
