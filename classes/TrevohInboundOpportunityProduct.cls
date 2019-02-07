@RestResource(urlMapping='/opportunity-product/*')
global class TrevohInboundOpportunityProduct {
    
    @HttpGet
    global static void getOpportunityProduct()
    {
        try
        {
            List<OpportunityUtility.OpportunityWrapper> oppList = new List<OpportunityUtility.OpportunityWrapper>();
            
            for(OpportunityLineItem oppLineItem: OpportunityUtility.getOpportunityProduct())
            {
                oppList.add(new OpportunityUtility.OpportunityWrapper(oppLineItem));
            }
            
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(oppList));            
            
        }
        catch(Exception exc)
        {
            RestContext.response.responseBody = Blob.valueOf('this is it');
        }
    }
}