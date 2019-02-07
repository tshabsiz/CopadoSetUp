/**
 * Selects Event records.
 * 
 * @author CloudSmiths (Avril)
 * @since 2019-01-24
 */ 
public class evEventSelector {
    /**
     * Selects Active events that start after a date relative 
     * to today adjusted by an offest. Associated Delegate__c records
     * are also selected.
     * @param dateOffsetInMonths Integer
     * @return Map<Id, Event__c>
     */      
    public static Map<Id, Event__c> selectActiveEventsSince(Integer dateOffsetInMonths) {
        Integer dateOffset = (dateOffsetInMonths == null) ? 12 : dateOffsetInMonths;
        dateOffset = Math.abs(dateOffSet) * -1;
        Date relativeDate = System.today().addMonths(dateOffset);
         return new Map<Id, Event__c> (
             [SELECT Id, 
                    Name,
                    Start_Date__c,
                    Type__c,
                    (SELECT Id,
                            Name,
                            Contact_Full_Name__c
                     FROM Delegates__r)
             FROM Event__c 
             WHERE Active__c = true
             AND Start_Date__c >= :relativeDate
             ORDER BY Start_Date__c DESC, Name] );        
    }

}