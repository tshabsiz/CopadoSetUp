public class BxdKnowledgeItem {
    public String id {get;set;}
    public String name {get;set;}
    public String description {get;set;}
    public String url {get;set;}
    public String parent {get;set;}
    public Blob content {get;set;}
    
    public BxdKnowledgeItem(String id, String name, String description, String url, String parent){
        this.id = id;
        this.name = name;
        this.description = description;
        this.url = url;
        this.parent = parent;
    }
    
    public BxdKnowledgeItem(String id, String name, String description, String url, String parent, Blob content){
        this.id = id;
        this.name = name;
        this.description = description;
        this.url = url;
        this.parent = parent;
        this.content = content;
    }
}