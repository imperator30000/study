package expression.generic;

import expression.operand.*;

import java.util.Map;

public class GenericTabulator  implements Tabulator{
    private static final Map<String, Operand<?>> operands = Map.of("i", new OperandIntDetected(),
            "d", new OperandDouble(),
            "bi", new OperandBigInt(),
            "u", new OperandInt(),
            "f", new OperandFloat(),
            "s", new OperandShort());

    @Override
    public Object[][][] tabulate(String mode, String expression, int x1, int x2, int y1, int y2, int z1, int z2) throws Exception {

        return iterateTabulate(operands.get(mode), expression, x1, x2, y1, y2, z1, z2);
    }

    public <T> Object[][][] iterateTabulate(Operand<T> operand, String expression, int x1, int x2, int y1, int y2, int z1, int z2) {
        GenericExpressionParser<T> expressionParser = new GenericExpressionParser<T>(operand);
        GenericTripleExpression<T> expressionEx = expressionParser.parse(expression);
        Object[][][] ans = new Object[x2 - x1 + 1][y2 - y1 + 1][z2 - z1 + 1];
        for (int i = x1; i < x2  + 1; i++) {
            for (int j = y1; j < y2  + 1; j++) {
                for (int k = z1; k < z2  + 1; k++) {
                    try {
                        ans[i - x1][j - y1][k - z1] = expressionEx.evaluate(i, j, k);
                    } catch (RuntimeException e) {
                    }
                }
            }
        }
        return ans;
    }
}
