/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class apProcessBuilder {
    global apProcessBuilder() {

    }
    @InvocableMethod(label='Apply an Action Plan' description='Apply the provided Action Plan Template to generate an Action Plan for the source record.')
    global static List<advpm.apProcessBuilder.CreateActionPlanResult> createActionPlan(List<advpm.apProcessBuilder.CreateActionPlanRequest> requests) {
        return null;
    }
global class CreateActionPlanRequest {
    @InvocableVariable(label='Action Plan Template ID' description='Provide Action Plan Template Id value here.' required=true)
    global String actionPlanTemplateId;
    @InvocableVariable(label='Source Record ID' description='Provide source record's Id value for which Action Plan will be executed.' required=true)
    global String recordId;
    global CreateActionPlanRequest() {

    }
}
global class CreateActionPlanResult {
    @InvocableVariable(label='Action Plan Call Result Message' required=false)
    global String resultMsg;
    global CreateActionPlanResult() {

    }
}
}
