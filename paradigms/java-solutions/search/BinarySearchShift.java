package search;


public class BinarySearchShift {
    // -----------------------------------------------------------------------------|
    // ] 0 <= k < n - сдвиг массива - a[i] перемещается на a[i + k]                 |
    // ] a[] = a[0] ... a[n] (отсортирован по невозрастани ) если его сдвинуть, то  |
    // a`[k] := a[0] , a`[k + 1] := a[1] ... a`[k + i] = a[i] ... a`[n] := a[n - k] |
    // a`[0] := a[n - k + 1], a`[1] := a[n - k + 2] ... a`[k - 1] := a[n]           |
    // -----------------------------------------------------------------------------| -->
    // --> for i in 0 ... n - k : a`[k + i] = a[i] && for i in 0 ... k : a`[i] = a[n - k + 1 + i]
    // два цикла сдвигают массив на k
    // обратим внимание , что a`[k] = a[0] - максимальный элемент, a на отрезке 0 ... k - 1 и на отрезке k + 1 ... n последовательности невозрастают -->
    // --> необходимо найти индекс такой элемент где справа и слева элементы меньше или равны
    // Pred := args[i]: int && len(args) >= 1 && args.sort() && 0 <= i < len(args) && k >= 0 && k + i < len(args) && args[i + k] >= args[i + k + 1]
    // Post := out : k : 0 <= k < len(args) && (i - k + len(args)) % len(args)
    public static void main(String[] args) {
        // Pred
        int[] arr = new int[args.length];
        // int[] arr := new int[len(args)]
//        int c = 0;
        // I := arr == [0, ... , 0] && i = 0 ... len(arr)

        for (int i = 0; i < arr.length; i++) {
            arr[i] = Integer.parseInt(args[i]);
//            c += arr[i];
            // arr[i] = cast to int args[i]
        }
        if (args.length % 2 == 0){
            // Pred && args.length % 2 == 0
            System.out.println(findK(arr, 0, arr.length - 1));
        }else {
            // Pred && args.length % 2 != 0
            System.out.println(findKIter(arr));
        }

    }

    // Pred := a[i]: int && len(a) >= 1 && a.sort() :  {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]}
    // && 0 <= l < r < len(a)
    // Post := k : (0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0
    public static int findK(int[] a, int l, int r) {
        // Pred
        if (r - l <= 1) {
            // -----------------------------------------------------------------------------|
            //                                                                              |
            //                                    \______________________________\          |
            //                 Pred       &&       \ 0 <= l < r <= l + 1 < len(a) \         |-------|
            //                                      \______________________________\ <=> r == l + 1 |
            //                                                             |------------------------|
            // ------------------------------------------------------------| --> len([l,r == l + 1]) == 2
            // P2 := Pred && len(a[l:l+2]) == 2
            if (a[r] > a[l]) {
                // P2 && a[r] > a[l == r - 1]
                // 0 <= r < len(a) && a[r - 1] < a[r] <-> r == k
                return r;
            } else {
                // P2 && a[r == l + 1] <= a[l] --> a.sort() && k == 0
                return 0;
            }
        }
        // Pred && r - l > 1 --> a[i]: int && len(a) >= 1 && a.sort() :
        // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]} &&
        // && 0 <= l < l + 1 < r < len(a)
        int m = (l + r) / 2;
        // m := (l + r) / 2
        // ------------------------------------|
        // m == (l + r) / 2 < (r + r) / 2 == r |
        // m == (l + r) / 2 > (l + l) / 2 == l |
        // ------------------------------------| --> l < m < r
        // P1 := a[i]: int && len(a) >= 1 && a.sort() :
        // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]} &&
        // && 0 <= l < l + 1 < r < len(a) && l < m < r
        if (a[r] > a[m]) {
            // P1 && a[r] > a[m]
            // l' := m
            // r' := r
            // l < l' --> left border increased --> the search segment has decreased
            // a[i]: int && len(a) >= 1 && a.sort() :
            // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) &&
            // && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]}  && l < l' <= r' < len(a)
            return findK(a, m, r);
        } else if (a[l] < a[m]) {
            // P1 && a[r] <= a[m] && a[l] < a[m]
            // l' := l
            // r' := m
            // r > r' --> right border decreased --> the search segment has decreased
            // a[i]: int && len(a) >= 1 && a.sort() :
            // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) &&
            // && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]}  && l <= r < r' < len(a)
            return findK(a, l, m);
        }
        return 0;
    }
    // Pred := a.sort() :  {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]}
    // Post := k : (0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0
    public static int findKIter(int[] a) {
        // P0 := Pred
        int l = 0;
        int r = a.length - 1;
        while (r - l > 1) {
            // Pred && r - l > 1 --> a[i]: int && len(a) >= 1 && a.sort() :
            // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]} &&
            // && 0 <= l < l + 1 < r < len(a)
            int m = (l + r) / 2;
            // m := (l + r) / 2
            // ------------------------------------|
            // m == (l + r) / 2 < (r + r) / 2 == r |
            // m == (l + r) / 2 > (l + l) / 2 == l |
            // ------------------------------------| --> l < m < r
            // P1 := a[i]: int && len(a) >= 1 && a.sort() :
            // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]} &&
            // && 0 <= l < l + 1 < r < len(a) && l < m < r
            if (a[r] > a[m]) {
                // P1 && a[r] > a[m]
                // l' := m
                // r' := r
                // l < l' --> left border increased --> the search segment has decreased
                // a[i]: int && len(a) >= 1 && a.sort() :
                // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) &&
                // && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]}  && l < l' <= r' < len(a)
                l = m;
            } else if (a[l] < a[m]) {
                // P1 && a[r] <= a[m] && a[l] < a[m]
                // l' := l
                // r' := m
                // r > r' --> right border decreased --> the search segment has decreased
                // a[i]: int && len(a) >= 1 && a.sort() :
                // {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) &&
                // && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]}  && l` <= r < r' < len(a)
                r = m;
            } else {
                return 0;
            }
            // Q1 :=  a[i]: int && len(a) >= 1 && a.sort() :
            //        {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) &&
            //        && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]} && 0 <= l < r < len(a)
        }
        // Q0 := a[i]: int && len(a) >= 1 && a.sort() :
        //       {((0 <= k - 1 < k < len(a) && a[k - 1] < a[k]) || k == 0) &&
        //       && a[(i + k) % len(a)] >= a[(i + k + 1) % len(a)]} && 0 <= l < r < len(a) &&  r - l <= 1
        // -----------------------------------------------------------------------------|
        //                                                                              |
        //                                    \______________________________\          |
        //                 Q0         &&       \ 0 <= l < r <= l + 1 < len(a) \         |-------|
        //                                      \______________________________\ <=> r == l + 1 |
        //                                                             |------------------------|
        // ------------------------------------------------------------| --> len([l,r == l + 1]) == 2
        // P2 := Pred && len(a[l:l+2]) == 2
        if (a[r] > a[l]) {
            // P2 && a[r] > a[l == r - 1]
            // 0 <= r < len(a) && a[r - 1] < a[r] <-> r == k
            return r;
        } else {
            // P2 && a[r == l + 1] <= a[l] --> a.sort() && k == 0
            return 0;
        }
    }

}


