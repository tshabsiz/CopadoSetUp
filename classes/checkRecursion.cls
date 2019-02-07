/**
 * NEED SEPERATE FLAG FOR EACH TRIGGER
**/
public Class checkRecursion 
{
    private static boolean run = true;
    public static Boolean runOnce_Condition = true;
    public static Boolean shouldIRun = true;
    
    public static Boolean getRunOnce_Condition() { 
        
        if(runOnce_Condition == true)
        {
            runOnce_Condition = false;
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static void setRunOnce_Condition(Boolean inputFlag) { 
        runOnce_Condition = inputFlag;
    }
    
    public static boolean runOnce()
    {
        if(run)
        {
            run=false;
            return true;
        }
        else
        {
            return run;
        }
    }

    public static Boolean canIRun(){
         return shouldIRun; 
    }
    
    public static void stopRecursion(){
        shouldIRun = false;
    }
    
    public static void allowTorun(){
        shouldIRun = true;
    }
    
    
}