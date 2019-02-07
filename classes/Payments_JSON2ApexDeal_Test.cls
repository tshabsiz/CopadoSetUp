/**
* Date:  2017-10-13 Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  Test class for Payments_JSON2ApexDeal
**/
@isTest
public class Payments_JSON2ApexDeal_Test {
    static testMethod void testDealParse() {
        String json='{'+
            '    "PORMSG": "*** Enquiry was Successful ***",'+
            '    "PODETAIL": {'+
            '        "IP_PREF": "P170704AAAAIN00",'+
            '        "IP_DLND": "Matured Transfer Deal",'+
            '        "IP_RECI": "M",'+
            '        "IP_CUST": "028738",'+
            '        "IP_CNAM": "BARCLAYS BANK PLC LONDON (BARCGB22)",'+
            '        "IP_CSSN": "BARCLYS LD",'+
            '        "IP_CRTN": "LONDON",'+
            '        "IP_CRNM": "BARCLAYS PLC LDN",'+
            '        "IP_PRFC": "3945",'+
            '        "IP_PRCD": "PIP:KWA ZULU NATAL",'+
            '        "IP_CENT": "",'+
            '        "IP_CEND": "",'+
            '        "IP_DLNO": "887940",'+
            '        "IP_FRNT": "887940-16622-LEG",'+
            '        "IP_SRCE": "GPP",'+
            '        "IP_SDAT": "",'+
            '        "IP_VDAT": "2017-07-04",'+
            '        "IP_DDAT": "2017-07-04",'+
            '        "IP_RRVL": "1,000.00   @   1.00000000",'+
            '        "IP_BOKC": "GP",'+
            '        "IP_BOKD": "GPP Meridian               BOP",'+
            '        "IP_BREP": "Y",'+
            '        "IP_BCAT": "900",'+
            '        "IP_SNTP": "",'+
            '        "IP_SND1": "028738ZAR000000671201888R",'+
            '        "IP_SACC": "028738-ZAR-6712-01",'+
            '        "IP_SNAM": "BARCLAYS BANK LONDON",'+
            '        "IP_SAMT": "ZAR 1,000.00",'+
            '        "IP_RBNK": "ZAR 17                  G",'+
            '        "IP_RACC": "969774-ZAR-6661-01",'+
            '        "IP_RNAM": "VOSTRO SYSTEM SUP",'+
            '        "IP_RAMT": "ZAR  1,000.00",'+
            '        "IP_RLPR": "GPP-NV-VD-0307M",'+
            '        "IP_RDL1": "GPP-NV-VD-0307M",'+
            '        "IP_RDL2": "GPP170703000052",'+
            '        "IP_RDL3": "",'+
            '        "IP_RDL4": "",'+
            '        "IP_RDL5": "",'+
            '        "IP_RDL6": "",'+
            '        "IP_RDL7": "",'+
            '        "IP_NTRF": "",'+
            '        "IP_BNC1": "BARCGB22XXX",'+
            '        "IP_BNC2": "",'+
            '        "IP_BNC3": "",'+
            '        "IP_BNC4": "",'+
            '        "IP_BNC5": "",'+
            '        "IP_AUP1": "AUTOAUTH1",'+
            '        "IP_AUP2": "AUTOAUTH2",'+
            '        "IP_USR1": "JDBC01",'+
            '        "IP_USR2": "JDBC01",'+
            '        "IP_TMST": "2017-07-04-07.07.39.205000",'+
            '        "FX_DLND": "",'+
            '        "FX_CUST": "",'+
            '        "FX_CNAM": "",'+
            '        "FX_CSSN": "",'+
            '        "FX_CRTN": "",'+
            '        "FX_CRNM": "",'+
            '        "FX_CENT": "",'+
            '        "FX_CEND": "",'+
            '        "FX_CBRN": "",'+
            '        "FX_CBRD": "",'+
            '        "FX_GRP5": "",'+
            '        "FX_GRPD": "",'+
            '        "FX_DLNO": "",'+
            '        "FX_DTYP": "",'+
            '        "FX_DLST": "",'+
            '        "FX_DSTN": "",'+
            '        "FX_BOKC": "",'+
            '        "FX_BRKC": "",'+
            '        "FX_CTYP": "",'+
            '        "FX_CSTP": "",'+
            '        "FX_COPN": "",'+
            '        "FX_CMTP": "",'+
            '        "FX_VDAT": "",'+
            '        "FX_DDAT": "",'+
            '        "FX_RRVL": "",'+
            '        "FX_PCST": "",'+
            '        "FX_OPCA": "",'+
            '        "FX_PACC": "",'+
            '        "FX_ANAM": "",'+
            '        "FX_PAMT": "",'+
            '        "FX_PCAT": "",'+
            '        "FX_SCST": "",'+
            '        "FX_OSCA": "",'+
            '        "FX_SACC": "",'+
            '        "FX_SNAM": "",'+
            '        "FX_SAMT": "",'+
            '        "FX_SPI1": "",'+
            '        "FX_SPE1": ""'+
            '    }'+
            '}';
       
        Payments_JSON2ApexDeal jsonclass = new Payments_JSON2ApexDeal();
        jsonclass = Payments_JSON2ApexDeal.parse(json);
            
        System.assert(jsonclass != null);
        String PORMSG = jsonclass.PORMSG;
        
        Payments_JSON2ApexDeal.cls_PODETAIL cls = new Payments_JSON2ApexDeal.cls_PODETAIL();
        String IP_PREF = cls.IP_PREF;
        String IP_DLND = cls.IP_DLND;
        String IP_RECI = cls.IP_RECI;
        String IP_CUST = cls.IP_CUST;
        String IP_CNAM = cls.IP_CNAM;
        String IP_CSSN = cls.IP_CSSN;
        String IP_CRTN = cls.IP_CRTN;
        String IP_CRNM = cls.IP_CRNM;
        String IP_PRFC = cls.IP_PRFC;
        String IP_PRCD = cls.IP_PRCD;
        String IP_CENT = cls.IP_CENT;
        String IP_CEND = cls.IP_CEND;
        String IP_DLNO = cls.IP_DLNO;
        String IP_FRNT = cls.IP_FRNT;
        String IP_SRCE = cls.IP_SRCE;
        String IP_SDAT = cls.IP_SDAT;
        String IP_VDAT = cls.IP_VDAT;
        String IP_DDAT = cls.IP_DDAT;
        String IP_RRVL = cls.IP_RRVL;
        String IP_BOKC = cls.IP_BOKC;
        String IP_BOKD = cls.IP_BOKD;
        String IP_BREP = cls.IP_BREP;
        String IP_BCAT = cls.IP_BCAT;
        String IP_SNTP = cls.IP_SNTP;
        String IP_SND1 = cls.IP_SND1;
        String IP_SACC = cls.IP_SACC;
        String IP_SNAM = cls.IP_SNAM;
        String IP_SAMT = cls.IP_SAMT;
        String IP_RBNK = cls.IP_RBNK;
        String IP_RACC = cls.IP_RACC;
        String IP_RNAM = cls.IP_RNAM;
        String IP_RAMT = cls.IP_RAMT;
        String IP_RLPR = cls.IP_RLPR;
        String IP_RDL1 = cls.IP_RDL1;
        String IP_RDL2 = cls.IP_RDL2;
        String IP_RDL3 = cls.IP_RDL3;
        String IP_RDL4 = cls.IP_RDL4;
        String IP_RDL5 = cls.IP_RDL5;
        String IP_RDL6 = cls.IP_RDL6;
        String IP_RDL7 = cls.IP_RDL7;
        String IP_NTRF = cls.IP_NTRF;
        String IP_BNC1 = cls.IP_BNC1;
        String IP_BNC2 = cls.IP_BNC2;
        String IP_BNC3 = cls.IP_BNC3;
        String IP_BNC4 = cls.IP_BNC4;
        String IP_BNC5 = cls.IP_BNC5;
        String IP_AUP1 = cls.IP_AUP1;
        String IP_AUP2 = cls.IP_AUP2;
        String IP_USR1 = cls.IP_USR1;
        String IP_USR2 = cls.IP_USR2;
        String IP_TMST = cls.IP_TMST;
        String FX_DLND = cls.FX_DLND;
        String FX_CUST = cls.FX_CUST;
        String FX_CNAM = cls.FX_CNAM;
        String FX_CSSN = cls.FX_CSSN;
        String FX_CRTN = cls.FX_CRTN;
        String FX_CRNM = cls.FX_CRNM;
        String FX_CENT = cls.FX_CENT;
        String FX_CEND = cls.FX_CEND;
        String FX_CBRN = cls.FX_CBRN;
        String FX_CBRD = cls.FX_CBRD;
        String FX_GRP5 = cls.FX_GRP5;
        String FX_GRPD = cls.FX_GRPD;
        String FX_DLNO = cls.FX_DLNO;
        String FX_DTYP = cls.FX_DTYP;
        String FX_DLST = cls.FX_DLST;
        String FX_DSTN = cls.FX_DSTN;
        String FX_BOKC = cls.FX_BOKC;
        String FX_BRKC = cls.FX_BRKC;
        String FX_CTYP = cls.FX_CTYP;
        String FX_CSTP = cls.FX_CSTP;
        String FX_COPN = cls.FX_COPN;
        String FX_CMTP = cls.FX_CMTP;
        String FX_VDAT = cls.FX_VDAT;
        String FX_DDAT = cls.FX_DDAT;
        String FX_RRVL = cls.FX_RRVL;
        String FX_PCST = cls.FX_PCST;
        String FX_OPCA = cls.FX_OPCA;
        String FX_PACC = cls.FX_PACC;
        String FX_ANAM = cls.FX_ANAM;
        String FX_PAMT = cls.FX_PAMT;
        String FX_PCAT = cls.FX_PCAT;
        String FX_SCST = cls.FX_SCST;
        String FX_OSCA = cls.FX_OSCA;
        String FX_SACC = cls.FX_SACC;
        String FX_SNAM = cls.FX_SNAM;
        String FX_SAMT = cls.FX_SAMT;
        String FX_SPI1 = cls.FX_SPI1;
        String FX_SPE1 = cls.FX_SPE1;
        
               
    }
    
}