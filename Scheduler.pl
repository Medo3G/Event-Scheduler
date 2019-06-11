/*--------Model Description----------*/
/*
* A schedule is a LIST of slots, a slot is defined as:
* slot(Week_Number,Group_Name,Day,Slot_Number,Course_Code,Event_Name, Event_Type)
* example slot:
* slot(3,group4MET,tuesday,1,csen403,quiz1, quiz)
* The schedule includes all events for all groups placed in timings and satisfies all test predicates
* example schedule
* [slot(3,group4MET,tuesday,1,csen403,quiz1, quiz),slot(4,group6MET,saturday,5,csen601,quiz1, quiz),...]
*/

/*-------Testing------*/
available_timings(Group_Name,L):- /* check if L is a list consisting of timings that satisfy quizzslots facts for the input group */
	setof(timing(Day,Slot_Number),quizslot(Group_Name,Day,Slot_Number),L).

/*---------*/
group_events(Group_Name,L):- /* check if L is a list of events of courses being studied by the input group */
				setof(event_in_course(Course_Code, X, Y),(event_in_course(Course_Code, X, Y),studying(Course_Code,Group_Name)),L).

/*---------*/
no_consec_quizzes(_,[]). /* an empty list doesn't break the consec quizes rule (base case)*/

no_consec_quizzes(Group_Name,[H|T]):- /* if group doesn't match, skip it */
		H = slot(_,Group_Name2,_,_,_,_,_),
		Group_Name \= Group_Name2,
		no_consec_quizzes(Group_Name,T).

no_consec_quizzes(Group_Name,[H|T]):- /* if group the group maches but not a quiz, skip*/
				H = slot(_,Group_Name,_,_,_,_,Not_Quiz),
				Not_Quiz \= quiz,
				no_consec_quizzes(Group_Name,T).

no_consec_quizzes(Group_Name,[H|T]):- /* checks for same week and next week quizes */
					H = slot(Week_Number,Group_Name,_,_,Course_Code,_,quiz),
					Y = slot(Week_Number,Group_Name,_,_,Course_Code,_,quiz),
					\+ member(Y,T), /* check that the tail list doesn't have a quiz for the same course on the same week */
					N is Week_Number+1,
					Z = slot(N,Group_Name,_,_,Course_Code,_,quiz), /* check that the tail list doesn't have a quiz for the same course next week */
					\+ member(Z,T),
					no_consec_quizzes(Group_Name,T).

/*---------*/
no_same_day_quiz(_,[]). /* an empty list doesn't have quizes happening on the same day (base case)*/

no_same_day_quiz(Group_Name,[H|T]):- /* if group doesn't match, skip it */
					H = slot(_,Group_Name2,_,_,_,_,_),
					Group_Name \= Group_Name2,
					no_same_day_quiz(Group_Name,T).

no_same_day_quiz(Group_Name,[H|T]):- /* if the group maches but not a quiz, skip it */
							H = slot(_,Group_Name,_,_,_,_,X),
							X\= quiz,
							no_same_day_quiz(Group_Name,T).

no_same_day_quiz(Group_Name,[H|T]):- /* check if the tail doesn't have	a quiz happening on the same day as the head */
									H = slot(Week_Number,Group_Name,Day,_,_,_,quiz),
									Y = slot(Week_Number,Group_Name,Day,_,_,_,quiz),
									\+ member(Y,T),
									no_same_day_quiz(Group_Name,T).

/*---------*/
no_same_day_assignment(_,[]). /* an empty list doesn't have assignments happening on the same day (base case)*/

no_same_day_assignment(Group_Name,[H|T]):- /* if group doesn't match, skip it */
									  	H = slot(_,Group_Name2,_,_,_,_,_),
											Group_Name \= Group_Name2,
											no_same_day_assignment(Group_Name,T).

no_same_day_assignment(Group_Name,[H|T]):- /* if the group maches but not an assignment, skip it */
												H = slot(_,Group_Name,_,_,_,_,X),
												X\= assignment,
												no_same_day_assignment(Group_Name,T).

no_same_day_assignment(Group_Name,[H|T]):- /* check if the tail doesn't have an assignment happening on the same day as the head */
				H = slot(Week_Number,Group_Name,Day,_,_,_,assignment),
				Y = slot(Week_Number,Group_Name,Day,_,_,_,assignment),
				\+ member(Y,T),
				no_same_day_assignment(Group_Name,T).

