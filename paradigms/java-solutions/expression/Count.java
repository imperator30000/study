package expression;

import expression.operand.Operand;

public class Count extends UnaryActions{




    public Count(AllExpression el) {
        super(el);
    }



    @Override
    protected int solve(int x) {
        return Integer.bitCount(x);
    }

    @Override
    public String toString() {
        return "count" + super.toString();
    }
    @Override
    public int hashCode() {
        return this.el.hashCode() * 31 + "count".hashCode();
    }

    @Override
    public int evaluate(int x, int y, int z) {
        return 0;
    }
}
