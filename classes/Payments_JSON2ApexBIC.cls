/**
* Date:  2017-10-13 - Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  parse the MIDAS BIC Client response JSON to Apex class structure 
**/

public class Payments_JSON2ApexBIC{
    
    public String PORMSG {get;set;}
    public Integer POACNT{get;set;}
    public cls_DETAILLINE[] DETAILLINE {get;set;}
    
    public class cls_DETAILLINE {
        public String POFNAM {get;set;}
        public String POCNUM {get;set;}
        public String POCURR {get;set;}
        public Integer POACOD {get;set;}
        public Integer POACSQ {get;set;}
        public String PODSPA {get;set;}
        public String POANAM {get;set;}
        public String POPDEC {get;set;}
        public String POAPRF {get;set;}
        public Decimal POFBAL {get;set;}
        public Decimal POCRAT {get;set;}
        public Decimal POLBAL {get;set;}
        public Decimal POCBAL {get;set;}
        public Decimal POZBAL {get;set;}
        public String POAOPN {get;set;}
    }
    public static Payments_JSON2ApexBIC parse(String json){
        return (Payments_JSON2ApexBIC) System.JSON.deserialize(json, Payments_JSON2ApexBIC.class);
    }
}