CREATE DATABASE StudentManagement;
use StudentManagement;
CREATE TABLE Students(
student_id VARCHAR(5) PRIMARY KEY,
full_name VARCHAR(50) NOT NULL,
total_debt DECIMAL(10,2) DEFAULT 0
);
CREATE TABLE Subjects(
subject_id VARCHAR(5) PRIMARY KEY,
subject_name VARCHAR(50) NOT NULL,
credits INT CHECK (credits > 0)
);
CREATE TABLE Grades(
student_id VARCHAR(5),
FOREIGN KEY(student_id) references Students(student_id),
subject_id VARCHAR(5) ,
PRIMARY KEY(student_id,subject_id),
FOREIGN KEY(subject_id) references Subjects(subject_id),
score DECIMAL(4,2) CHECK (score BETWEEN 0 AND 10)	
);
create table grade_log(
log_id INT PRIMARY KEY AUTO_INCREMENT,
student_id VARCHAR(5) ,
FOREIGN KEY(student_id) references Students(student_id),
old_score DECIMAL(4,2),
new_score DECIMAL(4,2),
change_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
CREATE TRIGGER tg_check_score
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    IF NEW.score < 0 THEN
        SET NEW.score = 0;
    ELSEIF NEW.score > 10 THEN
        SET NEW.score = 10;
    END IF;
END //
DELIMITER ;
DELIMITER //
START TRANSACTION;
INSERT INTO Students(student_id, full_name, total_debt)
VALUES ('SV02', 'Ha Bich Ngoc', 0);
UPDATE Students
SET total_debt = 5000000
WHERE student_id = 'SV02';
COMMIT;
DELIMITER //
CREATE TRIGGER tg_log_grade_update
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    INSERT INTO grade_log(student_id, old_score, new_score, change_date)
    VALUES (OLD.student_id, OLD.score, NEW.score, NOW());
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_pay_tuition()
BEGIN
    DECLARE v_debt INT DEFAULT 0;

    START TRANSACTION;

    UPDATE Students
    SET total_debt = total_debt - 2000000
    WHERE student_id = 'SV01';
    SELECT total_debt INTO v_debt
    FROM Students
    WHERE student_id = 'SV01';
    IF v_debt < 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER  tg_prevent_pass_update
BEFORE UPDATE on grades
FOR EACH ROW
BEGIN
	if OLD.score<=4.0
    then
    SIGNAL SQLSTATE '45000'
    set message_text='Khong cho cap nhat';
    end if;
END //
DELIMITER ;