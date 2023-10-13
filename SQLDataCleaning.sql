/*

Cleaning Data in SQL Queries

*/


  Select *
  From PortfolioProject..[dbo.Nashvillehousing]

  --------------------------------------------------------------------------------------------------------------

  -- Standardize Date Format

  Select SaleDate, CONVERT(date,Saledate) as ConvertedSaledate
  From PortfolioProject..[dbo.Nashvillehousing]

  Update [dbo.Nashvillehousing]
  Set SaleDate = CONVERT(date,Saledate)

  Select SaleDate
  From PortfolioProject..[dbo.Nashvillehousing]

  Alter Table [dbo.Nashvillehousing]
  ADD SaledateConverted date;

  Update [dbo.Nashvillehousing]
  Set SaledateConverted = CONVERT(date,Saledate)

  Select SaledateConverted
  From PortfolioProject..[dbo.Nashvillehousing]

  ---------------------------------------------------------------------------------------------------

  --Populate Property Address data

  Select *
  From PortfolioProject..[dbo.Nashvillehousing]
  Where PropertyAddress is Null
  Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[dbo.Nashvillehousing] a
Inner Join PortfolioProject..[dbo.Nashvillehousing] b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[dbo.Nashvillehousing] a
Inner Join PortfolioProject..[dbo.Nashvillehousing] b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null



-----------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


  Select *
  From PortfolioProject..[dbo.Nashvillehousing]


  Select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
  From PortfolioProject..[dbo.Nashvillehousing]

  ALTER TABLE PortfolioProject..[dbo.Nashvillehousing]
  ADD PropertySplitAddress Nvarchar(255)

  UPDATE PortfolioProject..[dbo.Nashvillehousing]
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE PortfolioProject..[dbo.Nashvillehousing]
  ADD PropertySplitCity Nvarchar(255)

  UPDATE PortfolioProject..[dbo.Nashvillehousing]
  SET PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  


  Select OwnerAddress
  From PortfolioProject..[dbo.Nashvillehousing]
  Order By OwnerAddress desc

  Select 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
  From PortfolioProject..[dbo.Nashvillehousing]
  ORDER BY OwnerSplitCity desc

  ALTER TABLE PortfolioProject..[dbo.Nashvillehousing]
  ADD OwnerSplitAddress Nvarchar(255)

  UPDATE PortfolioProject..[dbo.Nashvillehousing]
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

  ALTER TABLE PortfolioProject..[dbo.Nashvillehousing]
  ADD OwnerSplitCity Nvarchar(255)

  UPDATE PortfolioProject..[dbo.Nashvillehousing]
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

  ALTER TABLE PortfolioProject..[dbo.Nashvillehousing]
  ADD OwnerSplitState Nvarchar(255)

  UPDATE PortfolioProject..[dbo.Nashvillehousing]
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


  Select *
  From PortfolioProject..[dbo.Nashvillehousing]



  ----------------------------------------------------------------------------------------------------------

  -- Change Y And N to Yes and No in "SoldAsVacant" field

  Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
  From PortfolioProject..[dbo.Nashvillehousing]
  GROUP BY SoldAsVacant 

  Select
  CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
  From PortfolioProject..[dbo.Nashvillehousing]

  UPDATE PortfolioProject..[dbo.Nashvillehousing]
  SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE
AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

 From PortfolioProject..[dbo.Nashvillehousing]
 )

 --DELETE 
 --From RowNumCTE
 --WHERE row_num > 1

 Select *
 From RowNumCTE
 WHERE row_num > 1



 -----------------------------------------------------------------------------------

 -- Delete Unused Columns

  Select *
  From PortfolioProject..[dbo.Nashvillehousing]

  ALTER TABLE PortfolioProject..[dbo.Nashvillehousing]
  DROP COLUMN PropertyAddress, SaleDate, OwnerAddress