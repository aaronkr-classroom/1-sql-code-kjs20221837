-- 교사 테이블
CREATE TABLE teacher (
    id CHAR(1) PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(10) NOT NULL
);

-- 강의 테이블
CREATE TABLE course (
    id CHAR(1) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    teacher_id CHAR(1) NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teacher(id)
);

-- 학생 테이블
CREATE TABLE student (
    id CHAR(1) PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(10) NOT NULL
);

-- 학생-강의 관계 테이블
CREATE TABLE student_course (
    student_id CHAR(1) NOT NULL,
    course_id CHAR(1) NOT NULL,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (course_id) REFERENCES course(id)
);

ALTER TABLE teacher
ALTER COLUMN first_name TYPE VARCHAR(20);

-- 교사 데이터 삽입
INSERT INTO teacher (id, first_name, last_name) VALUES
('1', 'Taylah', 'Booker'),
('2', 'Sara-Louise', 'Blake');

-- 강의 데이터 삽입
INSERT INTO course (id, name, teacher_id) VALUES
('1', 'Database design', '1'),
('2', 'English literature', '2'),
('3', 'Python programming', '1');

-- 학생 데이터 삽입
INSERT INTO student (id, first_name, last_name) VALUES
('1', 'Shreya', 'Bain'),
('2', 'Rianna', 'Foster'),
('3', 'Yosef', 'Naylor');

-- 학생-강의 수강 데이터 삽입
INSERT INTO student_course (student_id, course_id) VALUES
('1', '2'),
('1', '3'),
('2', '1'),
('2', '2'),
('2', '3'),
('3', '1');

-- 1번 조인
SELECT 
    s.id AS student_id,
    s.first_name,
    s.last_name,
    sc.course_id
FROM student s
JOIN student_course sc ON s.id = sc.student_id;

-- 2번 조인
SELECT 
    c.id AS course_id,
    c.name AS course_name,
    t.first_name AS teacher_first_name,
    t.last_name AS teacher_last_name
FROM course c
JOIN teacher t ON c.teacher_id = t.id;

-- 3번 조인
SELECT 
    s.first_name AS student_first_name,
    s.last_name AS student_last_name,
    c.name AS course_name,
    t.first_name AS teacher_first_name,
    t.last_name AS teacher_last_name
FROM student s
JOIN student_course sc ON s.id = sc.student_id
JOIN course c ON sc.course_id = c.id
JOIN teacher t ON c.teacher_id = t.id;



