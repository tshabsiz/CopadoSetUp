public class AcmControllerLogic { 
    public static PageReferenceMessage saveToACM(ApexPages.StandardController sController, Collateral__c collateral, boolean saveNewSelected, String errorMessage) {
        PageReferenceMessage pageReferenceMessage = new PageReferenceMessage();
        System.debug('Could Not Save Record to ACM : ' + errorMessage);
        if(collateral.id != null) {
            Collateral_Type__c collateralType = [SELECT Id,Push_to_ACM__c, Credit_Code__c  FROM Collateral_Type__c WHERE Id = :collateral.Collateral_Type1__c];
            if(collateralType.Push_to_ACM__c) {
                System.debug('Pushing to ACM');
                AcmMitigantCRUDService.createOrUpdateMitigants(collateral.Id);
                pageReferenceMessage.message = AcmMitigantCRUDService.MESSAGE;
                pageReferenceMessage.redirectSuccess = redirect(sController, saveNewSelected, collateral);
            } else {
                pageReferenceMessage.message = 'Not Saving to ACM';
                pageReferenceMessage.redirectSuccess = redirect(sController, saveNewSelected, collateral);
            }
        }
        return pageReferenceMessage;
    }
    
    public static String ReadCreateCollateralAcmFacilities(Id clientId) {
        String facilityMessage = '';
        List<FacilityFromAcm> deserialfacilities = new List<FacilityFromAcm>();
        HttpResponse response = null;
        if(clientId != null) {
            List<Account> accounts = [SELECT Id,Name, SDS__c FROM Account WHERE Id = :clientId];
            System.debug('List of accounts : '+ accounts);
            if(accounts.size() > 0) {
                Account account = accounts.get(0);
                System.debug('SDS ID is ' + account.SDS__c);
                if(account.SDS__c != null) {
                    response = AcmMitigantCRUDService.getFacilityFromACM((account.SDS__c).trim());
                    if(response != null) {
                        if(response.getStatusCode() == 200) {
                            System.debug('Returned body : ' + response.getBody());
                            deserialfacilities = (List<FacilityFromAcm>)json.deserialize(response.getBody(), List<FacilityFromAcm>.class);
                            if(deserialfacilities.size() > 0) {
                                System.debug('Objects from facilities API ' + deserialfacilities);
                                List<AcmFacility__c> AcmFacilitiesToCreateOrUpdate = new List<AcmFacility__c>();
                                Integer numberOfActiveFacility = 0;
                                for(FacilityFromAcm facilityFromAcm : deserialfacilities) {
                                    if(facilityFromAcm.FACILITYACTIVE == 'Y') {
                                        numberOfActiveFacility = numberOfActiveFacility + 1;
                                    }
                                    AcmFacility__c acmCollateral = createOrUpdateAcmfacility(facilityFromAcm);
                                    if(acmCollateral != null) {
                                        acmCollateral.Relationship__c = clientId;
                                        AcmFacilitiesToCreateOrUpdate.add(acmCollateral);
                                    }
                                }
                                System.debug('Doing stuff : ' + numberOfActiveFacility );
                                if(numberOfActiveFacility == 0) {
                                    facilityMessage = 'Could Not find Active Facilities Client';
                                }

                                if(AcmFacilitiesToCreateOrUpdate.size() > 0) {
                                    System.debug('creating/updating facilities' + AcmFacilitiesToCreateOrUpdate);
                                    upsert AcmFacilitiesToCreateOrUpdate;
                                }
                            } else {
                                facilityMessage = 'Could Not find Facilities associated with client';
                            }
                            
                        } else {
                            facilityMessage =  'Could not complete request to get Facilities, Status : '+ response.getStatusCode();
                        }
                    }
                } else {
                    facilityMessage = 'Selected Client does not have SDS Id';
                }
            } else {
                facilityMessage = 'Could Not find Facilities associated with client';
            }
        }
        return facilityMessage;
    }
    
    public static AcmFacility__c createOrUpdateAcmfacility(FacilityFromAcm facilityFromAcm) {
        List<AcmFacility__c> acmFacilities = [SELECT Id, Facility_Id__c, MODIFIEDTIMESTAMP__c FROM ACMFacility__c where Name =: facilityFromAcm.FACILITYID];
        if(acmFacilities.size() > 0) {
            AcmFacility__c acmFacility =  acmFacilities.get(0);
            if(acmFacility.MODIFIEDTIMESTAMP__c != ConvertDateTime(facilityFromAcm.MODIFIEDTIMESTAMP)){
                acmFacility.Name = facilityFromAcm.FACILITYID;
                acmFacility.MODIFIEDTIMESTAMP__c = ConvertDateTime(facilityFromAcm.MODIFIEDTIMESTAMP);
                acmFacility.Bank_Application_key__c = facilityFromAcm.BANKAPPLICATIONKEY;
                acmFacility.BANKRISKTAKER__c = facilityFromAcm.BANKRISKTAKER;
                acmFacility.CPTYID__c = facilityFromAcm.CPTYID;
                acmFacility.EXPIRYDATE__c = ConvertDate(facilityFromAcm.EXPIRYDATE);
                acmFacility.FACILITYAMOUNT__c = facilityFromAcm.FACILITYAMOUNT;
                acmFacility.FACILITYCURRENCY__c = facilityFromAcm.FACILITYCURRENCY;
                acmFacility.FACILITYPRODUCTDESCRIPTION__c = facilityFromAcm.FACILITYPRODUCTDESCRIPTION;
                acmFacility.Facility_Id__c = facilityFromAcm.FACILITYID;
                acmFacility.FACILITYPRODUCT__c = facilityFromAcm.FACILITYPRODUCT;
                acmFacility.STARTDATE__c = ConvertDate(facilityFromAcm.STARTDATE);
            }
            return acmFacility;
        } else {
            return createAcmFacility(facilityFromAcm);
        }
    }
    public static Date ConvertDate(String dateStr){
        
        if(!String.isBlank(dateStr)){
            if(dateStr.contains('.')){
                return (ConvertDateTime(dateStr)).date();
            } else{
                Date rDate = null;
                try{
                rDate = Date.valueOf(dateStr);
                }catch(Exception e){
                    System.debug('COULD NOT CONVERT DATE : ' + e.getMessage());
                }
                return rDate;
            }
        } else {
             return null;
        }
    }
    public static DateTime ConvertDateTime(String dateString) {
        if(!String.isblank(dateString)) {
            System.debug('Converting Date : ' + dateString);
            try {
            String DatePart = (dateString.split('\\.'))[0];
            String TimePart = (dateString.split('\\.'))[1];
            Integer year = Integer.valueOf(DatePart.substring(0,4));
            Integer month = Integer.valueOf(DatePart.substring(4,6));
            Integer day = Integer.valueOf(DatePart.substring(6,8));
            Integer hour = Integer.valueOf(TimePart.substring(0,2));
            Integer minute = Integer.valueOf(TimePart.substring(2, 4));
                
            return Datetime.newInstance(year, month, day, hour, minute, 0);
            } catch(Exception e) {
                System.debug('Could not create date : ' + e.getMessage());
                return null;
            }
        }
        return null;
    }
    
    public static AcmFacility__c createAcmFacility(FacilityFromAcm facilityFromAcm){
        System.debug('Starts is : '+facilityFromAcm.STARTDATE);
        System.debug('end is : '+facilityFromAcm.EXPIRYDATE);
        AcmFacility__c acmFacility = new AcmFacility__c(Name = facilityFromAcm.FACILITYID
                                   ,MODIFIEDTIMESTAMP__c = ConvertDateTime(facilityFromAcm.MODIFIEDTIMESTAMP)
                                                       ,Bank_Application_key__c = facilityFromAcm.BANKAPPLICATIONKEY
                                                       ,BANKRISKTAKER__c = facilityFromAcm.BANKRISKTAKER
                                                       ,CPTYID__c = facilityFromAcm.CPTYID
                                                       ,EXPIRYDATE__c = ConvertDate(facilityFromAcm.EXPIRYDATE)
                                                       ,FACILITYAMOUNT__c = facilityFromAcm.FACILITYAMOUNT
                                                       ,FACILITYCURRENCY__c = facilityFromAcm.FACILITYCURRENCY
                                                       ,FACILITYPRODUCTDESCRIPTION__c = facilityFromAcm.FACILITYPRODUCTDESCRIPTION
                                                       ,Facility_Id__c = facilityFromAcm.FACILITYID
                                                       ,FACILITYPRODUCT__c = facilityFromAcm.FACILITYPRODUCT
                                                       ,STARTDATE__c = ConvertDate(facilityFromAcm.STARTDATE));
        
        return acmFacility;
    }

    public static PageReference redirect(ApexPages.StandardController sController, boolean saveNewSelected, Collateral__c collateral) {
        PageReference redirectSuccess = null;
        if(saveNewSelected) {
            Schema.DescribeSObjectResult describeResult = sController.getRecord().getSObjectType().getDescribe();
            PageReference pr = new PageReference('/' + describeResult.getKeyPrefix() + '/e'); 
            pr.setRedirect(true); 
            redirectSuccess = pr;
        } else {
            redirectSuccess = new ApexPages.StandardController(collateral).view();
        }
        return redirectSuccess;
    }
}