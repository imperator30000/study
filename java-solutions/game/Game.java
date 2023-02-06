package game;

/**
 * @author Georgiy Korneev (kgeorgiy@kgeorgiy.info)
 */
public class Game {
    private boolean log;
    private final Player player1, player2;
    private int wins = 0;




    public Game(final boolean log, final Player player1, final Player player2, final int wins) {
        this.log = log;
        this.player1 = player1;
        this.player2 = player2;
        this.wins = wins;
    }


    public int play(Board board) {
        while (true) {
            final int result1 = move(board, player1, 1);
            if (result1 != -1) {
                return result1;
            }
            final int result2 = move(board, player2, 2);
            if (result2 != -1) {
                return result2;
            }
        }
    }
    private int move(final Board board, final Player player, final int no) {
        final Move move = player.move(board.getPosition(), board.getCell());
        final Result result = board.makeMove(move);
        log("Player " + no + " move: " + move);
        log("Position:\n" + board);
        this.log = result == Result.WIN || result == Result.LOSE || result == Result.DRAW;
        if (result == Result.WIN) {
            log("Position:\n" + board);
            log("Player " + board.getCell() + " won");
            if (no == 1){
                player1.updateWins();
            }else {
                player2.updateWins();
            }
            log("            x's victories : " + player1.getWins() + "             0's victories : " + player2.getWins() + "           ");
            board.update();
        } else if (result == Result.LOSE) {
            log("Position:\n" + board);
            log("incorrect input\nPlayer " + board.getCell() + " lose");
            if (no == 2){
                player2.updateWins();
            }else {
                player1.updateWins();
            }
            log("            x's victories : " + player1.getWins() + "             0's victories : " + player2.getWins() + "           ");
            board.update();
        } else if (result == Result.DRAW) {
            log("Position:\n" + board);
            log("Draw");
            log("            x's victories : " + player1.getWins() + "             0's victories : " + player2.getWins() + "           ");
            board.update();
        }
        int ans = -1;
        if (player1.getWins() == wins){
            ans = 1;
            System.out.println("X won in tournament");
        }
        if (player2.getWins() == wins){
            ans = 2;
            System.out.println("0 won in tournament");
        }

        return ans;
    }

    private void log(final String message) {
        if (log) {
            System.out.println(message);
        }
    }
}
