
/*

Cleaning Data in SQL Queries

*/

Select *
From [portfolio_project ].dbo.NashVilleHousing

------------------------------------------------------------------------------------

--Standardize Date Format

select SaleDate , convert(date,saledate) 
from [portfolio_project ].dbo.NashVilleHousing

alter table [portfolio_project ].dbo.NashVilleHousing 
add SaleDateConverted date 

update [portfolio_project ].dbo.NashVilleHousing
set SaleDateConverted = convert(date,saledate) 

---------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From [portfolio_project ].dbo.NashVilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [portfolio_project ].dbo.NashVilleHousing a
JOIN [portfolio_project ].dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [portfolio_project ].dbo.NashVilleHousing a
JOIN [portfolio_project ].dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress , SUBSTRING(propertyaddress , CHARINDEX(',',PropertyAddress,1)+1 , len(propertyaddress)-CHARINDEX(',',PropertyAddress,1)) 
as PropertySplitCity , SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress,1)-1) as PropertySplitAddress
from [portfolio_project ].dbo.NashVilleHousing

alter table [portfolio_project ].dbo.NashVilleHousing
add PropertySplitAddress Nvarchar(255) 

update  [portfolio_project ].dbo.NashVilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress,1)-1) 

alter table [portfolio_project ].dbo.NashVilleHousing
add PropertySplitCity Nvarchar(255)

update [portfolio_project ].dbo.NashVilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress , CHARINDEX(',',PropertyAddress,1)+1 , len(propertyaddress)-CHARINDEX(',',PropertyAddress,1)) 

Select OwnerAddress
From [portfolio_project ].dbo.NashVilleHousing

select OwnerAddress , PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState,
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress
from [portfolio_project ].dbo.NashVilleHousing

alter table [portfolio_project ].dbo.NashVilleHousing 
add OwnerSplitAddress Nvarchar(255)

update [portfolio_project ].dbo.NashVilleHousing 
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table [portfolio_project ].dbo.NashVilleHousing
add OwnerSplitCity Nvarchar(255)

update [portfolio_project ].dbo.NashVilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table [portfolio_project ].dbo.NashVilleHousing
add OwnerSplitState Nvarchar(255)

update [portfolio_project ].dbo.NashVilleHousing 
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

----------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant , count(SoldAsVacant)  
from [portfolio_project ].dbo.NashVilleHousing
group by SoldAsVacant

update [portfolio_project ].dbo.NashVilleHousing  
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						WHEN SoldAsVacant = 'N' then 'No'
						else SoldAsVacant 
						end
		 
--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
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

From [portfolio_project ].dbo.NashVilleHousing
--order by ParcelID
)
delete 
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE [portfolio_project ].dbo.NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


