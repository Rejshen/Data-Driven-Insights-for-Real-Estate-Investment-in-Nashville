Select * from `nashville housing data for data cleaning`;

CREATE TABLE housing_records
LIKE `nashville housing data for data cleaning`;

INSERT housing_records 
SELECT * 
FROM `nashville housing data for data cleaning`;

SELECT * FROM housing_records;

ALTER TABLE housing_records
CHANGE COLUMN `嚜燃niqueID` UniqueID INT;


-- 1. Remove Duplicates

-- Find the Duplicates Row 
WITH DuplicatesCTE AS 
(
SELECT *
, ROW_NUMBER() 
OVER (PARTITION BY UniqueID, ParcelID, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, 
OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, 
TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath 
)AS row_num
FROM housing_records
)
SELECT *
FROM  DuplicatesCTE
WHERE row_num > 1; 

-- Creating the new table to store the row-num
CREATE TABLE `cleaning_housing_records` (
  `UniqueID` int DEFAULT NULL,
  `ParcelID` text,
  `LandUse` text,
  `PropertyAddress` text,
  `SaleDate` text,
  `SalePrice` int DEFAULT NULL,
  `LegalReference` text,
  `SoldAsVacant` text,
  `OwnerName` text,
  `OwnerAddress` text,
  `Acreage` double DEFAULT NULL,
  `TaxDistrict` text,
  `LandValue` int DEFAULT NULL,
  `BuildingValue` int DEFAULT NULL,
  `TotalValue` int DEFAULT NULL,
  `YearBuilt` int DEFAULT NULL,
  `Bedrooms` int DEFAULT NULL,
  `FullBath` int DEFAULT NULL,
  `HalfBath` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * 
FROM cleaning_housing_records;

INSERT INTO cleaning_housing_records
SELECT *
, ROW_NUMBER() 
OVER (PARTITION BY UniqueID, ParcelID, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, 
OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, 
TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath 
)AS row_num
FROM housing_records;

-- Turn off the SQL safe mode
SET SQL_SAFE_UPDATES = 0;

DELETE 
FROM  cleaning_housing_records
WHERE row_num > 1; 

SELECT * 
FROM cleaning_housing_records;



-- 2. Standardize the Data

-- Update the SoldAsVacant to same format

SELECT DISTINCT SoldAsVacant
FROM cleaning_housing_records
;

UPDATE cleaning_housing_records
SET SoldAsVacant = 'NO'
WHERE SoldAsVacant = 'N'
OR SoldAsVacant  = 'No'
;

UPDATE cleaning_housing_records
SET SoldAsVacant = 'YES'
WHERE SoldAsVacant = 'Y'
OR SoldAsVacant  = 'yes'
;


-- SaleDate Formatted

UPDATE cleaning_housing_records
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y')
;

SELECT SaleDate
FROM cleaning_housing_records
;


-- 3. Null Values or blanks values

UPDATE cleaning_housing_records
SET 
    PropertyAddress = NULLIF(PropertyAddress, ''),
    OwnerAddress = NULLIF(OwnerAddress, ''),
    OwnerName = NULLIF(OwnerName, ''),
    LandUse = NULLIF(LandUse, ''),
    TaxDistrict = NULLIF(TaxDistrict, ''),
    SoldAsVacant = NULLIF(SoldAsVacant, ''),
    SaleDate = NULLIF(SaleDate, ''),
    SalePrice = NULLIF(SalePrice, '')
;
    

-- Delete the Null Property Address
SELECT *
FROM cleaning_housing_records
WHERE PropertyAddress IS NULL
;

DELETE
FROM cleaning_housing_records
WHERE PropertyAddress IS NULL
;

-- Delete the OwnerName&OwnerAddress formatted

SELECT *
FROM cleaning_housing_records
WHERE OwnerAddress IS NULL 
AND OwnerName IS NULL
;

DELETE
FROM cleaning_housing_records
WHERE OwnerAddress IS NULL 
AND OwnerName IS NULL
;

-- Update the Null as Unknown
UPDATE cleaning_housing_records
SET OwnerAddress = 'Unknown'
WHERE OwnerAddress IS NULL
;

-- TaxDistrict update 

SELECT *
FROM cleaning_housing_records
WHERE TaxDistrict IS NULL 
;

DELETE
FROM cleaning_housing_records
WHERE TaxDistrict IS NULL 
;

-- 4. Remove Any Columns and rows 

SELECT * FROM cleaning_housing_records;

-- Delete the Row Number

ALTER TABLE cleaning_housing_records
DROP COLUMN row_num;