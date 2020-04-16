public class generateBase36 {
    public static String generateBase36(Decimal decimalValue, Integer contractNumberLength)
    {
        try
        {
            Integer inputBase = 10;
            Integer outputBase = 16;
            String outputValue = ''; 
            String numericBaseData = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            Integer x;
            Integer maxBase = NumericBaseData.length();
            if(DecimalValue == 0)
            {
                return '0';
            }
            else
            {
                while(decimalValue > 0)
                {
                    X = (Integer)(((DecimalValue/outputBase) - (Integer)(DecimalValue/OutputBase))* OutputBase + 1.5);
                    System.debug('x' + x);
                    OutputValue = NumericBaseData.subString(X - 1,X)+OutputValue;
                    DecimalValue = Integer.valueOf(DecimalValue/OutputBase);
                }
            }
            //We want to ensure all characters have a value. So if the Base 32 number is 10, and our Contract Number lenght is 5, we want to make the output String "00010"
            while(OutputValue.length() < contractNumberLength)
            {
                OutputValue = '0' + OutputValue;
            }
            return OutputValue;
        }catch(Exception e)
        {
            System.debug('There was an error converting the base values:' + e.getMessage());
            return 'There was an error converting the base values:' + e.getMessage();
        }
        
    }   
}