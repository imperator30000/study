package game;

import java.util.Arrays;
import java.util.Map;

import static java.lang.Math.log10;
import static java.lang.Math.max;

/**
 * @author Georgiy Korneev (kgeorgiy@kgeorgiy.info)
 */
public class MNKBoard implements Board, Position {
    private static final Map<Cell, Character> SYMBOLS = Map.of(
            Cell.X, 'X',
            Cell.O, 'O',
            Cell.E, '.'
    );

    private final Cell[][] cells;
    private Cell turn;
    private Cell startTurn;
    private final int m;
    private final int n;
    private final int k;
    private int mN;

    public MNKBoard(int m, int n, int k) {
        this.n = n;
        this.m = m;
        this.k = k;
        this.mN = m * n;
        this.cells = new Cell[m][n];
        for (Cell[] row : cells) {
            Arrays.fill(row, Cell.E);
        }
        this.startTurn = Cell.X;
        this.turn= Cell.X;
    }
    @Override
    public Position getPosition() {
        return this;
    }

    @Override
    public Cell getCell() {
        return turn;
    }

    @Override
    public Result makeMove(final Move move) {
        if (!isValid(move)) {
            return Result.LOSE;
        }
        cells[move.getRow()][move.getColumn()] = turn;
        this.mN--;
        boolean[] directions = new boolean[]{false, false, false, false, false, false, false, false};
        //012
        //3+4
        //567
        directions[0] = move.getRow() - 1 >= 0 && move.getColumn() - 1 >= 0 && cells[move.getRow() - 1][move.getColumn() - 1] == turn;
        directions[1] = move.getRow() - 1 >= 0 && cells[move.getRow() - 1][move.getColumn()] == turn;
        directions[2] = move.getRow() - 1 >= 0 && move.getColumn() + 1 < this.m && cells[move.getRow() - 1][move.getColumn() + 1] == turn;
        directions[3] = move.getColumn() - 1 >= 0 && cells[move.getRow()][move.getColumn() - 1] == turn;
        directions[4] = move.getColumn() + 1 < this.m && cells[move.getRow()][move.getColumn() + 1] == turn;
        directions[5] = move.getRow() + 1 < this.m && move.getColumn() - 1 >= 0 && cells[move.getRow() + 1][move.getColumn() - 1] == turn;
        directions[6] = move.getRow() + 1 < this.m && cells[move.getRow() + 1][move.getColumn()] == turn;
        directions[7] = move.getRow() + 1 < this.m && move.getColumn() + 1 < this.m && cells[move.getRow() + 1][move.getColumn() + 1] == turn;
        int[] countDirections = new int[]{1, 1, 1, 1};
        // 0     /
        // 1    \
        // 2    |
        // 3    --
        int maxLen = 0;
        for (int i = 1; i < this.k; i++) {
            if (directions[0] && move.getRow() - i >= 0 && move.getColumn() - i >= 0) {
                if (cells[move.getRow() - i][move.getColumn() - i] != turn) {
                    directions[0] = false;
                } else {
                    countDirections[0]++;
                }
            }
            if (directions[7] && move.getRow() + i < this.m && move.getColumn() + i < this.n) {
                if (cells[move.getRow() + i][move.getColumn() + i] != turn) {
                    directions[7] = false;

                } else {
                    countDirections[0]++;
                }
            }
            if (directions[2] && move.getRow() - i >= 0 && move.getColumn() + i < this.n) {
                if (cells[move.getRow() - i][move.getColumn() + i] != turn) {
                    directions[2] = false;
                } else {
                    countDirections[1]++;
                }
            }
            if (directions[5] && move.getColumn() - i >= 0 && move.getRow() + i < this.m) {
                if (cells[move.getRow() + i][move.getColumn() - i] != turn) {
                    directions[5] = false;
                } else {
                    countDirections[1]++;
                }
            }
            if (directions[1] && move.getRow() - i >= 0) {
                if (cells[move.getRow() - i][move.getColumn()] != turn) {
                    directions[1] = false;
                } else {
                    countDirections[2]++;

                }
            }
            if (directions[6] && move.getRow() + i < this.m) {
                if (cells[move.getRow() + i][move.getColumn()] != turn) {
                    directions[6] = false;

                } else {
                    countDirections[2]++;
                }
            }
            if (directions[3] && move.getColumn() - i >= 0) {
                if (cells[move.getRow()][move.getColumn() - i] != turn) {
                    directions[3] = false;
                } else {
                    countDirections[3]++;

                }
            }
            if (directions[4] && move.getColumn() + i < this.n) {
                if (cells[move.getRow()][move.getColumn() + i] != turn) {
                    directions[4] = false;
                } else {
                    countDirections[3]++;

                }
            }
            for (int g = 0; g < 4; g++) {
                if (maxLen < countDirections[g]) {
                    maxLen = countDirections[g];
                }
                if (countDirections[g] == this.k) {

                    return Result.WIN;
                }
            }
        }
        if (this.mN == 0) {
            return Result.DRAW;
        }
        if (maxLen < 4){
            turn = turn == Cell.X ? Cell.O : Cell.X;
        }


        return Result.UNKNOWN;
    }

    @Override
    public void update() {
        for (int i = 0; i<m; i++){
            for (int j = 0; j<n; j++){
                this.cells[i][j] = Cell.E;
            }
        }
        this.startTurn = this.startTurn == Cell.X ? Cell.O : Cell.X;
        this.turn = this.startTurn;
        this.mN = this.m * this.n;
    }

    @Override
    public boolean isValid(final Move move) {
        return 0 <= move.getRow() && move.getRow() < this.m
                && 0 <= move.getColumn() && move.getColumn() < this.n
                && cells[move.getRow()][move.getColumn()] == Cell.E
                && turn == getCell();
    }

    @Override
    public Cell getCell(final int r, final int c) {
        return cells[r][c];
    }

    @Override
    public String toString() {
        int koef = (int) log10(m);
        final StringBuilder sb = new StringBuilder(" ".repeat(koef + 2));
        for (int i = 0; i < n; i++) {
            sb.append(i);
            sb.append(" ");
        }
        int k1 = 10;
        for (int r = 0; r < this.m; r++) {
            if (r == k1){
                koef -= 1;
            }
            sb.append("\n");
            sb.append(r);
            sb.append(" ".repeat(koef));
            sb.append("|");
            int ck = 1;
            int k = 10;
            for (int c = 0; c < this.n; c++) {
                if (c == k){
                    k *= k;
                    ck ++;
                }
                sb.append(SYMBOLS.get(cells[r][c]));
                sb.append(" ".repeat( ck));

            }
        }
        return sb.toString();
    }
}
