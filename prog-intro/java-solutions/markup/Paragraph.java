package markup;

import java.util.List;

public class Paragraph extends RemakeText {

    public Paragraph(List<markup> list) {
    	super(list, "", "", "",  "<p>", "</p>");
    }

    public static void main(String[] args) {
        Paragraph paragraph = new Paragraph(List.of(
                new Strong(List.of(
                        new Text("1"),
                        new Strikeout(List.of(
                                new Text("2"),
                                new Emphasis(List.of(
                                        new Text("3"),
                                        new Text("4")
                                )),
                                new Text("5")
                        )),
                        new Text("6")
                ))
        ));
        StringBuilder st = new StringBuilder();
        paragraph.toTex(st);
        System.out.println(st);
        st = new StringBuilder();
        paragraph.toMarkdown(st);
        System.out.println(st);
    }
}
