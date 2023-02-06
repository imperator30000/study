package expression;

import java.util.Objects;

public abstract class UnaryActions implements AllExpression{
    AllExpression el;
    public UnaryActions (AllExpression el){
        this.el = el;
    }
    @Override
    public int evaluate(int x) {
        return solve(this.el.evaluate(x));
    }
    @Override
    public double evaluate(double x) {
        return 0;
    }
    @Override
    public int evaluate(int x, int y, int z) {
        return solve(this.el.evaluate(x, y, z));
    }
    protected abstract int solve(int x);

    @Override
    public String toString() {
        return "(" + el.toString() + ")";
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || obj.getClass() != this.getClass()) {
            return false;
        }
        return this.el.equals(((UnaryActions) obj).el) ;

    }
    @Override
    public int hashCode() {
        return Objects.hash(this.el, this.getClass());

    }public String toMiniString(){
        return "";
    }

}
