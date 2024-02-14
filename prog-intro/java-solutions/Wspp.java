import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

import static java.lang.Character.DASH_PUNCTUATION;
import static java.lang.Character.LOWERCASE_LETTER;

public class Wspp {

    static public MySc create(String name) throws IOException {
        return new MySc(new File(name));
    }

    static public FileWriter out(String name) throws IOException {
        return new FileWriter(name);
    }

    static public void appending(int g, LinkedHashMap<String, int[]> data, int counter, int start, String words) {
        if (data.containsKey(words.substring(start, g))) {
            System.out.println(words.substring(start, g));
            int[] a = data.get(words.substring(start, g));
            a[0]++;
            try {
                a[a[0]] = counter;
            } catch (IndexOutOfBoundsException ignored) {
                a = Arrays.copyOf(a, a.length * 2);
                a[a[0]] = counter;
            }
            data.put(words.substring(start, g), a);
        } else {
            System.out.println(words.substring(start, g));
            int[] a = new int[2];
            a[0] = 1;
            a[1] = counter;
            data.put(words.substring(start, g), a);
            System.out.println(data);
        }
    }

    static public void main(String[] args) {
        ArrayList<String> array = new ArrayList<>();
        LinkedHashMap<String, int[]> data = new LinkedHashMap();
        int[] arrayNum = new int[1];
        int start;
        String words;
        try {
            MySc sc = create(args[0]);
            try {
                FileWriter writer = out(args[1]);
                int counter = 0;
                while (sc.hasNext()) {
                    words = sc.nextLine().toLowerCase();
                    System.out.println(words);
                    start = -1;
                    for (int g = 0; g < words.length(); g++) {
                        if (DASH_PUNCTUATION == Character.getType(words.charAt(g)) || LOWERCASE_LETTER == Character.getType(words.charAt(g))
                                || words.charAt(g) == '\'') {
                            if (start == -1) {
                                start = g;
                            }
                        } else if (start != -1) {
                            counter++;
                            appending(g, data, counter, start, words);
                            start = -1;
                        }
                    }
                    if (start != -1) {
                        counter++;
                        appending(words.length(), data, counter, start, words);
                    }
                }
                for (Map.Entry<String, int[]> i : data.entrySet()) {
                    System.out.print(i.getKey());
                    writer.write(i.getKey());
                    for (int g = 0; i.getValue()[0] >= g; g++) {
                        System.out.print(" " + i.getValue()[g]);
                        writer.write(" " + i.getValue()[g]);
                    }
                    writer.write('\n');
                    System.out.println();
                }
                writer.close();
            } catch (IOException ignored) {

            } finally {
                sc.close();
            }
        } catch (IOException ignored) {
        }

    }

}
