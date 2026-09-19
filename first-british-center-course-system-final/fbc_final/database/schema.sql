SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 google_sub VARCHAR(255) NULL UNIQUE,
 username VARCHAR(80) NOT NULL UNIQUE,
 email VARCHAR(190) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NULL,
 full_name VARCHAR(190) NOT NULL,
 role ENUM('super_admin','admin','course_manager','data_entry','trainer','student','auditor') NOT NULL DEFAULT 'student',
 status ENUM('active','suspended') NOT NULL DEFAULT 'active',
 profile_complete TINYINT(1) NOT NULL DEFAULT 0,
 last_login_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_users_role(role), INDEX idx_users_status(status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS login_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NULL,
 result ENUM('success','failed') NOT NULL,
 method VARCHAR(40) NOT NULL,
 ip_address VARCHAR(64), user_agent VARCHAR(500), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_login_user(user_id), INDEX idx_login_created(created_at),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NULL,
 action VARCHAR(60) NOT NULL,
 entity VARCHAR(80) NOT NULL,
 entity_id BIGINT NULL,
 old_value LONGTEXT NULL,
 new_value LONGTEXT NULL,
 reason VARCHAR(500) NULL,
 ip_address VARCHAR(64), user_agent VARCHAR(500), request_id VARCHAR(64) NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_audit_user(user_id), INDEX idx_audit_entity(entity,entity_id), INDEX idx_audit_created(created_at), INDEX idx_audit_action(action),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS settings (
 setting_key VARCHAR(100) PRIMARY KEY, setting_value TEXT NOT NULL,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS levels (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(80) NOT NULL UNIQUE, level_order INT NOT NULL UNIQUE, active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS holidays (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, holiday_date DATE NOT NULL UNIQUE, name VARCHAR(190) NOT NULL, holiday_type VARCHAR(60) NOT NULL DEFAULT 'official', notes TEXT NULL, active TINYINT(1) NOT NULL DEFAULT 1,
 INDEX idx_holiday_date(holiday_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS terms (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, term_number INT NOT NULL, name VARCHAR(100) NOT NULL, academic_year VARCHAR(30), start_date DATE NOT NULL, end_date DATE NULL,
 required_teaching_days INT NOT NULL DEFAULT 20, exclude_friday TINYINT(1) NOT NULL DEFAULT 1, status ENUM('draft','active','completed','archived') NOT NULL DEFAULT 'draft', notes TEXT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uniq_term_number_year(term_number,academic_year), INDEX idx_term_dates(start_date,end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS term_holidays (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, term_id BIGINT UNSIGNED NOT NULL, holiday_id BIGINT UNSIGNED NOT NULL, UNIQUE KEY uniq_term_holiday(term_id,holiday_id),
 FOREIGN KEY(term_id) REFERENCES terms(id) ON DELETE CASCADE, FOREIGN KEY(holiday_id) REFERENCES holidays(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trainers (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id BIGINT UNSIGNED NULL, full_name VARCHAR(190) NOT NULL, email VARCHAR(190), country VARCHAR(100), country_code VARCHAR(10), phone VARCHAR(40), whatsapp VARCHAR(40),
 min_level_order INT NOT NULL DEFAULT 1, max_level_order INT NOT NULL DEFAULT 5, status ENUM('active','inactive') NOT NULL DEFAULT 'active', notes TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL, INDEX idx_trainer_status(status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trainer_availability (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, trainer_id BIGINT UNSIGNED NOT NULL, weekday TINYINT NOT NULL, start_time TIME NOT NULL, end_time TIME NOT NULL, active TINYINT(1) NOT NULL DEFAULT 1,
 FOREIGN KEY(trainer_id) REFERENCES trainers(id) ON DELETE CASCADE, INDEX idx_avail(trainer_id,weekday,start_time,end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS courses (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(190) NOT NULL, code VARCHAR(80) UNIQUE, category VARCHAR(100) NULL, level_name VARCHAR(80) NOT NULL, level_order INT NOT NULL DEFAULT 1, max_students INT NOT NULL DEFAULT 25,
 default_start TIME NULL, default_end TIME NULL, default_weekday TINYINT NULL, sessions_per_week INT NOT NULL DEFAULT 3, session_minutes INT NOT NULL DEFAULT 120,
 status ENUM('draft','active','suspended','completed','cancelled') NOT NULL DEFAULT 'active', suspension_reason VARCHAR(500) NULL, notes TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_course_level(level_order), INDEX idx_course_status(status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS students (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, student_code VARCHAR(80) UNIQUE, full_name VARCHAR(190) NOT NULL, date_of_birth DATE NULL, gender VARCHAR(30) NULL, country VARCHAR(100), country_code VARCHAR(10), phone VARCHAR(40), whatsapp VARCHAR(40), email VARCHAR(190),
 current_level_order INT NOT NULL DEFAULT 1, status ENUM('active','inactive','graduated') NOT NULL DEFAULT 'active', parent_name VARCHAR(190) NULL, parent_phone VARCHAR(40) NULL, notes TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_student_status(status), INDEX idx_student_level(current_level_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS enrollments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, student_id BIGINT UNSIGNED NOT NULL, course_id BIGINT UNSIGNED NOT NULL, term_id BIGINT UNSIGNED NOT NULL, status ENUM('active','completed','cancelled','pending') NOT NULL DEFAULT 'active', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uniq_enroll(student_id,course_id,term_id), FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE, FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE, FOREIGN KEY(term_id) REFERENCES terms(id) ON DELETE CASCADE,
 INDEX idx_enrollment_term(term_id), INDEX idx_enrollment_course(course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS term_courses (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, term_id BIGINT UNSIGNED NOT NULL, course_id BIGINT UNSIGNED NOT NULL, preferred_weekday TINYINT NULL, preferred_start TIME NULL, preferred_end TIME NULL, sessions_per_week INT NULL,
 status ENUM('pending','scheduled','suspended') NOT NULL DEFAULT 'pending', UNIQUE KEY uniq_term_course(term_id,course_id), FOREIGN KEY(term_id) REFERENCES terms(id) ON DELETE CASCADE, FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS schedule_entries (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, term_id BIGINT UNSIGNED NOT NULL, term_course_id BIGINT UNSIGNED NOT NULL, trainer_id BIGINT UNSIGNED NULL, session_date DATE NULL, session_index INT NULL, weekday TINYINT NOT NULL, start_time TIME NOT NULL, end_time TIME NOT NULL, room_name VARCHAR(100) NULL,
 status ENUM('proposed','approved','published','cancelled') NOT NULL DEFAULT 'proposed', override_flag TINYINT(1) NOT NULL DEFAULT 0, override_reason VARCHAR(500) NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(term_id) REFERENCES terms(id) ON DELETE CASCADE, FOREIGN KEY(term_course_id) REFERENCES term_courses(id) ON DELETE CASCADE, FOREIGN KEY(trainer_id) REFERENCES trainers(id) ON DELETE SET NULL,
 INDEX idx_schedule_term_date(term_id,session_date,start_time), INDEX idx_schedule_trainer(trainer_id,term_id,session_date,start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS schedule_generation_runs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, term_id BIGINT UNSIGNED NOT NULL, user_id BIGINT UNSIGNED NOT NULL, status ENUM('simulated','generated','approved','published','failed') NOT NULL, summary JSON NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(term_id) REFERENCES terms(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS overrides (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, schedule_entry_id BIGINT UNSIGNED NOT NULL, user_id BIGINT UNSIGNED NOT NULL, rule_name VARCHAR(190) NOT NULL, reason VARCHAR(500) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(schedule_entry_id) REFERENCES schedule_entries(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ocr_imports (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id BIGINT UNSIGNED NOT NULL, original_name VARCHAR(255), stored_path VARCHAR(500), source_type VARCHAR(30), extracted_text LONGTEXT, structured_json JSON NULL,
 status ENUM('uploaded','reviewed','imported','rejected') NOT NULL DEFAULT 'uploaded', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classrooms (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, term_id BIGINT UNSIGNED NOT NULL, course_id BIGINT UNSIGNED NOT NULL, room_key VARCHAR(190) NOT NULL UNIQUE, provider VARCHAR(40) NOT NULL DEFAULT 'livekit', status ENUM('active','disabled') NOT NULL DEFAULT 'active', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(term_id) REFERENCES terms(id) ON DELETE CASCADE, FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO settings(setting_key,setting_value) VALUES
('center_name','The First British Center for Online Education'),
('center_name_ar','المركز البريطاني الأول للتعليم أونلاين'),
('term_teaching_days','20'),
('exclude_friday','1'),
('minimum_repeat_gap_terms','2'),
('balance_workload','1'),
('default_sessions_per_week','3'),
('default_session_minutes','120'),
('timezone','Asia/Aden'),
('allow_admin_override','1'),
('require_admin_approval','1')
ON DUPLICATE KEY UPDATE setting_key=setting_key;

INSERT INTO levels(name,level_order) VALUES ('A1',1),('A2',2),('B1',3),('B2',4),('C1',5),('C2',6)
ON DUPLICATE KEY UPDATE name=VALUES(name);
