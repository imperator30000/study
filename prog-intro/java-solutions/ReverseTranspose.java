import java.io.IOException;
import java.util.Arrays;

public class ReverseTranspose {
    public static void main(String[] args) throws IOException {
        MySc sc = new MySc(System.in);
        String line;
        int[][] arr = new int[1][1];
        int maxH = 0;
        int count;
        int countLine = 0;
        while (sc.hasNext()) {
            MySc scInt;
            count = 0;
            line = sc.nextLine();
            if (line == null) {
                continue;
            }
            countLine += 1;
            scInt = new MySc(line);
            if (arr.length - 1 < countLine) {
                arr = Arrays.copyOf(arr, arr.length * 2);
            }
            arr[countLine] = new int[1];
            while (scInt.hasNextInt()) {
                if (arr[countLine].length - 1 < count + 1) {
                    arr[countLine] = Arrays.copyOf(arr[countLine], arr[countLine].length * 2);
                }
                arr[countLine][count + 1] = scInt.nextInt();
                count++;
            }
            if (maxH < count) {
                maxH = count;
            }
            arr[countLine][0] = count;
//            scInt.close();
        }
//        sc.close();
        for (int i = 1; i < maxH + 1; i++) {
            for (int g = 0; g <= countLine; g++) {
                if (arr[g][0] >= i) {
                    System.out.print(arr[g][i] + " ");
                }
            }
            System.out.println("");
        }
//        for (int i = 0; i < maxH; i++) {
//            for (int[] ints : arr) {
//                if (ints.length > i) {
//                    System.out.print(ints[i] + " ");
//                }
//            }
//            System.out.println("");
//        }
    }
}


