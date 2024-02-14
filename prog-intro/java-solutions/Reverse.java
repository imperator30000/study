import java.io.IOException;
import java.util.ArrayList;

public class Reverse {
    public static void main(String[] args) throws IOException {
        MySc sc = new MySc(System.in);
        String line = "";
        int indexstart = -1;
        ArrayList<int[]> arr = new ArrayList<>();
        int counter;
        while (sc.hasNext()) {

            counter = 0;
            line = sc.nextLine();
            if (line.isEmpty()) {
                arr.add(new int[0]);

                continue;
            }
//            System.out.println(line);
            arr.add(new int[line.length() + 1]);
            for (int i = 0; i < line.length(); i++) {
                if (!Character.isWhitespace(line.charAt(i))) {
                    if (indexstart == -1) {
                        indexstart = i;
                    }
                } else if (indexstart != -1) {
                    arr.get(arr.size() - 1)[counter] = Integer.parseInt(line.substring(indexstart, i));
                    indexstart = -1;
                    counter++;
                    arr.get(arr.size() - 1)[line.length()] += 1;
                }
            }
            if (indexstart != -1) {
                arr.get(arr.size() - 1)[counter] = Integer.parseInt(line.substring(indexstart));
                arr.get(arr.size() - 1)[line.length()] += 1;
                indexstart = -1;
            }
        }
//        if (line.isEmpty()) {
//            arr.add(new int[0]);
//        }

        sc.close();
        for (int i = arr.size() - 1; i >= 0; i--) {
//            System.out.println(Arrays.toString(arr.get(i)));
            if (arr.get(i).length > 0) {
                for (int j = arr.get(i)[arr.get(i).length - 1] - 1; j >= 0; j--) {
                    System.out.print(arr.get(i)[j] + " ");
                }
                System.out.println();
            } else {
                System.out.println();
            }

        }

    }

}