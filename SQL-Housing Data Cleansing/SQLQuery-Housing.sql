/*
Step 1.Cleaning Data in SQL queries
*/
SELECT *
FROM Housing;
/*
Step 2. Standardize Date format
*/
SELECT SaleDate
FROM Housing;

Select SaleDate, CONVERT(Date,SaleDate)
from dbo.Housing

UPDATE Housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Housing
Add SaleDateConverted Date;

UPDATE Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
From dbo.Housing

/*
Step 3. Property Address (Populate Null value)
*/
Select *
From [Project Porfolio].dbo.Housing
where PropertyAddress Is Null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From [Project Porfolio].dbo.Housing a
JOIN [Project Porfolio].dbo.Housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From [Project Porfolio].dbo.Housing a
JOIN [Project Porfolio].dbo.Housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

/*
Step 4. Address breakdown (Address, City, State)
*/

Select PropertyAddress
From [Project Porfolio].dbo.Housing
order by ParcelID

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, lEN(PropertyAddress)) as Address
from [Project Porfolio].dbo.Housing

ALTER TABLE Housing
Add PropertySplit_Address Nvarchar(255);

Update Housing
Set PropertySplit_Address = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Housing
Add PropertySplit_City Nvarchar(255);

Update Housing
Set PropertySplit_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, lEN(PropertyAddress))

SELECT *
FROM Housing;

/* Step 5: PARSENAME - Owner Address Cleansing*/

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing;

ALTER TABLE Housing
ADD OwnerSplit_Address NVARCHAR (255);

UPDATE Housing
SET OwnerSplit_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing
ADD OwnerSplit_City NVARCHAR (255);

UPDATE Housing
SET OwnerSplit_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing
ADD OwnerSplit_State NVARCHAR (255);

UPDATE Housing
SET OwnerSplit_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Housing;

/*Step 6: Cleansing Change Y/N to Yes/No */
SELECT DISTINCT SoldAsVacant, COUNT (SoldAsVacant) 
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
FROM Housing;

UPDATE Housing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
END

/* Step 7: Remove Duplicates */
WITH RowNumCTE AS (
SELECT *,
      ROW_NUMBER () OVER (
	  PARTITION BY ParcelID,
	               SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY  UniqueID 
				   ) row_num
FROM Housing
)

DELETE
FROM RowNumCTE
WHERE row_num >1

/* Delete Unused Columns */

SELECT *
FROM Housing

ALTER TABLE Housing

DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
