public class OpportunityUtility {
    
    public static List<OpportunityLineItem> getOpportunityProduct()
    {
        return [Select ID,Opportunity.Opportunity_Country__c,Opportunity.Name,
                		Opportunity.Owner.Name,Product_Level_2_Name__c,Product_Level_3_Name__c,Opportunity.Probability,
                		Opportunity.StageName,RefinanceAmount__c,Opportunity.CurrencyISOCode,Balance__c,
                		Terms_Years__c,Hold_Size__c,Margin__c,Opportunity.CloseDate,Opportunity.First_Drawdown__c,Opportunity.First_Drawdown_Amount__c
                From OpportunityLineItem
                Where Product_Level_2_Name__c = 'Debt Finance'
               AND (NOT Product_Level_3_Name__c Like '%100%')
               AND Opportunity.Opportunity_Country__c = 'South Africa'];
    }
    
    public class OpportunityWrapper
    {
        public integer termYears{get;set;}
        public string ownerName {get;set;}
        public string opportunityName{get;set;} 
        public string opportunityCountry{get;set;}
        
        public string productLevel3{get;set;}
        public string productLevel2{get;set;}
        public decimal probability{get;set;}
        public decimal margin{get;set;}
        public decimal refinance{get;set;}
        public integer holdSize{get;set;}
        public decimal firstDrawDownAmount{get;set;}
        public date firstDrawDown{get;set;}
        public string currencyISOCode{get;set;}
        public Date closeDate{get;set;}
        public string stage{get;set;}
        public decimal balance{get;set;}
        
        Public OpportunityWrapper(OpportunityLineItem oppLineItem)
        {
            termYears = integer.valueOf(oppLineItem.Terms_Years__c);
            ownerName = oppLineItem.opportunity.Owner.Name;
            opportunityName=oppLineItem.Opportunity.name;
            margin = oppLineItem.Margin__c;
            holdSize = Integer.valueOf(oppLineItem.Hold_Size__c);
            firstDrawDownAmount = oppLineItem.Opportunity.First_Drawdown_Amount__c;
            firstDrawDown = oppLineItem.Opportunity.First_Drawdown__c;
            currencyISOCode = oppLineItem.Opportunity.CurrencyISOCode;
            closeDate=oppLineItem.Opportunity.closeDate;
            balance = oppLineItem.Balance__c;
            opportunityCountry = oppLineItem.Opportunity.Opportunity_Country__c;
            productLevel2 = oppLineItem.Product_Level_2_Name__c; 
            productLevel3 = oppLineItem.Product_Level_3_Name__c;
            stage = oppLineItem.Opportunity.stageName;
            refinance = oppLineItem.RefinanceAmount__c;
            probability = oppLineItem.Opportunity.Probability;
        }
    }
}