/*---------*/
no_holidays(_,[]). /* an empty list doesn't have events occuring during holidays (base case)*/

no_holidays(Group_Name,[H|T]):- /* if group doesn't match, skip it */
				H = slot(_,Group_Name2,_,_,_,_,_),
				Group_Name \= Group_Name2,
				no_holidays(Group_Name,T).

no_holidays(Group_Name,[H|T]):- /*check if the current head doesn't occur during a holiday */
				  H = slot(Week_Number,Group_Name,Day,_,_,_,_),
				  \+ holiday(Week_Number,Day),
				  no_holidays(Group_Name,T).

/*---------*/
valid_slots_schedule(_,[]). /*an empty list doesn't have 2 events at the same time (Base Case)*/

valid_slots_schedule(Group_Name,[slot(_,Group_Name2,_,_,_,_,_)|T]):-			 /* if the group doesn't match skip it */
				Group_Name2 \= Group_Name,
				valid_slots_schedule(Group_Name,T).

valid_slots_schedule(Group_Name,[H|T]):- /* check if the tail list doesn't have an event happening at the same week+day+slot) */
					H = slot(Week_Number,Group_Name,Day,Slot_Number,_,_,_),
					Same = slot(Week_Number,Group_Name,Day,Slot_Number,_,_,_),
					\+ member(Same,T),
					valid_slots_schedule(Group_Name,T).

/*---------*/
precede(_,[]). /*an empty list doesn't break should_precede rules (Base Case)*/

precede(Group_Name,[slot(_,Group_Name2,_,_,_,_,_)|T]):-			 /* if the group doesn't match skip it and check the rest */
						Group_Name2 \= Group_Name,
						precede(Group_Name,T).

precede(Group_Name,[H|T]):-						 /* if the event doesn't have another preceding we are sure that a one preceding it is in  the tail , so skip*/
						H = slot(_,Group_Name,_,_,Course_Code,Event1_Name,_),
						\+ should_precede(Course_Code,_,Event1_Name),
						precede(Group_Name,T).

precede(Group_Name,[H|T]):-																	/* if the event has another preceding it check it isn't in the tail list */
						H = slot(_,Group_Name,_,_,Course_Code,Event2_Name,_),
						E1= slot(_,Group_Name,_,_,Course_Code,Event1_Name,_),
						should_precede(Course_Code,Event1_Name,Event2_Name),
						\+ member(E1,T),
						precede(Group_Name,T).

/*-------Generating-------*/
get_all_groups(L):- /* get all the groups (used for the predicate tests)*/
					findall(Group_Name,(studying(_,Group_Name)),M),
					sort(M,L).

/*---------*/
schedule(Max_Weeks,Schedule):- /* generate a list of all events with the Week_Number, Day & Slot as free variables, then send them to generate_schedule*/
	setof(slot(_,Group_Name,_,_,Course_Code,Event_Name, Event_Type),(
	event_in_course(Course_Code, Event_Name, Event_Type),
	studying(Course_Code,Group_Name)
	),
	List_of_all_slots),
	generate_schedule(Max_Weeks,List_of_all_slots,[],Schedule).

/*---------*/
generate_schedule(_,[],Output,Output).  /* There are no slots left to add so the list in the accum is the final one (base case)*/

/* try to generate a schedule slot by slot, if the mini schedule is correct try to add another event from what's left */
generate_schedule(Max_Weeks,Slots_left_to_add,Accum_List,Output):-
				Slots_left_to_add = [H|T],
				generate_slot_varriation(Max_Weeks,H,One_slot),
				Schedule_to_test = [One_slot|Accum_List],
				sort(1, @=<, Schedule_to_test, Schedule_to_test_sorted),
				get_all_groups(All_Groups),
				test_current_schedule(All_Groups,Schedule_to_test_sorted),
				generate_schedule(Max_Weeks,T,Schedule_to_test_sorted,Output).

/*---------*/
generate_slot_varriation(Max_Weeks,H,One_slot):- /* assign all possible timings a slot can have in terms of weeks and free slots(quizslosts)*/
	H =slot(_,Group_Name,_,_,Course_Code,Event_Name, Event_Type),
	numlist(1,Max_Weeks,Weeks),
	member(Week_Number,Weeks),
	quizslot(Group_Name, Day, Slot_Number),
	One_slot = slot(Week_Number,Group_Name,Day,Slot_Number,Course_Code,Event_Name, Event_Type).

