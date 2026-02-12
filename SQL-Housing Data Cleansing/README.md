# 🏠 SQL Project - Housing Data Cleansing

## 📌 Project Overview

This project demonstrates a practical **data cleaning workflow in SQL Server** using a housing dataset. The goal is to transform raw, inconsistent data into a **clean, analysis-ready table** by standardizing formats, fixing missing values, splitting messy fields, removing duplicates, and dropping unused columns.

This is the type of cleaning process that typically happens before reporting, dashboarding, or modeling—especially when working with real business datasets.

---

## 🧠 Business Objectives

Housing datasets are often noisy with inconsistent date formats, null addresses, duplicate records, and mixed-format fields make the data difficult to use for analysis.

This project cleans the dataset so it can be reliably used for:

* housing market analysis
* mortgage trend reporting
* property pricing exploration
* geographic segmentation (city/state level analysis)

---

## 🔧 Data Cleaning Process Flow

### 1) Inspect the raw table

Reviewed the full `Housing` dataset to understand structure and identify potential quality issues.

```sql
SELECT *
FROM Housing
```

---

### 2) Standardize date format

Converted `SaleDate` into a clean SQL `DATE` type for consistency and analytics readiness.

```sql
--- Add column for new sale date format
ALTER TABLE Housing
ADD SaleDateConverted Date;

--- Add data for that column
UPDATE Housing
SET SaleDateConverted = CONVERT(Date,SaleDate);
```

---

### 3) Populate missing property addresses

Filled missing `PropertyAddress` values by matching records using `ParcelID` (self-join backfill).

```sql
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Housing a
JOIN dbo.Housing b
  ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
```

---

### 4) Split property address into structured fields

Split the combined `PropertyAddress` into:

* `PropertySplit_Address`
* `PropertySplit_City`

eg: 1808  Fox Chase Dr, Goodlettsville, TN

-> Address: 1808  Fox Chase Dr, Goodlettsville, TN

-> City: Goodlettsville

-> State: TN
```sql
--- Check column PropertyAddress
SELECT PropertyAddress
FROM dbo.Housing
ORDER BY ParcelID;

--- Split PropertyAddress into: Address, City
SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM dbo.Housing;

--- Add new columns for Address
ALTER TABLE Housing
ADD PropertySplit_Address NVARCHAR(255);
UPDATE Housing
SET PropertySplit_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

--- Add new columns for City
ALTER TABLE Housing
ADD PropertySplit_City NVARCHAR(255);
UPDATE Housing
SET PropertySplit_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

```

---

### 5) Clean and split owner address into address/city/state

Transformed one `OwnerAddress` text field into:

* `OwnerSplit_Address`
* `OwnerSplit_City`
* `OwnerSplit_State`

```sql
SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing;

--- Full address
ALTER TABLE Housing
ADD OwnerSplit_Address NVARCHAR(255);
UPDATE Housing
SET OwnerSplit_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

--- Split City
ALTER TABLE Housing
ADD OwnerSplit_City NVARCHAR(255);
UPDATE Housing
SET OwnerSplit_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

---Split State
ALTER TABLE Housing
ADD OwnerSplit_State NVARCHAR(255);
UPDATE Housing
SET OwnerSplit_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM Housing;
```

---

### 6) Normalize categorical values (Y/N → Yes/No)

Standardized `SoldAsVacant` values to improve filtering and reporting consistency.

```sql
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) 
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END
FROM Housing;

UPDATE Housing
SET SoldAsVacant =
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END;
```

---

### 7) Remove duplicate records

Removed duplicate rows using a CTE + `ROW_NUMBER()` window function based on key transaction fields.

```sql

WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   SalePrice,
                   SaleDate,
                   LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;
```

---

### 8) Drop unused or redundant columns

Dropped fields no longer needed after cleaning and splitting.

```sql
ALTER TABLE Housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate;
```

---

## 🛠 Tools / SQL Concepts Used

* SQL Server
* Data type conversion (`CONVERT`)
* Schema updates (`ALTER TABLE`)
* String parsing (`SUBSTRING`, `CHARINDEX`, `REPLACE`, `PARSENAME`)
* Conditional logic (`CASE`)
* Null handling (`ISNULL`)
* Deduplication with window functions (`ROW_NUMBER`)
* CTEs

---

## 📈 Outcome

After cleaning, the dataset becomes:

* easier to query and analyze
* consistent across formatting and categorical values
* normalized for location-based analysis (city/state breakdown)
* free of duplicate records
* structured for downstream use (dashboards, analysis, modeling)

---
