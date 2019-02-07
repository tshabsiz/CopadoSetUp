/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mabhedle Tonga 
*@Description : Rest function that gets all matters
===============================================*/
@RestResource(urlMapping='/all/*')
global class Libra_Restful_Get_All {
    @HttpPost
    global static void getAll()
    {
        try
        {
            List<advpm__Matter__c> matterObjectList = Libra_Restul_Functions.getAll();
            List<Matter> matterWrapperList = new List<Matter>();
            
            if(matterObjectList!=null && matterObjectList.size()>0)
            {
                for(advpm__Matter__c matter : matterObjectList)
                {
                    matterWrapperList.add(new Matter(matter.ID,matter.Name,matter.Relationship__r.Name, matter.Master_agreement_type__c,matter.Relationship__r.SDS__c));
                }
                
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(matterWrapperList));
            }
            else
            {
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new List<Matter>()));
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
    
    public class Matter
    {
        public String MatterId{get;set;}
        public String MatterName{get;set;}
        public String RelationshipName{get;set;}
        public string RelationshipSds{get;set;}
         public String MasterAgreementType{get;set;}
        public Matter(String MatterId,String MatterName,String RelationshipName, String MasterAgreementType, String RelationshipSds)
        {
            this.MatterId = MatterId;
            this.MatterName = MatterName;
            this.RelationshipName = RelationshipName;
            this.MasterAgreementType = MasterAgreementType;
            this.RelationshipSds = RelationshipSds;
        }
        
    }

}