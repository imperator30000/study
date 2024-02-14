(defn all-numbers? [v]
  (every? number? v))
(defn equal-size? [m1 m2]
  (and (= (count m1) (count m2)) (= (count (first m1)) (count (first m2)))))
(defn isVector [v] (and (vector? v) (all-numbers? v)))
(defn isMatrix [m] (and (every? vector? m) (apply =
                                                  (map count m))))

(defn operation_v [fun] (fn [v1 v2] {:pre  [(isVector v1)
                                            (isVector v2)
                                            (= (count v1) (count v2))]
                                     :post [(isVector %) (= (count v1) (count %))]} (mapv fun v1 v2)))
(def v+ (operation_v +))
(def v- (operation_v -))
(def v* (operation_v *))
(def vd (operation_v /))


(defn scalar [v1 v2] {:pre  [(isVector v1)
                             (isVector v2)
                             (= (count v1) (count v2))]
                      :post [(number? %)]}
  (reduce + (v* v1 v2)))
(defn v*s [v s] {:pre  [(isVector v)
                        (number? s)]
                 :post [(isVector %)]} (mapv #(* s %) v))
(defn operation_m [fun] (fn [m1 m2] {:pre  [(isMatrix m1)
                                            (isMatrix m2)
                                            (equal-size? m1 m2)]
                                     :post [(isMatrix %)
                                            (equal-size? m1 %)]} (mapv #(fun %1 %2) m1 m2)))
(def m+ (operation_m v+))
(def m- (operation_m v-))
(def m* (operation_m v*))
(def md (operation_m vd))
(defn transpose [m] {:pre  [(isMatrix m)]
                     :post [(isMatrix %)
                            (= (count (first m)) (count %))
                            (= (count (first %)) (count m))
                            ]} (apply mapv vector m))

(defn m*s [m s] {:pre  [(isMatrix m)
                        (number? s)]
                 :port [(isMatrix %)
                        (equal-size? % m)]} (mapv #(v*s % s) m))
(defn m*v [m v] {:pre  [(isMatrix m)
                        (isVector v)]
                 :post [(= (count %) (count m))
                        (isVector %)]} (mapv #(scalar % v) m))
(defn m*m [m1 m2] {:pre  [(isMatrix m1)
                          (isMatrix m2)
                          (= (count (first m1)) (count m2))]
                   :post [(isMatrix %)
                          (= (count %) (count m1))
                          (= (count (first m2)) (count (first %)))
                          ]} (let [m2-t (transpose m2)]
                               (mapv (fn [row-m1]
                                       (mapv #(scalar %1 %2) (repeat row-m1) m2-t))
                                     m1)))
(defn vect [v1 v2] {:pre  [(isVector v1)
                           (isVector v2)
                           (= (count v1) 3)
                           (= (count v2) 3)
                           ]
                    :post [(isVector %)
                           (= (count %) 3)]}
  [(- (* (nth v1 1) (nth v2 2)) (* (nth v1 2) (nth v2 1)))
   (- (* (nth v1 2) (nth v2 0)) (* (nth v1 0) (nth v2 2)))
   (- (* (nth v1 0) (nth v2 1)) (* (nth v1 1) (nth v2 0)))])
(defn shape [fun] (fn s [a b] (cond
                              (number? a) (fun a b)
                              (vector? a) (mapv (shape fun) a b)
                              :else (mapv #((shape fun) %1 %2) a b))
                    ))
(def s+ (shape  +))
(def s- (shape -))
(def s* (shape *))
(def sd (shape /))