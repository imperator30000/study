
public class SumDouble {
    public static void main(String[] args) {
//        String argsStr = String.join(" ", args);
//        String argsStr = Arrays.toString(args);
//        StringBuilder argsStr = new StringBuilder();
//        for(int i = 0;i <args.length;i++) argsStr.append(args[i]).append(" ");
        double sum = 0d;
        int indexstart = -1;
        for (String arg : args) {
            for (int i = 0; i < arg.length(); i++) {
                if (!Character.isWhitespace(arg.charAt(i))) {
                    if (indexstart == -1) {
                        indexstart = i;
                    }
                } else if (indexstart != -1) {
                    sum += Double.parseDouble(arg.substring(indexstart, i));
                    indexstart = -1;
                }
            }
            if (indexstart != -1) {
                sum += Double.parseDouble(arg.substring(indexstart));
            }
        }
        System.out.println(sum);
    }
}
