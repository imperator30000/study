package expression.generic.actions;

import expression.generic.GenericTripleExpression;
import expression.operand.Operand;
import expression.operand.OperandIntDetected;

import java.util.Objects;

public abstract class UnaryActions<T> implements GenericTripleExpression<T> {
    final GenericTripleExpression<T> el;
    final Operand<T> operand;
    public UnaryActions (GenericTripleExpression<T> el, Operand<T> operand){
        this.el = el;
        this.operand = operand;
    }
    @Override
    public T evaluate(int x, int y, int z) {
        return solve(this.el.evaluate(x, y, z));
    }

    protected abstract T solve(T x);

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
