/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 08/08/2017 - PG    - Created Class. 
 02/10/2017 - PG    - Changed Transfer Task to be 1 day in the future from 7 days.
 04/10/2017 - PG    - Added handling to prevent save and show a message if the transferee OR transferee are missing a facility limit.
 08/11/2017 - TdB   - Add Facility and Facility Tranche fields based on where you create the Agency Transfer from
 09/11/2017 - TdB   - API Name change. Facility_Limit__c  to Limit__c on Agreements Object
 12/03/2018 - TdB   - Agreement Limit optional (prevent Users from creating Drawdown and Agency with no Agreement Limit) 
 01/08/2018 - TdB	- Remove commeneted code
**/  
public class Agency_Transfer_Override {
	
	/**
    * Variables
    **/
    public Agency_Transfer__c agencyTransfer { get; set; }
    private Agreement__c agreement { get; set; }
    public static Map <String, Schema.RecordTypeInfo> agencyTransfer_RecordTypes = Agency_Transfer__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public String selectedTransferor { get; set; }
    public String selectedTransferee { get; set; }
    public Integer transferAmount { get; set; }
    public List<Agency_Transfer_Detail__c> transferDetails { get; set; }
    public Boolean transferorMissingFacility { get; set; }
    public Boolean transfereeMissingFacility { get; set; }
    private Map<Id, sObject> sObjectParties { get; set; }
    private Facility__c facilityRecord;
    private Facility_Tranche__c facilityTrancheRecord;
    public Boolean facilityRequired { get; set; }
    public Boolean facilityTrancheRequired { get; set; }
    public Decimal lowestLevelLimit;
    public Decimal totalLenderPortionPercentage;
    public Boolean showPageContent { get; set; }
    
    /**
    * Constructor
    **/
	public Agency_Transfer_Override(ApexPages.StandardController stdController) 
	{	
		//Blank var.
		transferDetails = new List<Agency_Transfer_Detail__c>();
		transferAmount = 0;
		transferorMissingFacility = false;
		transfereeMissingFacility = false;
        showPageContent = True;

		 List<String> fields = new List<String>
        {
            //Transfer Detail
            'Facility_Tranche__c',
            'Agreement__c',
            'Transfer_Amount__c',
            'Facility__c' ,
            'Transfer_Fee__c',
                'Facility__r.Agreement__c',
                'Facility_Tranche__r.Agreement__c',
                'Agreement__r.Limit__c'
             
        };

        if(!Test.isRunningTest())
        {
            //Add fields
            stdController.addFields(fields);
        }
        
        
		//Fetch Record. 
		this.agencyTransfer = (Agency_Transfer__c)stdController.getRecord(); 
        
        setLenderPortions();
	}

	public List<SelectOption> getTransferorOptions()
	{
		//Blank var.
		List<SelectOption> options = new List<SelectOption>();

		//Add Default
		options.add(new SelectOption('','-- None --')); 
        
        for(Id key : sObjectParties.keySet())
		{
			//New Option.
            SelectOption option  = new SelectOption(key, String.valueOf(sObjectParties.get(key).get('Name')));
			options.add(option);
		}

		//Default Return.
		return options;
	}

	public List<SelectOption> getTransfereeOptions()
	{
		//Blank var.
		List<SelectOption> options = new List<SelectOption>();

		//Add Default
		options.add(new SelectOption('','-- None --')); 
        
        for(Id key : sObjectParties.keySet())
		{
			if(sObjectParties.get(key).Id != selectedTransferor && !String.isBlank(selectedTransferor))
			{
				//New Option.
				SelectOption option  = new SelectOption(key, String.valueOf(sObjectParties.get(key).get('Name')));
				options.add(option);
			}
		}

		//Default Return.
		return options;
	}

	public Boolean getDisabled()
	{	
		//Check if transferee should be disabled. 
		if(getTransfereeOptions().size() == 0 || String.isBlank(selectedTransferor))
		{
			return true;
		}
		else
		{
			return false;
		}		
	}

