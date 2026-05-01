-- =========================
-- DATABASE CREATION
-- =========================
CREATE DATABASE freelancehub;
USE freelancehub;

-- =========================
-- TABLE: USER
-- =========================
CREATE TABLE USER (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
    Role VARCHAR(20) CHECK (Role IN ('Client','Freelancer','Admin'))
);

-- =========================
-- TABLE: PROJECT
-- =========================
CREATE TABLE PROJECT (
    Project_ID INT AUTO_INCREMENT PRIMARY KEY,
    Client_ID INT,
    Title VARCHAR(100) NOT NULL,
    Description TEXT,
    Budget INT CHECK (Budget > 0),
    Deadline DATE,
    Status VARCHAR(20) DEFAULT 'Open',
    FOREIGN KEY (Client_ID) REFERENCES USER(User_ID)
);

-- =========================
-- TABLE: BID
-- =========================
CREATE TABLE BID (
    Bid_ID INT AUTO_INCREMENT PRIMARY KEY,
    Project_ID INT,
    Freelancer_ID INT,
    Bid_Amount INT CHECK (Bid_Amount > 0),
    Bid_Date DATE DEFAULT CURRENT_DATE,
    Cover_Letter TEXT,
    Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (Project_ID) REFERENCES PROJECT(Project_ID),
    FOREIGN KEY (Freelancer_ID) REFERENCES USER(User_ID)
);

-- =========================
-- TABLE: CONTRACT
-- =========================
CREATE TABLE CONTRACT (
    Contract_ID INT AUTO_INCREMENT PRIMARY KEY,
    Project_ID INT,
    Freelancer_ID INT,
    Start_Date DATE DEFAULT CURRENT_DATE,
    End_Date DATE,
    Total_Amount INT,
    Status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (Project_ID) REFERENCES PROJECT(Project_ID),
    FOREIGN KEY (Freelancer_ID) REFERENCES USER(User_ID)
);

-- =========================
-- TABLE: MILESTONE
-- =========================
CREATE TABLE MILESTONE (
    Milestone_ID INT AUTO_INCREMENT PRIMARY KEY,
    Contract_ID INT,
    Title VARCHAR(100),
    Amount INT CHECK (Amount > 0),
    Status VARCHAR(20) DEFAULT 'Pending',
    Due_Date DATE,
    FOREIGN KEY (Contract_ID) REFERENCES CONTRACT(Contract_ID)
);

-- =========================
-- TABLE: ESCROW
-- =========================
CREATE TABLE ESCROW (
    Escrow_ID INT AUTO_INCREMENT PRIMARY KEY,
    Contract_ID INT,
    Total_Deposited INT,
    Remaining_Balance INT,
    Created_Date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (Contract_ID) REFERENCES CONTRACT(Contract_ID)
);

-- =========================
-- INSERT SAMPLE DATA
-- =========================

-- USERS
INSERT INTO USER (Name, Email, Password, Role) VALUES
('Anisa','anisa@gmail.com','123','Client'),
('Akshat','akshat@gmail.com','123','Freelancer'),
('Admin','admin@gmail.com','admin','Admin');

-- PROJECT
INSERT INTO PROJECT (Client_ID, Title, Description, Budget, Deadline)
VALUES (1, 'Website Development', 'Build a responsive website', 5000, '2026-05-10');

-- BID
INSERT INTO BID (Project_ID, Freelancer_ID, Bid_Amount, Cover_Letter)
VALUES (1, 2, 4500, 'I can deliver this project in 7 days');

-- CONTRACT
INSERT INTO CONTRACT (Project_ID, Freelancer_ID, Total_Amount, End_Date)
VALUES (1, 2, 4500, '2026-05-15');

-- ESCROW
INSERT INTO ESCROW (Contract_ID, Total_Deposited, Remaining_Balance)
VALUES (1, 4500, 4500);

-- MILESTONE
INSERT INTO MILESTONE (Contract_ID, Title, Amount, Status, Due_Date) VALUES
(1, 'Frontend Completion', 2000, 'Pending', '2026-05-08'),
(1, 'Backend Completion', 2500, 'Pending', '2026-05-15');

-- =========================
-- BASIC QUERIES
-- =========================

-- VIEW USERS
SELECT * FROM USER;

-- VIEW PROJECTS
SELECT * FROM PROJECT;

-- VIEW BIDS
SELECT * FROM BID;

-- VIEW CONTRACTS
SELECT * FROM CONTRACT;

-- VIEW MILESTONES
SELECT * FROM MILESTONE;

-- VIEW ESCROW
SELECT * FROM ESCROW;

-- =========================
-- JOIN QUERIES
-- =========================

-- PROJECT + CLIENT
SELECT P.Project_ID, P.Title, U.Name AS Client_Name
FROM PROJECT P
JOIN USER U ON P.Client_ID = U.User_ID;

-- BID + FREELANCER
SELECT B.Bid_ID, B.Bid_Amount, U.Name AS Freelancer_Name
FROM BID B
JOIN USER U ON B.Freelancer_ID = U.User_ID;

-- CONTRACT DETAILS
SELECT C.Contract_ID, P.Title, U.Name AS Freelancer_Name
FROM CONTRACT C
JOIN PROJECT P ON C.Project_ID = P.Project_ID
JOIN USER U ON C.Freelancer_ID = U.User_ID;

-- =========================
-- AGGREGATE FUNCTIONS
-- =========================

SELECT SUM(Remaining_Balance) AS Total_Balance FROM ESCROW;
SELECT AVG(Bid_Amount) AS Avg_Bid FROM BID;

-- =========================
-- TRIGGER: ESCROW PAYMENT RELEASE
-- =========================

DELIMITER //
CREATE TRIGGER release_payment
AFTER UPDATE ON MILESTONE
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Approved' THEN
        UPDATE ESCROW
        SET Remaining_Balance = Remaining_Balance - NEW.Amount
        WHERE Contract_ID = NEW.Contract_ID;
    END IF;
END //
DELIMITER ;

-- =========================
-- PROCEDURE: CREATE CONTRACT
-- =========================

DELIMITER //
CREATE PROCEDURE CreateContract(
    IN p_project INT,
    IN p_freelancer INT,
    IN p_amount INT
)
BEGIN
    INSERT INTO CONTRACT(Project_ID, Freelancer_ID, Total_Amount)
    VALUES(p_project, p_freelancer, p_amount);
END //
DELIMITER ;

-- =========================
-- PROCEDURE: SHOW PROJECTS (CURSOR)
-- =========================

DELIMITER //
CREATE PROCEDURE ShowProjects()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE p_id INT;
    DECLARE p_title VARCHAR(100);

    DECLARE cur CURSOR FOR SELECT Project_ID, Title FROM PROJECT;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO p_id, p_title;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT p_id AS Project_ID, p_title AS Title;
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;

-- =========================
-- FUNCTION: CHECK BALANCE
-- =========================

DELIMITER //
CREATE FUNCTION CheckBalance(cid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE bal INT;

    SELECT Remaining_Balance INTO bal
    FROM ESCROW
    WHERE Contract_ID = cid;

    RETURN bal;
END //
DELIMITER ;

-- =========================
-- UPDATE EXAMPLE
-- =========================

UPDATE MILESTONE
SET Status = 'Approved'
WHERE Milestone_ID = 1;

-- =========================
-- DELETE EXAMPLE
-- =========================

DELETE FROM BID WHERE Bid_ID = 1;