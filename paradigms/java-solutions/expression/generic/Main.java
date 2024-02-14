package expression.generic;

public class Main {
    public static void main(String[] args) throws Exception {
        GenericTabulator gt = new GenericTabulator();
        StringBuilder exp = new StringBuilder();
        for (int i = 1; i < args.length; i++) {
            exp.append(args[i]);
            exp.append(" ");
        }
        Object[][][] ans = gt.tabulate(args[0].substring(1), exp.toString(), -2, 2, -2, 2, -2, 2);
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5; j++) {
                for (int k = 0; k < 5; k++) {
                    System.out.println("x = " + (i - 2) + "      y = " + (j - 2) + "\nz = " + (k - 2) + "      value = " + ans[i][j][k]);
                }
            }
        }
    }
}
