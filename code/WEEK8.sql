BEGIN;
DELETE FROM 학생 WHERE 학생.성별 = '남자';
DELETE FROM 학생 WHERE 학생.성별 = '여';
SELECT * FROM 학생;
ROLLBACK

BEGIN TRANSACTION;
UPDATE 학생 SET 이름 = '홍길순' WHERE 학번 = 'S002';
SELECT * FROM 학생;
ROLLBACK

COMMIT


