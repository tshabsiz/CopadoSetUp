/**
* Date:  2017-10-13 - Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  parse the MIDAS Deal enquiry response JSON to Apex class structure 
**/
public class Payments_JSON2ApexDeal{
    public String PORMSG {get;set;}
    public cls_PODETAIL PODETAIL {get;set;}
    
    Public class cls_PODETAIL {
        public String IP_PREF {get;set;}
        public String IP_DLND {get;set;}
        public String IP_RECI {get;set;}
        public String IP_CUST {get;set;}
        public String IP_CNAM {get;set;}
        public String IP_CSSN {get;set;}
        public String IP_CRTN {get;set;}
        public String IP_CRNM {get;set;}
        public String IP_PRFC {get;set;}
        public String IP_PRCD {get;set;}
        public String IP_CENT {get;set;}
        public String IP_CEND {get;set;}
        public String IP_DLNO {get;set;}
        public String IP_FRNT {get;set;}
        public String IP_SRCE {get;set;}
        public String IP_SDAT {get;set;}
        public String IP_VDAT {get;set;}
        public String IP_DDAT {get;set;}
        public String IP_RRVL {get;set;}
        public String IP_BOKC {get;set;}
        public String IP_BOKD {get;set;}
        public String IP_BREP {get;set;}
        public String IP_BCAT {get;set;}
        public String IP_SNTP {get;set;}
        public String IP_SND1 {get;set;}
        public String IP_SACC {get;set;}
        public String IP_SNAM {get;set;}
        public String IP_SAMT {get;set;}
        public String IP_RBNK {get;set;}
        public String IP_RACC {get;set;}
        public String IP_RNAM {get;set;}
        public String IP_RAMT {get;set;}
        public String IP_RLPR {get;set;}
        public String IP_RDL1 {get;set;}
        public String IP_RDL2 {get;set;}
        public String IP_RDL3 {get;set;}
        public String IP_RDL4 {get;set;}
        public String IP_RDL5 {get;set;}
        public String IP_RDL6 {get;set;}
        public String IP_RDL7 {get;set;}
        public String IP_NTRF {get;set;}
        public String IP_BNC1 {get;set;}
        public String IP_BNC2 {get;set;}
        public String IP_BNC3 {get;set;}
        public String IP_BNC4 {get;set;}
        public String IP_BNC5 {get;set;}
        public String IP_AUP1 {get;set;}
        public String IP_AUP2 {get;set;}
        public String IP_USR1 {get;set;}
        public String IP_USR2 {get;set;}
        public String IP_TMST {get;set;}
        public String FX_DLND {get;set;}
        public String FX_CUST {get;set;}
        public String FX_CNAM {get;set;}
        public String FX_CSSN {get;set;}
        public String FX_CRTN {get;set;}
        public String FX_CRNM {get;set;}
        public String FX_CENT {get;set;}
        public String FX_CEND {get;set;}
        public String FX_CBRN {get;set;}
        public String FX_CBRD {get;set;}
        public String FX_GRP5 {get;set;}
        public String FX_GRPD {get;set;}
        public String FX_DLNO {get;set;}
        public String FX_DTYP {get;set;}
        public String FX_DLST {get;set;}
        public String FX_DSTN {get;set;}
        public String FX_BOKC {get;set;}
        public String FX_BRKC {get;set;}
        public String FX_CTYP {get;set;}
        public String FX_CSTP {get;set;}
        public String FX_COPN {get;set;}
        public String FX_CMTP {get;set;}
        public String FX_VDAT {get;set;}
        public String FX_DDAT {get;set;}
        public String FX_RRVL {get;set;}
        public String FX_PCST {get;set;}
        public String FX_OPCA {get;set;}
        public String FX_PACC {get;set;}
        public String FX_ANAM {get;set;}
        public String FX_PAMT {get;set;}
        public String FX_PCAT {get;set;}
        public String FX_SCST {get;set;}
        public String FX_OSCA {get;set;}
        public String FX_SACC {get;set;}
        public String FX_SNAM {get;set;}
        public String FX_SAMT {get;set;}
        public String FX_SPI1 {get;set;}
        public String FX_SPE1 {get;set;}
    }
    public static Payments_JSON2ApexDeal parse(String json){
        return (Payments_JSON2ApexDeal) System.JSON.deserialize(json, Payments_JSON2ApexDeal.class);
    }
}