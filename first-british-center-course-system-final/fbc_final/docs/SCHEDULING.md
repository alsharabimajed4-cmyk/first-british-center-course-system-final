# Scheduling Engine

## Core rules
1. A trainer must be active.
2. The trainer's min/max level range must include the course level.
3. A weekly availability window must contain the session start/end.
4. A trainer cannot have an overlapping session on the same date.
5. A trainer cannot be assigned the same course again until the configured minimum term gap is satisfied. Default = 2 term positions, which means Term 1 → blocked Term 2 → eligible Term 3.
6. Suspended courses are not scheduled.
7. Workload balancing chooses the currently least-loaded eligible trainer when enabled.
8. Admin can simulate before committing.
9. Approval and publication are separate states.
10. Student timetable conflicts can be queried after enrollments and sessions exist.

## Term calendar
A term is calculated from a start date and teaching-day count. Friday can be excluded and all active holiday records are skipped. The end date is therefore derived rather than manually trusted.
