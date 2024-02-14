package markup;

import java.util.List;

public class Emphasis extends RemakeText {
    public Emphasis(List<markup> list) {
        super(list, "*", "\\emph{", "}", "<em>", "</em>");
    }
}
