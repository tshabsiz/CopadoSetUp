/**
* @author Deloitte
* @date 2015
*
* @description Controller for custom page - Add Opportunity Product
*/
global with sharing class AddProductToOpportunityRemoteController {

    public class BarclaysException extends Exception {}
    
    private ApexPages.StandardController stdCtrl;
    public String oppId {get; set; }
    public String displayNet {get;set;}
    public Integer daysFromCloseDateToEndOfYear {get;set;}
    public Integer monthsFromCloseDateToEndOfYear {get;set;}
    
    public OpportunityLineItem oppLine { get; private set; }
    public List<SelectOption> products2 { get; private set; }
    public List<SelectOption> products3 { get; private set; }
    
    /**
    * @description Custom button 'AddProduct' requires constructor with Standard Controller
    */
    public AddProductToOpportunityRemoteController (ApexPages.StandardController stdController) {
        stdCtrl = stdController;
        
        oppId = ApexPages.currentPage().getParameters().get('id');
        String lineId = ApexPages.currentPage().getParameters().get('lineId');
        
        if (String.isBlank(oppId)) {
            daysFromCloseDateToEndOfYear = 0;
            monthsFromCloseDateToEndOfYear = 0;
            
            throw new BarclaysException('Invalid Opportunity Id');
        }
        
        Opportunity opp = [Select id, Name, Type, CurrencyIsoCode, Pricebook2Id, Pricebook2.Name, CloseDate From Opportunity Where id=:oppId];

        if (String.isEmpty(lineId)) {
            oppLine = new OpportunityLineItem();
            products2 = new List<SelectOption>();
            products3 = new List<SelectOption>();
        } else {
            oppLine = getOppLineItem(lineId);
            
            List<Product_Level_2__c> prd2 = getProductsLevel2(oppLine.Product2Id);
            products2 = new List<SelectOption>();
            if (!prd2.isEmpty()) {
                products2.add(new SelectOption('', '-- Select --'));
                for (Product_Level_2__c p: prd2) {
                    products2.add(new SelectOption(p.Id, p.Name));
                }
            }
            
            List<Product_Level_3__c> prd3 = getProductsLevel3(oppLine.Product_Level_2__c);
            products3 = new List<SelectOption>();
            if (!prd3.isEmpty()) {
                products3.add(new SelectOption('', '-- Select --'));
                for (Product_Level_3__c p: prd3) {
                    products3.add(new SelectOption(p.Id, p.Name));
                }
            }
        }

        displayNet = opp.Type == 'New to Bank' || opp.Type == 'Cross Sell' ? 'hidden' : 'visible';

        Date endOfYear = Date.newInstance(opp.CloseDate.year(), 12, 31);
        daysFromCloseDateToEndOfYear = opp.CloseDate.daysBetween(endOfYear);
        monthsFromCloseDateToEndOfYear = opp.CloseDate.monthsBetween(endOfYear);
    }
    
    private static OpportunityLineItem getOppLineItem(String lineId) {
        return [
        SELECT
            Product2Id,
            Id, Fees__c, Annualised_Income__c, Balance__c, Booking_Centre__c,
            Estimated_Utilisation__c, Existing_Facility_Balance__c,
            Income_this_Year__c, Net_Facility_Balance__c, Margin__c, New_Facility__c,
            New_Facility_Balance__c, ROEC__c, RoRWA__c, Terms_Years__c,
            Product_Level_2__c, Product_Level_3__c, Recurring_Fees_Period__c, Recurring_Fees__c
        FROM OpportunityLineItem WHERE Id =: lineId
    ];
    }
    
    /**
    * @description returns product list
    */
    public List<SelectOption> getProducts() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('','-- Select --'));
       
        for(Product2 prod2 : [SELECT Id, Name FROM Product2 WHERE IsActive=:true ORDER BY Name asc]){
            options.add(new SelectOption(prod2.id, prod2.Name));
        }
        
        return options;
    }

    /**
    * @description return booking centres
    */
    public List<SelectOption> getBookingCentres() {
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Booking_Centre__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('','-- Select --'));
       
        for (Schema.PicklistEntry p: ple) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        
        return options;
    }

    /**
    * @description return Recurring Fees Period
    */
    public List<SelectOption> getRecurringFeesPeriod() {
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Recurring_Fees_Period__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('','-- Select --'));
       
        for (Schema.PicklistEntry p: ple) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        
        return options;
    }

    /**
    * @description returns 2nd level products via Remoting
    */
    @RemoteAction
    global static List<Product_Level_2__c> getProductsLevel2(String product) {
       return [SELECT Id, Name FROM Product_Level_2__c WHERE Active__c = true AND Product__c = :product ORDER BY Name asc];
    }

    /**
    * @description returns 3rd level products via Remoting
    */
    @RemoteAction
    global static List<Product_Level_3__c> getProductsLevel3(String prodLvl2Id) {
        return [SELECT Id, Name FROM Product_Level_3__c WHERE Active__c = true AND Product_Level_2__c = :prodLvl2Id ORDER BY Name asc];
    }
    
    /**
    * @description create product via Remoting
    */
    @RemoteAction
    global static boolean createProduct(
        String lineId, String oppId, String prod1Id, String prod2Id, String prod3Id,
        Double fees, Double annualisedIncome, Double balance,
        String bookingCentre,
        Double estimatedUtil, Double existingFacilityBalance,
        Double incomeThisYear, Double netFacilityBalance,
        Double margin, Double newFacility, Double newFacilityBalance,
        Double roec, Double rorwa, Double termsYears, Double recurringFees, String recurringFeesPeriod
    ) {
        if (String.isEmpty(prod1Id)) {
            throw new BarclaysException(System.Label.errMsg_AddProductToOpportunitySelectProduct);
        }
        
        List<Opportunity> oppList = [SELECT Id, PriceBook2Id, PriceBook2.Name, CurrencyIsoCode FROM Opportunity WHERE Id =: oppId];
        
        Opportunity opp = oppList.isEmpty() ? new Opportunity() : opplist.get(0);
        PriceBookEntry pbe;
        
        try{
            pbe = [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Product2Id = : prod1Id
                    AND Pricebook2Id = : opp.Pricebook2Id
                    AND CurrencyIsoCode =: opp.CurrencyIsoCode LIMIT 1];
        } catch(QueryException ex){
            throw new BarclaysException('There is no price specified for selected product and currency ' + opp.CurrencyIsoCode + ' in ' + opp.Pricebook2.Name+'.');
        }
        
        // Validation for empty values
        if (fees <= 0 || balance <= 0) {
            throw new BarclaysException(System.Label.errMsg_AddProductToOpportunitySelectFeesAndFacility);
        }
        
        OpportunityLineItem i = new OpportunityLineItem();
        
        if (!String.isEmpty(lineId)) {
            i = getOppLineItem(lineId);
        } else {
            i.OpportunityId = oppId;
            i.PriceBookEntryId = pbe.Id;
        }
        
        
        
        if (!String.isEmpty(prod2Id)) {
            i.Product_Level_2__c = prod2Id;
        }
        if (!String.isEmpty(prod3Id)) {
            i.Product_Level_3__c = prod3Id;
        }
        
        i.Fees__c = fees;
        i.Annualised_Income__c = annualisedIncome;
        i.Balance__c = balance;
        i.Booking_Centre__c = bookingCentre;
        i.Estimated_Utilisation__c = estimatedUtil;
        i.Existing_Facility_Balance__c = existingFacilityBalance;
        i.Income_this_Year__c = incomeThisYear;
        i.Net_Facility_Balance__c = netFacilityBalance;
        i.Margin__c = margin;
        i.New_Facility__c = newFacility;
        i.New_Facility_Balance__c = newFacilityBalance;
        i.ROEC__c = roec;
        i.RoRWA__c = rorwa;
        i.Terms_Years__c = termsYears;
        i.Recurring_Fees_Period__c = recurringFeesPeriod;
        i.Recurring_Fees__c = recurringFees;
        
        try {
            upsert i Id;
        } catch (DmlException ex) {
            String out = '';
            
            for (Integer j = 0; j < ex.getNumDml(); j++) {
                out += (String.isEmpty(out) ? '' : '; ') + ex.getDmlMessage(j);
            }
            throw new BarclaysException(String.isEmpty(out) ? ex.getMessage() : out);
        }
        
        return true;
    }
}