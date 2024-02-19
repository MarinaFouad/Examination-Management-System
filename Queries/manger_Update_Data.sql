CREATE PROCEDURE Person.UpdateInstractor 
    @ManagerID INT,
    @InsID INT,
    @InsName NVARCHAR(12) = NULL,
    @InsEmail NVARCHAR(12) = NULL,
    @InsPassword NVARCHAR(20) = NULL
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

            -- If @IsManager is 0, proceed with update
            IF @IsManager = 0
            BEGIN
                -- Update the Person.Person table based on non-null parameters
                UPDATE Person.Person
                SET
                    [Name] = ISNULL(@InsName, [Name]),
                    [Email] = ISNULL(@InsEmail, [Email]),
                    [Password] = ISNULL(@InsPassword, [Password])
                WHERE
                    ID = @InsID;

                PRINT 'Update successful.';
            END
            ELSE
            BEGIN
               
                PRINT 'Cannot update a manager.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Specified Instractor does not exist.';
            
        END
    END
    ELSE
    BEGIN
        PRINT 'Manager is not authorized.';
        
    END
END;
GO
----------------------------------------------
CREATE PROCEDURE Person.UpdateStudent
    @ManagerID INT,
    @StudID INT,
    @StudName NVARCHAR(12) = NULL,
    @StudEmail NVARCHAR(12) = NULL,
    @StudPassword NVARCHAR(20) = NULL
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
            -- Update the Person.Student table based on non-null parameters
            UPDATE Person.Person
            SET
                [Name] = ISNULL(@StudName, [Name]),
                [Email] = ISNULL(@StudEmail, [Email]),
                [Password] = ISNULL(@StudPassword, [Password])
            WHERE
                ID = @StudID;

            PRINT 'Update successful.';
        END
        ELSE
        BEGIN
            PRINT 'Specified Student does not exist.';
            -- You may want to add additional logic or raise an error.
        END
    END
    ELSE
    BEGIN
        PRINT 'Manager is not authorized.';
        -- You may want to add additional logic or raise an error.
    END
END;
GO
----------------------------------------------
CREATE PROCEDURE Content.UpdateCourse
	@ManagerID INT,
	@CourseID INT,
    @CourseName NVARCHAR(20) = NULL,
    @Description NVARCHAR(2000) = NULL,
    @MaxDegree INT = NULL,
    @MinDegree INT = NULL,
    @Duration INT = NULL
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
		IF EXISTS (SELECT 1 FROM Content.Course WHERE CourseID = @CourseID)
        BEGIN
			UPDATE Content.Course
            SET
                CourseName = ISNULL(@CourseName, CourseName),
                [Description] = ISNULL(@Description, [Description]),
                MaxDegree = COALESCE(@MaxDegree, MaxDegree),
				MinDegree = COALESCE(@MinDegree, MinDegree),
				Duration  = COALESCE(@Duration, Duration)
            WHERE
                CourseID = @CourseID;

            PRINT 'Update successful.';
        END
		ELSE
		BEGIN
			PRINT 'Course not found.';
		END
    END
	ELSE
	BEGIN
		PRINT 'Unauthorized manager.';
	END
END
GO
----------------------------------------------
CREATE PROCEDURE Content.UpdateClass
	@ManagerID INT,
	@ClassID INT,
    @ClassName NVARCHAR(10) = NULL
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
		IF EXISTS (SELECT 1 FROM Content.Class WHERE ClassID = @ClassID)
        BEGIN
			UPDATE Content.Class
            SET
                ClassName = COALESCE(@ClassName, ClassName)
            WHERE
                ClassID = @ClassID;

            PRINT 'Update successful.';
        END
		ELSE
		BEGIN
			PRINT 'Class not found.';
		END
    END
	ELSE
	BEGIN
		PRINT 'Unauthorized manager.';
	END
END
GO
-----------------------------------------------
CREATE PROCEDURE Content.UpdateInst_teach_cour_in_class
    @ManagerID INT,
    @ClassID INT,
    @CourseID INT,
    @InsID INT,
    @NewClassID INT,
    @NewCourseID INT,
    @NewInsID INT,
    @EnrolledYear INT
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        IF EXISTS (
                SELECT 1
                FROM Content.Inst_teach_cour_in_class
                WHERE ClassID = @ClassID
                    AND CourseID = @CourseID
                    AND InsID = @InsID
            ) AND   
            EXISTS (SELECT 1 FROM Content.Class WHERE ClassID = @NewClassID) AND
            EXISTS (SELECT 1 FROM Content.Course WHERE CourseID = @NewCourseID) AND
            EXISTS (SELECT 1 FROM Person.Instractor WHERE InsID = @NewInsID)
        BEGIN
            UPDATE Content.Inst_teach_cour_in_class
            SET
                ClassID = @NewClassID,
                CourseID = @NewCourseID,
                InsID = @NewInsID,
                EnrolledYear = @EnrolledYear
            WHERE
                ClassID = @ClassID
                AND CourseID = @CourseID
                AND InsID = @InsID;

            PRINT 'Update successful.';
        END
        ELSE
        BEGIN
            PRINT 'Record not found or invalid IDs for update.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Unauthorized manager.';
    END
