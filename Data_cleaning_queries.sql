-- change the SaleDate column to show the date only, instead of date and time
ALTER TABLE HousingData
ALTER COLUMN SaleDate Date;

-- populate the PropertyAddress column with values where PropertyAddress contains a null
-- do this by setting the PropertyAddress to the same address where the ParcelID has the same value
UPDATE HD1
SET PropertyAddress = ISNULL(HD1.PropertyAddress, HD2.PropertyAddress)
FROM HousingData HD1
JOIN HousingData HD2
ON HD1.ParcelID = HD2.ParcelID
AND HD1.[UniqueID ] <> HD2.[UniqueID ]
WHERE HD1.PropertyAddress IS NULL;

-- Split the PropertyAddress into two new columns, one for the street address and one for the City name
-- do this by adding two new tables, then filling the tables with values
ALTER TABLE HousingData
ADD PropertyStreet VARCHAR(100),
PropertyCity VARCHAR(100);

UPDATE HousingData
--SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);
SET PropertyStreet = PARSENAME(REPLACE(PropertyAddress, ',','.'),2);

UPDATE HousingData
SET PropertyCity = PARSENAME(REPLACE(PropertyAddress, ',','.'),1);

-- Split the OwnerAddress into three new columns, one for the street address and one for the City name, and one for the state name
-- do this by adding three new tables, then filling the tables with values
ALTER TABLE HousingData
ADD OwnerStreet VARCHAR(100),
OwnerCity VARCHAR(100),
OwnerState VARCHAR(100);

UPDATE HousingData
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);

UPDATE HousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);

UPDATE HousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);

-- change all the Y and N in SoldAsVacant column to Yes and No
UPDATE HousingData
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- show duplicates
WITH Duplicates AS(
SELECT *, ROW_NUMBER()
OVER(PARTITION BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID) AS "Count"
FROM HousingData)
SELECT *
FROM Duplicates
WHERE Count > 1;

-- delete duplicates
WITH Duplicates AS(
SELECT *, ROW_NUMBER()
OVER(PARTITION BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID) AS "Count"
FROM HousingData)
DELETE
FROM Duplicates
WHERE Count > 1;

-- remove unused rows
ALTER TABLE HousingData
DROP COLUMN PropertyAddress, OwnerAddress;