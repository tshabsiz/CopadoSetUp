/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Util class for Dates.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_DateUtils 
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class DateUtils {

     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     converts String timestamp to Date
      * @Returns:         null if an error occured, Date otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static Date convertTimestampToDate(String timestamp) {
        if (timestamp == null) {
            return null;
        }

        String timestampString = String.valueOf(timestamp);
        Long timestampLong;
        try {
            timestampLong = Long.valueOf(timestampString);
        } catch (TypeException e) {
            system.debug(e);
            return null;
        }
        return Datetime.newInstance(timestampLong).date();
    }

}