END
GO
-------------------------------------------
CREATE PROCEDURE General.UpdateBranch
    @ManagerID INT,
    @BranID INT,
    @NewBranName NVARCHAR(10)
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        IF EXISTS (
                SELECT 1
                FROM General.Branch
                WHERE BranID = @BranID
            )
        BEGIN
            UPDATE General.Branch
            SET
                BranName = @NewBranName
            WHERE
                BranID = @BranID;

            PRINT 'Update successful.';
        END
        ELSE
        BEGIN
            IF NOT EXISTS (
                    SELECT 1
                    FROM General.Branch
                    WHERE BranID = @BranID
                )
            BEGIN
                PRINT 'Record not found.';
            END
            ELSE
            BEGIN
                PRINT 'Invalid ID for update.';
            END
        END
    END
    ELSE
    BEGIN
        PRINT 'Unauthorized manager.';
    END
END
GO
-------------------------------------------
CREATE PROCEDURE General.UpdateDepartment
    @ManagerID INT,
    @DepID INT,
    @NewDepName NVARCHAR(10)
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        IF EXISTS (
                SELECT 1
                FROM General.Department
                WHERE DepID = @DepID
            )
        BEGIN
            UPDATE General.Department
            SET
                DepName = @NewDepName
            WHERE
                DepID = @DepID;

            PRINT 'Update successful.';
        END
        ELSE
        BEGIN
            IF NOT EXISTS (
                    SELECT 1
                    FROM General.Department
                    WHERE DepID = @DepID
                )
            BEGIN
                PRINT 'Record not found.';
            END
            ELSE
            BEGIN
                PRINT 'Invalid ID for update.';
            END
        END
    END
    ELSE
    BEGIN
        PRINT 'Unauthorized manager.';
    END
END
GO
-------------------------------------------
CREATE PROCEDURE General.UpdateTrack
    @ManagerID INT,
    @TraID INT,
    @NewTraName NVARCHAR(10)
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instractor
 AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        IF EXISTS (
                SELECT 1
                FROM General.Track
                WHERE TraID = @TraID
            )
        BEGIN
            UPDATE General.Track
            SET
                TraName = @NewTraName
            WHERE
                TraID = @TraID;

            PRINT 'Update successful.';
        END
        ELSE
        BEGIN
            IF NOT EXISTS (
                    SELECT 1
                    FROM General.Track
                    WHERE TraID = @TraID
                )
            BEGIN
                PRINT 'Record not found.';
            END
            ELSE
            BEGIN
                PRINT 'Invalid ID for update.';
            END
        END
    END
    ELSE
    BEGIN
        PRINT 'Unauthorized manager.';
    END
END
GO
------------------------------------------
CREATE PROCEDURE General.UpdateBran_has_Dep_has_Track
    @ManagerID INT,
    @BranID INT,
    @DepID INT,
    @TraID INT,
    @NewBranID INT,
    @NewDepID INT,
    @NewTraID INT
AS
BEGIN
    -- Check if the manager is an Instructor and is authorized
    IF EXISTS (
            SELECT 1
            FROM Person.Instructor AS I
            WHERE I.InsID = @ManagerID AND I.IsManager = 1
        )
    BEGIN
        IF EXISTS (
                SELECT 1
                FROM General.Bran_has_Dep_has_Track
                WHERE BranID = @BranID
                    AND DepID = @DepID
                    AND TraID = @TraID
            ) AND   
            EXISTS (SELECT 1 FROM General.Branch WHERE BranID = @NewBranID) AND
            EXISTS (SELECT 1 FROM General.Department WHERE DepID = @NewDepID) AND
            EXISTS (SELECT 1 FROM General.Track WHERE TraID = @NewTraID)
        BEGIN
            UPDATE General.Bran_has_Dep_has_Track
            SET
                BranID = @NewBranID,
                DepID = @NewDepID,
                TraID = @NewTraID
            WHERE
                BranID = @BranID
                AND DepID = @DepID
                AND TraID = @TraID;

            PRINT 'Update successful.';
        END
        ELSE
        BEGIN
            PRINT 'Record not found or invalid IDs for update.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Unauthorized manager.';
    END
END
GO