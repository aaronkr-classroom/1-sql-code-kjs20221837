-- 숫자 내장 함수
SELECT ABS(17), ABS(-17), CEIL(3.28), FLOOR(4.97);


SELECT 학번, 
SUM(기말성적)::FLOAT / COUNT(*) AS 평균성적
-- ROUND(SUM(기말성적)::FLOAT / COUNT(*), 2) -- MYSQL ROUND(숫자, 자릿수)
FROM 수강2 GROUP BY 학번;


SELECT LENGTH(소속학과), RIGHT(학번,2), REPEAT('*', 나이),
	CONCAT(소속학과,'학과')
FROM 학생2;


SELECT SUBSTRING(주소, 1, 2), REPLACE(SUBSTRING(휴대폰번호, 5, 9), '-', '*')
FROM 학생2;


-- 날짜 / 시간 내장 함수
SELECT 신청날짜, DATE_TRUNC('MONTH', 신청날짜) + INTERVAL '1 MONTH - 1DAY' AS 마지막날
FROM 수강2
WHERE EXTRACT (YEAR FROM 신청날짜) = 2019;
-- 2019/02/31


SELECT CURRENT_TIMESTAMP, 신청날짜 - DATE '2019-01-01' AS 일수차이
FROM 수강2;


SELECT 신청날짜,
	TO_CHAR(신청날짜, 'MON/DD/YY') AS 형식1,
	TO_CHAR(신청날짜, 'YYYY"년"MM"월"DD"일"') AS 형식2
FROM 수강2;


-- 저장 프로시저
CREATE OR REPLACE PROCEDURE InsertOrUpdateCourse(
	IN CourseNo VARCHAR(4),
	IN CourseName VARCHAR(20),
	IN CourseRoom CHAR(3),
	IN CourseDept VARCHAR(20),
	IN CourseCredit INT
)
LANGUAGE plpgsql
as $$ -- DELIMITER (MYSQL)
DECLARE
	COUNT INT; -- 지역 변수
BEGIN
	-- 과목이 이미 존재 하는지 확인
	SELECT COUNT(*) INTO COUNT FROM 과목2 WHERE 과목번호 = CourseNo;
	IF Count = 0 THEN -- 과목이 존재하지 않으면 새 과목 추가
		INSERT INTO 과목2(과목번호, 이름, 강의실, 개설학과, 시수)
		VALUES(CourseNo, CourseName, CourseRoom, CourseDept, CourseCredit);
	ELSE -- 과목이 존재하면 기존 과목 업데이트
		UPDATE 과목2
		SET 이름 = CourseName, 강의실 = CourseRoom, 개설학과 = CourseDept, 시수 = CourseCredit
		WHERE 과목번호 = CourseNo;
	END IF;
END;
$$;


-- 새 과목 추가하기
CALL INSERTORUPDATECOURSE('C006', '연극학개론', '310', '교양학부', 2);
SELECT * FROM 과목2;

-- 과목 업데이트하기
CALL INSERTORUPDATECOURSE('C006', '연극학개론', '410', '교양학부', 2);
SELECT * FROM 과목2;


-- BESTSCORE 프로시저
CREATE OR REPLACE PROCEDURE SELECTAVERAGEOFBESTSCORE(
	IN SCORE INT,
	OUT COUNT INT
)
LANGUAGE PLPGSQL
AS $$
DECLARE -- 여러가지 지역 변수 정의
	NOMOERDATE BOOLEAN DEFAULT FALSE;
	MIDTERM INT;
	FINAL INT;
	BEST INT;
	SCORELISTCURSOR CURSOR FOR SELECT 중간성적, 기말성적 FROM 수강2;
BEGIN 
	COUNT :=0; -- COUNT 변수 초기화
	OPEN SCORELISTCURSOR; -- 커서를 열고 각 레코드(행,투플)를 반복
	LOOP
		FETCH SCORELISTCURSOR INTO MIDTERM, FINAL;
		EXIT WHEN NOT FOUND;

		-- 더 높은 성적을 BEST에 설정
		IF MIDTERM > FINAL THEN
			BEST := MIDTERM;
		ELSE
			BEST := FINAL;
		END IF;

		-- 주어진 점수 이상인 경우 COUNT 증가
		IF BEST >= SCORE THEN
			COUNT := COUNT + 1;
		END IF;
	END LOOP;
END;
$$;


-- MYSQL에서만 간단해
-- CALL SELECTAVERAGEOFBESTSCORE(95,@COUNT);
-- SELECT @COUNT;

DO $$ -- POSTGRESQL 스타일
DECLARE COUNT INT;
BEGIN
	CALL SELECTAVERAGEOFBESTSCORE(95, COUNT);
	RAISE NOTICE 'COUNT: %', COUNT;
END;
$$;


-- 사용자 정의한 함수
CREATE OR REPLACE FUNCTION FN_GRADE(GRADE CHAR)
RETURNS TEXT AS $$
BEGIN
	CASE GRADE -- SWITCH문과 같이
		WHEN 'A' THEN RETURN '최우수';
		WHEN 'B' THEN RETURN '우수';
		WHEN 'C' THEN RETURN '보통';
		ELSE RETURN '미흡';
	END CASE;
END;
$$ LANGUAGE PLPGSQL;

SELECT 학번, 과목번호, 평가학점, FN_GRADE(평가학점) AS 평가등급 FROM 수강2;



-- 트리거
CREATE TABLE 남녀학생총수(
	성별 CHAR(1) NOT NULL DEFAULT 0,
	인원수 INT NOT NULL DEFAULT 0,
	PRIMARY KEY (성별)
	);
INSERT INTO 남녀학생총수 SELECT '남', COUNT(*) FROM 학생2 WHERE 성별 = '남';
INSERT INTO 남녀학생총수 SELECT '여', COUNT(*) FROM 학생2 WHERE 성별 = '여';
SELECT * FROM 남녀학생총수;


-- 2. 사용자 정의한 FUNCTION을 만들기
CREATE OR REPLACE FUNCTION AFTERINSERTSTUDENT()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN
	IF (NEW.성별 = '남') THEN
		UPDATE 남녀학생총수 SET 인원수 = 인원수 + 1 WHERE 성별 = '남';
	ELSEIF (NEW.성별 = '여') THEN
		UPDATE 남녀학생총수 SET 인원수 = 인원수 + 1 WHERE 성별 = '여';
	END IF;
	RETURN NEW;
END;
$$;


-- 3. 트리거를 생성하기
CREATE OR REPLACE TRIGGER AFTER_INSERT_STUDENT
AFTER INSERT ON 학생2 FOR EACH ROW
EXECUTE FUNCTION AFTERINSERTSTUDENT();

-- 4. 트리거를 실행한다
SELECT * FROM 남녀학생총수;
INSERT INTO 학생2
VALUES('S008', '최동석', '경기 수원', 2, 26, '남', '010-8888-6666', '컴퓨터');
SELECT * FROM 남녀학생총수;









