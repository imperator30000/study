prime(2).
prime(N) :- N > 1, \+ rec_search(N, 2).
rec_search(N, Cur_d) :- N mod Cur_d =:= 0.
rec_search(N, Cur_d) :- Cur_d * Cur_d < N, Cur_d1 is Cur_d + 1, rec_search(N, Cur_d1).
composite(N) :- \+ prime(N).
prime_divisors(N, Ds) :- rec_search_prime_divisors(N, 2, Ds).
rec_search_prime_divisors(1, _, []) :- !.
rec_search_prime_divisors(N, D, [D|Ds]) :- N mod D =:= 0, !, N1 is N // D, rec_search_prime_divisors(N1, D, Ds).
rec_search_prime_divisors(N, D, Ds) :- D1 is D + 1, rec_search_prime_divisors(N, D1, Ds).
square_divisors(N, D) :- prime_divisors(N, Ds), double_el(Ds,D).
double_el([], []).
double_el([H|T], [H, H|T1]) :- double_el(T, T1).
