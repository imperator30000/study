(defn action [f]
  (fn [& args]
    (fn [& val]
      (apply f (map #(apply % val) args)))))
(def subtract (action (fn [a b] (- a b))))
(def add (action (fn [a b] (+ a b))))
(def multiply (action (fn [a b] (* a b))))
(def divide (action (fn [a b] (/ a b))))
(def negate (action (fn [a] (- a))))
(def exp (action (fn [a] (exp a))))
(def ln (action (fn [a] (ln a))))
(defn constant [a] (fn [val] (double a)))
(defn variable [a] (fn [val] (double (get val a))))
(def actions {"-"      subtract
              "+"      add
              "*"      multiply
              "/"      divide
              "negate" negate
              "ln"     ln
              "exp"    exp})

(defn my_reverse [obj] (cond (and (not (number? obj)) (not (symbol? obj))) (reverse obj)
                             (or (number? obj) (symbol? obj)) obj))
(defn my-map [reverse-flag f v]
  (map f (map my_reverse v)))
(defn parse_ [const vari act reverse-flag expression] (cond
                                                        (number? expression) (const expression)
                                                        (symbol? expression) (vari (str expression))
                                                        :else (apply (get act (str (first expression))) (cond reverse-flag (map (partial parse_ const vari act reverse-flag) (my_reverse (map my_reverse (rest expression))))
                                                                                                              (not reverse-flag) (map (partial parse_ const vari act reverse-flag) (rest expression))))))
(defn parseFunction [expression] (parse_ constant variable actions false (read-string expression)))
;HW11
(defn proto-get
  ([obj key] (proto-get obj key nil))
  ([obj key default]
   (cond
     (contains? obj key) (get obj key)
     (contains? obj :proto) (proto-get (get obj :proto) key default)
     :else default)))
(defn proto-call
  [this key & args]
  (apply (proto-get this key) this args))
(defn field
  ([key] (field key nil))
  ([key default] (fn [obj] (proto-get obj key default))))
(defn method [key]
  (fn [obj & args] (apply proto-call obj key args)))
(defn constructor [constr proto]
  (fn [& args] (apply constr {:proto proto} args)))


(def toString (method :toString))
(def toStringPostfix (method :toStringPostfix))

(def evaluate (method :evaluate))

(defn Constant [x] (let [_x (field :x)] {
                                         :evaluate        (fn ([this] (evaluate this {})) ([this values] (double (_x this))))
                                         :x               x
                                         :toString        (fn [this] (str (_x this)))
                                         :toStringPostfix (fn [this] (str (_x this)))
                                         }))
(defn Variable [x] (let [_x (field :x)] {
                                         :evaluate        (fn [this values] (double (get values (clojure.string/lower-case (str (first (_x this)))))))
                                         :x               x
                                         :toString        (fn [this] (_x this))
                                         :toStringPostfix (fn [this] (_x this))
                                         }))


(def _sym (field :sym))
(def Operation (let [
                     _args (field :args)
                     _sym (field :sym)
                     _func (field :func)
                     ] {
                        :evaluate        (fn ([this] (evaluate this {}))
                                           ([this values] (apply (_func this) (map #(evaluate % values) (_args this)))))
                        :toString        (fn [this] (str "(" (_sym this) " " (clojure.string/join " " (map toString (_args this))) ")"))
                        :toStringPostfix (fn [this] (str "(" (clojure.string/join " " (map toStringPostfix (_args this))) " " (_sym this) ")"))
                        }))
(defn Operation_constructor [this func sym & args]
  (assoc this :func func :sym sym :args args))
(defn Add [x y] ((constructor Operation_constructor Operation) + "+" x y))
(defn Subtract [x y] ((constructor Operation_constructor Operation) - "-" x y))
(defn Multiply [x y] ((constructor Operation_constructor Operation) * "*" x y))
(defn Divide [x y] ((constructor Operation_constructor Operation) (fn [a b] (cond
                                                                              (== b 0) (/ a 1)
                                                                              :else (/ a b))) "/" x y))
(defn ArcTan [x] ((constructor Operation_constructor Operation) (fn [x] (Math/atan x)) "atan" x))
(defn Sin [x] ((constructor Operation_constructor Operation) (fn [x] (Math/sin x)) "sin" x))
(defn Cos [x] ((constructor Operation_constructor Operation) (fn [x] (Math/cos x)) "cos" x))
(defn ArcTan2 [x y] ((constructor Operation_constructor Operation) (fn [x y] (Math/atan2 x y)) "atan" x y))

(defn Negate [x] ((constructor Operation_constructor Operation) - "negate" x))
(defn Inc [x] ((constructor Operation_constructor Operation) inc "++" x))
(defn Dec [x] ((constructor Operation_constructor Operation) dec "--" x))


(def actions_ {
               "++"     Inc
               "--"     Dec
               "-"      Subtract
               "+"      Add
               "*"      Multiply
               "/"      Divide
               "negate" Negate
               "atan"   ArcTan
               "atan2"  ArcTan2
               "sin"    Sin
               "cos"    Cos
               })
(defn parseObject [expression] (parse_ Constant Variable actions_ false (read-string expression)))
(evaluate (parseObject "(+ 1 (- 3 (* 3 4)))"))
;H12


(defn -return [value tail] {:value value :tail tail})
(def -valid? boolean)
(def -value :value)
(def -tail :tail)


(defn _empty [value] (partial -return value))

(defn _char [p]
  (fn [[c & cs]]
    (if (and c (p c)) (-return c cs))))

(defn _map [f]
  (fn [result]
    (if (-valid? result)
      (-return (f (-value result)) (-tail result)))))

(defn _combine [f a b]
  (fn [str]
    (let [ar ((force a) str)]
      (if (-valid? ar)
        ((_map (partial f (-value ar)))
         ((force b) (-tail ar)))))))

(defn _either [a b]
  (fn [str]
    (let [ar ((force a) str)]
      (if (-valid? ar) ar ((force b) str)))))

(defn _parser [parser]
  (fn [input]
    (-value ((_combine (fn [v _] v) parser (_char #{\u0001})) (str input \u0001)))))
(mapv (_parser (_combine str (_char #{\a \b}) (_char #{\x}))) ["ax" "ax~" "bx" "bx~" "" "a" "x" "xa"])



(defn +char [chars] (_char (set chars)))
(defn +char-not [chars] (_char (comp not (set chars))))
(defn +map [f parser] (comp (_map f) parser))
(def +ignore (partial +map (constantly 'ignore)))

(defn iconj [coll value]
  (if (= value 'ignore) coll (conj coll value)))

(defn +seq [& parsers]
  (reduce (partial _combine iconj) (_empty []) parsers))

(defn +seqf [f & parsers] (+map (partial apply f) (apply +seq parsers)))

(defn +seqn [n & parsers] (apply +seqf (fn [& vs] (nth vs n)) parsers))

(defn +or [parser & parsers]
  (reduce (partial _either) parser parsers))

(defn +opt [parser]
  (+or parser (_empty nil)))

(defn +star [parser]
  (letfn [(rec [] (+or (+seqf cons parser (delay (rec))) (_empty ())))] (rec)))

(defn +plus [parser] (+seqf cons parser (+star parser)))

(defn +str [parser] (+map (partial apply str) parser))

(def +parser _parser)


(defn +rules [defs]
  (cond
    (empty? defs) ()
    (seq? (first defs)) (let [[[name args body] & tail] defs]
                          (cons
                            {:name name :args args :body body}
                            (+rules tail)))
    :else (let [[name body & tail] defs]
            (cons
              {:name name :args [] :body body :plain true}
              (+rules tail)))))

(defmacro defparser [name & defs]
  (let [rules (+rules defs)
        plain (set (map :name (filter :plain rules)))]
    (letfn [(rule [{name :name, args :args, body :body}] `(~name ~args ~(convert body)))
            (convert [value]
              (cond
                (seq? value) (map convert value)
                (char? value) `(+char ~(str value))
                (contains? plain value) `(~value)
                :else value))]
      `(def ~name (letfn ~(mapv rule rules) (+parser (~(:name (last rules)))))))))

(defn +string [ch]
  (+str (apply +seq (map (comp +char str) ch))))

(def *digit (+char "0123456789."))
(defn sign [s tail]
  (if (#{\- \+} s)
    (cons s tail)
    tail))
(def *number (+map read-string (+str (+seqf sign (+opt (+char "-+")) (+plus *digit)))))
(def *space (+char " \t\n\r"))
(def *ws (+ignore (+star *space)))
(def *constanta (+map Constant *number))
(def *variable (+map (comp Variable (partial apply str) (partial map str)) (+plus (+or (+char "xyz") (+char "XYZ")))))


(def *operator
  (+map
    actions_
              (apply +or  (map +string (reverse (vec (sort-by count (keys actions_)
              )
            )
          )
        )
      )
    )
  )

(def expressionPostfix (+seqn 0 *ws
                (+or *constanta *variable
                     (+map
                       (fn [[args op]] (apply op args))
                       (+seq
                         (+ignore (+char "("))
                         (+plus (delay expressionPostfix))
                         *operator
                         *ws
                         (+ignore (+char ")"))
                         )
                       )
                     )
                *ws)
  )



(def parseObjectPostfix (_parser expressionPostfix))





