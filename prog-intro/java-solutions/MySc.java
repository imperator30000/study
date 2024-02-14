import java.io.*;
import java.util.Arrays;

public class MySc {
    static int SIZE = 32;
    private final char[] buffer = new char[SIZE];
    private final Reader reader;
    private int kur = 0;
    private boolean hasMinus = false;


    public static void main(String[] args) throws IOException {


        MySc sc = new MySc(System.in);

//        sc.read();
        while (sc.hasNext()) {
            System.out.println("0:                                                             " + sc.kur);
            System.out.println("out                                                        ::::" + sc.nextLine());
            System.out.println("1:                                                             " + sc.kur);

        }
    }

    public MySc(String txt) throws IOException {
        reader = new StringReader(txt);
        updateBuffer();
    }

    public MySc(File file) throws IOException {
        reader = new FileReader(file);
        updateBuffer();
    }


    public MySc(InputStream bufferedInputStream) throws IOException {
        reader = new InputStreamReader(bufferedInputStream);
        updateBuffer();
    }

    public void close() throws IOException {
        reader.close();
    }

    private boolean updateBuffer() throws IOException {
        kur = 0;
        Arrays.fill(buffer, '\u0000');
        //    char subBuffer = '\u0000';
        return reader.read(buffer) != -1;
//        }

    }

    public int next() {
        kur++;
        return buffer[kur - 1];
    }

    public boolean hasNext() throws IOException {
        skiper();
        if (kur >= SIZE) {
            return updateBuffer();
        }

        if (buffer[kur] != '\u0000') {
            return true;
        }
        if (reader.markSupported()) {
            reader.mark(1);
            int a = reader.read();
            reader.reset();
            return a != -1;
        }
        return false;


    }

    public boolean hasNextInt() throws IOException {
        boolean a = skiperInt();
        if (!a) {
            return false;
        }
        if (kur == SIZE) {
            if (updateBuffer()) {
                return hasNextInt();
            } else {
                return false;
            }
        }
        return true;
    }

    public boolean hasNextWord() throws IOException {

        boolean a = skiperWord();
        if (!a) {
            return false;
        }
        if (kur == SIZE) {
            if (updateBuffer()) {
                return hasNextWord();
            } else {
                return false;
            }
        }
        return true;
    }

    public int nextInt() throws IOException {
        StringBuilder out = new StringBuilder();
        if (hasMinus) {
            out.append('-');
            hasMinus = false;
        }
        char next;

        while (true) {
            if (kur == SIZE) {
                updateBuffer();
            }
            next = (char) next();
            if (Character.getType(next) == 9) {
                out.append(next);
            } else {
                break;
            }
        }

        return Integer.parseInt(String.valueOf(out));
    }

    public int nextWord() throws IOException {
        StringBuilder out = new StringBuilder();
        if (hasMinus) {
            out.append('-');
            hasMinus = false;
        }
        char next;

        while (true) {
            if (kur == SIZE) {
                updateBuffer();
            }
            next = (char) next();
            if (Character.getType(next) == 2) {
                out.append((byte) next - 97);
            } else {
                break;
            }
        }

        return Integer.parseInt(String.valueOf(out));
    }

    private void skiper() {
//        System.out.println(buffer);
        char n;
        while (kur < SIZE) {
            n = (char) next();
            if (n != (int) '\u0000' && (n != '\n' || System.lineSeparator().getBytes().length == 1)) {
                kur--;
                break;
            }
        }
    }

    private boolean skiperInt() throws IOException {
        char a;
        while (kur < SIZE) {
            a = (char) next();
            if (Character.getType(a) == 15) {
                return false;
            }
            if (a == '-') {
                hasMinus = true;
            } else if (Character.getType(a) == 9) {
                kur--;
                break;
            } else {
                hasMinus = false;
            }
        }
        return true;
    }

    private boolean skiperWord() {
        char a;
        while (kur < SIZE) {

            a = (char) next();
            if (Character.getType(a) == 15) {
                return false;
            }
            if (a == '-') {
                hasMinus = true;
            } else if (Character.getType(a) == 2) {
                kur--;
                break;
            } else {
                hasMinus = false;
            }
        }
        return true;
    }

    public String nextLine() throws IOException {
        StringBuilder out = new StringBuilder();
        char next;
        while (true) {
            next = (char) next();
            if (!hasNext()) {
                return String.valueOf(out);
            }
            if (Character.getType(next) != 15 || next == '\t') {
                out.append(next);
            } else {

                return String.valueOf(out);
            }

        }

    }
}