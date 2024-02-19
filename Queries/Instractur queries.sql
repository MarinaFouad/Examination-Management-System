SET QUOTED_IDENTIFIER OFF;
Go
CREATE FUNCTION GetUserID()
RETURNS INT 
BEGIN	
	DECLARE @id INT
	SELECT @id = ID FROM Person.Person 
		WHERE Email = (SELECT suser_name())
	RETURN @id
END
Go

CREATE FUNCTION InshasCourse(@ins_id INT, @course_id INT)
RETURNS BIT 
BEGIN
	DECLARE @has_course INT
	SELECT @has_course = Count(ins_cour.CourseID) 
		FROM Content.Inst_teach_cour_in_class as ins_cour
		Where ins_cour.CourseID = @course_id 
			and  ins_cour.InsID = @ins_id
	IF @has_course = 0
		BEGIN
		RETURN 0 
		END
	RETURN 1
END
Go

CREATE FUNCTION dbo.GetQuesByCourID(@course_id INT)
RETURNS TABLE
AS RETURN 
	SELECT qu.* FROM Content.Exam as ex inner join Content.Ex_has_Ques as ex_qu 
		ON ex_qu.ExamId = ex.ExamID inner join Content.QuestionTable as qu
			ON qu.QID = ex_qu.QID
	WHERE ex.CourseID = @course_id 
GO

CREATE PROC dbo.ShowQuestions(@course_name NVARCHAR(20))
AS 
	DECLARE @course_id INT
	
	SELECT @course_id = co.CourseID
		FROM Content.Course as co
		WHERE co.CourseName = @course_name
	IF @course_id is null
		PRINT 'This course name not found'
	ELSE IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		SELECT * FROM dbo.GetQuesByCourID(@course_id)
	ELSE
		 PRINT 'You can not acces this Course'
Go

CREATE PROC dbo.AddQuesToExam(@exam_id INT, @ques_id INT = NULL)
AS
	DECLARE @course_id INT
	SELECT @course_id = ex.CourseID 
		FROM Content.Exam as ex
		WHERE ex.ExamID = @exam_id
	IF @course_id is null
		BEGIN
			PRINT 'You Must add Exam First'
		END
	ELSE
		BEGIN
			DECLARE @t TABLE(id INT)
			DECLARE @ques_num INT
		    IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
				BEGIN
					INSERT into @t SELECT QID FROM dbo.GetQuesByCourID(@course_id)
					SELECT @ques_num = COUNT(id) FROM @t
			
					if @ques_id is null
						BEGIN
						SET @ques_id = CONVERT(INT,RAND() * @ques_num)
						END
					BEGIN TRY
						INSERT INTO Content.Ex_has_Ques VALUES(@exam_id, @ques_id)
					END TRY
					BEGIN CATCH
						SELECT ERROR_MESSAGE() AS ErrorMessage 
					END CATCH
				END
		    ELSE PRINT 'This Exam does not belong to Course. You can not access to it'
		END
Go

CREATE PROC dbo.CreataQuestion(
				@ques_header NVARCHAR(2000), @point INT,
				@correct_ans NVARCHAR(2000), @options NVARCHAR(4000) =  NULL
				)
AS 
	INSERT INTO Content.QuestionTable
		VALUES (@ques_header, @point, @correct_ans)
	
	DECLARE  @q_id INT
	SELECT @q_id =  SCOPE_IDENTITY () 
	
	IF @options is not null 
		BEGIN
			DECLARE curs CURSOR FOR
			SELECT [value] FROM string_split(@options, ',')			
			declare @option NVARCHAR(1000)
		
			OPEN curs
			FETCH NEXT FROM curs INTO @option
			WHILE  @@FETCH_STATUS = 0
				BEGIN
				INSERT INTO Content.ChMultQues(QID, [Option])
					VALUES(@q_id, @option)
				FETCH NEXT FROM curs INTO @option
				END
			Close curs
		END
