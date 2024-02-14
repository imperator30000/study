package game;

import java.util.Scanner;

/**
 * @author Georgiy Korneev (kgeorgiy@kgeorgiy.info)
 */
public class Main {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        int result;
        System.out.println("input max wins, m, n, k \n(m >= k or n >= k, k >= 2, max wins > 0)");
        int wins = sc.nextInt();
        int m = sc.nextInt();
        int n = sc.nextInt();
        int k = sc.nextInt();
        while (m < k && n < k || k < 2 || wins < 1){
            System.out.println("incorrect input\n" +
                    "repeat the input");
            System.out.println("input max wins, m, n, k \n(m >= k or n >= k , k >= 2, max wins > 0)");
            wins = sc.nextInt();
            m = sc.nextInt();
            n = sc.nextInt();
            k = sc.nextInt();
        }
        final Game game = new Game(false, new HumanPlayer(), new HumanPlayer(), wins);
        do {
            result = game.play(new MNKBoard(m, n, k));
        } while (result == -1);

        }
}
