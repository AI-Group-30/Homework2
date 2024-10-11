/*swap the first two elements if they are not in order*/
swap([X, Y|T], [Y, X | T]):-
    Y < X.

/*swap elements in the tail*/
swap([H|T], [H|T1]):-
    swap(T, T1).

/*
    bubbleSort sorts a list by repeatatively swapping adjacent elements if in the wrong order.
    When a swap is made do a recursive call on the new (1 element more sorted) list.
    Otherwise, no swap was needed and the list is sorted
*/
bubbleSort(L,SL):-
    swap(L, L1), % at least one swap is needed
    !,
    bubbleSort(L1, SL).
bubbleSort(L, L). % Base case, the list is already sorted

/*
    Holds true if a list is in decending order
    Base Case: Assumes empty and 1 element lists are ordered.
    Otherwise, the head must be less than the next and the remainder of the list must be sorted
*/
ordered([]).
ordered([_X]).
ordered([H1, H2|T]):-
    H1 =< H2,  % Head less than or equal to the next
    ordered([H2|T]). % Sort remainder

/*
    An element (next minimum value) inserted into an emtpy list.
    Otherwise an element is inserted into a list as the new head.
    Elements should be inserted in order and the tail should be ordered
*/
insert(X, [],[X]).
insert(E, [H|T], [E,H|T]):-
    ordered(T),  % Checks our new sorted list is sorted
    E =< H,   % Maintains the new element is inserted in order i.e. less than the first value
    !.

/* Ignores the head from the previous clause and insert the element into the ordered list i.e. not as the head value. */
insert(E, [H|T], [H|T1]):-
    ordered(T),
    insert(E, T, T1).

/* Repeatedly call insert to sort elements in a sorted partition of the list. Increase the partition until its the whole list. */
insertionSort([], []).
insertionSort([H|T], SORTED) :-
    insertionSort(T, T1),
    insert(H, T1, SORTED).

/* Divides a list in half and sorts each of the remaining lists. Then uses merge to merge each sorted half. */
mergeSort([], []). % The empty list is sorted.
mergeSort([X], [X]):-!.  % List with 1 element is sorted
mergeSort(L, SL):-
    split_in_half(L, L1, L2),
    mergeSort(L1, S1),
    mergeSort(L2, S2),
    merge(S1, S2, SL).

/* Splits a list down the middle into 2 lists.*/
intDiv(N,N1, R):- R is div(N,N1).
split_in_half([], _, _):-!, fail.
split_in_half([X],[],[X]).
split_in_half(L, L1, L2):-
    length(L,N),
    intDiv(N,2,N1),
    length(L1, N1),
    append(L1, L2, L).

/* Combies 2 sorted lists into 1 sorted list containing each element of the initial lists. */
merge([], L, L). % Merging with an empty list result in the inital list.
merge(L, [],L). % Same is true here. This is necessary for the definition of S1=[] and S2=[].
merge([H1|T1],[H2|T2],[H1|T]):-
    H1 < H2,
    merge(T1,[H2|T2],T).
merge([H1|T1], [H2|T2], [H2|T]):-
    H2 =< H1,
    merge([H1|T1], T2, T).

/* Splits a list into 2 smaller lists at a given index `x` in the list.*/
split(_, [],[],[]).
split(X, [H|T], [H|SMALL], BIG):-
    H =< X,
    split(X, T, SMALL, BIG).
split(X, [H|T], SMALL, [H|BIG]):-
    X =< H,
    split(X, T, SMALL, BIG).

/* Selects a pivot and then recursively sorts around the pivot until each partition is sorted. */
quickSort([], []).
quickSort([H|T], LS):-
    split(H, T, SMALL, BIG),
    quickSort(SMALL, S),
    quickSort(BIG, B),
    append(S, [H|B], LS).

/*
    Combies 1 of a small sort (insertion & bubble) with a big sort (merge & quick) to more efficiently sort memebers of list.
    Base case: 0 or 1 lenght lists are always sorted.
    Otherwise: Select the big or large sorting algorithm respective to the value of the threshold and the lenght of the list.
*/
hybridSort(_, _, _, [], []).
hybridSort(_, _, _, [X], [X]).
hybridSort(SMALLALG, BIGALG, THRESHOLD, LIST, SLIST) :-
    length(LIST, N),
    N =< THRESHOLD,
    call(SMALLALG, LIST, SLIST).
hybridSort(SMALLALG, mergeSort, THRESHOLD, LIST, SLIST) :-
    length(LIST, N),
    N > THRESHOLD,
    split_in_half(LIST, L1, L2),
    hybridSort(SMALLALG, mergeSort, THRESHOLD, L1, S1),
    hybridSort(SMALLALG, mergeSort, THRESHOLD, L2, S2),
    merge(S1, S2, SLIST).
hybridSort(SMALLALG, quickSort, THRESHOLD, [H|T], SLIST) :-
    length([H|T], N),
    N > THRESHOLD,
    split(H, T, SMALL, BIG),
    hybridSort(SMALLALG, quickSort, THRESHOLD, SMALL, S),
    hybridSort(SMALLALG, quickSort, THRESHOLD, BIG, B),
    append(S, [H|B], SLIST).

:- dynamic(randomList/1).

randomList(0, _, _, []).
randomList(LENGTH, MIN, MAX, [H|T]):-
    LENGTH > 0,
    random_between(MIN, MAX, H),
    LENGTHMINUSONE is LENGTH - 1,
    randomList(LENGTHMINUSONE, MIN, MAX, T).

saveLists(0, _, _, _).
saveLists(N, LENGTH, MIN, MAX):-
    N > 0,
    randomList(LENGTH, MIN, MAX, LIST),
    assertz(randomList(LIST)),
    NMINUSONE is N - 1,
    saveLists(NMINUSONE, LENGTH, MIN, MAX).



:- dynamic(sortTime/2).

sortTime(ALGOTYPE, L, SL) :-
    statistics(cputime, T0),
    call(ALGOTYPE, L, SL),
    statistics(cputime, T1),
    T is T1 - T0,
    format('CPU time: ~w~n',[T]),
    format('Algotype: ~w~n',[ALGOTYPE]),
    assertz(sortTime(ALGOTYPE,T)).



runAlgos(L) :-
    sortTime(bubbleSort, L, _),
    sortTime(insertionSort, L, _),
    sortTime(mergeSort, L, _),
    sortTime(quickSort, L, _),
    sortTime(hybridSort(bubbleSort, quickSort, 10), L, _),
    sortTime(hybridSort(insertionSort, quickSort, 10), L, _),
    sortTime(hybridSort(bubbleSort, mergeSort, 10), L, _),
    sortTime(hybridSort(insertionSort, mergeSort, 10), L, _).

runProcess :-
    saveLists(50, 100, 1, 100),
    forall(randomList(List), (
        writeln('Running algorithms on list:'),
        writeln(List),
        runAlgos(List),
        nl
    )).