Go

CREATE PROC dbo.CreateExam(@st_time TIME,
						   @end_time TIME, @date DATE,
						   @type BIT, @intake INT,
						   @allow_opt NVARCHAR(1000),
						   @course_id INT)
AS
	IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		BEGIN
			INSERT INTO Content.Exam ([Date], StartTime,
									  EndTime, [Type], Intake, AllowOptions, CourseID)
			VALUES(@date, @st_time, @end_time, @type, @intake, @allow_opt, @course_id)
		END
	ELSE PRINT 'You are trying to acces to course that is not allowed for You'
GO

CREATE PROC dbo.AddStudentToExam(@student_id INT, @exam_id INT)
AS
	DECLARE @course_id INT
	SELECT @course_id = ex.CourseID 
		FROM Content.Exam as ex
		WHERE ex.ExamID = @exam_id
	IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		BEGIN
			BEGIN TRY
				INSERT INTO Content.Stu_enrol_ex (StuID, ExamID)
					VALUES(@student_id, @exam_id)
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE() AS ErrorMessage 
			END CATCH
		END
	ELSE PRINT 'This Exam does not belong to Your Courses. You can not access to it'
Go

CREATE PROC dbo.DeleteQuesFromExam(@exam_id INT, @ques_id INT)
AS
	DECLARE @course_id INT
	SELECT @course_id = ex.CourseID 
		FROM Content.Exam as ex
		WHERE ex.ExamID = @exam_id
	IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		BEGIN
			BEGIN TRY
				DELETE FROM Content.Ex_has_Ques 
					WHERE QID = @ques_id and @exam_id = ExamID
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE() AS ErrorMessage 
			END CATCH
				
		END
	ELSE PRINT 'This Exam does not belong to Your Courses. You can not access to it' 
Go	

CREATE PROC dbo.UpdateQuesExam(@exam_id INT, @ques_id INT,
							@new_exam_id INT = NULL, @new_ques_id INT = NULL)
AS
	DECLARE @course_id INT
	SELECT @course_id = ex.CourseID 
		FROM Content.Exam as ex
		WHERE ex.ExamID = @exam_id
	IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		BEGIN
			BEGIN TRY
				IF @new_exam_id is null and @new_ques_id is null
					PRINT 'You do not updated anything' 
				ELSE IF @new_exam_id is null 
					UPDATE Content.Ex_has_Ques SET QID = @new_ques_id
						WHERE QID = @ques_id and @exam_id = ExamID
				ELSE IF @new_ques_id is null
					UPDATE Content.Ex_has_Ques SET ExamID = @new_exam_id
						WHERE QID = @ques_id and @exam_id = ExamID
				ELSE 
					UPDATE Content.Ex_has_Ques 
					SET ExamID = @new_exam_id, QID = @new_ques_id
						WHERE QID = @ques_id and @exam_id = ExamID
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE() AS ErrorMessage 
			END CATCH		
		END
	ELSE PRINT 'This Exam does not belong to Your Courses. You can not access to it' 
Go

CREATE PROC dbo.RmStudentExam(@exam_id INT, @student_id INT)
AS
	DECLARE @course_id INT
		SELECT @course_id = ex.CourseID 
			FROM Content.Exam as ex
			WHERE ex.ExamID = @exam_id
	IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		BEGIN
			BEGIN TRY
				DELETE FROM Content.Stu_enrol_ex 
				WHERE StuID = @student_id and ExamID = @exam_id
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE() AS ErrorMessage 
			END CATCH
		END
	ELSE PRINT 'This Exam does not belong to Your Courses. You can not access to it'
Go	

