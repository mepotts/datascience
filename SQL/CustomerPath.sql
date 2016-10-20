-- Define the Database I want to use
USE testDb
GO

--Create a table to insert test data
CREATE TABLE test(
ID int,
PageNumber int,
Time datetime,
PageType varchar(50)
)
GO

--Insert some test data to practice grouping the customer path
INSERT INTO test (
ID,
PageNumber,
Time,
PageType
)

VALUES

('100', 1, '2016-04-04 16:08:44.000', 'Homepage'),
('100', 2, '2016-04-04 16:15:44.000', 'Search'),
('100', 3, '2016-04-04 16:20:44.000', 'Search'),
('100', 4, '2016-04-04 16:25:44.000', 'Product'),
('100', 5, '2016-04-04 16:30:44.000', 'Product'),
('100', 6, '2016-04-04 16:35:44.000', 'Category'),
('100', 7, '2016-04-04 16:40:44.000', 'Search'),
('100', 8, '2016-04-04 16:45:44.000', 'Homepage'),
('100', 9, '2016-04-04 16:50:44.000', 'Category'),
('100', 10, '2016-04-04 16:55:44.000', 'Category'),
('100', 11, '2016-04-04 17:00:44.000', 'Product'),
('100', 12, '2016-04-04 17:05:44.000', 'Product'),
('100', 13, '2016-04-04 17:10:44.000', 'Product'),
('100', 14, '2016-04-04 17:15:44.000', 'Search')

GO

--This query puts the data in a format that makes only changes to PageType
--(in sequential order) unique. If we create a variable "Diff" that is the same
--for consecutive PageTypes then we can group by ID, PageType and Diff to get
--unique values on PageType and the order they happened in i.e. the customer
--path. Using the OVER funtion in MS SQL Server we can order virtual "test" TABLE
--by ID, PageType and PageNumber. When we take the difference between the
--page number and the ROW_NUMBER difference between records, consecutive rows
--that have the same PageType will have the same Diff number allowing us to
--group them and leave nonconsecutive PageTypes as distinct groupings.
SELECT
  ID
  ,min(PageNumber) AS Sequence
  ,min(Time) AS StartTime
  ,PageType
  ,COUNT(*) AS Count
FROM (
      SELECT
        ID,
        PageNumber,
        Time,
        PageNumber - ROW_NUMBER() OVER (ORDER BY ID, PageType, PageNumber) AS Diff,
        PageType
      FROM
      testDb.dbo.test
) AS TablePreSort
GROUP BY
	ID, PageType, Diff
ORDER BY Sequence
GO
