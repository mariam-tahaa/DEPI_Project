---------------------------------------------------------------------
-- 1.  CREATE DATABASE & SCHEMAS
---------------------------------------------------------------------
USE master;
GO

IF DB_ID('ProHost') IS NOT NULL
   DROP DATABASE ProHost;
GO
CREATE DATABASE ProHost
			ON (
				NAME = 'ProHostData',
				FILENAME = 'F:\ProHost\DB/ProHostData.MDF',
				SIZE = 100MB,
				FILEGROWTH = 10MB,
				MAXSIZE = Unlimited
			)
			LOG ON (
				NAME = 'ProHostLog',
				FILENAME = 'F:\ProHost\DB/ProHostData.LDF',
				SIZE = 100MB,
				FILEGROWTH = 10MB,
				MAXSIZE = Unlimited		
			);
GO

USE ProHost;
GO

CREATE SCHEMA HR;
GO
CREATE SCHEMA Guests;
GO
CREATE SCHEMA Operations;
GO

---------------------------------------------------------------------
-- 2.  CORE MASTER TABLES (Hotels, Departments, Positions)
---------------------------------------------------------------------
CREATE TABLE Operations.Hotels(
    HotelID         INT             PRIMARY KEY,
    Name            NVARCHAR(100)   NOT NULL,
    Address         NVARCHAR(200),
    City            NVARCHAR(60),
    Country         NVARCHAR(60),
    StarRating      NVARCHAR(60),
    NumberOfRooms   INT,
    ChainName       NVARCHAR(100)
);

CREATE TABLE HR.Departments(
    DepartmentID        INT             PRIMARY KEY,
    DepartmentName      NVARCHAR(100)   NOT NULL,
    Description         NVARCHAR(250),
    HotelID             INT,
    ManagerID           INT             NULL,  -- FK to Employees later
    MinStaffRequired    INT
);

CREATE TABLE HR.Positions(
    PositionID          INT             PRIMARY KEY,
    PositionTitle       NVARCHAR(100)   NOT NULL,
    DepartmentID        INT             NOT NULL,
    SalaryRangeMin      DECIMAL(12,2),
    SalaryRangeMax      DECIMAL(12,2),
    Level               VARCHAR(30),
    JobDescription      NVARCHAR(500)
);

---------------------------------------------------------------------
-- 3.  HR TABLES (Employees, Shifts)
---------------------------------------------------------------------
CREATE TABLE HR.Employees(
    EmployeeID          INT             PRIMARY KEY,
    FirstName           NVARCHAR(50)    NOT NULL,
    LastName            NVARCHAR(50)    NOT NULL,
    PositionID          INT             NOT NULL,
    DepartmentID        INT             NOT NULL,
    HireDate            DATE            NOT NULL,
    TerminationDate     DATE            NULL,
    EmploymentStatus    VARCHAR(30)     NOT NULL,
    Salary              DECIMAL(12,2),
    HourlyRate          DECIMAL(10,2),
    StandardHours       DECIMAL(5,2),
    TrainingTimes       INT,
    Satisfaction        INT,
    Email               NVARCHAR(100)   UNIQUE,
    PhoneNumber         NVARCHAR(30),
    DateOfBirth         DATE,
    Gender              CHAR(1),
    MaritalStatus       VARCHAR(20),
    Country             NVARCHAR(60),
    City                NVARCHAR(60),
    DistanceFromHome    INT,
    Education           VARCHAR(50),
    EducationField      VARCHAR(50),
    ManagerID           INT             NULL,
    EmploymentType      VARCHAR(20),
    ContractType        VARCHAR(20)
);

CREATE TABLE HR.Shifts(
    ShiftID             INT             PRIMARY KEY,
    EmployeeID          INT             NOT NULL,
    ShiftDate           DATE            NOT NULL,
    StartTime           TIME            NOT NULL,
    EndTime             TIME            NOT NULL,
    DepartmentID        INT             NOT NULL,
    ShiftType           VARCHAR(20),
    HoursWorked         DECIMAL(4,2),
    OvertimeHours       DECIMAL(4,2),
    Status              VARCHAR(20)
);