	public PageReference actionUpdateTransferDetails() 
	{
		updateTransferDetails();

		//Default return.
		return null;
	}

	public void updateTransferDetails() 
	{
		//Default value.
		transfereeMissingFacility = false;
		transferorMissingFacility = false;
        totalLenderPortionPercentage = 0;

		//Clear details
		transferDetails = new List<Agency_Transfer_Detail__c>();

		//Set transfer amount
		agencyTransfer.Transfer_Amount__c = transferAmount;
        
        if(facilityTrancheRecord != null)
        {
            lowestLevelLimit =  facilityTrancheRecord.Tranche_Limit__c;
        }
        else if (facilityRecord != null)
        {
            lowestLevelLimit =  facilityRecord.Facility_Limit__c;                            
        }
        else
        {
            lowestLevelLimit = agreement.Limit__c;
        }

		//Transferor selected.
		if(!String.isBlank(selectedTransferor))
		{
			sObject sObjectParty = sObjectParties.get(selectedTransferor);
			Agency_Transfer_Detail__c transferor = new Agency_Transfer_Detail__c();
            if(agencyTransfer.Facility_Tranche__c != null)
        	{
                transferor.Tranche_Party__c = (Id)sObjectParty.get('id');
                transferor.Facility_Amount_Original__c = (Decimal)sObjectParty.get('Facility_Amount__c');
                transferor.Facility_Percentage_Original__c = (Decimal)sObjectParty.get('Facility_Percentage__c');
            }
            else if(agencyTransfer.Facility__c != null)
        	{
                transferor.Facility_Party__c = (Id)sObjectParty.get('id');
                transferor.Facility_Amount_Original__c = (Decimal)sObjectParty.get('Facility_Amount__c');
                transferor.Facility_Percentage_Original__c = (Decimal)sObjectParty.get('Facility_Percentage__c');
            }
            else
            {
                transferor.Agreement_Party__c = (Id)sObjectParty.get('id');
                transferor.Facility_Amount_Original__c = (Decimal)sObjectParty.get('Lender_Amount__c');
                transferor.Facility_Percentage_Original__c = (Decimal)sObjectParty.get('Lender_Percentage__c');
            }

			if(transferAmount != null || transferAmount != 0)
			{
                //Facility and Tranche
                if(agencyTransfer.Facility_Tranche__c != null || agencyTransfer.Facility__c != null)
        		{
                    if((Decimal)sObjectParty.get('Facility_Amount__c') != null)
                    {
                        transferor.Facility_Amount_New__c = (Decimal)sObjectParty.get('Facility_Amount__c')-transferAmount;
                        transferor.Facility_Percentage_New__c = (transferor.Facility_Amount_New__c / lowestLevelLimit) * 100; 
                    }
                    else
                    {
                        transferorMissingFacility = true;
                    }
                }
                else
                {
                    if((Decimal)sObjectParty.get('Lender_Amount__c') != null)
                    {
                        transferor.Facility_Amount_New__c = (Decimal)sObjectParty.get('Lender_Amount__c')-transferAmount;
                        transferor.Facility_Percentage_New__c = (transferor.Facility_Amount_New__c / lowestLevelLimit) * 100;
                    }
                    else
                    {
                        transferorMissingFacility = true;
                    }
                }
			}
			System.debug('### transferor : ' + transferor);
            
            totalLenderPortionPercentage = totalLenderPortionPercentage + transferor.Facility_Percentage_New__c;
            
			//Add to list.
			transferDetails.add(transferor);
		}

		//Transferee selected.
		if(!String.isBlank(selectedTransferee))
		{
			sObject sObjectParty = sObjectParties.get(selectedTransferee);
			Agency_Transfer_Detail__c transferee = new Agency_Transfer_Detail__c();
            if(agencyTransfer.Facility_Tranche__c != null)
        	{
                transferee.Tranche_Party__c = (Id)sObjectParty.get('Id');
                transferee.Facility_Amount_Original__c = (Decimal)sObjectParty.get('Facility_Amount__c');
				transferee.Facility_Percentage_Original__c = (Decimal)sObjectParty.get('Facility_Percentage__c');
            }
            else if(agencyTransfer.Facility__c != null)
        	{
                transferee.Facility_Party__c = (Id)sObjectParty.get('Id');
                transferee.Facility_Amount_Original__c = (Decimal)sObjectParty.get('Facility_Amount__c');
				transferee.Facility_Percentage_Original__c = (Decimal)sObjectParty.get('Facility_Percentage__c');
            }
            else
            {
                transferee.Agreement_Party__c = (Id)sObjectParty.get('Id');
                transferee.Facility_Amount_Original__c = (Decimal)sObjectParty.get('Lender_Amount__c');
				transferee.Facility_Percentage_Original__c = (Decimal)sObjectParty.get('Lender_Percentage__c');
            }

			if(transferAmount != null || transferAmount != 0)
			{
                //Facility and Tranche
                if(agencyTransfer.Facility_Tranche__c != null || agencyTransfer.Facility__c != null)
        		{
                    if((Decimal)sObjectParty.get('Facility_Percentage__c') != null)
                    {
                        transferee.Facility_Amount_New__c = (Decimal)sObjectParty.get('Facility_Amount__c') + transferAmount;
                        transferee.Facility_Percentage_New__c = (transferee.Facility_Amount_New__c / lowestLevelLimit) * 100;    
                    }
                    else
                    {
                        transfereeMissingFacility = true;
                    }
                }else
                {
                    if((Decimal)sObjectParty.get('Lender_Percentage__c') != null)
                    {
                        transferee.Facility_Amount_New__c = (Decimal)sObjectParty.get('Lender_Amount__c') + transferAmount;
                     	transferee.Facility_Percentage_New__c = (transferee.Facility_Amount_New__c / lowestLevelLimit) * 100;
                        
                    }
                    else
                    {
                        transfereeMissingFacility = true;
                    }
                }
			}
            
            totalLenderPortionPercentage = totalLenderPortionPercentage + transferee.Facility_Percentage_New__c;

			//Add to list.
			transferDetails.add(transferee);
		}
        
        if(totalLenderPortionPercentage < 100)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Warning,'The lenders portion is less than 100%. Do you want to proceed?'));
            System.debug('totalLenderPortionPercentage : ' + totalLenderPortionPercentage);
        }
	}

	public PageReference actionUpdateTransferee() 
	{
		//Reset Transferee
		selectedTransferee = '';

		updateTransferDetails();

		//Default return.
		return null;
	}

	/**
	* Save Page and Data
	**/
	public PageReference actionSave()
	{
        Decimal transferAmount = 0.00;
        String dynamicTransferQuery = '';
        String dynamicTotalTransferQuery = '';
        List<sObject> sObjectLimitRecord = new List<sObject>();
        List<AggregateResult> dynamicTotalTransfer;
        
              
      if(agencyTransfer.Transfer_Amount__c != null)
        {
            transferAmount = agencyTransfer.Transfer_Amount__c;
        }
        
        //Get Parent (lowest level) limit
        //Create Dynamic query based on Tranche/Facility/Agreement - Only for new Transfer
        if(agencyTransfer.Id == null)
        {
            if(agencyTransfer.Facility_Tranche__c != null)
            {
                dynamicTransferQuery = 'SELECT Id, Tranche_Limit__c FROM Facility_Tranche__c WHERE Id = \'' + agencyTransfer.Facility_Tranche__c + '\' limit 1';
                dynamicTotalTransferQuery = 'SELECT SUM(Transfer_Amount__c) totalAmount, Facility_Tranche__c FROM Agency_Transfer__c WHERE Facility_Tranche__c =  \'' + agencyTransfer.Facility_Tranche__c + '\' GROUP BY Facility_Tranche__c';
            }
            else if(agencyTransfer.Facility__c != null)
            {
                dynamicTransferQuery = 'SELECT Id, Facility_Limit__c FROM Facility__c WHERE Id = \'' + agencyTransfer.Facility__c + '\' limit 1';
                dynamicTotalTransferQuery = 'SELECT SUM(Transfer_Amount__c) totalAmount, Facility__c FROM Agency_Transfer__c WHERE Facility__c =  \'' + agencyTransfer.Facility__c + '\' GROUP BY Facility__c';
            }
            else if(agencyTransfer.Agreement__c != null)
            {
                dynamicTransferQuery = 'SELECT Id,  limit__c FROM Agreement__c WHERE Id = \'' + agencyTransfer.Agreement__c + '\' limit 1';
                dynamicTotalTransferQuery = 'SELECT SUM(Transfer_Amount__c) totalAmount, Agreement__c FROM Agency_Transfer__c WHERE Agreement__c =  \'' + agencyTransfer.Agreement__c + '\' GROUP BY Agreement__c';
            }
        }
        else
        {
            //Get all existing drowdowns linked to Tranche/Facility/Agreement
            if(agencyTransfer.Facility_Tranche__c != null)
            {
                dynamicTransferQuery = 'SELECT Id, Tranche_Limit__c FROM Facility_Tranche__c WHERE Id = \'' + agencyTransfer.Facility_Tranche__c + '\' limit 1';
                dynamicTotalTransferQuery = 'SELECT SUM(Transfer_Amount__c) totalAmount, Facility_Tranche__c FROM Agency_Transfer__c WHERE Facility_Tranche__c =  \'' + agencyTransfer.Facility_Tranche__c + '\' AND Id != \'' + agencyTransfer.Id + '\' GROUP BY Facility_Tranche__c';
            }
            else if(agencyTransfer.Facility__c != null)
            {
                 dynamicTransferQuery = 'SELECT Id, Facility_Limit__c FROM Facility__c WHERE Id = \'' + agencyTransfer.Facility__c + '\' limit 1';
                dynamicTotalTransferQuery = 'SELECT SUM(Transfer_Amount__c) totalAmount, Facility__c FROM Agency_Transfer__c WHERE Facility__c =  \'' + agencyTransfer.Facility__c + '\' AND Id != \'' + agencyTransfer.Id + '\' GROUP BY Facility__c';
            }
            else if(agencyTransfer.Agreement__c != null)
            {
                dynamicTransferQuery = 'SELECT Id,  limit__c FROM Agreement__c WHERE Id = \'' + agencyTransfer.Agreement__c + '\' limit 1';
                dynamicTotalTransferQuery = 'SELECT SUM(Transfer_Amount__c) totalAmount, Agreement__c FROM Agency_Transfer__c WHERE Agreement__c =  \'' + agencyTransfer.Agreement__c + '\' AND Id != \'' + agencyTransfer.Id + '\' GROUP BY Agreement__c';
            }
        
        }

        //Query to get limit
        sObjectLimitRecord = Database.query(dynamicTransferQuery);
        
        //Query Aggregate result for Transfer amount on lowest level
        if(dynamicTotalTransferQuery != '')
        {
            dynamicTotalTransfer = database.query(dynamicTotalTransferQuery);
        }
        
        //Display error message if all transfers exceed the lowest level limit
        //Facility Tranche
        if(sObjectLimitRecord.size() > 0 && sObjectLimitRecord.getSObjectType() == Facility_Tranche__c.sObjectType && sObjectLimitRecord[0].get('Tranche_Limit__c') != null)
        {
            if(dynamicTotalTransfer != null && dynamicTotalTransfer.size() > 0)
            {
                if(((Decimal)dynamicTotalTransfer[0].get('totalAmount') + transferAmount)  > (Decimal)sObjectLimitRecord[0].get('Tranche_Limit__c'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Facility Tranche Limit is not exceeded.'));   
                    return null;
                }
            }
            else
            {
                if(transferAmount  > (Decimal)sObjectLimitRecord[0].get('Tranche_Limit__c'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Facility Tranche Limit is not exceeded.'));   
                    return null;
                }
            }
            
        }
        //Facility
        else if(sObjectLimitRecord.size() > 0 && sObjectLimitRecord.getSObjectType() == Facility__c.sObjectType  && sObjectLimitRecord[0].get('Facility_Limit__c') != null)
        {
            if(dynamicTotalTransfer != null && dynamicTotalTransfer.size() > 0)
            {
                if(((Decimal)dynamicTotalTransfer[0].get('totalAmount') + transferAmount)  > (Decimal)sObjectLimitRecord[0].get('Facility_Limit__c'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Facility Limit is not exceeded.'));   
                    return null;
                }
            }
            else
            {
                if(transferAmount  > (Decimal)sObjectLimitRecord[0].get('Facility_Limit__c'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Facility Limit is not exceeded.'));   
                    return null;
                }
            }
        }
        //Agreement
        else if( sObjectLimitRecord.size() > 0 && sObjectLimitRecord.getSObjectType() == Agreement__c.sObjectType && sObjectLimitRecord[0].get('Limit__c') != null)
        {
            if(dynamicTotalTransfer != null && dynamicTotalTransfer.size() > 0)
            {
                if(((Decimal)dynamicTotalTransfer[0].get('totalAmount') + transferAmount)  > (Decimal)sObjectLimitRecord[0].get('Limit__c'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Agreement Limit is not exceeded.'));   
                    return null;
                }
            }
            else
            {
                if(transferAmount  > (Decimal)sObjectLimitRecord[0].get('Limit__c'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Agreement Limit is not exceeded.'));   
                    return null;
                }
            }
        }      

		//Check if we can save?
		if(transferorMissingFacility == true)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure the "transferor" has a facility defined before doing a transfer.');
            ApexPages.addMessage(myMsg);
            return null;
		}

		//Check if we can save?
		if(transfereeMissingFacility == true)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure the "transferee" has a facility defined before doing a transfer.');
            ApexPages.addMessage(myMsg);
            return null;
		}

		//Blank var.
		List<sObject> updateParties = new List<sObject>();

		//Make sure parties were selected.
		if(String.isBlank(selectedTransferee) || String.isBlank(selectedTransferor))
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure both parties (transferor & transferee) have been specified.');
            ApexPages.addMessage(myMsg);
            return null;
		}

		//Make sure the transferor has not exceeded their limit.
		//Facility and Tranche
		if(agencyTransfer.Facility_Tranche__c != null || agencyTransfer.Facility__c != null)
        {
            if(transferAmount > (Decimal)sObjectParties.get(selectedTransferor).get('Facility_Amount__c'))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You may not transfer more than the facility limit for the transferor.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        else
        {
            if(transferAmount > (Decimal)sObjectParties.get(selectedTransferor).get('Lender_Amount__c'))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You may not transfer more than the facility limit for the transferor.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
        }
		

		// Create a savepoint
		Savepoint sp = Database.setSavepoint(); 

		try 
		{
			//Set relationship to agreement parties.
			if(agencyTransfer.Facility_Tranche__c != null)
        	{
                agencyTransfer.Transferor_Tranche__c = sObjectParties.get(selectedTransferor).Id;
				agencyTransfer.Transferee_Tranche__c = sObjectParties.get(selectedTransferee).Id; 
                agencyTransfer.RecordTypeId = agencyTransfer_RecordTypes.get('Tranche Agency Transfer').getRecordTypeId();
            }
            else if(agencyTransfer.Facility__c != null)
        	{
                agencyTransfer.Transferor_Facility__c = sObjectParties.get(selectedTransferor).Id;
				agencyTransfer.Transferee_Facility__c = sObjectParties.get(selectedTransferee).Id; 
                agencyTransfer.RecordTypeId = agencyTransfer_RecordTypes.get('Facility Agency Transfer').getRecordTypeId();
            }
            else
            {
                agencyTransfer.Transferor_Agreement__c = sObjectParties.get(selectedTransferor).Id;
				agencyTransfer.Transferee_Agreement__c = sObjectParties.get(selectedTransferee).Id; 
                agencyTransfer.RecordTypeId = agencyTransfer_RecordTypes.get('Agreement Agency Transfer').getRecordTypeId();
            }
			

			//Insert main record.
            insert agencyTransfer;
            
			//Set the agency transfer in all the detail records.
			for(Agency_Transfer_Detail__c transferDetail : transferDetails)
			{
				transferDetail.Agency_Transfer__c = agencyTransfer.Id;
				
				if(transferDetail.Tranche_Party__c == sObjectParties.get(selectedTransferor).get('Id') || transferDetail.Facility_Party__c == sObjectParties.get(selectedTransferor).get('Id'))
				{

					sObject sObjectParty = sObjectParties.get(selectedTransferor);
					sObjectParty.put('Facility_Amount__c', transferDetail.Facility_Amount_New__c) ;

					//Add to update list.
					updateParties.add(sObjectParty);
				}
                else if(transferDetail.Agreement_Party__c == sObjectParties.get(selectedTransferor).get('Id'))
                {
                    sObject sObjectParty = sObjectParties.get(selectedTransferor);
					sObjectParty.put('Lender_Amount__c', transferDetail.Facility_Amount_New__c) ;

					//Add to update list.
					updateParties.add(sObjectParty);
                }


				if(transferDetail.Tranche_Party__c == sObjectParties.get(selectedTransferee).get('Id') || transferDetail.Facility_Party__c == sObjectParties.get(selectedTransferee).get('Id'))
				{
					sObject sObjectParty = sObjectParties.get(selectedTransferee);
                    sObjectParty.put('Facility_Amount__c', transferDetail.Facility_Amount_New__c) ;

					//Add to update list.
					updateParties.add(sObjectParty);
				}
                else if(transferDetail.Agreement_Party__c == sObjectParties.get(selectedTransferee).get('Id'))
                {
                    sObject sObjectParty = sObjectParties.get(selectedTransferee);
                    sObjectParty.put('Lender_Amount__c', transferDetail.Facility_Amount_New__c) ;

					//Add to update list.
					updateParties.add(sObjectParty);
                }
			}

			//Insert detail records.
			insert transferDetails;

			//Create a task.
			if(agencyTransfer.Transfer_Fee__c == true)
			{
				Task t = new Task();
				t.OwnerId = UserInfo.getUserId();
				t.Subject = 'Transfer Fee Invoice Required.';
				t.Status = 'Open';
				t.Priority = 'Normal';
				t.WhatId = agencyTransfer.Id; 
				t.ActivityDate = Date.today()+1;
				insert t;
			}

			//Update agreement parties.
			update updateParties;

			//New Page Setup
            PageReference standardPage = new PageReference('/'+agencyTransfer.Id);  
            standardPage.setRedirect(true); 
            
            //Redirect.
            return standardPage; 

		}
		catch(Exception e)
		{	
			//Rollback.
			Database.rollback(sp);

			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
		}

		//Default return
		return null;
	}	
    
    public PageReference actionResetLenderParties()
    {
        selectedTransferor = null;
        selectedTransferee = null;
        transferDetails = new List<Agency_Transfer_Detail__c>();
		transferAmount = 0;
		transferorMissingFacility = false;
		transfereeMissingFacility = false;
        transferAmount = 0;
        transferDetails = new List<Agency_Transfer_Detail__c>();
        sObjectParties = null;
        
        setLenderPortions();
		updateTransferDetails();
        
        return null;
    }
    
    public void setLenderPortions()
    {
        //Logic to prompt the User link Transfer to a Facility if Agreement is link to a Facility
		if(agencyTransfer.Facility__c == null && [SELECT Id FROM Facility__c WHERE Agreement__c =: agencyTransfer.Agreement__c].size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is Facilities linked to the Agreement, please select a Facility'));   
            //return null;
            facilityRequired = True;
            facilityTrancheRequired = False;
        }
           
        //Logic to prompt the User link Transfer to a Facility Tranche if Facility is link to a Facility Tranche
        if(agencyTransfer.Facility_Tranche__c == null && agencyTransfer.Facility__c != null && [SELECT Id FROM Facility_Tranche__c WHERE Facility__c =: agencyTransfer.Facility__c].size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is Facilities Tranches linked to the Facility, please select a Facility Tranche'));   
            //return null;
            facilityTrancheRequired = True;
            facilityRequired = True;
        }

		//Create Agency Transfer from Facility Tranches Level
       if(agencyTransfer.Facility_Tranche__c != null)
        {
            facilityTrancheRecord = [SELECT id,  Facility__c, Facility__r.Agreement__c, Tranche_Limit__c
                         FROM  Facility_Tranche__c
                         WHERE id = : agencyTransfer.Facility_Tranche__c
                         LIMIT 1];
            agencyTransfer.Facility__c = facilityTrancheRecord.Facility__c;
            agencyTransfer.Agreement__c = facilityTrancheRecord.Facility__r.Agreement__c;

            //Get Tranche Parties
            sObjectParties = new Map<Id, Tranche_Party__c>([SELECT 
                            Id,
                            Name,
                            Facility_Party__c,
                            Facility_Tranche__c,
                            Party_Type__c,
                            Facility_Amount__c,
                            Facility_Percentage__c
                        FROM Tranche_Party__c
                        WHERE
                            Facility_Tranche__c = :agencyTransfer.Facility_Tranche__c
                            AND Party_Type__c = 'Lender'
                    ]);
             
            System.debug('agencyTransfer.Facility_Tranche__r.Agreement__c :' + agencyTransfer.Facility_Tranche__r.Agreement__c);
            System.debug('agencyTransfer.Agreement__c :' + agencyTransfer.Agreement__c);
            
        }
        
 		//Create Agency Transfer from Facility Level
        else if(agencyTransfer.Facility__c != null)
        {
            facilityRecord = [SELECT id, Agreement__c, facility_limit__c
                         FROM Facility__c
                         WHERE id = : agencyTransfer.Facility__c
                         LIMIT 1];
            
            agencyTransfer.Agreement__c = facilityRecord.Agreement__c;
            
             //Get Facility Parties
            sObjectParties = new Map<Id, Facility_Party__c>([SELECT 
                            Id,
                            Name,
                            Agreement_Party__c,
                            Facility__c,
                            Party_Type__c,
                            Facility_Amount__c,
                            Facility_Percentage__c
                        FROM Facility_Party__c
                        WHERE
                            Facility__c = :agencyTransfer.Facility__c
                            AND Party_Type__c = 'Lender'
                    ]);
           
            
        }
        //Create Agency Transfer from Agreement Level
        else
        {
            //Get Agreement Parties
            sObjectParties = new Map<Id, Agreement_Party__c>([SELECT 
                            Id,
                            Name,
                            Agreement__c,
                            Party_Type__c,
                            Lender_Amount__c,
                            Lender_Percentage__c
                        FROM Agreement_Party__c
                        WHERE
                            Agreement__c = :agencyTransfer.Agreement__c
                            AND Party_Type__c = 'Lender'
                    ]);
 
        }

		//Get some additional agreement parties.
		agreement = [
			SELECT 
				Id,
				Limit__c 
			FROM Agreement__c
			WHERE 
				Id = :agencyTransfer.Agreement__c 
			LIMIT 1 
		];
        
        if(agreement.Limit__c == null || agreement.Limit__c == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not allowed to create a Agency Transfer without specifying a Agreement Limit'));
        	showPageContent = False;
        }
    }

}