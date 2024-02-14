import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.util.Scanner;

import static java.lang.Character.DASH_PUNCTUATION;
import static java.lang.Character.LOWERCASE_LETTER;

public class WordStatInput {

    static public Scanner create(String name) throws FileNotFoundException {
        return new Scanner(new File(name));
    }

    static public FileWriter out(String name) throws IOException {
        return new FileWriter(name);
    }

    static public void main(String[] args) {
        ArrayList<String> array = new ArrayList<>();
        int[] arrayNum = new int[1];
        int start;
        String words;
        boolean append;
        try {
            Scanner sc = create(args[0]);
            try {
                FileWriter writer = out(args[1]);

                while (sc.hasNext()) {
                    words = sc.nextLine().toLowerCase();
                    start = -1;
                    for (int g = 0; g < words.length(); g++) {
                        if (DASH_PUNCTUATION == Character.getType(words.charAt(g)) || LOWERCASE_LETTER == Character.getType(words.charAt(g))
                                || words.charAt(g) == '\'') {
                            if (start == -1) {
                                start = g;
                            }
                        } else if (start != -1) {
                            append = true;
                            for (int i = 0; array.size() > i; i++) {
                                if (Objects.equals(array.get(i), words.substring(start, g))) {
                                    arrayNum[i]++;
                                    arrayNum = Arrays.copyOf(arrayNum, arrayNum.length + 1);
                                    append = false;
                                    break;
                                }
                            }
                            if (append) {
                                if (array.size() == arrayNum.length) {
                                    arrayNum = Arrays.copyOf(arrayNum, arrayNum.length * 2);
                                }
                                arrayNum[array.size()] = 1;
                                array.add(words.substring(start, g));
                            }
                            start = -1;
                        }
                    }
                    if (start != -1) {
                        append = true;

                        for (int i = 0; array.size() > i; i++) {
                            if (Objects.equals(array.get(i), words.substring(start))) {
                                arrayNum[i]++;
                                if (array.size() == arrayNum.length) {
                                    arrayNum = Arrays.copyOf(arrayNum, arrayNum.length * 2);
                                }
                                append = false;
                                break;
                            }
                        }
                        if (append) {
                            if (array.size() == arrayNum.length) {
                                arrayNum = Arrays.copyOf(arrayNum, arrayNum.length * 2);
                            }
                            arrayNum[array.size()] = 1;
                            array.add(words.substring(start));
//                            for (int i = array.size() - 2; i >= 0; i--) {
//                                if (array.get(i).compareTo(array.get(i + 1)) > 0){
//                                    String a = array.get(i);
//                                    int b = arrayNum[i];
//                                    array.set(i, array.get(i + 1));
//                                    array.set(i + 1, a);
//                                    arrayNum[i] = arrayNum[i + 1];
//                                    arrayNum[i + 1] = b;
////                                        array.get(i),array.get(i + 1) =array.get(i + 1), array.get(i);
//                                }else {
//                                    break;
//                                }
//                            }
                        }
                    }
                }
                for (int i = 0; array.size() > i; i++) {
                    writer.write(array.get(i) + " " + arrayNum[i] + '\n');
                    System.out.println(arrayNum[i] + " " + array.get(i));
                }
                writer.close();
            } catch (IOException ignored) {

            } finally {
                sc.close();
            }
        } catch (IOException ignored) {
        }

    }

    static public void sort(ArrayList<String> array, int[] arrayNum) {
        for (int i = 1; i < array.size(); i++) {
//            for (int j = 1; i < array.size(); i++)
        }
    }
}
