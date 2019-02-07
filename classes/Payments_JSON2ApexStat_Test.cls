/**
* Date:  2017-10-13 Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  Test class for Payments_JSON2ApexStat
**/
@isTest
public class Payments_JSON2ApexStat_Test {
    
    static testMethod void testParse() {
        String json='{'+
            '    "MACCNO": "028738ZAR000000671201",'+
            '    "SDATE": 20170701,'+
            '    "OPENBAL": -22953601.39,'+
            '    "CURPAGE": 1,'+
            '    "TOTPAGE": 1,'+
            '    "TOTLINE": 222,'+
            '    "LINECOUNT": 222,'+
            '    "DETAILLINE": ['+
            '        {'+
            '            "STRRN": 1,'+
            '            "STSTYPE": "B",'+
            '            "STWSEQ": "V",'+
            '            "STCNUM": 28738,'+
            '            "STCCY": "ZAR",'+
            '            "STACOD": 6712,'+
            '            "STACSQ": 1,'+
            '            "STPDAT": 20170704,'+
            '            "STVDAT": 20170704,'+
            '            "STPNAR": "P170704AAAAIN00 Transfer",'+
            '            "STPAMT": 0,'+
            '            "STBAMT": -22952601.39,'+
            '            "STSPOS": "  GE-FT",'+
            '            "STATYP": "R",'+
            '            "STGETP": "G",'+
            '            "STPREF": "P170704AAAAIN00",'+
            '            "STDLNO": 0,'+
            '            "STREF1": "GPP-NV-VD-0307M",'+
            '            "STREF2": "",'+
            '            "STREF3": "",'+
            '            "STCNA1": "",'+
            '            "STBRAT": 0,'+
            '            "STBIBL": 0,'+
            '            "STITYP": ""'+
            '        },'+
            '        {'+
            '            "STRRN": 83,'+
            '            "STSTYPE": "B",'+
            '            "STWSEQ": "V",'+
            '            "STCNUM": 28738,'+
            '            "STCCY": "ZAR",'+
            '            "STACOD": 6712,'+
            '            "STACSQ": 1,'+
            '            "STPDAT": 20170712,'+
            '            "STVDAT": 20170712,'+
            '            "STPNAR": "P170712AAGBIN00 Transfer",'+
            '            "STPAMT": 1004,'+
            '            "STBAMT": -22858792.85,'+
            '            "STSPOS": "  GE-FT",'+
            '            "STATYP": "R",'+
            '            "STGETP": "G",'+
            '            "STPREF": "P170712AAGBIN00",'+
            '            "STDLNO": 888151,'+
            '            "STREF1": "NEWTEST1GP4",'+
            '            "STREF2": "GPP170711000083",'+
            '            "STREF3": "",'+
            '            "STCNA1": "",'+
            '            "STBRAT": 0,'+
            '            "STBIBL": 0,'+
            '            "STITYP": ""'+
            '        },'+
            '        {'+
            '            "STRRN": 222,'+
            '            "STSTYPE": "I",'+
            '            "STWSEQ": "V",'+
            '            "STCNUM": 28738,'+
            '            "STCCY": "ZAR",'+
            '            "STACOD": 6712,'+
            '            "STACSQ": 1,'+
            '            "STPDAT": 20170801,'+
            '            "STVDAT": 20170801,'+
            '            "STPNAR": "",'+
            '            "STPAMT": 3636.84,'+
            '            "STBAMT": 23086015.49,'+
            '            "STSPOS": "",'+
            '            "STATYP": "",'+
            '            "STGETP": "",'+
            '            "STPREF": "",'+
            '            "STDLNO": 0,'+
            '            "STREF1": "",'+
            '            "STREF2": "",'+
            '            "STREF3": "",'+
            '            "STCNA1": "",'+
            '            "STBRAT": 5.75,'+
            '            "STBIBL": -156931,'+
            '            "STITYP": "ACR"'+
            '        }'+
            '    ]'+
            '}';
        
        Payments_JSON2ApexStat jsonclass = new Payments_JSON2ApexStat();
        jsonclass = Payments_JSON2ApexStat.parse(json);
            
        System.assert(jsonclass != null);
        String  MACCNO = jsonclass.MACCNO;   
        Integer SDATE = jsonclass.SDATE;   
        Decimal OPENBAL = jsonclass.OPENBAL;  
        Integer CURPAGE = jsonclass.CURPAGE;  
        Integer TOTPAGE = jsonclass.TOTPAGE;  
        Integer TOTLINE = jsonclass.TOTLINE;  
        Integer LINECOUNT = jsonclass.LINECOUNT;
        
        Payments_JSON2ApexStat.cls_DETAILLINE cls = new Payments_JSON2ApexStat.cls_DETAILLINE();
        Integer STRRN   = cls.STRRN;  
         String  STSTYPE = cls.STSTYPE;
         String  STWSEQ  = cls.STWSEQ; 
         Integer STCNUM  = cls.STCNUM; 
         String  STCCY   = cls.STCCY; 
         Integer STACOD  = cls.STACOD; 
         Integer STACSQ  = cls.STACSQ; 
         Integer STPDAT  = cls.STPDAT; 
         Integer STVDAT  = cls.STVDAT; 
         String  STPNAR  = cls.STPNAR; 
         Decimal STPAMT  = cls.STPAMT;
         Decimal STBAMT  = cls.STBAMT;
         String  STSPOS  = cls.STSPOS; 
         String  STATYP  = cls.STATYP; 
         String  STGETP  = cls.STGETP; 
         String  STPREF  = cls.STPREF; 
         Integer STDLNO  = cls.STDLNO; 
         String  STREF1  = cls.STREF1; 
         String  STREF2  = cls.STREF2; 
         String  STREF3  = cls.STREF3; 
         String  STCNA1  = cls.STCNA1; 
         Double  STBRAT  = cls.STBRAT; 
         Decimal STBIBL  = cls.STBIBL; 
         String  STITYP  = cls.STITYP;
        
    }
}