---------------------------------------------------------------------
-- 4.  GUEST TABLES (Guests, GuestPreferences, GuestsFeedback)
---------------------------------------------------------------------
CREATE TABLE Guests.Guests(
    GuestID             INT             PRIMARY KEY,
    FirstName           NVARCHAR(50),
    LastName            NVARCHAR(50),
    Email               NVARCHAR(100)   UNIQUE,
    PhoneNumber         NVARCHAR(30),
    Nationality         NVARCHAR(50),
    DateOfBirth         DATE,
    RegistrationDate    DATE            DEFAULT GETDATE()
);

CREATE TABLE Guests.GuestPreferences(
    GuestID             INT             PRIMARY KEY,
    Preferences         NVARCHAR(500)   
);

CREATE TABLE Guests.GuestsFeedback (
    GuestID       INT           NOT NULL,
    ServiceID     INT           NOT NULL,
    Rating        INT           NOT NULL,
    Comments      NVARCHAR(500),
    FeedbackDate  DATE          NOT NULL,
);

---------------------------------------------------------------------
-- 5.  ROOM OPERATIONS (RoomTypes, Rooms, RoomPricing)
---------------------------------------------------------------------
CREATE TABLE Operations.RoomTypes(
    RoomTypeID          INT             PRIMARY KEY,
    TypeName            NVARCHAR(50)    NOT NULL,
    Description         NVARCHAR(250),
    Capacity            TINYINT
);

CREATE TABLE Operations.Rooms(
    RoomID              INT             PRIMARY KEY,
    HotelID             INT             NOT NULL,
    RoomNumber          NVARCHAR(15)    NOT NULL,
    RoomTypeID          INT             NOT NULL,
    Status              VARCHAR(20)     DEFAULT 'Available',
    FloorNumber         INT
);

CREATE TABLE Operations.RoomPricing(
    PricingID           INT             PRIMARY KEY,
    RoomTypeID          INT             NOT NULL,
    StartDate           DATE            NOT NULL,
    EndDate             DATE            NOT NULL,
    Price               DECIMAL(12,2)   NOT NULL,
    Currency            CHAR(3)         DEFAULT 'USD'
);

---------------------------------------------------------------------
-- 6.  RESERVATIONS & BILLING
---------------------------------------------------------------------
CREATE TABLE Guests.Reservations(
    ReservationID       INT             PRIMARY KEY,
    GuestID             INT             NOT NULL,
    RoomID              INT             NOT NULL,
    PricingID           INT             NOT NULL,
    CheckInDate         DATE            NOT NULL,
    CheckOutDate        DATE            NOT NULL,
    BookingDate         DATE            NOT NULL,
    NumberOfAdults      TINYINT         NOT NULL,
    NumberOfChildren    TINYINT         NOT NULL,
    Meal                VARCHAR(5),
    BookingSource       VARCHAR(20),
    PaymentStatus       VARCHAR(15),
    PaymentMethod       VARCHAR(30),
    Status              VARCHAR(15)
);

CREATE TABLE Operations.Billings(
    BillingID           INT             PRIMARY KEY,
    ReservationID       INT             NOT NULL,
    IssueDate           DATE            NOT NULL,
    DueDate             DATE            NOT NULL,
    TotalAmount         DECIMAL(12,2)   NOT NULL,
    DiscountAmount      DECIMAL(12,2)   NULL,
    TaxAmount           DECIMAL(12,2)   NULL,
    AmountPaid          DECIMAL(12,2)   NULL,
    PaymentDate         DATE            NULL,
    PaymentMethod       VARCHAR(30),
    Status              VARCHAR(20)     NOT NULL
);

CREATE TABLE Operations.BillingItems(
    BillingItemID       INT             PRIMARY KEY,
    BillingID           INT             NOT NULL,
    ItemType            VARCHAR(30)     NOT NULL,
    ItemName            NVARCHAR(100)   NOT NULL,
    Quantity            INT             NOT NULL,
    UnitPrice           DECIMAL(12,2)   NOT NULL,
    TotalPrice          DECIMAL(12,2)   NOT NULL,
    ServiceDate         DATE            NOT NULL
);

