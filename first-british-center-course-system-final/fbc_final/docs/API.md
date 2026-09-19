# API map

All state-changing requests are POST and require `X-CSRF-Token` from `/api/?action=me` or `/api/?action=csrf`.

## Authentication
- `GET /api/?action=me`
- `POST /api/?action=login`
- `POST /api/?action=logout`
- `GET /api/?action=google_start`
- `GET /api/?action=google_callback`
- `POST /api/?action=onboarding`

## Data
- `GET terms`, `holidays`, `levels`, `courses`, `trainers`, `students`
- `POST create_term`, `create_holiday`, `create_level`, `create_course`, `create_trainer`, `create_student`
- `POST enroll_student`
- `POST assign_courses`
- `GET enrollments`

## Scheduling
- `POST calculate_term`
- `POST generate_schedule` with `simulate: true|false`
- `GET schedule`
- `GET conflicts`
- `POST approve_schedule`
- `POST publish_schedule`
- `POST override`
- `GET print`

## Audit / administration
- `GET dashboard`
- `GET audit`
- `GET login_history`
- `GET archives`
- `GET my_archive`
- `GET settings`
- `POST save_settings`

## OCR
- `POST upload_ocr` multipart/form-data, field `file`.
