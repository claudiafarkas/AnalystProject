-- DATA CLEANING QUERY

SELECT *
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------Standardize Date Format----------------------------------------------
Select SaleDateConverted, CONVERT (Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT (Date, SaleDate)

--Updating table with the new changes
ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT (Date, SaleDate)

----------------------------------------------Populate Property Address Data----------------------------------------------
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- Filtering out when ParcelID is the same as PropertyAddress
Select A.ParcelID, a.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

--Update table A with the SET conditions
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

----------------------------------------------Breaking Address into Individual Columns----------------------------------------------
--Option 1.
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--SELECT * 
--FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

--Option 2.(Easier Way of Breaking up the Address)
--
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------Changing Binary Values----------------------------------------------
-- Prints total count of each used distinct value for column SoldAsVacant
SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Creating Coditions where the swap needs to happen
SELECT SoldAsVacant
, CASE WHEN SoldASVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

--Updating the database with the SET cases
Update NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldASVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------REMOVE DUPLICATES----------------------------------------------
--Using a CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


----------------------------------------------DELETE UNUSED COLUMNS----------------------------------------------
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate



