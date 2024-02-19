create view StudentInfo
as
select 
    [Person].[Student].StuID as StudentID, 
    [Person].[Person].[Name] as StudentName, 
    [Person].[Person].[Email] as StudentEmail, 
    [General].[Branch].[BranName] as BranchName, 
    [General].[Track].[TraName] as Track, 
    [Person].[Student].[INTake] as Intake, 
    [General].[Department].[DepName] as Department
from
	[Person].[Student]
join
    [General].[Branch] on [Student].[BranID] = [Branch].[BranID]
join
    [General].[Track] on [Student].[TrackID] = [Track].[TraID]
join
    [General].[Department] on [Student].[DepID] = [General].[Department].[DepID]
join
    [Person].[Person] ON [Person].[Student].StuID = [Person].[Person].ID;
Go


	---- student view his info

create proc View_My_info_Result  
as
begin 
	select * from StudentInfo 
	--join [Person].[Student] on [Person].[Student].StuID 
	WHERE dbo.StudentInfo.StudentID  = dbo.GetUserID()
end
go


--to view the exam result of the student 
create View Student_Exam_Result
as

select
	Person.Student.StuID as StudentID, 
	[Person].[Person].[Name] as StudentName, 
	[Content].[Course].CourseName ,
	[Content].[Stu_enrol_ex].JoinDate as JoinDate , 
	sum ([Content].[Stu_ans_Que_Ex].Result ) as ExamResult 
from Person.Student
join [Person].[Person] on [Person].[Student].StuID = [Person].[Person].ID 
join [Content].[Stu_enrol_ex] on Stu_enrol_ex.StuID = Person.Student.StuID
join Content.Stu_ans_Que_Ex on Content.Stu_ans_Que_Ex.StuID = Person.Student.StuID
join Content.Exam on Content.Exam.ExamID = Content.Stu_ans_Que_Ex.ExamID
join [Content].[Course] on Course.CourseID = Content.Exam.CourseID
group by
    Person.Student.StuID,
    [Person].[Person].[Name],
    [Content].[Course].CourseName,
    [Content].[Stu_enrol_ex].JoinDate;


--- Student view his Result only 

create proc View_My_Exam_Result 
as
begin 
	select * from Student_Exam_Result 
	Where dbo.Student_Exam_Result.StudentID = dbo.GetUserID()
end


------------------------------------------------------------------------------
--to see the exam 

create view StudentExam 
as
	select 
		Person.Student.StuID,
		[Content].[Course].CourseName,
		Content.Exam.ExamID as ExamID,
		Content.QuestionTable.Question  as Question,
		Content.Stu_ans_Que_Ex.StuAns as StudentAnswer,
		Content.QuestionTable.CorrectAns as CorrectAnswer,
		Content.Stu_ans_Que_Ex.Result as QuestionResult
	from 
		Person.Student 
		join [Content].[Stu_enrol_ex] on Stu_enrol_ex.StuID = Person.Student.StuID
		join Content.Stu_ans_Que_Ex on Content.Stu_ans_Que_Ex.StuID = Person.Student.StuID
		join Content.QuestionTable on Content.QuestionTable.QID = Content.Stu_ans_Que_Ex.QID
		join Content.Exam on Content.Exam.ExamID = Content.Stu_ans_Que_Ex.ExamID
		join [Content].[Course] on Course.CourseID = Content.Exam.CourseID


--- Student view his Exam and answer only 

alter proc View_My_Exam_Answer 
as
begin 
	select * from StudentExam 
	where dbo.StudentExam.StuID = dbo.GetUserID()
end


-----------------------------------------------------------------------------------------

-- calculate the correct answers as a trigger..

create trigger MarkTheQuestion
on Content.Stu_ans_Que_Ex
after update , insert
 as
	begin 

    update Answers
    set Answers.Result = case
							when inserted.StuAns = Content.QuestionTable.CorrectAns 
							then Content.QuestionTable.Point 
						 else 0 
						 end

	from inserted
		inner join Content.QuestionTable on inserted.QID = Content.QuestionTable.QID
		inner join Content.Stu_ans_Que_Ex Answers
		on inserted.StuID = Answers.StuID and 
		inserted.ExamId = Answers.ExamId and 
		inserted.QId = Answers.QId
	end


-- Proc for searching 

create proc Searching  @searchCategory nvarchar(max) 
as
	begin
		if @searchCategory = 'StudentInfo'
		begin
			exec View_My_info_Result ;
			--select * from dbo.StudentInfo
		end
		else if @searchCategory = 'StudentExam'
		begin
			exec View_My_Exam_Answer ;
			--select * from dbo.StudentExam
			
		end
		else if @searchCategory = 'Result'
		begin
			exec View_My_Exam_Result ;
			--select * from dbo.Student_Exam_Result
			
		end
		else
		begin
			print 'Invalid Search Category';
	    end

	end



	
--- student access to the exam 
create proc StudExam  @ExamID int 
as 
begin 
	declare @AccessExam bit

	select @AccessExam = case 
							when Person.Student.StuID is not null 
							and  convert(time, Exam.StartTime) <= convert(time, GETDATE()) 
                            and  convert(time, Exam.EndTime) >= convert(time, GETDATE())
							 then 1
							else 0
						 end
	from Person.Student 
	join Content.Exam Exam
	on  Person.Student.StuID = dbo.GetUserID()
	and Exam.ExamID = @ExamID
	


	if @AccessExam = 1 
	begin 
		select Exam.ExamID, Exam.StartTime, Exam.EndTime, Exam.Date, Exam.Type,Exam.CourseID
		from Content.Exam Exam
		where Exam.ExamID =@ExamID
	end
	else 
	begin
		print 'You don''t have access'
	end

end

--- student insert his answer 
create proc AnswerQuestion  @ExamID int, @QuestionID int, @StudentAnswer nvarchar(max)
as
begin
    insert into Content.Stu_ans_Que_Ex (StuID, ExamID, QID, StuAns)
    values (dbo.GetUserID(), @ExamID, @QuestionID, @StudentAnswer);
end;

-- student update his info 

create proc StudentUpdate @Name nvarchar , @Email nvarchar , @Password nvarchar
as 
begin 
	update Person.Person
	set [Person].[Person].Name = @Name ,
		[Person].[Person].Email =@Email ,
		[Person].[Person].Password= @Password
	where Person.Person.ID = dbo.GetUserID()
end



