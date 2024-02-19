CREATE PROCEDURE Person.DeleteStudent
    @ManagerID INT,
    @StudID INT
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
        SELECT 1
        FROM Person.Instractor AS I
        WHERE I.InsID = @ManagerID AND I.IsManager = 1
    )
    BEGIN
        -- Check if the specified Student (@StudID) exists
        IF EXISTS (SELECT 1 FROM Person.Student WHERE StuID = @StudID)
        BEGIN
            DELETE FROM Content.Stu_ans_Que_Ex
            WHERE StuID = @StudID;

            DELETE FROM Stu_enrol_ex
            WHERE StuID = @StudID;

            DELETE FROM Person.Student
            WHERE StuID = @StudID;

            DELETE FROM Person.Person
            WHERE ID = @StudID;
        END
        ELSE
        BEGIN
            -- Print a message or handle the case where the student doesn't exist
            PRINT 'Specified student does not exist.';
        END
    END
END;
GO
-----------------------------------------------------
CREATE PROCEDURE Person.DeleteInstractor
    @ManagerID INT,
    @InsID INT
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        -- Check if the specified Instractor (@InsID) exists
        IF EXISTS (SELECT 1 FROM Person.Instractor WHERE InsID = @InsID)
        BEGIN
            DECLARE @IsManager BIT;

            -- Check if the specified Instractor (@InsID) is a manager
            SELECT @IsManager = IsManager
            FROM Person.Instractor
            WHERE InsID = @InsID;

            -- If @IsManager is 0, proceed with deletion
            IF @IsManager = 0
            BEGIN
                DELETE FROM Person.Instractor
                WHERE InsID = @InsID;

                DELETE FROM Content.Inst_teach_cour_in_class
                WHERE InsID = @InsID;

                DELETE FROM Person.Person
                WHERE ID = @InsID;
            END
            ELSE
            BEGIN
                -- Print a message or handle the case where the Instractor is a manager
                PRINT 'You cannot delete a manager.';
            END
        END
        ELSE
        BEGIN
            -- Print a message or handle the case where the Instractor doesn't exist
            PRINT 'Specified Instractor does not exist.';
        END
    END
END;
GO
-----------------------------------------------------------
CREATE PROCEDURE Person.DeleteCourse
    @ManagerID INT,
    @CourseID INT
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        -- Check if the specified Course (@CourseID) exists
        IF EXISTS (SELECT 1 FROM Content.Course WHERE CourseID = @CourseID)
        BEGIN
            -- Delete the course from the Content.Course table
            DELETE FROM Content.Course
            WHERE CourseID = @CourseID;

            -- Delete related exams from the Content.Exam table
            DELETE FROM Content.Exam
            WHERE CourseID = @CourseID;

            -- Delete Course from Inst_teach_cour_in_class
            DELETE FROM Content.Inst_teach_cour_in_class
            WHERE CourseID = @CourseID;
        END
        ELSE
        BEGIN
            -- Print a message or handle the case where the course doesn't exist
            PRINT 'Specified course does not exist.';
        END
    END
END;
GO

-----------------------------------------------------------
CREATE PROCEDURE General.DeleteBranch
    @ManagerID INT,
    @BranID INT
AS
BEGIN
    -- Check if the manager is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        -- Check if the specified Branch (@BranID) exists
        IF EXISTS (SELECT 1 FROM General.Branch WHERE BranID = @BranID)
        BEGIN
            -- Delete the branch from the General.Branch table
            DELETE FROM General.Branch
            WHERE BranID = @BranID;
        END
        ELSE
        BEGIN
            -- Print a message or handle the case where the branch doesn't exist
            PRINT 'Specified branch does not exist.';
        END
    END
END;
GO
-------------------------------------------------------------------
CREATE PROCEDURE General.DeleteDepartment
    @ManagerID INT,
    @DepID INT
AS
BEGIN
    -- Check if the manager is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        -- Check if the specified Department (@DepID) exists
        IF EXISTS (SELECT 1 FROM General.Department WHERE DepID = @DepID)
        BEGIN
            -- Delete the department from the General.Department table
            DELETE FROM General.Department
            WHERE DepID = @DepID;
        END
        ELSE
        BEGIN
            -- Print a message or handle the case where the department doesn't exist
            PRINT 'Specified department does not exist.';
        END
    END
END;
GO
----------------------------------------------------------------------
CREATE PROCEDURE General.DeleteTrack
    @ManagerID INT,
    @TraID INT
AS
BEGIN
    -- Check if the manager is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        -- Check if the specified Track (@TraID) exists
        IF EXISTS (SELECT 1 FROM General.Track WHERE TraID = @TraID)
        BEGIN
            -- Delete the track from the General.Track table
            DELETE FROM General.Track
            WHERE TraID = @TraID;
        END
        ELSE
        BEGIN
            -- Print a message or handle the case where the track doesn't exist
            PRINT 'Specified track does not exist.';
        END
    END
END;
GO

