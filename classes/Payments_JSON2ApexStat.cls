/**
* Date:  2017-10-13 - Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  parse the MIDAS Statements response JSON to Apex class structure 
**/
public class Payments_JSON2ApexStat{
    
    public String MACCNO {get;set;}
    public Integer SDATE {get;set;}
    public Decimal OPENBAL{get;set;}
    public Integer CURPAGE {get;set;}
    public Integer TOTPAGE {get;set;}
    public Integer TOTLINE {get;set;}
    public Integer LINECOUNT {get;set;}
    public cls_DETAILLINE[] DETAILLINE {get;set;}
    
    Public class cls_DETAILLINE {
        public Integer STRRN {get;set;}
        public String STSTYPE {get;set;}
        public String STWSEQ {get;set;}
        public Integer STCNUM {get;set;}
        public String STCCY {get;set;}
        public Integer STACOD {get;set;}
        public Integer STACSQ {get;set;}
        public Integer STPDAT {get;set;}
        public Integer STVDAT {get;set;}
        public String STPNAR {get;set;}
        public Decimal STPAMT {
            get{
                Decimal x = STPAMT;
                if(x==0 || x==null){
                    return 0;
                }else{
                    if(STSTYPE=='I'){
                       return x; 
                    }else{
                       return (x * -1);
                    }
                }
            }
            set;
        }
        public Decimal STBAMT {
            get{
                Decimal x = STBAMT;
                if(x==0 || x==null){
                    return 0;
                }else{
                    if(STSTYPE=='I'){
                       return x; 
                    }else{
                       return (x * -1);
                    }
                }
            }
            set;
        }
        public String STSPOS {get;set;}
        public String STATYP {get;set;}
        public String STGETP {get;set;}
        public String STPREF {get;set;}
        public Integer STDLNO {get;set;}
        public String STREF1 {get;set;}
        public String STREF2 {get;set;}
        public String STREF3 {get;set;}
        public String STCNA1 {get;set;}
        public Double STBRAT {get;set;}
        public Decimal STBIBL {get;set;}
        public String STITYP {get;set;}
    }
    
    public static Payments_JSON2ApexStat parse(String json){
        return (Payments_JSON2ApexStat) System.JSON.deserialize(json, Payments_JSON2ApexStat.class);
    }
}