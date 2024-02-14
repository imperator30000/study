package search;


public class BinarySearch {
    // Pred := args[i]: int && len(args) >= 1 && args.sort() && i < 0 && args[i] >= args[i + 1] && a[i'] <= x
    // Post := out : R: a[R] <= x && (R == 0 || a[R - 1] > x) && a.sort() && a[i] >= a[i + 1]
    public static void main(String[] args) {
        // Pred
        int x = Integer.parseInt(args[0]);
        // int x := cast to int args[0]
        int[] arr = new int[args.length - 1];
        // int[] arr := new int[len(args) - 1]
        // I := arr == [0, ... , 0] && i = 0 ... len(arr)
        for (int i = 0; i < arr.length; i++) {
            arr[i] = Integer.parseInt(args[i + 1]);
            // arr[i] = cast to int args[i + 1]
        }
        // arr == args[1:]
        // -------------------------------------------|
        // Pred && arr == args[1:] && arr[i]: int --> |-------------------|
        // --> arr.sort() && arr[i] >= arr[i + 1] && arr[l:r + 2][j] <= x |
        // int[] a := arr |-----------------------------------------------|
        // ---------------| --> a.sort() && a[i] >= a[i + 1] && a[l:r + 2][j] <= x
        // P1 := a.sort() && a[i] >= a[i + 1] && a[l:r + 2][j] <= x
        int ansIter = iterativeBinarySearch(x, arr);
        // int ansIter  = R
        // Q1 := a[ansIter] <= x && (ansIter == 0 || a[ansIter - 1] > x) && a.sort() && a[i] >= a[i + 1]
        // -----------------------------|
        // a.sort() && a[i] >= a[i + 1] |
        // int l := 0 |-----------------|
        // int r := len(a) - 1 |
        // --------------------| --> a.sort() && a[i] >= a[i + 1] && 0 <= l <= r + 1 =< len(a) && a[l:r + 2][j] <= x
        // P2 := a.sort() && a[i] >= a[i + 1] && 0 <= l <= r + 1 =< len(a) && a[l:r + 2][j] <= x
        int ansRec = RecursiveBinarySearch(x, arr, 0, arr.length - 1);
        // int ansRec := R
        // Q2 := a[ansRec] <= x && (ansRec == 0 || a[ansRec - 1] > x) && a.sort() && a[i] >= a[i + 1]
        System.out.println(ansIter);
        // out: ansIter && Q1
//        System.out.println(ansRec);
        // out: ansRec && Q2
    }

    // Pred := a.sort() && a[i] >= a[i + 1] && 0 <= l <= r + 1 =< len(a) && a[l:r + 2][j] <= x
    // Post := R: a[R] <= x && (R == 0 || a[R - 1] > x) && a.sort() && a[i] >= a[i + 1]
    public static int RecursiveBinarySearch(int x, int[] a, int l, int r) {
        // Pred
        if (l >= r + 1) {
            //----------------------------------------------------------------------------------------------------------|
            // Pred && l >= r + 1 ~ a.sort() && a[i] >= a[i + 1] && 0 <= l == r + 1 =< len(a) && a[l:r + 2][j] <= x --> |
            // --> len(a[l:l + 1][j]) == 1 && a[l:r + 2][j] <= x --> a[l] <= x |----------------------------------------|
            // if l > 0 --> l ^ --> l - 1 > x |--------------------------------|
            //--------------------------------| --> a[l] <= x && (l == 0 || a[l - 1] > x) && a.sort() && a[i] >= a[i + 1]
            return l;
        }
        // Pred && l < r + 1
        int m = (l + r) / 2;
        // -----------------------------------------------|
        // m = (l + r) / 2 > (l + l - 1) / 2 = l - 0.5 && |
        // && m = (l + r) / 2 < (r + r + 1) / 2 = r + 0.5 |
        // -----------------------------------------------| --> l =< m <= r
        // P := Pred && l < r + 1 && l =< m <= r
        if (x >= a[m]) {
            // P && x >= a[m]
            // l' = l
            // r' = m - 1
            // l' - 1 <= m - 1 --> l' <= r' + 1
            // P && x >= a[m] && l' <= r' + 1 --> a.sort() && a[i] >= a[i + 1] && 0 <= l' <= m <= r' + 1 < len(a) &&
            // && a[l':r' + 2][m] <= x
            return RecursiveBinarySearch(x, a, l, m - 1);
        } else {
            // P && x < a[m]
            // l' = m + 1
            // r' = r
            // m + 1 <= r' + 1 --> l' <= r' + 1
            // P && x < a[m] && l' <= r' + 1 --> a.sort() && a[i] >= a[i + 1] && 0 <= m < l' <= r' + 1 =< len(a)
            // && a[l':r' + 2][j] <= x
            // ex: a.sort() && a[i'] >= a[i' + 1] --> min(a) == a[r] --> a[l':r' + 2][r - l] <= x
            return RecursiveBinarySearch(x, a, m + 1, r);
        }
    }

    // Pred := a.sort() && a[i] >= a[i + 1] && a[l:r + 2][j] <= x
    // Post := a[R] <= x && (R == 0 || a[R - 1] > x) && a.sort() && a[i] >= a[i + 1]
    public static int iterativeBinarySearch(int x, int[] a) {
        // Pred
        int l = 0;
        int r = a.length - 1;
        while (l < r + 1) {
            // Pred && 0 <= l < r + 1 <= len(a)
            int m = (l + r) / 2;
            // -----------------------------------------------|
            // m = (l + r) / 2 > (l + l - 1) / 2 = l - 0.5 && |
            // && m = (l + r) / 2 < (r + r + 1) / 2 = r + 0.5 |
            // -----------------------------------------------| --> l =< m <= r
            // P := Pred && l < r + 1 && l =< m <= r
            if (x >= a[m]) {
                // P && x >= a[m]
                // l' = l
                r = m - 1;
                // r' = m - 1  (v)
                // l' - 1 <= m - 1 --> l' <= r' + 1
                // P && x >= a[m] && l' <= r' + 1 --> a.sort() && a[i] >= a[i + 1] && 0 <= l' <= m <= r' + 1 < len(a) &&
                // && a[l':r' + 2][j] <= x
            } else {
                // P && x < a[m]
                l = m + 1;
                // l' = m + 1  (^)
                // r' = r
                // m + 1 <= r' + 1 --> l' <= r' + 1
                // P && x < a[m] && l' <= r' + 1 --> a.sort() && a[i] >= a[i + 1] && 0 <= m < l' <= r' + 1 =< len(a)
                // && a[l':r' + 2][j] <= x
                // |ex| --- a.sort() && a[i'] >= a[i' + 1] --> min(a) == a[r] --> a[l':r' + 2][r - l] <= x --- |ex|
            }
            // Q := a.sort() && a[i] >= a[i + 1] && 0 <= l' <= r' + 1 <= len(a) && a[l':r' + 2][j] <= x
        }
        // l ^ && r v --> while !~ inf
        //-------------------------------------------------------------------------------------------------------------|
        // Q && l >= r + 1 --> a.sort() && a[i] >= a[i + 1] && 0 <= l' == r' + 1 <= len(a) && a[l':r' + 2][j] <= x --> |
        // --> len(a[l:l + 1][j]) == 1 && a[l:r + 2][j] <= x --> a[l] <= x |-------------------------------------------|
        // if l > 0 --> l ^ --> l - 1 > x |--------------------------------|
        //--------------------------------| --> a[l] <= x && (l == 0 || a[l - 1] > x) && a.sort() && a[i] >= a[i + 1]
        return l;
    }

}