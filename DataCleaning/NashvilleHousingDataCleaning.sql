--Cleaning Data with SQL Queries

SELECT * 
FROM NashvilleHousing

-- Standardize Sale Date format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data
-- ParcelID is a property identifier. Same ParcelID = same property.
-- We use self-join to find another row with same ParcelID that HAS an address,
-- then fill in the NULL address from that matching row.

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID=b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE  a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID=b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE  a.PropertyAddress IS NULL

--Breaking Property Adress Into Columns(Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing 

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyPlace Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertyPlace= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

--Breaking the Owner address 

SELECT OwnerAddress FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnersAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnersAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnersCity Nvarchar(255);
  
UPDATE NashvilleHousing
SET OwnersCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnersState Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnersState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM NashvilleHousing

--Changing 0's and 1's to Yes and No in SOLD AS VACANT field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3);

SELECT 
     CASE
	 WHEN SoldAsVacant = 1 THEN 'YES'
	 WHEN SoldAsVAcant = 0 THEN 'NO'
	 ELSE 'Unknown'
	 END AS SoldAsVacant
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	 WHEN SoldAsVacant = 1 THEN 'YES'
	 WHEN SoldAsVAcant = 0 THEN 'NO'
	 ELSE 'Unknown'
	 END ;

SELECT * FROM NashvilleHousing

--Removing Duplicates

WITH RowNum AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY
								UniqueID) row_num
FROM NashvilleHousing)

--DELETE 
--FROM RowNum
--WHERE row_num > 1

SELECT * FROM RowNum

--Deleting Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate;

SELECT * 
FROM NashvilleHousing

