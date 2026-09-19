# Data model

Core relationships:

- `users` → authentication, roles and personal archive ownership.
- `levels` → numeric order used by trainer eligibility.
- `terms` → 20 teaching-day academic periods.
- `holidays` → editable Admin calendar exclusions.
- `courses` → reusable course definitions.
- `trainers` + `trainer_availability` → teacher eligibility and time windows.
- `students` → contact, DOB and current level.
- `enrollments` → student/course/term relationship and capacity enforcement.
- `term_courses` → which reusable courses are offered in a term.
- `schedule_entries` → actual dated teaching sessions.
- `schedule_generation_runs` → future extension for generation traceability.
- `audit_logs` + `login_logs` → operational archive.
- `ocr_imports` → uploaded source documents and extracted text.
- `classrooms` → reserved mapping for LiveKit/online classroom integration.
