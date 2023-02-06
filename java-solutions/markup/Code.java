package markup;

import java.util.List;

public class Code extends RemakeText{
    public Code(List<markup> list){
        super(list, "`", "", "", "<code>", "</code>");
    }
}
