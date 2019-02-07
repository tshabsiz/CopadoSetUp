public class BxdRecordHelper {
    public SObject record {get;set;}
    public String recordId {get;set;}
    public String recordName {get;set;}
    public String recordTypeId {get;set;}
    public String parentRecordId {get;set;}
    
    public BxdRecordHelper(SObject record, String recordId, String recordName, String recordTypeId, String parentRecordId){
        this.record = record;
        this.recordId = recordId;
        this.recordName = recordName;
        this.recordTypeId = recordTypeId;      
        this.parentRecordId = parentRecordId;
    }
}