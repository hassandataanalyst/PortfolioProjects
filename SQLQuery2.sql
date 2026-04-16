-- Cleaning Data in SQL Queries  

SELECT * FROM [Portfolio Project]..nashvilleHousing

--- Standardize Date Format   ---  1

SELECT SaleDate, SaleDateConverted
FROM [Portfolio Project]..nashvilleHousing

ALTER TABLE [Portfolio Project]..nashvilleHousing
ADD SaleDateConverted DATE;

UPDATE [Portfolio Project]..nashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--- Populate Property Address Data  ---  2
SELECT * FROM [Portfolio Project]..nashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..nashvilleHousing a
JOIN [Portfolio Project]..nashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE  a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..nashvilleHousing a
JOIN [Portfolio Project]..nashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking Out Address into Individual Columns (Address, City, State)  --- 3
SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [Portfolio Project]..nashvilleHousing

ALTER TABLE [Portfolio Project]..nashvilleHousing
ADD 
PropertySplitAddress nvarchar(255),
PropertySplitCity nvarchar(255);

UPDATE [Portfolio Project]..nashvilleHousing
SET 
PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM [Portfolio Project]..nashvilleHousing

ALTER TABLE [Portfolio Project]..nashvilleHousing
ADD 
OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255);

UPDATE [Portfolio Project]..nashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * FROM [Portfolio Project]..nashvilleHousing


--- Changing Y and N to Yes and No in SolidAsVacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM [Portfolio Project]..nashvilleHousing

UPDATE [Portfolio Project]..nashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--- Remove Duplicates 
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [Portfolio Project]..nashvilleHousing
)

DELETE 
FROM RowNumCTE 
WHERE row_num > 1;



--- Delete Unused Columns 
SELECT * FROM [Portfolio Project]..nashvilleHousing

ALTER TABLE [Portfolio Project]..nashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict, OwnerAddress