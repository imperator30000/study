package expression;

import java.util.List;

public class Subtract extends BinaryAction{
    public Subtract(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    @Override
    protected int solve(int x, int y) {
        return x - y;
    }

    @Override
    protected double solve(double x, double y) {
        return x - y;
    }

    @Override
    protected String getActionChar() {
        return "-";
    }
}
