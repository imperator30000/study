import java.io.IOException;
import java.util.Arrays;

public class ReverseAbc {
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
            while (scInt.hasNextWord()) {
                if (arr[countLine].length - 1 < count + 1) {
                    arr[countLine] = Arrays.copyOf(arr[countLine], arr[countLine].length * 2);
                }
                arr[countLine][count + 1] = scInt.nextWord();
                count++;
            }
            if (maxH < count) {
                maxH = count;
            }
            arr[countLine][0] = count;
//            scInt.close();
        }
//        sc.close();
        for (int g = countLine; g > 0; g--) {
            for (int i = arr[g][0]; i >= 1; i--) {
                if (arr[g][i] < 0) {
                    System.out.print('-');
                    arr[g][i] *= -1;
                }
                if (arr[g][i] == 0) {
                    System.out.print("a");
                }
                int j = (int) Math.pow(10, (int) Math.log10(arr[g][i]));
                while (j != 0) {
                    System.out.print((char) (arr[g][i] / j + 97));
                    arr[g][i] %= j;
                    j /= 10;
                }
                System.out.print(" ");
            }
            System.out.println();
        }
    }
}


