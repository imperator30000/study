package expression.parser;

public enum TaskElementType {
    BRACKET_LEFT, BRACKET_RIGHT,
    ACTION_ADD, ACTION_SUBTRACT, ACTION_MULTIPLY, ACTION_DIVIDE,
    POW, LEFT_SHIFT, RIGHT_SHIFT,
    ACTION_UNARY_SUBTRACT,
    CONST, VARIABLE,
    ACTION_MIN,ACTION_MAX,ACTION_SET, ACTION_CLEAR, ACTION_COUNT,
    FUNCTION, VIRGULE,
    NONE, END
}