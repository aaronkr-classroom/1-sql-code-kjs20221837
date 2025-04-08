CREATE TABLE 과목2 (
	과목번호 CHAR(4) NOT NULL PRIMARY KEY,
	이름 VARCHAR(20) NOT NULL,
	강의실 CHAR(5) NOT NULL,
	개설학과 VARCHAR(20) NOT NULL,
	시수 INT NOT NULL
);

CREATE TABLE 학생2 (
	학번 CHAR(4) NOT NULL,
	이름 VARCHAR(20) NOT NULL,
	주소 VARCHAR(50) DEFAULT '미정', -- MYSQL에서 DEFAULT기능
	학년 INT NOT NULL,
	나이 INT NULL,
	성별 CHAR(1) NOT NULL,
	휴대폰번호 CHAR(13) NOT NULL,
	소속학과 VARCHAR(20) NOT NULL,
	PRIMARY KEY (학번),
	UNIQUE (휴대폰번호)
);
ALTER TABLE 학생2 ALTER COLUMN "휴대폰번호" DROP NOT NULL;
ALTER TABLE 학생2 ALTER COLUMN "소속학과" DROP NOT NULL;

CREATE TABLE 수강2 (
	학번 CHAR(6) NOT NULL,
	과목번호 CHAR(4) NOT NULL,
	신청날짜 DATE NOT NULL,
	중간성적 INT NULL DEFAULT 0,
	기말성적 INT NULL DEFAULT 0,
	평가학점 CHAR(1) NULL, -- A,B,C,D,F,P
	PRIMARY KEY (학번, 과목번호),
	FOREIGN KEY (학번) REFERENCES 학생2 (학번),
	FOREIGN KEY (과목번호) REFERENCES 과목2 (과목번호)
);

INSERT INTO 학생2
VALUES 
	('s001', '김연아', '서울 서초', 4, 23, '여', '010-1111-2222', '컴퓨터'),
	('s002', '홍길동', DEFAULT, 1, 26, '남', '010-2222-5555', '통계'),
	('s003', '이승엽', NULL, 3, 30, '남', '010-3333-4444', '정보통신'),
	('s004', '이영애', '경기 분당', 2, NULL, '여', '010-4444-5555', '정보통신'),
	('s005', '송윤아', '경기 분당', 4, 23, '여', '010-6666-7777', '컴퓨터'),
	('s006', '홍길동', '서울 종로', 2, 26, '남', '010-8888-9999', '컴퓨터'),
	('s007', '이온진', '경기 과천', 1, 23, '여', '010-2222-3333', '경영');

-- 존재하는 테이블 데이터를 불러오고 사본 만들기
INSERT INTO 과목2 SELECT * FROM 과목;
INSERT INTO 학생2 SELECT * FROM 학생; -- 제약조건 변경으로 해결 시도했지만 키값 중복으로 실패 그냥 따로 데이터 삽입하는것으로 해결
INSERT INTO 수강2 SELECT * FROM 수강;

-- 연결해야 하는 키 (S003)가 이미 있어서 못 합니다.
-- INSERT INTO 학생2
-- VALUES ('SOO3', '이순신', DEFAULT, 4, 54, '남', NULL, NULL);

TABLE 학생2;
TABLE 과목2;
TABLE 수강2;

-- ALTER TABLE문 (테이블 수정/변경)
ALTER TABLE 학생2
	ADD COLUMN 등록날짜 DATE NOT NULL DEFAULT '2025-04-08';

ALTER TABLE 수강2
	ADD COLUMN 등록날짜 DATE NOT NULL DEFAULT '2025-04-08';

ALTER TABLE 수강2 DROP COLUMN 등록날짜; -- 열 삭제

-- 학생2 테이블의 사본 만들기
CREATE TABLE 학생3 AS SELECT * FROM 학생2;
TABLE 학생3;
DROP TABLE 학생3;

-- 사용자와 권한에 대한 명령문 --
SELECT CURRENT_USER; -- POSTGRES (기본사용자)
CREATE USER superman WITH PASSWORD '0000'; 
GRANT ALL PRIVILEGES ON DATABASE nuivdb25 TO superman; -- DB에서만 권한 부여
GRANT ALL PRIVILEGES ON 학생2, 수강2, 과목2 TO superman; -- 테이블에서도 권한부여

ALTER DATABASE nuivdb25 OWNER TO superman; -- 소유자도 변경하면 모든 권한이 있다

INSERT INTO 과목2
VALUES ('c012', '데이터', 'dj408', '정보보안', 4);
-- 사용자 변경 -- 
INSERT INTO 과목2
VALUES ('c022', '데이터과학', 'dj408', '정보통신', 5);

-- 뷰 생성하기
CREATE VIEW V1_고학년학생(학생이름, 나이, 성, 학년) AS
	SELECT 이름, 나이, 성별, 학년 FROM 학생2
	WHERE 학년 >= 3 AND 학년<= 4;

SELECT * FROM V1_고학년학생;

DROP VIEW IF EXISTS V2_과목수강현황;

CREATE VIEW V2_과목수강현황(과목번호, 강의실, 수강인원수) AS
	SELECT 과목2.과목번호, 강의실, COUNT(과목2.과목번호)
	FROM 과목2 JOIN 수강2 ON 과목2.과목번호 = 수강2.과목번호
	GROUP BY 과목2.과목번호
	ORDER BY 과목2.과목번호;

SELECT * FROM V2_과목수강현황;

CREATE VIEW V3_고학년여학생 AS
	SELECT * FROM V1_고학년학생
	WHERE 성 = '여';

SELECT * FROM V3_고학년여학생;

-- 인덱스
GRANT ALL ON SCHEMA PUBLIC TO superman;
ALTER TABLE 수강2 OWNER TO superman;

CREATE INDEX idx_수강 ON 수강2(학번, 과목번호);
CREATE UNIQUE INDEX idx_과목 ON 과목2(이름 ASC);
CREATE UNIQUE INDEX idx_학생 ON 학생2(학번);


