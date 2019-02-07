/**
* @Author       
* Company:      Deloitte
* @Description: Treeview controller class.
* @Date:        
* @TestClass:   ZZTEST_TreeviewController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 23/02/2016    C Reinecke      Added New Relationship Hierarchy Methods to draw the full hierarchy
*------------------------------------------------------------*/
global class TreeViewController {
    public static Id adminProfileId;

    public TreeViewController(){}

    @RemoteAction
    global static String getBuyingGroupHierarchy(String accountId){
        List<TreeItem> data = new List<TreeItem>();
        CoreItem core = new CoreItem(data);
        Tree tree = new Tree(core, false);

        Account buyingGroup = getBuyingGroup(accountId);
        if(buyingGroup != null){
            Boolean selected = buyingGroup.Id == accountId ? true : false;
            String label = buyingGroup.Name+', '+buyingGroup.Owner.Name;
            TreeItem root = new TreeItem(buyingGroup.Id, label, selected, false);
            data.add(root);

            for(Account a : [SELECT Id, Name, Owner.Name FROM Account WHERE ParentId = :buyingGroup.Id]){
                selected = a.Id == accountId ? true : false;
                label = a.Name+', '+a.Owner.Name;
                TreeItem child = new TreeItem(a.Id, label, selected, false);
                root.children.add(child);
            }

            return JSON.serialize(tree);
            
        } else{
            return null;
        }
    }

    @RemoteAction
    global static String getRelationshipHierarchy(String accountId, Boolean checkboxes){
        try{
            adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        } catch(QueryException ex){
            adminProfileId = null;
        }

        Account ultimateRelationshipParent = getUltimateRelationshipParent(accountId);

        Map<Id, TreeItem> mapRoot = new Map<Id, TreeItem>();
        List<TreeItem> data = new List<TreeItem>();
        CoreItem core = new CoreItem(data);
        Tree tree = new Tree(core, checkboxes);

        Boolean selected = ultimateRelationshipParent.Id == accountId ? true : false;
        Boolean disabled = checkboxes && UserInfo.getProfileId() != adminProfileId && ultimateRelationshipParent.OwnerId != UserInfo.getUserId() ? true : false;
        String label = ultimateRelationshipParent.Name+', '+ultimateRelationshipParent.Owner.Name;
        if (ultimateRelationshipParent.Client_Country__c != null){
                    label += ', '+ultimateRelationshipParent.Client_Country__c;  
        }
        TreeItem root = new TreeItem(ultimateRelationshipParent.Id, label, selected, disabled);
        data.add(root);
        mapRoot.put(ultimateRelationshipParent.Id, root);

        getChildRelationshipRecords(mapRoot, ultimateRelationshipParent.Id, checkboxes, accountId);

        return JSON.serialize(tree);
    }

    public static Account getBuyingGroup(Id accountId){
        Account currentAccount = [SELECT Id, Name, Parent.Name, OwnerId, Owner.Name, ParentId, RecordType.DeveloperName FROM Account WHERE Id = :accountId];
        if(currentAccount.RecordType.DeveloperName == 'Relationship_Group'){
            return currentAccount;
        } else if(String.isNotBlank(currentAccount.ParentId)){
            try{
                Account buyingGroup = [SELECT Id, Name, Parent.Name, OwnerId, Owner.Name FROM Account WHERE Id = :currentAccount.ParentId];
                return buyingGroup;
            } catch(System.QueryException ex){
                return null;
            }
        } else{
            return null;
        }
    }

    @RemoteAction
    global static String getSdsHierarchy(String accountId, Boolean checkboxes) {
        try{
            adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        } catch(QueryException ex){
            adminProfileId = null;
        }

        Account ultimateParent = getUltimateParent(accountId);

        Map<Id, TreeItem> mapRoot = new Map<Id, TreeItem>();
        List<TreeItem> data = new List<TreeItem>();
        CoreItem core = new CoreItem(data);
        Tree tree = new Tree(core, checkboxes);

        Boolean selected = ultimateParent.Id == accountId ? true : false;
        Boolean disabled = checkboxes && UserInfo.getProfileId() != adminProfileId && ultimateParent.OwnerId != UserInfo.getUserId() ? true : false;
        String label = ultimateParent.Name+', '+ultimateParent.Owner.Name;
        if(ultimateParent.ParentId != null){
            label += ', '+ultimateParent.Parent.Name;
        }
        TreeItem root = new TreeItem(ultimateParent.Id, label, selected, disabled);
        data.add(root);
        mapRoot.put(ultimateParent.Id, root);

        getChildrens(mapRoot, accountId, checkboxes);

        return JSON.serialize(tree);
    }

    public static Account getUltimateRelationshipParent(Id accountId){
        Account currentAccount = [SELECT Id, Name, Parent.Name, OwnerId, Owner.Name, ParentId, RecordType.DeveloperName, Client_Country__c FROM Account WHERE Id = :accountId];
        if(currentAccount.ParentId == null || currentAccount.Parent.Name == 'Unknown Parent'){
            return currentAccount; 
        } else{
            return getUltimateRelationshipParent(currentAccount.ParentId);
        }
    }

    public static Account getUltimateParent(Id accountId){
        List<Hierarchy__c> parents = [SELECT Parent__c, Parent__r.Name FROM Hierarchy__c WHERE Hierarchy_Type__c = 'SDS' AND Child__c = :accountId];
        if(parents.isEmpty()){
            return [SELECT Id, Name, Parent.Name, OwnerId, Owner.Name FROM Account WHERE Id = :accountId];
        } else{
            return getUltimateParent(parents[0].Parent__c);
        }
    }

    public static void getChildRelationshipRecords(Map<Id, TreeItem> items, String accountId, Boolean checkboxes, String currentAccount){
        Map<Id, TreeItem> children = new Map<Id, TreeItem>();

            for(Account a : [SELECT Id, Name, Owner.Name, ParentId, Parent.Name, Client_Country__c FROM Account WHERE ParentId IN :items.KeySet()]){
                Boolean selected = a.Id == currentAccount ? true : false;
                Boolean disabled = checkboxes && UserInfo.getProfileId() != adminProfileId && a.OwnerId != UserInfo.getUserId() ? true : false;
                String label = a.Name+', '+a.Owner.Name;
                if (a.Client_Country__c != null){
                    label += ', '+a.Client_Country__c;    
                }
                TreeItem child = new TreeItem(a.Id, label, selected, disabled);
                items.get(a.ParentId).children.add(child);
                children.put(a.Id, child);
            }
            if(!children.isEmpty()){
            getChildRelationshipRecords(children, accountId, checkboxes, currentAccount);
        }        
    }

    public static void getChildrens(Map<Id, TreeItem> items, String accountId, Boolean checkboxes){
        Map<Id, TreeItem> childrens = new Map<Id, TreeItem>();
        for(Hierarchy__c h : [SELECT Child__c, Child__r.Name, Child__r.Parent.Name, Child__r.OwnerId, Child__r.Owner.Name, Parent__c
                                FROM Hierarchy__c WHERE Hierarchy_Type__c = 'SDS' AND Parent__c IN :items.KeySet()]){
            Boolean selected = h.Child__c == accountId ? true : false;
            Boolean disabled = checkboxes && UserInfo.getProfileId() != adminProfileId && h.Child__r.OwnerId != UserInfo.getUserId() ? true : false;
            String label = h.Child__r.Name+', '+h.Child__r.Owner.Name;
            if(h.Child__r.ParentId != null){
                label += ', '+h.Child__r.Parent.Name;
            }
            TreeItem child = new TreeItem(h.Child__c, label, selected, disabled);
            items.get(h.Parent__c).children.add(child);
            childrens.put(h.Child__c, child);
        }
        if(!childrens.isEmpty()){
            getChildrens(childrens, accountId, checkboxes);
        }
    }

    public class Tree {
        CoreItem core; 
        List<String> plugins;
        Checkbox checkbox;
        
        public Tree(CoreItem core, Boolean checkboxes){
            this.core = core;
            this.plugins = new List<String>();
            if(checkboxes){
                this.plugins.add('checkbox');
                this.checkbox = new Checkbox();
            }
            //this.plugins.add('contextmenu');
        }
    }

    public class CoreItem {
        List<TreeItem> data; 
        
        public CoreItem(List<TreeItem> data){
            this.data = data;
        }
    }

    public class TreeItem {
        String id;
        String text; 
        StateItem state; 
        public List<TreeItem> children;
        
        public TreeItem(String id, String text, Boolean selected, Boolean disabled){
            this.id = id;
            this.text = text;
            this.state = new StateItem(selected, disabled);
            this.children = new List<TreeItem>();
        }
    }

    public class StateItem{
        Boolean selected;
        Boolean opened;
        Boolean disabled;

        public StateItem(Boolean selected, Boolean disabled){
            this.selected = selected;
            this.disabled = disabled;
            this.opened = true;
        }
    }

    public class Checkbox{
        Boolean three_state;
        String cascade;

        public Checkbox(){
            three_state = false;
            cascade = 'down';
        }
    }
}