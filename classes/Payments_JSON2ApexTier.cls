/**
* Date:  2017-10-13 - Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  parse the MIDAS Tier response JSON to Apex class structure 
**/

public class Payments_JSON2ApexTier{
    
    public String PO_MSG {get;set;}
    public cls_PO_TIERS PO_TIERS {get;set;}
    public cls_PO_DRTRESH PO_DRTRESH {get;set;}
    public cls_PO_CRTRESH PO_CRTRESH {get;set;}
    
    public class cls_PO_TIERS {
        public String d10TIERTP {get;set;}
        public String d10TIERDR {get;set;}
        public String d10TIERCR {get;set;}
        public Long d10ACNO {get;set;}
        public Long d10CNUM {get;set;}
        public String d10CCY {get;set;}
        public Long d10ACOD {get;set;}
        public Long d10ACSQ {get;set;}
        public String d10BRCA {get;set;}
        public String d10CNAME {get;set;}
        public Decimal d10LDBL {get;set;}
        public String d10LDBLA {get;set;}
    }
    
    public class cls_PO_DRTRESH {
        public String DRT_D01TIERCD {get;set;}
        public String DRT_D01TIERDS {get;set;}
        public Integer DRT_D01TIERBC {get;set;}
        public String DRT_D01TIERDC {get;set;}
        public Decimal DRT_D01TIERT01 {get;set;}
        public Decimal DRT_D01TIERT02 {get;set;}
        public Decimal DRT_D01TIERT03 {get;set;}
        public Decimal DRT_D01TIERT04 {get;set;}
        public Decimal DRT_D01TIERT05 {get;set;}
        public Decimal DRT_D01TIERT06 {get;set;}
        public Decimal DRT_D01TIERT07 {get;set;}
        public Decimal DRT_D01TIERT08 {get;set;}
        public Decimal DRT_D01TIERT09 {get;set;}
        public Decimal DRT_D01TIERT10 {get;set;}
        public Decimal DRT_D01TIERT11 {get;set;}
        public Double DRT_D01TIERR01 {get;set;}
        public Double DRT_D01TIERR02 {get;set;}
        public Double DRT_D01TIERR03 {get;set;}
        public Double DRT_D01TIERR04 {get;set;}
        public Double DRT_D01TIERR05 {get;set;}
        public Double DRT_D01TIERR06 {get;set;}
        public Double DRT_D01TIERR07 {get;set;}
        public Double DRT_D01TIERR08 {get;set;}
        public Double DRT_D01TIERR09 {get;set;}
        public Double DRT_D01TIERR10 {get;set;}
        public Double DRT_D01TIERR11 {get;set;}
        public Decimal DRT_D01DRCTOT {get;set;}
        public Decimal DRT_D01CRCTOT {get;set;}
    }
    
    public class cls_PO_CRTRESH {
        public String CRT_D01TIERCD {get;set;}
        public String CRT_D01TIERDS {get;set;}
        public Integer CRT_D01TIERBC {get;set;}
        public String CRT_D01TIERDC {get;set;}
        public Decimal CRT_D01TIERT01 {get;set;}
        public Decimal CRT_D01TIERT02 {get;set;}
        public Decimal CRT_D01TIERT03 {get;set;}
        public Decimal CRT_D01TIERT04 {get;set;}
        public Decimal CRT_D01TIERT05 {get;set;}
        public Decimal CRT_D01TIERT06 {get;set;}
        public Decimal CRT_D01TIERT07 {get;set;}
        public Decimal CRT_D01TIERT08 {get;set;}
        public Decimal CRT_D01TIERT09 {get;set;}
        public Decimal CRT_D01TIERT10 {get;set;}
        public Decimal CRT_D01TIERT11 {get;set;}
        public Double CRT_D01TIERR01 {get;set;}
        public Double CRT_D01TIERR02 {get;set;}
        public Double CRT_D01TIERR03 {get;set;}
        public Double CRT_D01TIERR04 {get;set;}
        public Double CRT_D01TIERR05 {get;set;}
        public Double CRT_D01TIERR06 {get;set;}
        public Double CRT_D01TIERR07 {get;set;}
        public Double CRT_D01TIERR08 {get;set;}
        public Double CRT_D01TIERR09 {get;set;}
        public Double CRT_D01TIERR10 {get;set;}
        public Double CRT_D01TIERR11 {get;set;}
        public Decimal CRT_D01DRCTOT {get;set;}
        public Decimal CRT_D01CRCTOT {get;set;}
    }
    public static Payments_JSON2ApexTier parse(String json){
        return (Payments_JSON2ApexTier) System.JSON.deserialize(json, Payments_JSON2ApexTier.class);
    }
}