package markup;

import java.util.List;

public class Underline extends RemakeText{
    public Underline(List<markup> list){
        super(list, "++", "", "", "<u>", "</u>");
    }
}
