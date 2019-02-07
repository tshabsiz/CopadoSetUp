/**
* Date:  2017-10-13 Friday the 13th :-)
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  Test class for Payments_JSON2ApexBIC
**/
@isTest
public class Payments_JSON2ApexBIC_Test {
    
     static testMethod void testBICParse(){
         
        String json='{'+
            '    "PORMSG": "",'+
            '    "POACNT": 3,'+
            '    "DETAILLINE": ['+
            '        {'+
            '            "POFNAM": "BARCLAYS PLC LDN",'+
            '            "POCNUM": "028738",'+
            '            "POCURR": "ZAR",'+
            '            "POACOD": 6712,'+
            '            "POACSQ": 1,'+
            '            "PODSPA": "028738-ZAR-0000006712-01",'+
            '            "POANAM": "BARCLAYS BANK LONDON",'+
            '            "POPDEC": "BARCLAYS BANK LONDON",'+
            '            "POAPRF": "3945",'+
            '            "POFBAL": 0,'+
            '            "POCRAT": 0,'+
            '            "POLBAL": 0,'+
            '            "POCBAL": 0,'+
            '            "POZBAL": 0,'+
            '            "POAOPN": "2009-07-15"'+
            '        },'+
            '        {'+
            '            "POFNAM": "BARCLAYS PLC LDN",'+
            '            "POCNUM": "028738",'+
            '            "POCURR": "ZAR",'+
            '            "POACOD": 6850,'+
            '            "POACSQ": 1,'+
            '            "PODSPA": "028738-ZAR-0000006850-01",'+
            '            "POANAM": "BARCLAYS PLC LDN",'+
            '            "POPDEC": "BARCLAYS PLC LDN",'+
            '            "POAPRF": "9866",'+
            '            "POFBAL": 0,'+
            '            "POCRAT": 0,'+
            '            "POLBAL": 0,'+
            '            "POCBAL": 0,'+
            '            "POZBAL": 0,'+
            '            "POAOPN": "2010-11-29"'+
            '        },'+
            '        {'+
            '            "POFNAM": "BARCLAYS PLC LDN",'+
            '            "POCNUM": "028738",'+
            '            "POCURR": "ZAR",'+
            '            "POACOD": 6851,'+
            '            "POACSQ": 1,'+
            '            "PODSPA": "028738-ZAR-0000006851-01",'+
            '            "POANAM": "BARCLAYS PLC LDN",'+
            '            "POPDEC": "BARCLAYS PLC LDN",'+
            '            "POAPRF": "9866",'+
            '            "POFBAL": 0,'+
            '            "POCRAT": 0,'+
            '            "POLBAL": 0,'+
            '            "POCBAL": 0,'+
            '            "POZBAL": 0,'+
            '            "POAOPN": "2010-11-29"'+
            '        }'+
            '    ]'+
            '}';
         
        Payments_JSON2ApexBIC jsonclass = new Payments_JSON2ApexBIC();
        jsonclass = Payments_JSON2ApexBIC.parse(json);
        
        System.assert(jsonclass != null);
        String PORMSG = jsonclass.PORMSG;
        Integer POACNT = jsonclass.POACNT;
         
        Payments_JSON2ApexBIC.cls_DETAILLINE cls = new Payments_JSON2ApexBIC.cls_DETAILLINE();
        
        String POFNAM = cls.POFNAM;
        String POCNUM = cls.POCNUM;
        String POCURR = cls.POCURR;
        Integer POACOD = cls.POACOD;
        Integer POACSQ = cls.POACSQ;
        String  PODSPA  = cls.PODSPA;
        String  POANAM  = cls.POANAM;
        String  POPDEC  = cls.POPDEC;
        String  POAPRF  = cls.POAPRF;
        Decimal POFBAL = cls.POFBAL;
        Decimal POCRAT = cls.POCRAT;
        Decimal POLBAL = cls.POLBAL;
        Decimal POCBAL = cls.POCBAL;
        Decimal POZBAL = cls.POZBAL;
        String  POAOPN  = cls.POAOPN;
    }
}