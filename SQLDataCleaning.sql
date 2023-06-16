/*
	CLEANING DATA IN SQL QUERIES
*/

select *
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------

--Standardize date format

select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate =  CONVERT(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------

--Populate Property Address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress )
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)
select PropertyAddress
from PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



select 
Parsename(Replace(OwnerAddress,',','.'), 3),
Parsename(Replace(OwnerAddress,',','.'), 2),
Parsename(Replace(OwnerAddress,',','.'), 1)
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress =Parsename(Replace(OwnerAddress,',','.'), 3);

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity =Parsename(Replace(OwnerAddress,',','.'), 2);

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState =Parsename(Replace(OwnerAddress,',','.'), 1);

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------

--Change Y and N to 'Yes' and 'No' in Sold as Vacant Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select Distinct(SoldAsVacant), 
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

---------------------------------------------------------------------------------------

--Remove Duplicates
With RownumCTE as
(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				order by UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RownumCTE
where row_num >1
order by PropertyAddress

DELETE 
from RownumCTE
where row_num >1


----------------------------------------------------------------------------

--Delete unused columns
select *
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
drop column SaleDate