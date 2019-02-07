/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for DateUtils class
*                 Tests executed:
*                 1 - testConvertTimestampToDate()
*                   Tests conversion of timestamp to Date
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_DateUtils {
    
    static testMethod void testConvertTimestampToDate() {
    
        //null test
        Date result = DateUtils.convertTimestampToDate(null);
        System.assertEquals(null, result);
        
        //param not number
        result = DateUtils.convertTimestampToDate('asdf');
        System.assertEquals(null, result);
        
        //param not number
        Date expextedDate = Date.newInstance(2016, 1, 1);
        result = DateUtils.convertTimestampToDate('1451606400000');
        System.assertNotEquals(null, result);
        System.assertEquals(true, expextedDate.isSameDay(result));
    }
    
}