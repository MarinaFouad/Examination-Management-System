USE ExaminationSystem;
-- 1
EXEC [dbo].[ShowQuestions] 'OOP';
Go

-- 2
EXEC dbo.AddQuesToExam 2,15
Go

-- 3
EXEC dbo.CreataQuestion 'Type of Errors in Progemming Language',10, 'All', 
			'before run,during run,All'
GO

-- 4
EXEC dbo.CreataQuestion 'What is a Programming',10, 'Programming is a language that are understood by computer'
Go

-- 5
EXEC dbo.CreateExam '17:05', '18:5', '02-01-2024', 0, 5, 'Null', 1  
Go

--6
EXEC dbo.AddStudentToExam 1, 2
Go

--7
EXEC dbo.DeleteQuesFromExam 2, 2
Go

--8
EXEC dbo.UpdateQuesExam 2, 2,5,null
Go

--9
Exec dbo.RmStudentExam 2, 7
Go
--10
SELECT * FROM dbo.GetMyCourses
Go

--11
SELECT * FROM dbo.GetAllExams 
Go

--12
SELECT * FROM dbo.GeNumCourses 
Go

--13
EXEC dbo.GetStudentAnswers 7, 2
Go



------------------------------------------------------------

INSERT INTO Person.Person (Email, Name, Password)
Values('faresA', 'Mohamed Yasser', 'malkYass123')

SELECT * FROM Person.Person
INSERT INTO Person.Instractor(InsID, IsManager) VALUES(15, 1)


EXEC Person.InsertPerson 15, 'Student', 'Fares Ahmed', 'fars_ahm' , '123456'
Exec Person.InsertStudent 16, 1, 1,1,5