/*---------*/
test_current_schedule([],_). /*if there's no groups left to test agains, so it passes (base case) */

test_current_schedule(Groups,Schedule_to_test_sorted):- /*Test if the schdule/mini-schedule passes all the constraints */
		Groups = [H|T],
		valid_slots_schedule(H,Schedule_to_test_sorted),
		no_consec_quizzes(H,Schedule_to_test_sorted),
		no_same_day_quiz(H,Schedule_to_test_sorted),
		no_same_day_assignment(H,Schedule_to_test_sorted),
		no_holidays(H,Schedule_to_test_sorted),
		precede(H,Schedule_to_test_sorted),
		test_current_schedule(T,Schedule_to_test_sorted).

/*---------Database--------*/
event_in_course(csen403, labquiz1, assignment).
event_in_course(csen403, labquiz2, assignment).
event_in_course(csen403, project1, evaluation).
event_in_course(csen403, project2, evaluation).
event_in_course(csen403, quiz1, quiz).
event_in_course(csen403, quiz2, quiz).
event_in_course(csen403, quiz3, quiz).

event_in_course(csen401, quiz1, quiz).
event_in_course(csen401, quiz2, quiz).
event_in_course(csen401, quiz3, quiz).
event_in_course(csen401, milestone1, evaluation).
event_in_course(csen401, milestone2, evaluation).
event_in_course(csen401, milestone3, evaluation).

event_in_course(csen402, quiz1, quiz).
event_in_course(csen402, quiz2, quiz).
event_in_course(csen402, quiz3, quiz).

event_in_course(math401, quiz1, quiz).
event_in_course(math401, quiz2, quiz).
event_in_course(math401, quiz3, quiz).

event_in_course(elct401, quiz1, quiz).
event_in_course(elct401, quiz2, quiz).
event_in_course(elct401, quiz3, quiz).
event_in_course(elct401, assignment1, assignment).
event_in_course(elct401, assignment2, assignment).

event_in_course(csen601, quiz1, quiz).
event_in_course(csen601, quiz2, quiz).
event_in_course(csen601, quiz3, quiz).
event_in_course(csen601, project, evaluation).
event_in_course(csen603, quiz1, quiz).
event_in_course(csen603, quiz2, quiz).
event_in_course(csen603, quiz3, quiz).

event_in_course(csen602, quiz1, quiz).
event_in_course(csen602, quiz2, quiz).
event_in_course(csen602, quiz3, quiz).

event_in_course(csen604, quiz1, quiz).
event_in_course(csen604, quiz2, quiz).
event_in_course(csen604, quiz3, quiz).
event_in_course(csen604, project1, evaluation).
event_in_course(csen604, project2, evaluation).


holiday(3,monday).
holiday(5,tuesday).
holiday(10,sunday).


studying(csen403, group4MET).
studying(csen401, group4MET).
studying(csen402, group4MET).
studying(csen402, group4MET).

studying(csen601, group6MET).
studying(csen602, group6MET).
studying(csen603, group6MET).
studying(csen604, group6MET).

should_precede(csen403,project1,project2).
should_precede(csen403,quiz1,quiz2).
should_precede(csen403,quiz2,quiz3).

quizslot(group4MET, tuesday, 1).
quizslot(group4MET, thursday, 1).
quizslot(group6MET, saturday, 5).

/*Added should_precede-ONLY FOR TESTING*/
/*
should_precede(csen403,labquiz1,labquiz2).

should_precede(csen401,quiz1,quiz2).
should_precede(csen401,quiz2,quiz3).

should_precede(csen401,milestone1,milestone2).
should_precede(csen401,milestone2,milestone3).

should_precede(csen402,quiz1,quiz2).
should_precede(csen402,quiz2,quiz3).

should_precede(math401,quiz1,quiz2).
should_precede(math401,quiz2,quiz3).

should_precede(elct401,quiz1,quiz2).
should_precede(elct401,quiz2,quiz3).

should_precede(elct401,assignment1,assignment2).

should_precede(csen601,quiz1,quiz2).
should_precede(csen601,quiz2,quiz3).

should_precede(csen602,quiz1,quiz2).
should_precede(csen602,quiz2,quiz3).

should_precede(csen603,quiz1,quiz2).
should_precede(csen603,quiz2,quiz3).

should_precede(csen604,quiz1,quiz2).
should_precede(csen604,quiz2,quiz3).

should_precede(csen604,project1,project2).
*/