CREATE PROC dbo.GetStudentAnswers(@student_id INT, @exam_id INT)
AS
	DECLARE @course_id INT
	SELECT @course_id = ex.CourseID 
		FROM Content.Exam as ex
		WHERE ex.ExamID = @exam_id
	IF dbo.InshasCourse(dbo.GetUserID(), @course_id) = 1
		BEGIN
			SELECT per.[Name], stu_ques.StuAns FROM Content.Stu_ans_Que_Ex as stu_ques
			inner join Person.Person as per
				ON per.ID = stu_ques.StuID
			WHERE stu_ques.ExamID = @exam_id and stu_ques.StuID = @student_id
		END
	ELSE PRINT 'This Exam does not belong to Your Courses. You can not access to it'
Go

CREATE VIEW dbo.GetMyData AS
	SELECT per.*, ins.IsManager  FROM Person.Person as per
	inner join Person.Instractor as ins
		ON per.ID = ins.InsID
	WHERE per.ID = dbo.GetUserID()
Go
CREATE VIEW dbo.GetMyCourses AS
	SELECT cour.* FROM Content.Inst_teach_cour_in_class as ins_cour
	inner join Content.Course as cour
		ON cour.CourseID = ins_cour.CourseID
	WHERE ins_cour.InsID = dbo.GetUserID()
Go

CREATE VIEW dbo.GetAllExams AS
	SELECT ex.ExamID, ex.Date, ex.StartTime, ex.EndTime,
		CASE ex.[Type] WHEN 0 THEN 'Exam' WHEN 1 THEN 'Corrective' END as 'Type', ex.Degree, ex.Intake, ex.AllowOptions
	FROM Content.Inst_teach_cour_in_class as ins_cour
	inner join Content.Course as cour
		ON cour.CourseID = ins_cour.CourseID
	inner join Content.Exam as ex
		ON ex.CourseID = ins_cour.CourseID
	WHERE ins_cour.InsID = dbo.GetUserID()
Go

CREATE VIEW dbo.GeNumCourses AS
	SELECT Count(cour.CourseID) as 'Number of Courses' FROM Content.Inst_teach_cour_in_class as ins_cour
	inner join Content.Course as cour
		ON cour.CourseID = ins_cour.CourseID
	WHERE ins_cour.InsID = dbo.GetUserID()
Go

CREATE FUNCTION dbo.GetQuestion(@id INT)
RETURNS TABLE 
AS
RETURN SELECT ques.QID, ques.Question, ques.Point, 
			  opts.[Option] FROM Content.QuestionTable as ques
		left join Content.ChMultQues as opts
			ON opts.QID = ques.QID
		WHERE  ques.QID = @id
Go

-------------------------------------------------------------------------

CREATE TRIGGER Person.LoginInst ON [Person].[Instractor]
AFTER INSERT
AS 
BEGIN
	DECLARE @email NVARCHAR(50), @pass NVARCHAR(20), @is_manger BIT
	
	SELECT @email = pr.Email, @pass = pr.[Password], @is_manger = ins.IsManager
	FROM inserted as ins
		inner join Person.Person as pr
		ON pr.ID = ins.InsID
	
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = N' CREATE LOGIN ' + QUOTENAME(@email) + 
			   N' WITH PASSWORD = ' + QUOTENAME(@pass, '''') + 
               N'; CREATE USER ' + QUOTENAME(@email) +
		       N' FOR LOGIN ' + QUOTENAME(@email)
    EXEC(@sql)
   
   SET @sql = N' GRANT EXECUTE ON dbo.ShowQuestions TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.AddQuesToExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.CreataQuestion TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.CreateExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.AddStudentToExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.DeleteQuesFromExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.UpdateQuesExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.RmStudentExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.GetStudentAnswers TO ' + QUOTENAME(@email) +
			   N' GRANT SELECT ON dbo.GetMyData TO ' + QUOTENAME(@email) +
			   N' GRANT SELECT ON dbo.GetMyCourses TO ' + QUOTENAME(@email) +
			   N' GRANT SELECT ON dbo.GetAllExams TO ' + QUOTENAME(@email) +
			   N' GRANT SELECT ON dbo.GeNumCourses TO ' + QUOTENAME(@email) 
   EXEC(@sql)

   If @is_manger = 1
		BEGIN
			SET @sql = N' GRANT EXECUTE ON Person.InsertStudent TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Person.InsertInstractor TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Person.InsertPerson TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Content.InsertCourse TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Content.InsertClass TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Content.Insert_Instractor_Course_In_Class TO ' + QUOTENAME(@email) +		
					N' GRANT EXECUTE ON General.InsertData TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Person.UpdateInstractor TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Person.UpdateStudent TO ' + QUOTENAME(@email) +	
					N' GRANT EXECUTE ON Content.UpdateCourse TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Content.UpdateClass TO ' + QUOTENAME(@email) +		
					N' GRANT EXECUTE ON Content.UpdateInst_teach_cour_in_class TO ' + QUOTENAME(@email) +			
					N' GRANT EXECUTE ON General.UpdateBranch TO ' + QUOTENAME(@email) +				
					N' GRANT EXECUTE ON General.UpdateDepartment TO ' + QUOTENAME(@email) +			
					N' GRANT EXECUTE ON General.UpdateTrack TO ' + QUOTENAME(@email) +				
					N' GRANT EXECUTE ON General.UpdateBran_has_Dep_has_Track TO ' + QUOTENAME(@email) +
					N' GRANT EXECUTE ON Person.DeleteStudent TO ' + QUOTENAME(@email) +			
					N' GRANT EXECUTE ON Person.DeleteInstractor TO ' + QUOTENAME(@email) +		
					N' GRANT EXECUTE ON Person.DeleteCourse TO ' + QUOTENAME(@email) +					
					N' GRANT EXECUTE ON General.DeleteBranch TO ' + QUOTENAME(@email) +					
					N' GRANT EXECUTE ON General.DeleteDepartment TO ' + QUOTENAME(@email) +						
					N' GRANT EXECUTE ON General.DeleteTrack TO ' + QUOTENAME(@email)
			EXEC(@sql)
		END
END
Go

CREATE TRIGGER Person.LoginStud ON [Person].[Student]
AFTER INSERT
AS 
BEGIN
	DECLARE @email NVARCHAR(50), @pass NVARCHAR(20)
	
	SELECT @email = pr.Email, @pass = pr.[Password]
	FROM inserted as ins
		inner join Person.Person as pr
		ON pr.ID = ins.StuID
	
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = N' CREATE LOGIN ' + QUOTENAME(@email) + 
			   N' WITH PASSWORD = ' + QUOTENAME(@pass, '''') + 
               N'; CREATE USER ' + QUOTENAME(@email) +
		       N' FOR LOGIN ' + QUOTENAME(@email)
    EXEC(@sql)
    SET @sql = N' GRANT EXECUTE ON dbo.StudentUpdate TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.AnswerQuestion TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.StudExam TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.Searching TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.View_My_Exam_Answer TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.View_My_Exam_Result TO ' + QUOTENAME(@email) +
			   N' GRANT EXECUTE ON dbo.View_My_info_Result TO ' + QUOTENAME(@email) 
   EXEC(@sql)
END
Go

CREATE TRIGGER Content.UpExdeg ON Content.Ex_has_Ques 
AFTER INSERT
AS 
	DECLARE @degree INT, @max_deg INT,
			@ex_id INT

	SELECT @degree = ex.Degree + ques.Point,
		   @max_deg = cor.MaxDegree,
		   @ex_id = ex.ExamID
			From inserted 
			inner join Content.QuestionTable as ques
			ON inserted.QID = ques.QID 
			inner join Content.Exam as ex
			ON inserted.ExamID = ex.ExamID
			inner join Content.Course as cor
			ON cor.CourseID = ex.CourseID
	IF @degree > @max_deg
		Begin
			rollback transaction
			raiserror('Can not assign the question, because higher than course max degree', 16, 1)
		End
	ELSE
		BEGIN
		UPDATE Content.Exam SET Degree = @degree
			WHERE ExamID = @ex_id
		END
Go
CREATE TRIGGER Content.StuEx ON Content.Stu_enrol_ex
AFTER INSERT
AS
	DECLARE @coun INT 
	SELECT @coun = Count(st.StuID) FROM inserted as ins
	inner join Content.Exam as ex ON ins.ExamID = ex.ExamID
	inner join Person.Student as st ON st.StuID = ins.StuID
	WHERE ex.Intake = st.InTake

	IF @coun = 0
		BEGIN
			rollback transaction
			raiserror('Student and Exam do not in the same Intake', 16, 1)
		END
GO
CREATE TRIGGER Content.DeExDeg ON Content.Ex_has_Ques 
AFTER DELETE
AS
	DECLARE @degree INT, @min_deg INT,
			@ex_id INT

	SELECT @degree = ex.Degree - ques.Point,
		   @min_deg = cor.MinDegree,
		   @ex_id = ex.ExamID
		    From deleted 
			inner join Content.QuestionTable as ques
			ON deleted.QID = ques.QID 
			inner join Content.Exam as ex
			ON deleted.ExamID = ex.ExamID
			inner join Content.Course as cor
			ON cor.CourseID = ex.CourseID
	 IF @degree < @min_deg
		Begin
			rollback transaction
			raiserror('Can not assign the question, because less than course max degree', 16, 1)
		End
	ELSE
		BEGIN
		UPDATE Content.Exam SET Degree = @degree
			WHERE ExamID = @ex_id
		END
Go	
CREATE TRIGGER Content.ChExDeg ON Content.Ex_has_Ques 
AFTER Update
AS
	DECLARE @new_ques INT, @old_ques INT, @old_exam INT,
			@degree INT, @max_deg INT, @ex_id INT

	SELECT @new_ques = QID FROM inserted
	SELECT @old_ques = QID, @old_exam = ExamID FROM deleted
	IF @new_ques != @old_ques
		BEGIN
			SELECT @degree = ex.Degree - ques.Point,
				   @max_deg = cor.MaxDegree,
				   @ex_id = ex.ExamID From deleted 
					inner join Content.QuestionTable as ques
					ON deleted.QID = ques.QID 
					inner join Content.Exam as ex
					ON deleted.ExamID = ex.ExamID
					inner join Content.Course as cor
					ON cor.CourseID = ex.CourseID
			SELECT @degree += ques.Point From inserted 
					inner join Content.QuestionTable as ques
					ON inserted.QID = ques.QID 
			IF @degree > @max_deg
				Begin
					rollback transaction
					raiserror('Can not assign the question, because higher than course max degree', 16, 1)
				End
			ELSE
				BEGIN
				UPDATE Content.Exam SET Degree = @degree
					WHERE ExamID = @ex_id
				END
		END
	ELSE
		BEGIN
			DECLARE @old_point INT
			SELECT @degree = ex.Degree + ques.Point,
				   @max_deg = cor.MaxDegree, 
				   @ex_id = ex.ExamID
					From inserted 
					inner join Content.QuestionTable as ques
					ON inserted.QID = ques.QID 
					inner join Content.Exam as ex
					ON inserted.ExamID = ex.ExamID
					inner join Content.Course as cor
					ON cor.CourseID = ex.CourseID
			SELECT @old_point = ques.Point From deleted 
				inner join Content.QuestionTable as ques
				ON deleted.QID = ques.QID
			IF @degree > @max_deg
				Begin
					rollback transaction
					raiserror('Can not assign the question, because higher than course max degree', 16, 1)
				End
			ELSE
				BEGIN
				UPDATE Content.Exam SET Degree = @degree
					WHERE ExamID = @ex_id
				UPDATE Content.Exam SET Degree = Degree - @old_point
					WHERE ExamID = @old_exam
				END
		END
Go