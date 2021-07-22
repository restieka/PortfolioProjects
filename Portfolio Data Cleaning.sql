/*
Cleaning data in SQL queries
*/
select * from [dbo].[NashvilleHousing]

----------------------------------------------------------------------------------------------------------------------------
--Standardize date format

select SaleDate, convert (date, SaleDate)
from [dbo].[NashvilleHousing]

update NashvilleHousing
set SaleDateConverted=convert (date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

select SaleDateConverted
from [dbo].[NashvilleHousing]

------------------------------------------------------------------------------------------------------------------------------
--Populate property address data
select *
from [dbo].[NashvilleHousing]
where PropertyAddress is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


--------------------------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns (Address, city, state)
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address2
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);--1st char until comma

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress));--func len, start from comma until the last char of PropertyAddress

select *
from NashvilleHousing


select OwnerAddress
from NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),3),--parsename = read from back, separate by period '.' ex : cikeas.gunungputri.bogor --> parsename(ex,1)=bogor,parsename(ex,2)=gunungputri 
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N into Yes and No in "Sold as vacant field"
select SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant 
order by 2

select SoldAsVacant,
CASE when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
End
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant= CASE when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
End

-----------------------------------------------------------------------------------------------------------------------------------
--Remove duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over(
Partition by ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 order by uniqueID
			) rownum
from NashvilleHousing
--where rownum = 2
--order by ParcelID
)

select *
from RowNumCTE
where rownum >1
order by PropertyAddress

--delete
--from RowNumCTE
--where rownum >1



-----------------------------------------------------------------------------------------------------------------------------------------
--Delete unused Columns
select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict



