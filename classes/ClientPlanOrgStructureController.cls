/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanOrgStructure VF component.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanOrgStructureController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 26.1.2016   Marek Cech         added content type condition to queries
*------------------------------------------------------------*/
public class ClientPlanOrgStructureController {
  public Client_Plan__c plan { get; set; }
  public Account relationship { get; set; }
  
  private List<Client_Plan_Borrowers_Guarantors__c> borrowersGuarantors;
  public  List<Client_Plan_Borrowers_Guarantors__c> borrowers { get; set; }
  public  List<Client_Plan_Borrowers_Guarantors__c> guarantors { get; set; }

  public String borrowerGuarantorId { get; set; }
  public String borrowerGuarantorType { get; set; }
  public String borrowerGuarantorValue { get; set; }

  public Transient Blob imageBody {get; set;}
  public String imageName {get;set;}
  public String imageContentType {get;set;}
  
  @testVisible
  private String errorMessage;

  private final static String pdfContentType = 'application/pdf';
  
  public ClientPlanOrgStructureController() {
    String planIdParam = ApexPages.currentPage().getParameters().get('planId');
    if(String.isEmpty(planIdParam)) {
      planIdParam = ApexPages.currentPage().getParameters().get('id');
    }
    if(!String.isEmpty(planIdParam)) {
      queryClientPlan(planIdParam);

      this.queryBorrowersGuarantors();
    }
  }

  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     prepares JSON with data for diagram
    * @Params:          Id of client plan
    * @Returns:         String - JSON with data
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  @RemoteAction
  public static String getData(String planId) {
      List<ChartItem> items = new List<ChartItem>();
      
      for (Organisation_Structure_Item__c osi: 
              [SELECT Id, Description__c, Related_To__c
               FROM Organisation_Structure_Item__c
               WHERE Client_Plan__c = :planId]) {
      
          ChartItem ci = new ChartItem();
          ci.id = osi.Id;
          ci.parent = osi.Related_To__c;
          ci.description = osi.Description__c;
          items.add(ci);
      }
      
      if (items.isEmpty()) {
          return '';
      } else {
          return JSON.serialize(items);
      }
  }

  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     adds organisation item
    * @Params:          Id of client plan, Id of parent item, Boolean indication if item is below or not, item description
    * @Returns:         Boolean - false if an error occured, true otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  @RemoteAction
  public static Boolean addOrgItem(String planId, String parentId, Boolean isBelow, String description) {
  
      Organisation_Structure_Item__c osi = new Organisation_Structure_Item__c();
      try {
          if (isBelow) {
              osi.Related_To__c = parentId == '' ? null : parentId;
          }
          osi.Client_Plan__c = planId;
          osi.Description__c = description;
      } catch (StringException e) {
          System.debug(e);
          return false;
      }
      
      Savepoint sp = Database.setSavepoint();
      try {
          insert osi;
      } catch (Exception e) {
          System.debug(e);
          return false;
      }
  
      if (!isBelow) {
          List<Organisation_Structure_Item__c> items = [
              SELECT Id, Related_To__c 
              FROM Organisation_Structure_Item__c
              WHERE Id = :parentId
          ];
          
          if (items.isEmpty()) {
              Database.rollback(sp);
              return false;
          }
          
          try {
              items[0].Related_To__c = osi.Id;
              update items[0];
          } catch (Exception e) {
              System.debug(e);
              Database.rollback(sp);
              return false;
          }
      }
      return true;
  }
  
  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     editation of structure item
    * @Params:          Id of parent item, item description
    * @Returns:         Boolean - false if an error occured, true otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  @RemoteAction
  public static Boolean editStructureItem(String itemId, String description) {
      List<Organisation_Structure_Item__c> osis = [
          SELECT Id, Description__c
          FROM Organisation_Structure_Item__c
          WHERE Id = :itemId
      ];
      
      if (osis.isEmpty()) {
          return false;
      }
      
      osis[0].Description__c = description;
      
      try {
          update osis;
      } catch (Exception e) {
          System.debug(e);
          return false;
      }
      return true;
  }
  
  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     deletion of structure items
    * @Params:          list of item ids
    * @Returns:         Boolean - false if an error occured, true otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  @RemoteAction
  public static Boolean removeStructureItem(List<Id> itemIds) {
      List<Organisation_Structure_Item__c> items = [
          SELECT Id
          FROM Organisation_Structure_Item__c
          WHERE Id IN :itemIds
      ];
  
      try {
          delete items;
      } catch (DmlException e) {
          System.debug(e);
          return false;
      }
      return true;
  }
  
  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     uploads org structure image to attachments
    * @Returns:         PageReference - null
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 26.1.2016   Marek Cech         added content type condition
    *------------------------------------------------------------*/
  public PageReference uploadImage() {
      //First get rid of the old one
      this.deleteImage();
      
      //Store the new one
      Attachment image = new Attachment();
      image.ParentId = plan.Id;
      image.IsPrivate = false;
      image.Name = imageName;
      image.ContentType = imageContentType;
      image.Body = imageBody;
      
      Id imageId = null;
      try {
          INSERT image;
          imageId = image.Id;
      } catch (DMLException e) {
          System.debug(e);
      }

      if(imageId != null) {
        this.plan.Org_Structure_Image_ID__c = imageId;
        try {
          UPDATE plan;
        } catch (DMLException e) {
          System.debug(e);
        }
      }

      return null;
  }
  
  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     deletes org structure image
    * @Returns:         PageReference - null
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 26.1.2016   Marek Cech         added content type condition
    *------------------------------------------------------------*/
  public PageReference deleteImage() {
      //remove existing one if it exists
      if(this.plan.Org_Structure_Image_ID__c != null) {
        List<Attachment> attachments = [
          SELECT  Id
          FROM    Attachment
          WHERE   ParentId = :plan.Id AND Id = :plan.Org_Structure_Image_ID__c
        ];
      
        DELETE attachments;
      }

      plan.Org_Structure_Image_ID__c = null;
      try {
         UPDATE plan;
      } catch (DMLException e) {
         System.debug(e);
      }

      return null;
  }
  
