package expression.generic.actions;

import expression.generic.GenericTripleExpression;
import expression.operand.Operand;
import expression.operand.OperandIntDetected;

import java.util.Arrays;
import java.util.Objects;


public abstract class BinaryAction<T> implements GenericTripleExpression<T> {
    final GenericTripleExpression<T>[] list;
    final Operand<T> operand;

    public BinaryAction(GenericTripleExpression<T> operand1, GenericTripleExpression<T> operand2, Operand<T> operand) {

        this.operand = operand;
        list = new GenericTripleExpression[]{operand1, operand2};
    }



    @Override
    public T evaluate(int x, int y, int z) {
        return solve(this.list[0].evaluate(x, y, z), this.list[1].evaluate(x, y, z));
    }

    @Override
    public String toString() {
        return '(' +
                list[0].toString() +
                ' ' +
                this.getActionChar() +
                ' ' +
                list[1].toString() +
                ')';
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null || obj.getClass() != this.getClass()) {
            return false;
        }
        BinaryAction<T> el = (BinaryAction<T>) obj;
        return this.list[0].equals(el.list[0]) && this.list[1].equals(el.list[1]);

    }

    @Override
    public int hashCode() {
        return Objects.hash(Arrays.hashCode(this.list), this.getClass());
    }

    protected abstract T solve(T x, T y);

    protected abstract String getActionChar();


}
