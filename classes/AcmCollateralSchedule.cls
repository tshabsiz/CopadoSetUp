global class AcmCollateralSchedule implements System.Schedulable {
    global void execute(SchedulableContext SC) {
        System.scheduleBatch(new AcmBatchJob(), 'Salesforce ACM Collateral Integration', 1, 50);
    }
}