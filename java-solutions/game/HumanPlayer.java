package game;

import java.io.PrintStream;
import java.util.InputMismatchException;
import java.util.Scanner;

/**
 * @author Georgiy Korneev (kgeorgiy@kgeorgiy.info)
 */
public class HumanPlayer implements Player {
    private final PrintStream out;
    private final Scanner in;
    public int wins = 0;

    public HumanPlayer(final PrintStream out, final Scanner in) {
        this.out = out;
        this.in = in;
    }

    public HumanPlayer() {
        this(System.out, new Scanner(System.in));
    }

    @Override
    public Move move(final Position position, final Cell cell) {
        while (true) {
            out.println("Position");
            out.println(position);
            out.println(cell + "'s move");
            out.println("Enter row and column");
            try {
                int a = in.nextInt();
                int b = in.nextInt();
                in.nextLine();
                final Move move = new Move(a, b, cell);
                if (position.isValid(move)) {
                    return move;
                }
                out.println("Move " + move + " is invalid");
            }catch (InputMismatchException e){
                out.println("Move is invalid");
                in.nextLine();
            }

        }
    }

    @Override
    public void updateWins() {
        this.wins ++;
    }
    public int getWins(){
        return this.wins;
    }
}
