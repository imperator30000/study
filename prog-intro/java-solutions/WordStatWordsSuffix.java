
import java.io.*;
import java.util.*;

import static java.lang.Character.DASH_PUNCTUATION;
import static java.lang.Character.LOWERCASE_LETTER;

public class WordStatWordsSuffix {

    static public Scanner create(String name) throws FileNotFoundException {
        return new Scanner(new File(name));
    }

    static public FileWriter out(String name) throws IOException {
        return new FileWriter(name);
    }

    static public void main(String[] args) {
        try {
            ArrayList<String> array = new ArrayList<>();
            int[] arrayNum = new int[1];
            int start;
            String words;
            boolean append;
            try (Scanner sc = create(args[0]); FileWriter writer = out(args[1])) {
                while (sc.hasNextLine()) {
                    words = sc.nextLine().toLowerCase();
                    start = -1;

                    for (int g = 0; g < words.length(); g++) {
                        if (DASH_PUNCTUATION == Character.getType(words.charAt(g)) || LOWERCASE_LETTER == Character.getType(words.charAt(g))
                                || words.charAt(g) == '\'') {
                            if (start == -1) {
                                start = g;
                            }
                        } else if (start != -1) {
                            if (g - start > 3){
                                start = g - 3;
                            }
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
                        if (words.length() - start > 3){
                            start = words.length() - 3;
                        }
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

                        }
                    }
                }
                sort(array, arrayNum);
                for (int i = 0; array.size() > i; i++) {
                    writer.write(array.get(i) + " " + arrayNum[i] + '\n');
                    System.out.println(arrayNum[i] + " " + array.get(i));
                }
            }
        } catch (IOException ignored) {
        }
    }static private void swap(ArrayList<String> array, int[] arrayNum, int ind1, int ind2) {
        int tmp = arrayNum[ind1];
        arrayNum[ind1] = arrayNum[ind2];
        arrayNum[ind2] = tmp;
        String tmp1 = array.get(ind1);
        array.set(ind1, array.get(ind2));
        array.set(ind2, tmp1);
    }
    public static void sort(ArrayList<String> array,int[] arrayNum){
        for (int left = 0; left < array.size(); left++) {
            int minInd = left;
            for (int i = left; i < array.size(); i++) {
                if (array.get(i).compareTo(array.get(minInd)) < 0) {
                    minInd = i;
                }
            }
            swap(array, arrayNum, left, minInd);
        }
    }
}

