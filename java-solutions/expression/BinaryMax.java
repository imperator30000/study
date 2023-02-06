package expression;

public class BinaryMax extends BinaryAction{
    public BinaryMax(AllExpression operand1, AllExpression operand2) {
        super(operand1, operand2);
    }

    @Override
    protected int solve(int x, int y) {
        if (x < y){
            return y;
        }
        return x;    }

    @Override
    protected double solve(double x, double y) {
        if (x < y){
            return y;
        }
        return x;    }

    @Override
    protected String getActionChar() {
        return null;
    }
}