---------------------------------------------------------------------
-- 7.  SERVICES (Services, ServiceUsage)
---------------------------------------------------------------------
CREATE TABLE Operations.Services(
    ServiceID           INT             PRIMARY KEY,
    ServiceName         NVARCHAR(100)   NOT NULL,
    Description         NVARCHAR(250),
    BasePrice           DECIMAL(12,2),
    ServiceType         VARCHAR(30),
    IsChargeable        VARCHAR(30)             DEFAULT 'Yes',
    UnitOfMeasure       VARCHAR(20)
);

CREATE TABLE Operations.ServiceUsage(
    ServiceUsageID      INT             PRIMARY KEY,
    GuestID             INT             NOT NULL,
    ServiceID           INT             NOT NULL,
    UsageDate           DATE            NOT NULL,
    Quantity            INT             NOT NULL,
    UnitCost            DECIMAL(12,2)   NOT NULL,
    TotalCost           DECIMAL(12,2)   NOT NULL
);

---------------------------------------------------------------------
-- 8.  EXPENSES (ExpenseCategories, Expenses)
---------------------------------------------------------------------
CREATE TABLE Operations.ExpenseCategories(
    ExpenseCategoryID   INT             PRIMARY KEY,
    CategoryName        NVARCHAR(100)   NOT NULL
);

CREATE TABLE Operations.Expenses(
    ExpenseID           INT             PRIMARY KEY,
    HotelID             INT             NOT NULL,
    ExpenseCategoryID   INT             NOT NULL,
    ExpenseDate         DATE            NOT NULL,
    Description         NVARCHAR(250),
    Amount              DECIMAL(12,2)   NOT NULL,
    VendorName          NVARCHAR(100),
    PaymentMethod       VARCHAR(30),
    Status              VARCHAR(20)
);

---------------------------------------------------------------------
-- 9.  FOREIGN KEY RELATIONSHIPS
---------------------------------------------------------------------
-- HR Relationships
ALTER TABLE HR.Positions 
    ADD CONSTRAINT FK_Positions_Department 
    FOREIGN KEY(DepartmentID) REFERENCES HR.Departments(DepartmentID);

ALTER TABLE HR.Employees 
    ADD CONSTRAINT FK_Employees_Position 
    FOREIGN KEY(PositionID) REFERENCES HR.Positions(PositionID),
    CONSTRAINT FK_Employees_Department 
    FOREIGN KEY(DepartmentID) REFERENCES HR.Departments(DepartmentID),
    CONSTRAINT FK_Employees_Manager 
    FOREIGN KEY(ManagerID) REFERENCES HR.Employees(EmployeeID);

ALTER TABLE HR.Shifts
    ADD CONSTRAINT FK_Shifts_Employee 
    FOREIGN KEY(EmployeeID) REFERENCES HR.Employees(EmployeeID),
    CONSTRAINT FK_Shifts_Department 
    FOREIGN KEY(DepartmentID) REFERENCES HR.Departments(DepartmentID);

ALTER TABLE HR.Departments
    ADD CONSTRAINT FK_Departments_Hotels 
    FOREIGN KEY(HotelID) REFERENCES Operations.Hotels(HotelID);

-- Guest Relationships  
ALTER TABLE Guests.GuestPreferences
    ADD CONSTRAINT FK_GuestPref_Guest 
    FOREIGN KEY(GuestID) REFERENCES Guests.Guests(GuestID);

ALTER TABLE Guests.GuestsFeedback
    ADD CONSTRAINT FK_GuestFeed_Guest 
    FOREIGN KEY(GuestID) REFERENCES Guests.Guests(GuestID),
    CONSTRAINT FK_GuestFeed_Service 
    FOREIGN KEY(ServiceID) REFERENCES Operations.Services(ServiceID);

