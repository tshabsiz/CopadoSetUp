/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanOverview Lightning component.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanOverviewControllerMob
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanOverviewControllerMobile {

    private final static String pdfContentType = 'application/pdf';
    
     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of client plan
      * @Params:          String planId - Id of client plan
      * @Returns:         Client_Plan__c
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Client_Plan__c getClientPlan(String planId) {
    
        List<Client_Plan__c> plans = [
            SELECT Sector_Overview__c, Client_Overview__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        
        if (plans.isEmpty()) {
            return null;
        } else {
            return plans[0];
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     editation of client and sector overview richtexts
      * @Params:          String planId - Id of client plan, String value - to set, 
      *                   Boolean isSector - indicating whether client or sector should be set
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editRichtextField(String planId, String value, Boolean isSector) {
      
        List<Client_Plan__c> plans = [
            SELECT Sector_Overview__c, Client_Overview__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];

        if (plans.isEmpty()) {
            return true;
        }

        if (isSector) {
            plans[0].Sector_Overview__c = value;
        } else {
            plans[0].Client_Overview__c = value;
        }

        try {
            update plans[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of client scores
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Client_Score__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Client_Score__c> getClientScores(String planId) {
        
        return [
            SELECT Name, Description__c, Score_Type__c
            FROM Client_Score__c
            WHERE Client_Plan__c = :planId
            ORDER BY CreatedDate ASC
        ];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds score
      * @Params:          String planId - Id of client plan, String name - score name, String description - score description,
      *                   String scoreType - type of score (Strength, Weakness, ...)
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addScore(String planId, String name, String description, String scoreType) {
    
        Client_Score__c score = new Client_Score__c();
        score.Score_Type__c = scoreType;
        score.Name = name;
        score.Description__c = description;
        
        try {
            score.Client_Plan__c = planId;
            insert score;
        } catch (Exception e) {
            System.debug(e);
            return true;
        }
        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     score editation
      * @Params:          String scoreId - Id of score, String name - score name, String description - score description
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editScore(String scoreId, String name, String description) {

        List<Client_Score__c> scores = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
            WHERE Id = :scoreId
        ];
     
        if (scores.isEmpty()) {
            return true;
        }

        scores[0].Name = name;
        scores[0].Description__c = description;
        
        try {
            update scores[0];
        } catch (Exception e) {
            System.debug(e);
            return true;
        }
        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes score
      * @Params:          String scoreId - Id of score
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeScore(String scoreId) {

        List<Client_Score__c> scores = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
            WHERE Id = :scoreId
        ];
     
        if (scores.isEmpty()) {
            return true;
        }

        try {
            delete scores[0];
        } catch (Exception e) {
            System.debug(e);
            return true;
        }
        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of organogram image Id
      * @Params:          String planId - Id of client plan
      * @Returns:         String - Id of image or empty string if no image found
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static String getImageId(String planId) {
        List<Attachment> ats = [
            SELECT Id
            FROM Attachment
            WHERE ParentId = :planId AND ContentType != :pdfContentType
        ];
        
        if (ats.isEmpty()) {
            return '';
        } else {
            return ats[0].Id;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of organogram items
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Organisation_Structure_Item__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Organisation_Structure_Item__c> getOrganogramData(String planId) {
        return [
            SELECT Id, Description__c, Related_To__c
            FROM Organisation_Structure_Item__c
            WHERE Client_Plan__c = :planId
        ];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds organogram item
      * @Params:          String planId - Id of client plan, String department - item value, String relatedTo - realtionship to another item,
      *                   Boolean isBelow - indicates whether added item is below or above related item
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addOrgItem(String planId, String department, String relatedTo, Boolean isBelow) {
    
        if (isBelow == null) {
            return true;
        }
    
        Organisation_Structure_Item__c osi = new Organisation_Structure_Item__c();
        try {
            if (isBelow) {
                osi.Related_To__c = relatedTo == '' ? null : relatedTo;
            }
            osi.Client_Plan__c = planId;
            osi.Description__c = department;
        } catch (StringException e) {
            System.debug(e);
            return true;
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            insert osi;
        } catch (Exception e) {
            System.debug(e);
            return true;
        }
        
        if (!isBelow) {
            List<Organisation_Structure_Item__c> items = [
                SELECT Id, Related_To__c 
                FROM Organisation_Structure_Item__c
                WHERE Id = :relatedTo
            ];
            
            if (items.isEmpty()) {
                Database.rollback(sp);
                return true;
            }
            
            items[0].Related_To__c = osi.Id;
            update items[0];
        }
        return false;
    
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     organogram item editation
      * @Params:          String itemId - Id of item, String department - item value
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editOrgItem(String department, String itemId) {
        
        List<Organisation_Structure_Item__c> items = [
            SELECT Id, Related_To__c, Description__c
            FROM Organisation_Structure_Item__c
            WHERE Id = :itemId
        ];
        
        if (items.isEmpty()) {
            return true;
        }
        
        try {
            items[0].Description__c = department;
            update items[0];
        } catch (Exception e) {
            System.debug(e);
            return true;
        }
        
        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes organogram item
      * @Params:          String itemIds - Ids of items to delete
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeOrgItem(List<String> itemIds) {
    
        if (itemIds == null) {
            return true;
        }
    
        List<Organisation_Structure_Item__c> items = [
            SELECT Id
            FROM Organisation_Structure_Item__c
            WHERE Id IN :itemIds
        ];
        
        if (items.isEmpty()) {
            return true;
        }
        
        try {
            delete items;
        } catch (Exception e) {
            System.debug(e);
            return true;
        }
        
        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     deleted organogram image
      * @Params:          String imageId - Id of image to delete
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static void deleteImage(String imageId) {

        List<Attachment> ats = [
            SELECT Id
            FROM Attachment
            WHERE Id = :imageId  AND ContentType != :pdfContentType
        ];

        delete ats;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     organogram image upload, crossroad of saving file or appending to existing one
      * @Params:          String planId - Id of client plan, String fileName - name of file, String base64Data - image data,
      *                   String contentType - image content type, Boolean append - indicated whether to create file or append
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean saveImageChunk(String planId, String fileName, String base64Data, String contentType, 
            Boolean append) {
            
        if (planId == null || fileName == null || base64Data == null || contentType == null || append == null) {
            return true;
        }

        if (append) {
            return appendToFile(base64Data, planId);
        } else {
            return saveTheFile(planId, fileName, base64Data, contentType);
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves organogram image
      * @Params:          String planId - Id of client plan, String fileName - name of file, String base64Data - image data,
      *                   String contentType - image content type
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static Boolean saveTheFile(String planId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        try {
            a.parentId = planId;
            insert a;
        } catch (Exception e) {
            System.debug(e);
            return true;
        }

        return false;
    }
    
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     appends data to organogram image
      * @Params:          String planId - Id of client plan, String base64Data - image data
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static Boolean appendToFile(String base64Data, String planId) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        List<Attachment> atts = [
            SELECT Id, Body
            FROM Attachment
            WHERE ParentId = :planId AND ContentType != :pdfContentType
        ];
        
        if (atts.isEmpty()) {
            return true;
        }
        Attachment a = atts[0];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        try {
            update a;
        } catch (Exception e) {
            System.debug(e);
            return true;
        }

        return false;
    }
    
}