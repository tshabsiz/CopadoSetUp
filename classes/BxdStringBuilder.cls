public class BxdStringBuilder {
    final List<String> strs = new List<String>();
    
    public BxdStringBuilder() {
    }
    
    public void append(String str) {
        strs.add(str);
    }
    
    public String build() {
        return String.join(strs, '');
    } 
}