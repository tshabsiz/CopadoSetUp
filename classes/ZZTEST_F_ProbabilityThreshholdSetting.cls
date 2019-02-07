/**
 * @Author			Dino Scarcella
 * @Company:		Barclays Africa
 * @Description:	Helper test class to instantiate custom setting Probability Threshhold Setting.
 * @Date:			15-Aug-2016
 * History:
 * 15-Aug-2016 - Dino Scarcella - US-0775 - class created.
 *-------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_F_ProbabilityThreshholdSetting {

    /**
     * @Author          Dino Scarcella
     * @Company:        Barclays Africa
     * @Description:    Test method which adds a record for custom setting Probability Threshhold Setting.
     *
     * @params:         
     * 					threshhold - The threshhold
     * 
     * History:
     * 15-Aug-2016, Dino Scarcella, US-0775, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static ProbabilityThreshhold__c InstantiateProbabilityThreshholdSetting(Decimal threshhold) {
        ProbabilityThreshhold__c prob_threshhold = new ProbabilityThreshhold__c();
        prob_threshhold.Name = 'DebtFamilyProbability';
        prob_threshhold.Probability__c = threshhold;
        return prob_threshhold;
    }
}