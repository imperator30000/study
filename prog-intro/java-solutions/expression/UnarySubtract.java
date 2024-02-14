package expression;

public class UnarySubtract extends UnaryActions{
    public UnarySubtract(AllExpression el) {
        super(el);
    }

    @Override
    protected int solve(int x) {
        return -x;
    }

    @Override
    public int hashCode() {
        return this.el.hashCode() * 31 + "-".hashCode();
    }

    @Override
    public String toString() {
        return "-" + super.toString();
    }
}