-- Room Relationships
ALTER TABLE Operations.Rooms
    ADD CONSTRAINT FK_Rooms_Hotel 
    FOREIGN KEY(HotelID) REFERENCES Operations.Hotels(HotelID),
    CONSTRAINT FK_Rooms_RoomType 
    FOREIGN KEY(RoomTypeID) REFERENCES Operations.RoomTypes(RoomTypeID);

ALTER TABLE Operations.RoomPricing
    ADD CONSTRAINT FK_RoomPricing_RoomType 
    FOREIGN KEY(RoomTypeID) REFERENCES Operations.RoomTypes(RoomTypeID);

-- Reservation & Billing Relationships
ALTER TABLE Guests.Reservations
    ADD CONSTRAINT FK_Reservations_Guest 
    FOREIGN KEY(GuestID) REFERENCES Guests.Guests(GuestID),
    CONSTRAINT FK_Reservations_Room 
    FOREIGN KEY(RoomID) REFERENCES Operations.Rooms(RoomID),
    CONSTRAINT FK_Reservations_Pricing 
    FOREIGN KEY(PricingID) REFERENCES Operations.RoomPricing(PricingID);

ALTER TABLE Operations.Billings
    ADD CONSTRAINT FK_Billings_Reservation 
    FOREIGN KEY(ReservationID) REFERENCES Guests.Reservations(ReservationID);

ALTER TABLE Operations.BillingItems
    ADD CONSTRAINT FK_BillingItems_Billing 
    FOREIGN KEY(BillingID) REFERENCES Operations.Billings(BillingID);

-- Service Relationships
ALTER TABLE Operations.ServiceUsage
    ADD CONSTRAINT FK_ServiceUsage_Guest 
    FOREIGN KEY(GuestID) REFERENCES Guests.Guests(GuestID),
    CONSTRAINT FK_ServiceUsage_Service 
    FOREIGN KEY(ServiceID) REFERENCES Operations.Services(ServiceID);

-- Expense Relationships
ALTER TABLE Operations.Expenses
    ADD CONSTRAINT FK_Expenses_Hotel 
    FOREIGN KEY(HotelID) REFERENCES Operations.Hotels(HotelID),
    CONSTRAINT FK_Expenses_Category 
    FOREIGN KEY(ExpenseCategoryID) REFERENCES Operations.ExpenseCategories(ExpenseCategoryID);

---------------------------------------------------------------------
-- 10. BULK INSERT FOR ALL 18 CSV FILES
---------------------------------------------------------------------
DECLARE @Path NVARCHAR(260) = N'F:\ProHost\RawData\';
DECLARE @bulk NVARCHAR(MAX);

-- 1. Hotels.csv
SET @bulk = N'
BULK INSERT Operations.Hotels
FROM ''' + @Path + 'Hotels.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Hotels.csv';

-- 2. ExpenseCategories.csv (Load before Expenses)
SET @bulk = N'
BULK INSERT Operations.ExpenseCategories
FROM ''' + @Path + 'ExpenseCategories.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded ExpenseCategories.csv';

-- 3. Departments.csv  
SET @bulk = N'
BULK INSERT HR.Departments
FROM ''' + @Path + 'Departments.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Departments.csv';

-- 4. Positions.csv
SET @bulk = N'
BULK INSERT HR.Positions
FROM ''' + @Path + 'Positions.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Positions.csv';

-- 5. Employees.csv
SET @bulk = N'
BULK INSERT HR.Employees
FROM ''' + @Path + 'Employees.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Employees.csv';

-- 6. Shifts.csv
SET @bulk = N'
BULK INSERT HR.Shifts
FROM ''' + @Path + 'Shifts.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Shifts.csv';

-- 7. Guests.csv
SET @bulk = N'
BULK INSERT Guests.Guests
FROM ''' + @Path + 'Guests.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Guests.csv';

-- 8. GuestPreferences.csv
SET @bulk = N'
BULK INSERT Guests.GuestPreferences
FROM ''' + @Path + 'GuestPreferences.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded GuestPreferences.csv';

