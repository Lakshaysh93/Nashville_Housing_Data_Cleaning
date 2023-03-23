/*

Cleaning data using SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------

-- Standardize Date Format

Alter table PortfolioProject.dbo.NashvilleHousing
add Dateofsale date

update PortfolioProject.dbo.NashvilleHousing
set Dateofsale = convert(date,SaleDate)

select Dateofsale, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------
--- Populate property address data

select * from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
join PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
join PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

----------------------------------------------------------------------------------
-----breaking address into individual columns

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as address1
, substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress)) as address2
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add Addresspartone nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set Addresspartone = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add Addressparttwo nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set Addressparttwo = substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress))

select Addresspartone,Addressparttwo
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'), 3), 
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add Ownersplitaddress nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set Ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

alter table PortfolioProject.dbo.NashvilleHousing
add Ownersplitcity nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set Ownersplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

alter table PortfolioProject.dbo.NashvilleHousing
add Ownersplitstate nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set Ownersplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------
--------Change Y and N to yes and No in "Sold as Vacant" field.

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant
	                    end

select * from PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------
-----Removing duplicates

with RowNumCTE as(
select *, 
      row_number() over(
	  partition by ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   order by 
				        uniqueID
						) row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

select * from
PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------
-----Delete unused columns


alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAdress, TaxDistrict, PropertyAddress, SaleDate