/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

29/06/2017 - DF    - Created Class.

**/ 
@isTest
public class checkRecursion_Test 
{
    public static testMethod void checkRecursion_Test() 
    { 
        checkRecursion.runOnce();
        checkRecursion.runOnce();
        checkRecursion.getRunOnce_Condition();
        checkRecursion.setRunOnce_Condition(false);
        checkRecursion.getRunOnce_Condition();
    }
}