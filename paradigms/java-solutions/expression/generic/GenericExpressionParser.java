package expression.generic;

import expression.exceptions.*;
import expression.generic.actions.*;
import expression.parser.TaskElement;
import expression.parser.TaskElementType;

import java.util.*;

public class GenericExpressionParser<T> implements GenericParser<T> {

    protected final expression.operand.Operand<T> operand;
    static int kur = -1;
    static Set<TaskElementType> BinaryOperations = Set.of(
            TaskElementType.ACTION_ADD,
            TaskElementType.ACTION_SUBTRACT,
            TaskElementType.ACTION_MULTIPLY,
            TaskElementType.ACTION_DIVIDE);


    static Map<String, TaskElementType> actions = new HashMap<>();

    static {
        actions.put("+", TaskElementType.ACTION_ADD);
        actions.put("-", TaskElementType.ACTION_SUBTRACT);
        actions.put("*", TaskElementType.ACTION_MULTIPLY);
        actions.put("/", TaskElementType.ACTION_DIVIDE);
        actions.put("(", TaskElementType.BRACKET_LEFT);
        actions.put(")", TaskElementType.BRACKET_RIGHT);
        actions.put("x", TaskElementType.VARIABLE);
        actions.put("y", TaskElementType.VARIABLE);
        actions.put("z", TaskElementType.VARIABLE);
    }

    public GenericExpressionParser(expression.operand.Operand<T> operand) {
        this.operand = operand;
    }


    public GenericTripleExpression<T> priority1(ArrayList<TaskElement> taskElements) {
        GenericTripleExpression<T> left = null;
        while (true) {
            kur++;
            if (kur >= taskElements.size()) {
                System.out.println(taskElements);
            }
            TaskElement taskElement = taskElements.get(kur);

            if (taskElement.type == TaskElementType.CONST) {
                return new Const<>(operand.cast(taskElement.value.toString()), operand);
            } else if (taskElement.type == TaskElementType.VARIABLE) {
                return new Variable<>(String.valueOf(taskElement.value), operand);
            } else if (taskElement.type == TaskElementType.ACTION_UNARY_SUBTRACT) {
                return new UnarySubtract<>(priority1(taskElements), operand);
            } else if (!BinaryOperations.contains(taskElement.type) && taskElement.type != TaskElementType.BRACKET_RIGHT) {
                if (taskElement.type == TaskElementType.BRACKET_LEFT) {
                    left = priority3(taskElements);
                }
                kur++;
                return left;


            }
        }

    }

    // generics! -> TaskElement<?>
    public GenericTripleExpression<T> priority2(ArrayList<TaskElement> taskElements) {
        GenericTripleExpression<T> left = priority1(taskElements);
        while (true) {
            kur++;
            TaskElement taskElement = taskElements.get(kur);
            if (taskElement.type == TaskElementType.ACTION_MULTIPLY) {
                left = new Multiply<>(left, priority1(taskElements), operand);
            } else if (taskElement.type == TaskElementType.ACTION_DIVIDE) {
                left = new Divide<>(left, priority1(taskElements), operand);
            } else if (BinaryOperations.contains(taskElement.type) || taskElement.type == TaskElementType.END
                    || taskElement.type == TaskElementType.BRACKET_RIGHT) {
                kur--;
                return left;
            }
        }
    }

    public GenericTripleExpression<T> priority3(ArrayList<TaskElement> taskElements) {
        GenericTripleExpression<T> left = priority2(taskElements);
        while (true) {
            kur++;
            TaskElement taskElement = taskElements.get(kur);
            if (taskElement.type == TaskElementType.ACTION_ADD) {
                left = new Add<>(left, priority2(taskElements), operand);
            } else if (taskElement.type == TaskElementType.ACTION_SUBTRACT) {
                left = new Subtract<>(left, priority2(taskElements), operand);
            } else if (BinaryOperations.contains(taskElement.type) || taskElement.type == TaskElementType.END
                    || taskElement.type == TaskElementType.BRACKET_RIGHT) {
                kur--;
                return left;
            }
        }
    }


    public static TaskElementType itIsUnarySubtract(List<TaskElement> taskElements, TaskElementType taskElementType) {
        if (taskElementType == TaskElementType.ACTION_SUBTRACT && (taskElements.size() - 1 < 0 ||
                taskElements.get(taskElements.size() - 1).type != TaskElementType.BRACKET_RIGHT &&
                        taskElements.get(taskElements.size() - 1).type != TaskElementType.VARIABLE &&
                        taskElements.get(taskElements.size() - 1).type != TaskElementType.CONST

        )) {
            return TaskElementType.ACTION_UNARY_SUBTRACT;
        }
        return taskElementType;
    }


    public static int iter(int i, String task, char l, char r, boolean searchVirgule) {
        int finish = i;
        int el;
        boolean wasVirgule = false;
        while (true) {
            el = task.charAt(finish);
            if ((el > r || el < l) && !(el == '.' && searchVirgule && !wasVirgule || !searchVirgule)) {
                finish--;
                break;
            }
            if (!wasVirgule) {
                wasVirgule = el == '.';
            }
            finish++;
            if (finish >= task.length()) {
                finish--;
                break;
            }
        }
        return finish;
    }

    public ArrayList<TaskElement> lexAnalysis(String task) {
        ArrayList<TaskElement> taskElements = new ArrayList<>();
        boolean wasSpace = false;
        for (int i = 0; i < task.length(); ) {
            char el = task.charAt(i);
            TaskElementType taskElementType = actions.getOrDefault(String.valueOf(el), TaskElementType.NONE);
            taskElementType = itIsUnarySubtract(taskElements, taskElementType);
            if (taskElementType == TaskElementType.NONE) {
                if (el <= '9' && el >= '0') {
                    taskElementType = TaskElementType.CONST;
                    int finish = iter(i, task, '0', '9', true);
                    if (taskElements.size() > 0 && taskElements.get(taskElements.size() - 1).type == TaskElementType.ACTION_UNARY_SUBTRACT && !wasSpace) {
                        taskElements.set(taskElements.size() - 1, new TaskElement(TaskElementType.CONST, operand.cast('-' + task.substring(i, finish + 1))));
                    } else {
                        T elem = operand.cast(task.substring(i, finish + 1));
                        taskElements.add(new TaskElement(taskElementType, elem));
                    }
                    i = finish;
                } else if (el >= 'a' && el <= 'z') {
                    int finish = iter(i, task, 'a', 'z', false);
                    taskElementType = actions.getOrDefault(task.substring(i, finish + 1), TaskElementType.NONE);
                    taskElements.add(new TaskElement(taskElementType, task.substring(i, finish + 1)));
                    i = finish;
                } else if (Character.isWhitespace(el)) {
                    wasSpace = true;
                }
            } else {
                wasSpace = false;
                taskElements.add(new TaskElement(taskElementType, el));
            }

            i++;
        }
        taskElements.add(new TaskElement(TaskElementType.END, '\n'));
        return taskElements;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        ExpressionParser e = new ExpressionParser();
//        e.parse("-2147483647 * -1");
        System.out.println(e.parse("-(2)"));
//        for (int i = 0; i < 11; i++) {
//            try {
//                System.out.println(e.parse("y *").evaluate(1046457733, -1830650320, 1598611754));
//
//            } catch (Exception E) {
//                System.out.println(E.getMessage());
//            }
//        }
    }

    @Override
    public GenericTripleExpression<T> parse(String expression) {
        kur = -1;
        ArrayList<TaskElement> list = lexAnalysis(expression);
        return priority3(list);
    }
}
