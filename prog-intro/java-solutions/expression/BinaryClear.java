package expression;

public class BinaryClear extends BinaryAction{
    public BinaryClear(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    @Override
    protected int solve(int x, int y) {
        return x & (~(1<<y));
    }

    @Override
    protected double solve(double x, double y) {
        return 0;
    }

    @Override
    protected String getActionChar() {
        return "clear";
    }
}
