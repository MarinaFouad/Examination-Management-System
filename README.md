# Examination-Management-System
Using SQL
# System Requirement Sheet

## Project Title:
Examination System Database

## System Overview:

The Examination System Database is designed to facilitate the management of 
exams, questions, courses, instructors, and students within an educational institution. 
The system aims to provide a robust platform for creating, managing, and assessing exams while ensuring data integrity, security, 
and ease of use for different user roles.

## Functional Requirements:

1. **Question Pool Management:**
   - The system should provide a question pool from which instructors can select questions for exams.
   - Question types include Multiple Choice, True & False, and Text Questions.

2. **Answer Validation:**
   - For Multiple Choice and True & False questions, the system should store correct answers and validate student responses.
   - Text questions should be evaluated using text functions and regular expressions, allowing instructors to review and manually enter marks.

3. **Course and Instructor Management:**
   - The system should store information on courses (name, description, max degree, min degree), instructors, and students.
   - Instructors can be associated with one or more courses, and courses may have different instructors in different classes.

4. **Question Pool Editing:**
   - Instructors can add, update, and delete questions in their assigned courses.

5. **Training Manager's Responsibilities:**
   - The Training Manager can add, update, and delete instructors, courses, branches, tracks, and intakes.
   - Student information, including personal data, intake, branch, and track, can be managed by the Training Manager.

6. **User Authentication:**
   - Login accounts for Training Manager, Instructors, and Students, ensuring restricted access to relevant tasks and data.

7. **Exam Creation:**
   - Instructors can create exams for their courses, specifying the number and type of questions, total degrees, and distribution of marks.

8. **Exam Information:**
   - Each exam should be categorized by type 
     (exam or corrective), intake, branch, track, course, start time, end time, total time, and allowance options.

9. **Exam Administration:**
   - Instructors can select students for specific exams, defining exam dates, start times, and end times.
   - Students can access and complete exams only during specified time frames.

10. **Results and Assessment:**
    - The system should store students' answers, calculate correct responses, and compute final results for each student in a course.

## Technical Requirements:

1. **Database Structure:**
   - Implement the database in files and file groups according to data size.

2. **Data Types and Naming Conventions:**
   - Choose appropriate data types for each column and adhere to naming conventions for all database objects.

3. **Indexes:**
   - Implement indexes for optimal database performance.

4. **Constraints and Triggers:**
   - Use constraints and triggers to ensure data integrity and regulate user access.

5. **Stored Procedures and Functions:**
   - Implement procedures and functions for all system tasks to simplify user interactions.

6. **Views:**
   - Create views to display results, eliminating the need for users to write direct queries.

7. **User Authentication and Permissions:**
   - Implement SQL users and their permissions to restrict access based on roles.

8. **Daily Backup:**
   - Set up an automated daily backup process to safeguard system data.
