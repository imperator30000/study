package expression.operand;

import expression.Const;
import expression.exceptions.*;

public class OperandIntDetected implements Operand<Integer> {
    @Override
    public Integer add(Integer a, Integer b) {
        CheckedAdd add = new CheckedAdd( new Const(a), new Const(b));
//        System.out.println(a);
//        System.out.println(b);
//
//        System.out.println(add.evaluate(0,0,0));
//        System.out.println("++++++++++++++++++++");
        return add.evaluate();
    }

    @Override
    public Integer subtract(Integer a, Integer b) {
        CheckedSubtract subtract = new CheckedSubtract(new Const(a), new Const(b));
//        System.out.println(a);
//        System.out.println(b);
//        System.out.println(a - b);
//
//        System.out.println(subtract.evaluate(0,0,0));
//        System.out.println("____________________");
        return subtract.evaluate();
    }

    @Override
    public Integer multiply(Integer a, Integer b) {
        CheckedMultiply multiply = new CheckedMultiply(new Const(a), new Const(b));
        return multiply.evaluate();
    }

    @Override
    public Integer divide(Integer a, Integer b) {
        CheckedDivide divide = new CheckedDivide(new Const(a), new Const(b));
        return divide.evaluate();
    }

    @Override
    public Integer unarySubtract(Integer a) {
        CheckedNegate negate = new CheckedNegate(new Const(a));
        return negate.evaluate();    }

    @Override
    public Integer cast(String a) {
        return Integer.parseInt(a);
    }

    @Override
    public Integer cast(int a) {
        return cast(String.valueOf(a));

    }

}
