package markup;

import java.util.List;

public class Strong extends RemakeText{
    public Strong(List<markup> list) {
        super(list, "__", "\\textbf{", "}", "<strong>", "</strong>");
    }
}
