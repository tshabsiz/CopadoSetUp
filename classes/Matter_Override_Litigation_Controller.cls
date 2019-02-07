public with sharing class Matter_Override_Litigation_Controller {

	public advpm__Matter__c matterRec {get;set;}
    public Boolean showDuplicates {get;set;}
    public String boxFolderId {get;set;}
    public Boolean showBox {get;set;}
    public List<Duplicate> potentialDuplicates {get;set;}
    
    @TestVisible private List<advpm__Participant__c> participants;
    @TestVisible private List<Business_Unit_Claim__c> claims;

    public Matter_Override_Litigation_Controller() {

        Id litigationId = [SELECT Id FROM RecordType WHERE Name = 'Litigation Matter' AND SobjectType = 'advpm__Matter__c' LIMIT 1][0].Id;
        matterRec = new advpm__Matter__c(OwnerId = UserInfo.getUserId(), RecordTypeId = litigationId);

        if(potentialDuplicates == null)
            potentialDuplicates = new List<Duplicate>();

        participants = new List<advpm__Participant__c>();
        claims = new List<Business_Unit_Claim__c>();
        addClaim();
        
        showDuplicates = false;
        showBox = false;
        
    }

    public PageReference save() {

        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }

        Decimal totalPercentage = 0;
        Boolean hasUnits = false;

        for(Business_Unit_Claim__c claim: claims) {

            if(claim.Business_Unit__c != null) {

                hasUnits = true;

                if(claim.Portion_of_Claim__c != null)
                    totalPercentage += claim.Portion_of_Claim__c;

            }
            
        }

        if(totalPercentage != 100 && hasUnits) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claim apportions must add up to 100%'));
            return null;
        }
                
        saveMatter();
        saveClaims();
        saveParticipants();
        saveRelations();

        return null;

    }

    public PageReference done() {

        save();

        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }

        PageReference retRef = new PageReference('/' + matterRec.Id);
        retRef.setRedirect(true);

        return retRef;

    }

    private void saveMatter() {

        if(matterRec.advpm__Description__c == null) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Matter Summary is mandatory'));
            return;
        }

        if(matterRec.Name == null) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Matter Name is mandatory'));
            return;
        }

        if(matterRec.Id == null)
            insert matterRec;
         else 
            update matterRec;       

    }

    public PageReference createBox() {

        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }

        boxFolderId = BxdMatterDealService.createBoxFolderSync(matterRec.Id);
        showBox = true;
        return null;

    }

    public PageReference cancel() {

        PageReference redirect = new PageReference(ApexPages.currentPage().getParameters().get('retUrl'));        
        
        redirect.setRedirect(true);
        return redirect;

    }

    public List<advpm__Participant__c> getParticipants() {
        return participants;
    }
	
   @TestVisible private void saveParticipants() {

        if(ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<advpm__Participant__c> toSave = new List<advpm__Participant__c>();
        Set<Id> userIds = new Set<Id>();

        for(advpm__Participant__c part: participants) {
            if(part.advpm__Staff__c != null) {

                part.advpm__Matter__c = matterRec.Id;
                userIds.add(part.advpm__Staff__c);
                toSave.add(part);

            }
        }

        Map<Id, User> participantUsersMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]);

        for(advpm__Participant__c part: toSave) {
            if(!participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'All participants must be Litigation users'));
                part.advpm__Staff__c.addError('User is not a Litigation user');
            }
        }

        if(ApexPages.getMessages().isEmpty()) {
            upsert toSave;
            toSave.clear();
        }

    }

    public PageReference addParticipant() {
        participants.add(new advpm__Participant__c());
        return null;
    }

    //Although the List is unordered and the user may have filled in 
    //from the back of the list because s/he is weird, 
    //this is the most reliable method
    public PageReference removeParticipant() {

        participants.remove(participants.size() - 1);
        return null;

    }

    public List<Business_Unit_Claim__c> getClaims() {
        return claims;
    }

    private void saveClaims() {

        if(ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<Business_Unit_Claim__c> toSave = new List<Business_Unit_Claim__c>();        

        for(Business_Unit_Claim__c claim: claims) {
            if(claim.Business_Unit__c != null) {

                claim.Matter__c = matterRec.Id;
                toSave.add(claim);

            }
        }

        if(toSave.size() != 0) {            

            upsert toSave;
            toSave.clear();
                            
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Must have business unit'));
        }

    }

    public PageReference addClaim() {
        claims.add(new Business_Unit_Claim__c());
        return null;
    }

    //Although the List is unordered and the user may have filled in 
    //from the back of the list because s/he is weird, 
    //this is the most reliable method. One claim must remain.
    public PageReference removeClaim() {

        Integer endList = claims.size() - 1;

        if(endList > 0)
            claims.remove(endList);

        return null;

    }

    private void saveRelations() {

        if(potentialDuplicates == null)
            return;

        if(ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<Matter_Relation__c> toInsert = new List<Matter_Relation__c>();

        for(Duplicate dup: potentialDuplicates) 
            if(dup.isRelated)
                toInsert.add(new Matter_Relation__c(Matter1__c = matterRec.Id, Matter2__c = dup.matter.Id, Name = dup.matter.Name));
        
        Database.SaveResult[] results = Database.Insert(toInsert, false);

        //TODO
        //for(Database.SaveResult res: results)
        //    if(!res.isSuccess())
        //        for(Database.Error err: res.getErrors())
        //            if(!err.getMessage().contains('DUPLICATE_VALUE'))
        //                throw err;

    }

    public class Duplicate {

        public advpm__Matter__c matter {get;set;}
        public Boolean isRelated {get;set;}

        public Duplicate(advpm__Matter__c potentialDuplicate) {
            this.matter = potentialDuplicate;
            this.isRelated = false;
        }

    }

    public PageReference searchDupes() {

        if(String.isBlank(matterRec.Name)){

            showDuplicates = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Potential duplicates cannot be determined without a name!'));
        
        }
        else {

            String likeToken = String.format('%{0}%', new List<String>{matterRec.Name});
            List<advpm__Matter__c> queryResult = [SELECT Id, Name, OwnerId, advpm__Description__c, Business_Unit_Cluster_Segment__c FROM advpm__Matter__c WHERE Name LIKE :likeToken];

            for(advpm__Matter__c res: queryResult) 
                potentialDuplicates.add(new Duplicate(res));

            showDuplicates = true;

        }

        return null;
    }

    public PageReference clearFinancial() {

        matterRec.Reasonably_Possible__c = null;
        matterRec.Probable_For_Approval__c = null;
        matterRec.Securitization_value__c = null;

        return null;

    }

    public PageReference claimTypeChange() {

        if(matterRec.Claim_By_Against_Barclays__c == 'Claim By Barclays') {

            matterRec.Probable_Approved__c = matterRec.Probable_For_Approval__c;
            matterRec.Probable_For_Approval__c = null;

        }
        else if(matterRec.Claim_By_Against_Barclays__c == 'Claim Against Barclays') {

            matterRec.Probable_For_Approval__c = matterRec.Probable_Approved__c;
            matterRec.Probable_Approved__c = null;

        } 

        return null;

    }

}