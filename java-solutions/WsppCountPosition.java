import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

import static java.lang.Character.DASH_PUNCTUATION;
import static java.lang.Character.LOWERCASE_LETTER;

public class WsppCountPosition {


    public static MySc create(String name) throws IOException {
        return new MySc(new File(name));
    }

    public static FileWriter out(String name) throws IOException {
        return new FileWriter(name);
    }

    public static void appending(int g, Map<String, int[]> data, int counter, int start, String words, int counter_h) {
        ArrayList<String> b = new ArrayList<String>();
        //:note: too much gets
        int[] a = data.get(words.substring(start, g));
        if (a != null) {
            //System.out.println(words.substring(start, g));
            a[0]++;
            if (a.length > a[0] * 2) {
                a[a[0] * 2 - 1] = counter_h;
                a[a[0] * 2] = counter;
            } else {
                a = Arrays.copyOf(a, a.length * 2);
                a[a[0] * 2 - 1] = counter_h;
                a[a[0] * 2] = counter;
            }
            data.put(words.substring(start, g), a);
        } else {

            //System.out.println(words.substring(start, g));
            a = new int[3];
            a[0] = 1;
            a[1] = counter_h;
            a[2] = counter;
            data.put(words.substring(start, g), a);
            //System.out.println(data);
        }

    }

    public static void main(String[] args) {
        Map<String, int[]> data = new LinkedHashMap<>();
        HashMap<String, Integer> dataCount = new LinkedHashMap<>();
        int start;
        String words;
        try {
            MySc sc = create(args[0]);
            int counter;
            int counterH = 0;
            while (sc.hasNext()) {
                words = sc.nextLine().toLowerCase();
                counterH++;
                counter = 0;
                start = -1;
                for (int g = 0; g < words.length(); g++) {
                    if (DASH_PUNCTUATION == Character.getType(words.charAt(g)) || LOWERCASE_LETTER == Character.getType(words.charAt(g))
                            || words.charAt(g) == '\'') {
                        if (start == -1) {
                            start = g;
                        }
                    } else if (start != -1) {
                        counter++;
                        appending(g, data, counter, start, words, counterH);
                        start = -1;
                    }
                }
                if (start != -1) {
                    counter++;
                    appending(words.length(), data, counter, start, words, counterH);
                }

            }

            List<Map.Entry<String, int[]>> list = new ArrayList(data.entrySet());
            list.sort(new Comparator<Map.Entry<String, int[]>>() {
                @Override
                public int compare(Map.Entry<String, int[]> a, Map.Entry<String, int[]> b) {
                    return a.getValue()[0] - b.getValue()[0];
                }
            });
            int fin;
            try {
                FileWriter writer = out(args[1]);
                for (Map.Entry<String, int[]> i : list) {
                    for (fin = 0; fin < i.toString().length(); fin++) {
                        if (i.toString().charAt(fin) == '=') {
                            break;
                        }
                    }

                    System.out.print(i.getKey() + " " + i.getValue()[0]);
                    writer.write(i.getKey() + " " + i.getValue()[0]);
                    for (int g = 1; data.get(i.toString().substring(0, fin))[0] >= g; g++) {
                        System.out.print(" " + i.getValue()[g * 2 - 1] + ":" + i.getValue()[g * 2]);
                        writer.write(" " + i.getValue()[g * 2 - 1] + ":" + i.getValue()[g * 2]);
                    }
                    writer.write('\n');
                    System.out.println();
                }
                writer.close();
            } catch (IOException ignored) {
                sc.close();
            } finally {
                sc.close();
            }
        } catch (IOException e) {
            System.out.print(e.getMessage());
        }
    }
}

