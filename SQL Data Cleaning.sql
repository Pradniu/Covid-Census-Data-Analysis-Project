SELECT *
FROM [census ]..NashvilleHousing

---converting datetime to date 
ALTER TABLE NashvilleHousing ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT SaleDateConverted,CONVERT(date, SaleDate)
FROM NashvilleHousing;
---
SELECT *
FROM NashvilleHousing
--where PropertyAddress is null
order by ParcelID
--checking the parcelId of PropertyAddress 
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null;
---Update the null propertyAddress with the propertyAddress value
UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null;

-----------------
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM NashvilleHousing

---Adding new column PropertyHometown to split home Address with City
ALTER TABLE NashvilleHousing ADD PropertyHometown NVarchar(255);

UPDATE NashvilleHousing
SET PropertyHometown = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

---Updating new column PropertyCity to split home Address with City
ALTER TABLE NashvilleHousing ADD PropertyCity NVarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


SELECT *

FROM NashvilleHousing
--------------------------------------------
--Separating OwnerAddress with HomeAddress,City and State
SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

---Adding new column OwnerHomeAdress from split OwnerAdress

ALTER TABLE NashvilleHousing ADD OwnerHomeAddress NVarchar(255);

UPDATE NashvilleHousing
SET OwnerHomeAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3);

---Adding new column OwnerCity from split OwnerAdress

ALTER TABLE NashvilleHousing ADD OwnerCity NVarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2);

---Adding new column OwnerState from split OwnerAdress

ALTER TABLE NashvilleHousing ADD OwnerState NVarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME (REPLACE(OwnerAddress,',','.'),1);


SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
Case When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =Case When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
-----------------------------------
---Remove Duplicates
WITH RowNumCTE As (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
Order by
UniqueID)row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
---Order by PropertyAddress


ALTER TABLE NashvilleHousing 
DROP column SaleDate,OwnerAddress,PropertyAddress,wnerHomeAddress,TaxDistrict;
SELECT *
FROM NashvilleHousing