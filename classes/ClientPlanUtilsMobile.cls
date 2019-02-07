/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Util class for mobile version of client plan
* @Date:        03/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanUtilsMobile
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanUtilsMobile {

  /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     converts potential opportunity to opportunity
      * @Params:          String optyId - Id of potential opportunity to convert
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
  public static Boolean convertUnqOpty(String optyId) {

    List<Potential_Opportunity__c> optys = [
      SELECT Id, Client_Plan__r.Relationship__c, Name, Close_Date__c, Product__c, Stage__c, Probability__c, 
        Type__c, Client_Plan_Strategy__c
            FROM Potential_Opportunity__c
            WHERE Id = :optyId
        ];

        if (optys.isEmpty()) {
          return true;
        }

        Potential_Opportunity__c uo = optys[0];

        Boolean isConvertible = checkUnqOptyConvertibility(uo);
        if (!isConvertible) {
            return true;
        }

        Opportunity opp = new Opportunity();
        opp.Name = uo.Name;
        opp.CloseDate = uo.Close_Date__c;
        opp.Type = uo.Type__c;
        opp.StageName = 'Opportunity Identified';
        opp.AccountId = uo.Client_Plan__r.Relationship__c;
        opp.Client_Plan_Strategy__c = uo.Client_Plan_Strategy__c;

        Savepoint sp = Database.setSavepoint();
        try {
            insert opp;
        } catch (DmlException e) {
            System.debug(e);
            return true;
        }

        uo.IsConverted__c = true;
        uo.Opportunity__c = opp.Id;
        try {
            update uo;
        } catch (DmlException e) {
            System.debug(e);
            Database.rollback(sp);
            return true;
        }

        return false;
  }

  /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     tests whether potential opportunity in param can be converted
      * @Params:          Potential_Opportunity__c uo - opportunity to be tested
      * @Returns:         Boolean - true if opty can be converted, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
  @testVisible
    private static Boolean checkUnqOptyConvertibility(Potential_Opportunity__c uo) {
        if (uo.Name == null || uo.Name == '') {
            return false;
        } else if (uo.Close_Date__c == null) {
            return false;
        } else {
            return true;
        }
    }

}