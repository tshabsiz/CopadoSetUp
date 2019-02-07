@RestResource(urlMapping='/market-collateral/*')
global class Libra_Resful_Market_Collateral {

      @HttpPost
    global static void getMarketCollateral()
    {
          String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Market_Collateral__c> marketCollateralList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.MarketCollateralWrapper marketCollateral =(Libra_Restul_Functions.MarketCollateralWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.MarketCollateralWrapper.class);
                
                if(String.isNotBlank(marketCollateral.marketCollateralId))
                {
                    String additionalClause = ' (Agreement__r.Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\') OR Supporting_Agreement__r.Agreement__r.Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                    marketCollateralList = Libra_Restul_Functions.getSObjectById(marketCollateral.marketCollateralId,Libra_Restful_Constants.MarketCollateralColumns,Libra_Restful_Constants.MarketCollateralObject,additionalClause);
                    
                    if(marketCollateralList!=null && marketCollateralList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.MarketCollateral(marketCollateralList[0])));
                    }
                    else
                    {
                        RestContext.response.responseBody = Blob.valueOf(Libra_Restful_Constants.NotFound);
                        RestContext.response.statusCode =Libra_Restful_Constants.statusCodeNotFound;
                    }
                }
            }       
        }
        catch(StringException eex)
        {
            RestContext.response.responseBody = Blob.valueOf(Libra_Restful_Constants.NotFound);
            RestContext.response.statusCode =Libra_Restful_Constants.statusCodeNotFound;
        }catch(QueryException qe)
        {
            RestContext.response.responseBody = Blob.valueOf(qe.getMessage());
            RestContext.response.statusCode =400;
        }
    }
}