package md2html;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.Stack;
import markup.Code;
import markup.Emphasis;
import markup.Heading;
import markup.Paragraph;
import markup.Strikeout;
import markup.Strong;
import markup.SuperText;
import markup.Text;
import markup.Underline;
import markup.markup;

public class Md2Html {
    static int finish = 0;
    static Set<String> specialCharacters = Set.of("*", "**", "--", "__", "_", "++", "`");
    // :NOTE: тоже надо бы в Set
    static String escapedCharacters = "+_*";
    static Stack<String> stack = new Stack<>();


    public static markup get(String type, List<markup> list) {
        if (type.equals("*") || type.equals("_")) {
            return new Emphasis(list);
        }
        if (type.equals("**") || type.equals("__")) {
            return new Strong(list);
        }
        if (type.equals("--")) {
            return new Strikeout(list);
        }
        if (type.equals("`")) {
            return new Code(list);
        }
        if (type.equals("++")) {
            return new Underline(list);
        }
        if (type.equals("st")) {
            return new SuperText(list);
        }
        if (type.equals("p")) {
            return new Paragraph(list);
        }
        if (type.charAt(0) == 'h') {
            return new Heading(list, type);

        }
        return new Text("");
    }


    public static markup parser(String type, String text) {
        ArrayList<markup> list = new ArrayList<>();
        int start = finish;
        while (finish < text.length()) {

            // Первый случай: finish и (опционально) finish + 1 находится маркдаун тег
            // Второй случай: символ на позиции finish экранирован - ты просто пропускаешь \
            // Третий случай: все остальное

            String symbols;
            if (finish + 1 == text.length()) {
                symbols = text.substring(finish, finish + 1);
            } else {
                symbols = text.substring(finish, finish + 2);
            }

            if (specialCharacters.contains(String.valueOf(symbols.charAt(0))) || specialCharacters.contains(symbols)) {
                int lenSymbols;
                if (specialCharacters.contains(symbols)) { //String.valueOf(symbols.charAt(1)))
                    lenSymbols = 2;
                } else {
                    lenSymbols = 1;
                }
                if (finish - start > 0) {
                    list.add(new Text(text.substring(start, finish)));
                }
                symbols = text.substring(finish, finish + lenSymbols);
                if (!stack.isEmpty() && stack.lastElement().equals(symbols)) {
                    stack.pop();
                    finish += lenSymbols;
                    return get(symbols, list);
                }
                stack.push(symbols);
                finish += lenSymbols;
                list.add(parser(symbols, text));
                start = finish;
            } else if (symbols.charAt(0) == '\\' && escapedCharacters.contains(String.valueOf(symbols.charAt(1)))) {
                list.add(new Text(text.substring(start, finish)));
                start = finish + 1;
                finish += 2;
            } else {
                finish++;
            }
        }
        if (finish - start > -1) {
            list.add(new Text(text.substring(start, finish)));
        }
        if (!stack.isEmpty()) {
            list.add(0, new Text(stack.pop()));
            return get("st", list);
        }

        return get(type, list);
    }

    public static String paragraphOrHeading(String text) {
        for (int i = 0; i < text.length(); i++) {
            if (text.charAt(i) != '#') {
                if (i > 0 && text.charAt(i) == ' ') {
                    StringBuilder h = new StringBuilder("h");
                    finish = i + 1;
                    h.append(i);
                    return h.toString();
                }
                break;
            }
        }
        return "p";
    }

    public static void main(String[] args) {
        ArrayList<markup> listParagraphAndHeading = new ArrayList<>();
        try {
//            args = new String[]{"in", "out.txt"};
            BufferedReader in = new BufferedReader(new FileReader(args[0]));
            String next = in.readLine();
            StringBuilder text = new StringBuilder();
            String tokenTypeParagraphHeading = "";
            while (next != null) {
                if (!next.isEmpty()) {
                    if (text.isEmpty()) {
                        finish = 0;
                        tokenTypeParagraphHeading = paragraphOrHeading(next);
                    }
                    System.out.println(next);
                    text.append(next);
                    text.append("\n");

                } else if (!text.isEmpty()) {
                    text.deleteCharAt(text.length() - 1);
                    listParagraphAndHeading.add(parser(tokenTypeParagraphHeading, text.toString()));
                    text = new StringBuilder();
                }

                next = in.readLine();
            }
            if (!text.isEmpty()) {
                text.deleteCharAt(text.length() - 1);
                listParagraphAndHeading.add(parser(tokenTypeParagraphHeading, text.toString()));
            }
            in.close();

            try {
                Writer wr = new FileWriter(args[1]);
                for (markup m : listParagraphAndHeading) {
                    StringBuilder srh = new StringBuilder();
                    m.toHTML(srh);
                    wr.write(srh.toString());
                    wr.write('\n');
                }
                wr.close();

            } catch (IOException e) {
                in.close();
                System.out.println(e.getMessage());
            }

        } catch (IOException e) {
            System.out.println(e.getMessage());
        }
    }
}
