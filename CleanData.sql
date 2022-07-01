-- Drop Duplicate Table if Necesary
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE BROOKLYN_COPY';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Create Duplicate Table
CREATE TABLE BROOKLYN_COPY AS (SELECT * FROM BROOKLYN_SALES_MAP);

-- Part 1: Adding NULL Year, Month, Day, Day of Week Columns to Original Table
ALTER TABLE BROOKLYN_COPY
ADD (
    MONTH NUMBER(2) NULL,
    YEAR NUMBER(4) NULL,
    DAY NUMBER(2) NULL,
    DAY_OF_WEEK NUMBER(1) NULL
    )
;

-- Part 2: Update Year, Month, Day, Day of Week Columns in Original Table
UPDATE BROOKLYN_COPY
SET
    MONTH = EXTRACT(MONTH FROM SALE_DATE),
    YEAR = EXTRACT(YEAR FROM SALE_DATE),
    DAY = EXTRACT(DAY FROM SALE_DATE),
    DAY_OF_WEEK = to_char(SALE_DATE,'D')
WHERE rowid=rowid
;

-- Part 3: Change Column Types: Create New Empty Columns With Correct Data Type
ALTER TABLE BROOKLYN_COPY
ADD
(
    ZIP_CODE_ VARCHAR2(26),
    LOT_ VARCHAR2(26),
    YEAR_ VARCHAR2(26),
    MONTH_ VARCHAR2(26),
    DAY_ VARCHAR2(26),
    DAY_OF_WEEK_ VARCHAR2(26)
)
;

Part 4: Change Column Types: Populate New Columns With Data
UPDATE BROOKLYN_COPY
SET 
    ZIP_CODE_       = ZIP_CODE,
    LOT_            = LOT,
    YEAR_           = YEAR,
    MONTH_          = MONTH,
    DAY_            = DAY,
    DAY_OF_WEEK_    = DAY_OF_WEEK
WHERE rowid=rowid
;

-- Part 5: Change Column Types: Drop OId Columns
ALTER TABLE BROOKLYN_COPY
DROP
(
    ZIP_CODE,
    LOT,
    YEAR,
    MONTH,
    DAY,
    DAY_OF_WEEK
)
;

-- Part 6: Change Column Types: Change Name of New Columns
ALTER TABLE BROOKLYN_COPY
RENAME COLUMN ZIP_CODE_ TO ZIP_CODE;
ALTER TABLE BROOKLYN_COPY
RENAME COLUMN LOT_ TO LOT;
ALTER TABLE BROOKLYN_COPY
RENAME COLUMN YEAR_ TO YEAR;
ALTER TABLE BROOKLYN_COPY
RENAME COLUMN MONTH_ TO MONTH;
ALTER TABLE BROOKLYN_COPY
RENAME COLUMN DAY_ TO DAY;
ALTER TABLE BROOKLYN_COPY
RENAME COLUMN DAY_OF_WEEK_ TO DAY_OF_WEEK;

-- Drop BROOKLYN_VIEW Table if Necesary
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW BROOKLYN_VIEW';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Drop BROOKLYN_VIEW_FINAL Table if Necesary
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW BROOKLYN_VIEW_FINAL';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Filter Table So Sale_Price is > $400K and < $7M & Select Columns That ADS Selected
CREATE VIEW BROOKLYN_VIEW AS
SELECT NEIGHBORHOOD, BUILDING_CLASS_CATEGORY, BLOCK, BUILDING_CLASS, LAND_SQFT, GROSS_SQFT, YEAR_BUILT, SALE_PRICE, SANITBORO, SANITSUB, LOTAREA, BLDGAREA, COMAREA, 
RETAILAREA, GARAGEAREA, LOTFRONT, ASSESSLAND,
ASSESSTOT, EXEMPTTOT, YEARBUILT, BUILTFAR, FACILFAR, SANBORN, MONTH, YEAR
FROM BROOKLYN_COPY
WHERE SALE_PRICE > 400000 AND SALE_PRICE < 7000000
;

-- Filter The Building Class Category in Brooklyn View Final Where We Are Only Looking at Family Homes
CREATE VIEW BROOKLYN_VIEW_FINAL AS
SELECT * FROM BROOKLYN_VIEW
WHERE BUILDING_CLASS_CATEGORY = '02 TWO FAMILY HOMES'
OR BUILDING_CLASS_CATEGORY = '01 ONE FAMILY HOMES'
OR BUILDING_CLASS_CATEGORY = '03 THREE FAMILY HOMES'
;
