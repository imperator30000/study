//import java.util.Arrays;

public class Sum {
    public static void main(String[] args) {
        String argsStr = String.join(" ", args);
//        String argsStr = Arrays.toString(args);
//        String argsStr = "";
//        for(int i = 0;i <args.length;i++)argsStr += args[i] + " ";
        int sum = 0;
        int indexstart = -1;
        for (int i = 0; i < argsStr.length(); i++) {
            if ("1234567890+-".contains(Character.toString(argsStr.charAt(i)))) {
                if (indexstart == -1) indexstart = i;

            } else if (indexstart != -1) {
                sum += Integer.parseInt(argsStr.substring(indexstart, i));

                indexstart = -1;
            }
        }
        if (indexstart != -1) {
            System.out.println(sum + Integer.parseInt(argsStr.substring(indexstart)));
        } else {
            System.out.println(sum);
        }
    }
}
