package markup;

import java.util.List;

public class Strikeout extends RemakeText{
    public Strikeout(List<markup> list) {
        super(list, "~", "\\textst{", "}", "<s>", "</s>");
    }
}
