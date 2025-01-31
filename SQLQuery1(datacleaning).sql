/*

Cleaning Data in SQL Queries


*/	

Select *
From PortfolioProject.dbo.Datacleaning

-- Standardize Data Format
Select Saledateconvert,CONVERT(Date,SaleDate)
From PortfolioProject.dbo.Datacleaning

UPDATE PortfolioProject.dbo.Datacleaning
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject.dbo.Datacleaning
add Saledateconvert Date;

UPDATE PortfolioProject.dbo.Datacleaning
SET Saledateconvert = CONVERT(Date,SaleDate)




-- Populate Property Address Data
Select *
From PortfolioProject.dbo.Datacleaning
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.PropertyAddress,b.ParcelID,ISNULL(a.PropertyAddress,b.PropertyAddress)
From  PortfolioProject.dbo.Datacleaning a
Join PortfolioProject.dbo.Datacleaning b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Datacleaning a
Join PortfolioProject.dbo.Datacleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Colums(Address, City, State)
SELECT PropertyAddress
From PortfolioProject.dbo.Datacleaning

Select SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.Datacleaning

ALTER TABLE PortfolioProject.dbo.Datacleaning
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.Datacleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject.dbo.Datacleaning
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.Datacleaning
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.Datacleaning



Select OwnerAddress
From PortfolioProject.dbo.Datacleaning


Select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From PortfolioProject.dbo.Datacleaning

ALTER TABLE PortfolioProject.dbo.Datacleaning
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.Datacleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE PortfolioProject.dbo.Datacleaning
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.Datacleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

ALTER TABLE PortfolioProject.dbo.Datacleaning
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.Datacleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

SELECT *
FROM PortfolioProject.dbo.Datacleaning




-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT (SoldAsVacant),COUNT(SoldAsVacant)
From  PortfolioProject.dbo.Datacleaning
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
		FROM PortfolioProject.dbo.Datacleaning

UPDATE PortfolioProject.dbo.Datacleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
			WHEN SoldAsVacant = 'N' THEN 'NO'
			ELSE SoldAsVacant
			END

SELECT *
FROM PortfolioProject.dbo.Datacleaning


-- Remove Duplicates

WITH RowNumCTE AS (
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
From PortfolioProject.dbo.Datacleaning
)
SELECT *
FROM RowNumCTE
where row_num > 1
order by PropertyAddress



-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.Datacleaning


ALTER TABLE PortfolioProject.dbo.Datacleaning
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate