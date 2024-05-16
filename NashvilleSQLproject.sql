
select * 
from [Portfolio Project]..nashvillehousing

--standardize date format

select saledate
from [Portfolio Project]..nashvillehousing

	alter table [Portfolio Project]..nashvillehousing
	alter column saledate date

--Populate property address data

select *
from [Portfolio Project]..nashvillehousing
where propertyaddress is null 
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,
isnull(a.propertyaddress, b.propertyaddress)
from [Portfolio Project]..nashvillehousing a
join [Portfolio Project]..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from [Portfolio Project]..nashvillehousing a
join [Portfolio Project]..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

Breaking out address into individual columns (Address, city, State)

select *
from [Portfolio Project]..nashvillehousing
--where propertyaddress is null 
order by parcelid

select 
substring(Propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) +1,
LEN(propertyaddress)) as Address
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing
Add PropertySplitAddress  Nvarchar(255);

update  [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1)

alter table [Portfolio Project]..NashvilleHousing
add PropertySplitCity Nvarchar(255);

update  [Portfolio Project]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress)
+1, LEN(propertyaddress))

select *
from [Portfolio Project]..NashvilleHousing

select OwnerAddress
from [Portfolio Project]..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', ','), 3),
PARSENAME(REPLACE(OwnerAddress, ',', ','), 2),
PARSENAME(REPLACE(OwnerAddress, ',', ','), 1)
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing
add OwnerSPlitAddress Nvarchar(255);

update [Portfolio Project]..NashvilleHousing
SET OwnerSPlitAddress = PARSENAME(REPLACE(OwnerAddress, ',', ','), 3)

alter table [Portfolio Project]..NashvilleHousing
add OwnerSPlitCity Nvarchar(255);

update [Portfolio Project]..NashvilleHousing
SET OwnerSPlitCity = PARSENAME(REPLACE(OwnerAddress, ',', ','), 2)

alter table [Portfolio Project]..NashvilleHousing
add OwnerSPlitState Nvarchar(255);

update [Portfolio Project]..NashvilleHousing
SET OwnerSPlitState = PARSENAME(REPLACE(OwnerAddress, ',', ','), 1)

select *
from [Portfolio Project]..NashvilleHousing

Change Y and N to yes and no in "SoldAsVacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
from [Portfolio Project]..NashvilleHousing

update [Portfolio Project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

-Remove Duplicates
with RowNUmCTE as (
select *,
		ROW_NUMBER() over(
		partition by parcelid,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								order by uniqueid) row_num
from [Portfolio Project]..NashvilleHousing
order by ParcelID
)
select *
from RowNUmCTE
where row_num > 1
order by [UniqueID ]

select *
from [Portfolio Project]..NashvilleHousing

Delete unused Columns

select *
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing
drop column OwnerAddress, TaxDistrict,PropertyAddress

select SaleDate, LandUse, SalePrice, LandValue, TotalValue, SoldAsVacant, BuildingValue
from [Portfolio Project]..NashvilleHousing
WHERE LandValue IS NOT NULL and BuildingValue <> 0
ORDER BY BuildingValue DESC