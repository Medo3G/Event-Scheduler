# Event-Scheduler
A Prolog scheduler for academic events for different study groups

## Properties of a Schedule
Assuming that there is an infinite number of locations, a produced schedule should have the following features:
1. No events should be scheduled on a holiday.
2. A group cannot have two events at the same time.
3. All events of any course are scheduled for any group taking the course.
4. Events of a group are scheduled only in the allowed slots.
5. No group can have two quizzes or assignments on the same day.
6. Two quizzes of one course should be separated by at least one weak.
7. The schedule generated should take into account that some courses have some events that should precede others.

## Provided Predicates
* `event_in_course(Course_Code, Event_Name, Event_Type)` encodes the fact that the course with
code `Course_Code` has an event of type `Event_Type` named Event_Name. For example, the following fact is available in our database `event_in_course(csen403, quiz1, quiz)`.
* `studying(Course_Code, Group_Name)` provides the course catalogue. It encodes that the group `Group_Name` has to study `Course_Code` e.g. `studying(csen403, group4MET)`.
* `holiday(Week_Number,Day)` represents a holiday on the day: `Day` in the week numbered `Week_Number` e.g. `holiday(3,monday)`.
* `should_precede(Course_Code,Event1,Event2)` is available to make sure that the event named `Event1` should be scheduled before `Event2` for the course `Course_Code` e.g. `should_precede(csen403,quiz1,quiz2)`.
* Every group has predefined slots in which academic events could be held. Such slots are encoded
through the predicate `quizslot(Group_Name, Day, Slot_Number)`. For example `quizslot(group4MET, tuesday, 1)` encodes the fact that `group4MET` could have events on Tuesdays during the first slot. Each group could have more than one possible timing for events.
***
Done as a part of Concepts of Programming languages course.