-- 9. RoomTypes.csv
SET @bulk = N'
BULK INSERT Operations.RoomTypes
FROM ''' + @Path + 'RoomTypes.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded RoomTypes.csv';

-- 10. Rooms.csv
SET @bulk = N'
BULK INSERT Operations.Rooms
FROM ''' + @Path + 'Rooms.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Rooms.csv';

-- 11. RoomPricing.csv
SET @bulk = N'
BULK INSERT Operations.RoomPricing
FROM ''' + @Path + 'RoomPricing.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded RoomPricing.csv';

-- 12. Services.csv
SET @bulk = N'
BULK INSERT Operations.Services
FROM ''' + @Path + 'Services.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Services.csv';

-- 13. Reservations.csv
SET @bulk = N'
BULK INSERT Guests.Reservations
FROM ''' + @Path + 'Reservations.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Reservations.csv';

-- 14. Billings.csv
SET @bulk = N'
BULK INSERT Operations.Billings
FROM ''' + @Path + 'Billings.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Billings.csv';

-- 15. BillingItems.csv
SET @bulk = N'
BULK INSERT Operations.BillingItems
FROM ''' + @Path + 'BillingItems.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded BillingItems.csv';

-- 16. ServiceUsage.csv
SET @bulk = N'
BULK INSERT Operations.ServiceUsage
FROM ''' + @Path + 'ServiceUsage.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded ServiceUsage.csv';

-- 17. GuestsFeedback.csv
SET @bulk = N'
BULK INSERT Guests.GuestsFeedback
FROM ''' + @Path + 'GuestsFeedback.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded GuestsFeedback.csv';

-- 18. Expenses.csv
SET @bulk = N'
BULK INSERT Operations.Expenses
FROM ''' + @Path + 'Expenses.csv''
WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
EXEC(@bulk);
PRINT 'Loaded Expenses.csv';

---------------------------------------------------------------------
-- 11. DATA VERIFICATION & SUMMARY
---------------------------------------------------------------------
PRINT '========================================';
PRINT 'LOADING COMPLETE - DATA VERIFICATION';
PRINT '========================================';

SELECT 'Hotels' as TableName, COUNT(*) as RecordCount FROM Operations.Hotels
UNION ALL SELECT 'Departments', COUNT(*) FROM HR.Departments  
UNION ALL SELECT 'Positions', COUNT(*) FROM HR.Positions
UNION ALL SELECT 'Employees', COUNT(*) FROM HR.Employees
UNION ALL SELECT 'Shifts', COUNT(*) FROM HR.Shifts
UNION ALL SELECT 'Guests', COUNT(*) FROM Guests.Guests
UNION ALL SELECT 'GuestPreferences', COUNT(*) FROM Guests.GuestPreferences
UNION ALL SELECT 'GuestsFeedback', COUNT(*) FROM Guests.GuestsFeedback
UNION ALL SELECT 'RoomTypes', COUNT(*) FROM Operations.RoomTypes
UNION ALL SELECT 'Rooms', COUNT(*) FROM Operations.Rooms
UNION ALL SELECT 'RoomPricing', COUNT(*) FROM Operations.RoomPricing
UNION ALL SELECT 'Services', COUNT(*) FROM Operations.Services
UNION ALL SELECT 'Reservations', COUNT(*) FROM Guests.Reservations
UNION ALL SELECT 'Billings', COUNT(*) FROM Operations.Billings
UNION ALL SELECT 'BillingItems', COUNT(*) FROM Operations.BillingItems
UNION ALL SELECT 'ServiceUsage', COUNT(*) FROM Operations.ServiceUsage
UNION ALL SELECT 'ExpenseCategories', COUNT(*) FROM Operations.ExpenseCategories
UNION ALL SELECT 'Expenses', COUNT(*) FROM Operations.Expenses
ORDER BY TableName;

PRINT 'All 18 CSV files have been successfully loaded!';
PRINT 'Database: HotelDW is ready for analysis and reporting.';