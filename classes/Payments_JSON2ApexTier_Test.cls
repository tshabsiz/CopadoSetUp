/**
* 2017-10-16
* Rudolf Niehaus - CloudSmiths
* TEst class for MIDAS outbound calls - Payments_JSON2ApexTier
**/
@isTest
public class Payments_JSON2ApexTier_Test {
    
    static testMethod void testJasonTier() {
        String json='{'+
            '    "PO_MSG": "**** Customer Tiers Successfully Processed **",'+
            '    "PO_TIERS": {'+
            '        "d10TIERTP": "CR",'+
            '        "d10TIERDR": " 0000000ZARD",'+
            '        "d10TIERCR": " 0207101ZARD",'+
            '        "d10ACNO": 287870231,'+
            '        "d10CNUM": 28787,'+
            '        "d10CCY": "ZAR",'+
            '        "d10ACOD": 6712,'+
            '        "d10ACSQ": 1,'+
            '        "d10BRCA": "888",'+
            '        "d10CNAME": "BARCLAYS BANK PLC WHOLESALE LONDON",'+
            '        "d10LDBL": 1019933321631,'+
            '        "d10LDBLA": "   10,199,333,216.31"'+
            '    },'+
            '    "PO_DRTRESH": {'+
            '        "DRT_D01TIERCD": "",'+
            '        "DRT_D01TIERDS": "",'+
            '        "DRT_D01TIERBC": 0,'+
            '        "DRT_D01TIERDC": "",'+
            '        "DRT_D01TIERT01": 0,'+
            '        "DRT_D01TIERT02": 0,'+
            '        "DRT_D01TIERT03": 0,'+
            '        "DRT_D01TIERT04": 0,'+
            '        "DRT_D01TIERT05": 0,'+
            '        "DRT_D01TIERT06": 0,'+
            '        "DRT_D01TIERT07": 0,'+
            '        "DRT_D01TIERT08": 0,'+
            '        "DRT_D01TIERT09": 0,'+
            '        "DRT_D01TIERT10": 0,'+
            '        "DRT_D01TIERT11": 0,'+
            '        "DRT_D01TIERR01": 0,'+
            '        "DRT_D01TIERR02": 0,'+
            '        "DRT_D01TIERR03": 0,'+
            '        "DRT_D01TIERR04": 0,'+
            '        "DRT_D01TIERR05": 0,'+
            '        "DRT_D01TIERR06": 0,'+
            '        "DRT_D01TIERR07": 0,'+
            '        "DRT_D01TIERR08": 0,'+
            '        "DRT_D01TIERR09": 0,'+
            '        "DRT_D01TIERR10": 0,'+
            '        "DRT_D01TIERR11": 0,'+
            '        "DRT_D01DRCTOT": 0,'+
            '        "DRT_D01CRCTOT": 0'+
            '    },'+
            '    "PO_CRTRESH": {'+
            '        "CRT_D01TIERCD": " 0207101ZARD",'+
            '        "CRT_D01TIERDS": "VOSTRO DEBIT PRICING 07101",'+
            '        "CRT_D01TIERBC": 12,'+
            '        "CRT_D01TIERDC": "CR",'+
            '        "CRT_D01TIERT01": 0,'+
            '        "CRT_D01TIERT02": 999999999999900,'+
            '        "CRT_D01TIERT03": 0,'+
            '        "CRT_D01TIERT04": 0,'+
            '        "CRT_D01TIERT05": 0,'+
            '        "CRT_D01TIERT06": 0,'+
            '        "CRT_D01TIERT07": 0,'+
            '        "CRT_D01TIERT08": 0,'+
            '        "CRT_D01TIERT09": 0,'+
            '        "CRT_D01TIERT10": 0,'+
            '        "CRT_D01TIERT11": 0,'+
            '        "CRT_D01TIERR01": 3,'+
            '        "CRT_D01TIERR02": 3,'+
            '        "CRT_D01TIERR03": 0,'+
            '        "CRT_D01TIERR04": 0,'+
            '        "CRT_D01TIERR05": 0,'+
            '        "CRT_D01TIERR06": 0,'+
            '        "CRT_D01TIERR07": 0,'+
            '        "CRT_D01TIERR08": 0,'+
            '        "CRT_D01TIERR09": 0,'+
            '        "CRT_D01TIERR10": 0,'+
            '        "CRT_D01TIERR11": 0,'+
            '        "CRT_D01DRCTOT": 18,'+
            '        "CRT_D01CRCTOT": 23'+
            '    }'+
            '}';
       
        Payments_JSON2ApexTier jsonclass = new Payments_JSON2ApexTier();
        jsonclass = Payments_JSON2ApexTier.parse(json);
            
        System.assert(jsonclass != null);
        
        Payments_JSON2ApexTier.cls_PO_TIERS cls = new Payments_JSON2ApexTier.cls_PO_TIERS();
        String  d10TIERTP = cls.d10TIERTP;
        String  d10TIERDR = cls.d10TIERDR;
        String  d10TIERCR = cls.d10TIERCR;
        Long d10ACNO  = cls.d10ACNO;
        Long d10CNUM  = cls.d10CNUM;
        String  d10CCY   = cls.d10CCY;
        Long d10ACOD  = cls.d10ACOD;
        Long d10ACSQ  = cls.d10ACSQ;
        String  d10BRCA  = cls.d10BRCA;
        String  d10CNAME = cls.d10CNAME;
        Decimal d10LDBL  = cls.d10LDBL;
        String  d10LDBLA = cls.d10LDBLA;
        Payments_JSON2ApexTier.cls_PO_DRTRESH cls2 = new Payments_JSON2ApexTier.cls_PO_DRTRESH();
        String DRT_D01TIERCD   = cls2.DRT_D01TIERCD; 
        String DRT_D01TIERDS   = cls2.DRT_D01TIERDS; 
        Integer DRT_D01TIERBC  = cls2.DRT_D01TIERBC; 
        String DRT_D01TIERDC   = cls2.DRT_D01TIERDC; 
        Decimal DRT_D01TIERT01 = cls2.DRT_D01TIERT01;
        Decimal DRT_D01TIERT02 = cls2.DRT_D01TIERT02;
        Decimal DRT_D01TIERT03 = cls2.DRT_D01TIERT03;
        Decimal DRT_D01TIERT04 = cls2.DRT_D01TIERT04;
        Decimal DRT_D01TIERT05 = cls2.DRT_D01TIERT05;
        Decimal DRT_D01TIERT06 = cls2.DRT_D01TIERT06;
        Decimal DRT_D01TIERT07 = cls2.DRT_D01TIERT07;
        Decimal DRT_D01TIERT08 = cls2.DRT_D01TIERT08;
        Decimal DRT_D01TIERT09 = cls2.DRT_D01TIERT09;
        Decimal DRT_D01TIERT10 = cls2.DRT_D01TIERT10;
        Decimal DRT_D01TIERT11 = cls2.DRT_D01TIERT11;
        Double DRT_D01TIERR01  = cls2.DRT_D01TIERR01;
        Double DRT_D01TIERR02  = cls2.DRT_D01TIERR02;
        Double DRT_D01TIERR03  = cls2.DRT_D01TIERR03;
        Double DRT_D01TIERR04  = cls2.DRT_D01TIERR04;
        Double DRT_D01TIERR05  = cls2.DRT_D01TIERR05;
        Double DRT_D01TIERR06  = cls2.DRT_D01TIERR06;
        Double DRT_D01TIERR07  = cls2.DRT_D01TIERR07;
        Double DRT_D01TIERR08  = cls2.DRT_D01TIERR08;
        Double DRT_D01TIERR09  = cls2.DRT_D01TIERR09;
        Double DRT_D01TIERR10  = cls2.DRT_D01TIERR10;
        Double DRT_D01TIERR11  = cls2.DRT_D01TIERR11;
        Decimal DRT_D01DRCTOT  = cls2.DRT_D01DRCTOT; 
        Decimal DRT_D01CRCTOT  = cls2.DRT_D01CRCTOT;
        Payments_JSON2ApexTier.cls_PO_CRTRESH cls3 = new Payments_JSON2ApexTier.cls_PO_CRTRESH();
        String  CRT_D01TIERCD  = cls3.CRT_D01TIERCD; 
        String  CRT_D01TIERDS  = cls3.CRT_D01TIERDS; 
        Integer CRT_D01TIERBC  = cls3.CRT_D01TIERBC; 
        String  CRT_D01TIERDC  = cls3.CRT_D01TIERDC; 
        Decimal CRT_D01TIERT01 = cls3.CRT_D01TIERT01;
        Decimal CRT_D01TIERT02 = cls3.CRT_D01TIERT02;
        Decimal CRT_D01TIERT03 = cls3.CRT_D01TIERT03;
        Decimal CRT_D01TIERT04 = cls3.CRT_D01TIERT04;
        Decimal CRT_D01TIERT05 = cls3.CRT_D01TIERT05;
        Decimal CRT_D01TIERT06 = cls3.CRT_D01TIERT06;
        Decimal CRT_D01TIERT07 = cls3.CRT_D01TIERT07;
        Decimal CRT_D01TIERT08 = cls3.CRT_D01TIERT08;
        Decimal CRT_D01TIERT09 = cls3.CRT_D01TIERT09;
        Decimal CRT_D01TIERT10 = cls3.CRT_D01TIERT10;
        Decimal CRT_D01TIERT11 = cls3.CRT_D01TIERT11;
        Double  CRT_D01TIERR01 = cls3.CRT_D01TIERR01;
        Double  CRT_D01TIERR02 = cls3.CRT_D01TIERR02;
        Double  CRT_D01TIERR03 = cls3.CRT_D01TIERR03;
        Double  CRT_D01TIERR04 = cls3.CRT_D01TIERR04;
        Double  CRT_D01TIERR05 = cls3.CRT_D01TIERR05;
        Double  CRT_D01TIERR06 = cls3.CRT_D01TIERR06;
        Double  CRT_D01TIERR07 = cls3.CRT_D01TIERR07;
        Double  CRT_D01TIERR08 = cls3.CRT_D01TIERR08;
        Double  CRT_D01TIERR09 = cls3.CRT_D01TIERR09;
        Double  CRT_D01TIERR10 = cls3.CRT_D01TIERR10;
        Double  CRT_D01TIERR11 = cls3.CRT_D01TIERR11;
        Decimal CRT_D01DRCTOT  = cls3.CRT_D01DRCTOT; 
        Decimal CRT_D01CRCTOT  = cls3.CRT_D01CRCTOT;
    }
    
}