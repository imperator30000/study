package markup;

import java.util.List;

public class Heading extends RemakeText {
    public Heading(List<markup> list, String type) {
        super(list, "", "", "", "<" + type + ">", "</" + type + ">");
    }
}