  /**
    * @Author:          Marek Cech
    * @Company:         Deloitte
    * @Description:     queries client plan
    * @Params:          Id of client plan
    * @Returns:         void
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  private void queryClientPlan(String planId) {
    List<Client_Plan__c> plans = [
      SELECT  Id, Org_Structure_Image_ID__c, Relationship__c
      FROM    Client_Plan__c 
      WHERE   Id = :planId
    ];
          
    if(!plans.isEmpty()) {
      plan = plans[0];

      relationship = [
        SELECT  Id, Name 
        FROM    Account 
        WHERE   Id = :plan.Relationship__c
      ];
    } else {
      plan = null;
      relationship = null;
    }
  }

  private void queryBorrowersGuarantors() {
    borrowersGuarantors = new List<Client_Plan_Borrowers_Guarantors__c>();
    borrowers = new List<Client_Plan_Borrowers_Guarantors__c>();
    guarantors = new List<Client_Plan_Borrowers_Guarantors__c>();

    if(this.relationship != null) {
      borrowersGuarantors = [
        SELECT    Id, Type__c, Value__c
        FROM      Client_Plan_Borrowers_Guarantors__c 
        WHERE     Relationship__c = :this.relationship.Id
        ORDER BY  Value__c
      ];
        
      if(!borrowersGuarantors.isEmpty()) {
        for(Client_Plan_Borrowers_Guarantors__c bgItem : borrowersGuarantors) {
          if(bgItem.Type__c == 'Borrower') {
            borrowers.add(bgItem);
          } else if(bgItem.Type__c == 'Guarantor') {
            guarantors.add(bgItem);
          }
        }
      }
    }
  }

  public PageReference modifyBorrowerGuarantor() {
    Client_Plan_Borrowers_Guarantors__c dmlItem;

    if(!String.isEmpty(borrowerGuarantorId)) {
      for(Client_Plan_Borrowers_Guarantors__c bgItem : this.borrowersGuarantors) {
        if(bgItem.Id == borrowerGuarantorId) {
          //This is an existing record
          dmlItem = bgItem;
          break;
        }
      }
    }

    if(dmlItem == null) {
      //This is a new record
      dmlItem = new Client_Plan_Borrowers_Guarantors__c();
      dmlItem.Relationship__c = this.relationship.Id;
      dmlItem.Type__c = borrowerGuarantorType;
    }

    //Update value
    dmlItem.Value__c = borrowerGuarantorValue;

    try {
      UPSERT dmlItem;
    } catch(Exception e) {
      System.debug(e);
      setErrorMessage('Error when saving.');
    }

    this.queryBorrowersGuarantors();
    return null;
  }

  public PageReference removeBorrowerGuarantor() {
    System.debug('removeBorrowerGuarantor called. Values: ' + borrowerGuarantorId + ', ' + borrowerGuarantorType + ', ' + borrowerGuarantorValue);
    
    if(!String.isEmpty(borrowerGuarantorId)) {
      for(Client_Plan_Borrowers_Guarantors__c bgItem : this.borrowersGuarantors) {
        if(bgItem.Id == borrowerGuarantorId) {
          try {
            DELETE bgItem;

            this.queryBorrowersGuarantors();
          } catch(Exception e) {
            System.debug(e);
            setErrorMessage('Error when saving.');
          }
        }
      }
    }
    
    return null;
  }
  
  //inner class for JSON creation
  private class ChartItem {
      String id;
      String parent;
      String description;
  }

  public void setErrorMessage(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}