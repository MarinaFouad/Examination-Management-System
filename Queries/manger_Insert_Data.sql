-- Function to insert student
CREATE PROCEDURE Person.InsertStudent
    @StuID INT, 
    @BranID INT, 
    @DepID INT, 
    @TrackID INT, 
    @INTake INT
AS
BEGIN
    -- Check if the specified IDs exist
    IF (
        EXISTS (SELECT 1 FROM General.Branch WHERE BranID = @BranID) AND
        EXISTS (SELECT 1 FROM General.Department WHERE DepID = @DepID) AND
        EXISTS (SELECT 1 FROM General.Track WHERE TraID = @TrackID)
    )
    BEGIN
        -- Insert into Person.Student
        INSERT INTO Person.Student (StuID, BranID, DepID, TrackID, INTake)
        VALUES (@StuID, @BranID, @DepID, @TrackID, @INTake);
    END
    ELSE
    BEGIN
        -- Throw an error if one or more of the specified IDs do not exist
        THROW 50000, 'One or more of the specified IDs do not exist.', 1;
    END
END;
GO
-----------------------------------------------------

-- Procedure to insert Instractor
CREATE PROCEDURE Person.InsertInstractor @InsID INT
AS
BEGIN
    -- Insert into Person.
    INSERT INTO Person.Instractor (InsID, IsManager)
    VALUES (@InsID, 0);
END;
-----------------------------------------------------
GO
-- Function to insert person (can be a student or an Instractor)


Go
CREATE PROCEDURE Person.InsertPerson
    @ManagerId INT, 
    @Status NVARCHAR(12), 
    @Name NVARCHAR(12), 
    @Email NVARCHAR(12), 
    @Password NVARCHAR(20),
    @StuID INT = NULL,
    @InsID INT = NULL,
    @BranID INT = NULL, 
    @DepID INT = NULL, 
    @TrackID INT = NULL, 
    @INTake INT = NULL
AS
BEGIN
    -- Declare variable to store manager status
    DECLARE @IsManager BIT;

    -- Check If Instractor is a manager
    SELECT @IsManager = IsManager
    FROM Person.Instractor
    WHERE InsID = @ManagerId;

    IF @IsManager = 1
    BEGIN
        -- Insert into Person.Person
        INSERT INTO Person.Person ([Name], [Email], [Password])
        VALUES (@Name, @Email, @Password);

        -- If the status is 'Student', call the InsertStudent procedure
        IF @Status = 'Student'
        BEGIN
            SELECT @StuID = ID FROM Person.Person WHERE [Email] = @Email;
            EXEC Person.InsertStudent @StuID, @BranID, @DepID, @TrackID, @INTake;
        END
        -- If the status is 'Instractor', call the InsertInstractor procedure
        ELSE IF @Status = 'Instractor'
        BEGIN
            SELECT @InsID = ID FROM Person.Person WHERE [Email] = @Email;
            EXEC Person.InsertInstractor @InsID;
        END
    END
END;
GO

----------------------------------------------------
CREATE PROCEDURE Content.InsertCourse
    @ManagerId INT,
    @CourseName NVARCHAR(20),
    @Description TEXT,
    @MaxDegree INT,
    @MinDegree INT,
    @Duration INT
AS
BEGIN
    -- Declare variable to store manager status
    DECLARE @IsManager BIT;

    -- Check If Instractor is a manager
    SELECT @IsManager = IsManager
    FROM Person.Instractor
    WHERE InsID = @ManagerId;

    -- If the manager is an Instractor
    IF @IsManager = 1
    BEGIN
        INSERT INTO Content.Course (
            CourseName,
            [Description],
            MaxDegree,
            MinDegree,
            Duration
        )
        VALUES (
            @CourseName,
            @Description,
            @MaxDegree,
            @MinDegree,
            @Duration
        );
    END
END;
GO
------------------------------------------------
CREATE PROCEDURE Content.InsertClass
    @ManagerId INT, 
    @ClassName NVARCHAR(10)
AS
BEGIN
    -- Declare variable to store manager status
    DECLARE @IsManager BIT;

    -- Check if the manager is an Instractor
    SELECT @IsManager = IsManager
    FROM Person.Instractor
    WHERE InsID = @ManagerId;

    -- If the manager is an Instractor
    IF @IsManager = 1
    BEGIN
        INSERT INTO Content.Class (ClassName)
        VALUES (@ClassName);
    END
END;
GO
------------------------------------------------
CREATE PROCEDURE Content.Insert_Instractor_Course_In_Class
    @ManagerId INT,
    @ClassID INT,
    @CourseID INT,
    @InsID INT,
    @EnrolledYear INT
AS
BEGIN
    -- Declare variable to store manager status
    DECLARE @IsManager BIT;

    -- Check if the manager is an Instractor
    SELECT @IsManager = IsManager
    FROM Person.Instractor
    WHERE InsID = @ManagerId;

    -- If the manager is an Instractor
    IF @IsManager = 1
    BEGIN
        -- Check if the specified IDs exist
        IF (
            EXISTS (SELECT 1 FROM Content.Class WHERE ClassID = @ClassID) AND
            EXISTS (SELECT 1 FROM Content.Course WHERE CourseID = @CourseID) AND
            EXISTS (SELECT 1 FROM Person.Instractor WHERE InsID = @InsID)
        )
        BEGIN
            INSERT INTO Content.Inst_teach_cour_in_class (ClassID, CourseID, InsID, EnrolledYear)
            VALUES (@ClassID, @CourseID, @InsID, @EnrolledYear);
        END
    END;
END;
GO
--------------------------------------------------------
CREATE PROCEDURE General.InsertData
    @ManagerId INT,
    @InsertType NVARCHAR(50),
    @BranName NVARCHAR(10) = NULL,
    @DepName NVARCHAR(10) = NULL,
    @TraName NVARCHAR(10) = NULL,
    @BranID INT = NULL,
    @DepID INT = NULL,
    @TraID INT = NULL
AS
BEGIN
    -- Check if the manager is an Instractor and is authorized
    IF EXISTS (
        SELECT 1
        FROM Person.Instractor AS I
        WHERE I.InsID = @ManagerId AND I.IsManager = 1
    )
    BEGIN
        IF @InsertType = 'Branch' AND @BranName IS NOT NULL
        BEGIN
            INSERT INTO General.Branch (BranName)
            VALUES (@BranName);
        END
        ELSE IF @InsertType = 'Department' AND @DepName IS NOT NULL
        BEGIN
            INSERT INTO General.Department (DepName)
            VALUES (@DepName);
        END
        ELSE IF @InsertType = 'Track' AND @TraName IS NOT NULL
        BEGIN
            INSERT INTO General.Track (TraName)
            VALUES (@TraName);
        END
        ELSE IF @InsertType = 'Bran_has_Dep_has_Track' AND @BranID IS NOT NULL AND @DepID IS NOT NULL AND @TraID IS NOT NULL
        BEGIN
            -- Check if the specified IDs exist in one query
            IF (
                EXISTS (SELECT 1 FROM General.Branch WHERE BranID = @BranID) AND
                EXISTS (SELECT 1 FROM General.Department WHERE DepID = @DepID) AND
                EXISTS (SELECT 1 FROM General.Track WHERE TraID = @TraID)
            )
            BEGIN
                INSERT INTO General.Bran_has_Dep_has_Track (BranID, DepID, TraID)
                VALUES (@BranID, @DepID, @TraID);
            END
        END
    END
END;
GO



