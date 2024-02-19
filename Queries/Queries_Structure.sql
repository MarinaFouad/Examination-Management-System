SP_CONFIGURE 'SHOW ADVANCE',1
GO
RECONFIGURE WITH OVERRIDE
GO
SP_CONFIGURE 'AGENT XPs',1
GO
RECONFIGURE WITH OVERRIDE
GO
--CREATE DATABASE ExaminationSystem ON(
--	Name ='LibFile',
--	FileName= N'C:\Users\my137\OneDrive - Beni-suef University faculty of fcis\Desktop\My Subjects\dotnet Full Stack\ITI\SQL\project\working\DB\ExaminationSystem_logical.mdf',
--	Size=10MB, 
--	FileGrowth=10%,
--	MaxSize=50MB	
--)
--Log ON(
--	Name ='LogFile',
--	FileName= 'C:\Users\my137\OneDrive - Beni-suef University faculty of fcis\Desktop\My Subjects\dotnet Full Stack\ITI\SQL\project\working\DB\ExaminationSystem_log.ldf',
--	Size=5MB,
--	FileGrowth=10%,
--	MaxSize=40MB
--);

Go
CREATE SCHEMA General;
Go
CREATE SCHEMA Content;
Go
CREATE SCHEMA Person;
Go

CREATE TABLE General.Branch (
	BranID INT IDENTITY(1,1),
    BranName  NVARCHAR(10),
	CONSTRAINT BraPK PRIMARY KEY (BranID)
)
CREATE TABLE General.Department (
    DepID INT IDENTITY(1,1),
    DepName  NVARCHAR(10),
	CONSTRAINT DepPK PRIMARY KEY (DepID)
)
CREATE TABLE General.Track(
    TraID INT IDENTITY(1,1),
    TraName NVARCHAR(10),
	CONSTRAINT TraPK PRIMARY KEY (TraID)
)
CREATE TABLE General.Bran_has_Dep_has_Track(
    BranID INT,
    DepID INT,
    TraID INT,
	CONSTRAINT BranDepTraPK PRIMARY KEY (BranID ,DepID ,TraID),
	CONSTRAINT BranDepTraBranFK FOREIGN KEY (BranID) REFERENCES General.Branch(BranID )
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BranDepTraDepFK FOREIGN KEY (DepID) REFERENCES General.Department(DepID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BranDepTraTraFK FOREIGN KEY (TraID) REFERENCES General.Track(TraID)
	ON DELETE CASCADE ON UPDATE CASCADE,
)

CREATE TABLE Content.Course(
    CourseID INT IDENTITY(1,1),
    CourseName NVARCHAR(20),
    [Description] NVARCHAR(2000),
    MaxDegree INT NOT NULL DEFAuLT(100),
    MinDegree INT NOT NULL DEFAuLT(50),
    Duration INT NOT NULL DEFAULT(0), -- Number of Dayes
	CONSTRAINT CourPK PRIMARY KEY (CourseID)
)

--  Good for performance always used with join for NVARCHAR
CREATE TABLE Person.Person(
	ID INT IDENTITY(1,1),
	[Name] NVARCHAR(50) Not Null, 
	[Email] NVARCHAR(100) NOT NULL UNIQUE,
	[Password] NVARCHAR(20) NOT NULL,
	-- [Type] BIT, -- 0 student 1 instractur
	CONSTRAINT PersPK PRIMARY KEY(ID)
)
CREATE TABLE Person.Student (
	StuID INT,
    BranID INT ,
    DepID INT ,
    TrackID INT,
    InTake INT NOT NULL,
	CONSTRAINT StuIDFK FOREIGN KEY (StuID) REFERENCES Person.Person(ID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT StuPK PRIMARY KEY (StuID),
	CONSTRAINT StuBranFK FOREIGN KEY (BranID) REFERENCES General.Branch(BranID)
	ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT StuDepFK FOREIGN KEY (DepID) REFERENCES General.Department(DepID)
	ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT StuTraFK FOREIGN KEY (TrackID) REFERENCES General.Track(TraID)
	ON DELETE SET NULL ON UPDATE CASCADE
)

CREATE TABLE Content.Exam(
    ExamID INT IDENTITY(1,1),
    Degree INT DEFAULT(0),
    StartTime TIME(0) NOT NULL DEFAULT(GetDate()),
    EndTime TIME(0) NOT NULL,
	[Date] DATE NOT NULL,
	[Type]  BIT NOT NULL, -- VARCCHAR(11),
    CourseID INT,
	Intake INT, 
	AllowOptions NVARCHAR(1000),
	CONSTRAINT ExPK PRIMARY KEY (ExamID),
	CONSTRAINT ExCourFK FOREIGN KEY (CourseID) REFERENCES Content.Course(CourseID)
	ON DELETE SET NULL ON UPDATE CASCADE
	--CONSTRAINT TypeRan CHECK(LOWER([Type]) = 'exam' or LOWER([Type]) = 'corrective')

	--CREATE VIEW ExamView AS
	--	SELECT CASE [Type] WHEN 0 THEN 'Exam' WHEN 1 THEN 'Corrective' END AS [Type] FROM Exam

)

CREATE TABLE Content.Stu_enrol_ex (
    StuID INT,
    ExamID INT,
	JoinDate DATETIME DEFAULT(GETDATE()),
	CONSTRAINT StuEnrExPK PRIMARY KEY (StuID, ExamID),
    CONSTRAINT StuEnrExStuFK FOREIGN KEY (StuID) REFERENCES Person.Student(StuID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT StuEnrExExFK FOREIGN KEY (ExamID) REFERENCES Content.Exam(ExamID)
	ON DELETE CASCADE ON UPDATE CASCADE
)
-- mostly used with join 
CREATE TABLE Content.QuestionTable ( 
    QID INT IDENTITY(1,1),
    Question NVARCHAR(2000), -- 2000 char 300 - 400 words
    Point INT NOT NULL,
    CorrectAns NVARCHAR(2000),
	CONSTRAINT QuesPK PRIMARY KEY (QID)
)
---- mostly used with join 
--CREATE TABLE Content.MultQues(
--    QID INT,
--	CONSTRAINT MultQuesPK PRIMARY KEY (QID),
--	CONSTRAINT MultQuesFK FOREIGN KEY (QID) REFERENCES Content.QuestionTable (QID)
--	)
-- mostly used with join 
CREATE TABLE Content.ChMultQues (
    QID INT,
	OptID INT IDENTITY(1,1),
	[Option] NVARCHAR(1000) NOT NULL, -- Text store in image/text pages LOB pages
	CONSTRAINT ChMultQuesPK PRIMARY KEY (QID, OptID),
	CONSTRAINT ChMultQuesFK FOREIGN KEY (QID) REFERENCES Content.QuestionTable(QID)
	ON DELETE CASCADE ON UPDATE CASCADE
   )

CREATE TABLE Content.Ex_has_Ques(
	ExamID INT,
	QID INT,
	CONSTRAINT ExQuesQuesFK FOREIGN KEY (QID) REFERENCES Content.QuestionTable (QID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ExQuesExFK FOREIGN KEY (ExamID) REFERENCES Content.Exam(ExamID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ExQuesPK PRIMARY KEY (ExamID, QID)
)
---

CREATE TABLE Content.Stu_ans_Que_Ex (
    StuID INT,
    ExamID INT,
    QID INT  ,
	Result int,
    StuAns NVARCHAR(2000),
	CONSTRAINT StuAnsQuesPK PRIMARY KEY (StuID, ExamID, QID),
	CONSTRAINT StuAnsQuesExFK FOREIGN KEY (ExamID) REFERENCES Content.Exam(ExamID),
	CONSTRAINT StuAnsQuesQuFK FOREIGN KEY (QID) REFERENCES Content.QuestionTable (QID),
	CONSTRAINT StuAnsQuesStFK FOREIGN KEY (StuID) REFERENCES Person.student(StuID)
)

CREATE TABLE Person.Instractor (
    InsID INT,
	IsManager BIT NOT NULL,
	CONSTRAINT InstIDFK FOREIGN KEY (InsID) REFERENCES Person.Person(ID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT InstPK PRIMARY KEY (InsID)
)

CREATE TABLE Content.Class (
    ClassID INT IDENTITY(1,1),
    ClassName  NVARCHAR(10), -- not used in selection many times
	CONSTRAINT ClassPK PRIMARY KEY (ClassID)
	)
CREATE TABLE Content.Inst_teach_cour_in_class  ( 
      ClassID INT ,
	  CourseID INT,
      InsID INT, 
	  EnrolledYear INT NOT NULL,
	  CONSTRAINT InstCourClsPK PRIMARY KEY (CourseID,InsID , ClassID),
	  
	  CONSTRAINT InstCourClsInFK FOREIGN KEY (InsID) REFERENCES Person.Instractor(InsID)
	  ON DELETE CASCADE ON UPDATE CASCADE,

	  CONSTRAINT InstCourClsCouFK FOREIGN KEY (CourseID ) REFERENCES Content.Course(CourseID)
	  ON DELETE CASCADE ON UPDATE CASCADE,
	  
	  CONSTRAINT InstCourClsClsFK FOREIGN KEY (ClassID ) REFERENCES Content.Class(ClassID)
	  ON DELETE CASCADE ON UPDATE CASCADE
	  )


--SELECT * FROM sys.dm_db_index_physical_stats
--    (DB_ID(N'Test'), OBJECT_ID(N'Person.Address'), NULL, NULL , 'DETAILED');

--CREATE UNIQUE INDEX Inst_Cour_Cls_ind_course ON Inst_teach_cour_in_class(ClassID, CourseID, EnrolledYear) 
--CREATE UNIQUE INDEX Inst_Cour_Cls_ind_instractor ON Inst_teach_cour_in_class(ClassID, InsID, EnrolledYear) 

--CREATE TABLE Inst_teach_cour(
--	CourseID INT,
--    InsID INT, 
--	CONSTRAINT InstTeaCourPK PRIMARY KEY (CourseID,InsID ),
--	CONSTRAINT InstTeaCourInsFK FOREIGN KEY (InsID) REFERENCES Instractor(InsID),
--	CONSTRAINT InstTeaCourCouFK FOREIGN KEY (CourseID ) REFERENCES Course(CourseID)
--)