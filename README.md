# 🏠 Nashville Housing — Data Cleaning with SQL

![SQL Server](https://img.shields.io/badge/SQL-Server-blue) ![Data Cleaning](https://img.shields.io/badge/Data-Cleaning-orange) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## 📌 Project Overview

This project demonstrates end-to-end **data cleaning using SQL Server** on a real-world Nashville housing dataset. Raw data is transformed into a clean, analysis-ready format through a series of structured SQL operations.

> 🎯 **Goal:** Take messy raw housing data and clean it using SQL best practices — handling NULLs, splitting columns, standardizing values, removing duplicates, and dropping redundant fields.

---

## 🗂️ Project Structure

```
Nashville-Housing-Data-Cleaning/
│
├── README.md
├── SQL/
│   └── NashvilleHousing_Cleaning.sql    # Full cleaning script with comments
└── Data/
    └── RawData.csv                       # Original raw dataset
```

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| **SQL Server (SSMS)** | All data cleaning operations |
| **GitHub** | Version control and portfolio showcase |

---

## 🧹 Cleaning Steps Performed

### 1. 📋 Data Preview & Quality Check
Initial exploration and row-level quality audit — counting NULLs across key columns before cleaning begins.

### 2. 📅 Standardize Sale Date Format
Converted `SaleDate` (datetime with timestamp) to a clean `DATE` format using `CONVERT()` and stored in a new column `SaleDateConverted`.

### 3. 📍 Populate Missing Property Addresses
Used a **self-join on ParcelID** to fill NULL `PropertyAddress` values. Logic: if two rows share the same `ParcelID`, they represent the same property — so a missing address can be filled from the matching row.

```sql
UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
```

### 4. 🏘️ Split PropertyAddress into Street + City
Used `SUBSTRING` and `CHARINDEX` to split a single address field into two separate usable columns.

```sql
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Street
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
```

### 5. 👤 Split OwnerAddress into Street, City, State
Used `PARSENAME` with `REPLACE` to parse a 3-part address string into three separate columns.

```sql
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Street
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
```

### 6. ✅ Standardize SoldAsVacant (0/1 → Yes/No)
Converted binary integer flags to human-readable `Yes`/`No` text using a `CASE` statement.

```sql
CASE
    WHEN SoldAsVacant = '1' THEN 'Yes'
    WHEN SoldAsVacant = '0' THEN 'No'
    ELSE SoldAsVacant
END
```

### 7. 🔁 Remove Duplicate Rows
Used `ROW_NUMBER()` with `PARTITION BY` to identify and delete exact duplicates based on key identifying fields.

```sql
ROW_NUMBER() OVER (
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ORDER BY UniqueID
) AS row_num
-- Deleted all rows where row_num > 1
```

### 8. 🗑️ Drop Unused Columns
Removed original (now redundant) columns: `OwnerAddress`, `PropertyAddress`, `TaxDistrict`, `SaleDate` — replaced by the cleaner split columns.

### 9. 🔍 Final Verification
Row count, unique property count, date range, and remaining NULL checks to confirm data quality.

---

## 📊 Before vs After

| Metric | Before | After |
|--------|--------|-------|
| NULL Property Addresses | ✅ Present | ❌ Removed |
| Address columns | 1 combined | 2 split (Street + City) |
| Owner Address columns | 1 combined | 3 split (Street, City, State) |
| SoldAsVacant values | 0 / 1 | Yes / No |
| Duplicate rows | ✅ Present | ❌ Removed |
| Unused columns | 4 columns | Dropped |

---

## 💡 Key SQL Concepts Demonstrated

- `ISNULL()` for NULL handling
- Self-JOIN for data imputation
- `SUBSTRING()` + `CHARINDEX()` for string parsing
- `PARSENAME()` + `REPLACE()` for address splitting
- `CASE` statements for value standardization
- `ROW_NUMBER()` window function for duplicate detection
- `ALTER TABLE` / `DROP COLUMN` for schema changes
- CTEs (Common Table Expressions) for readable query structure

---

## 🚀 How to Run

1. Install **SQL Server Express** + **SSMS**
2. Create a database (e.g., `NashvilleHousing_DB`)
3. Import `Data/RawData.csv` using the Import Flat File wizard
4. Open `SQL/NashvilleHousing_Cleaning.sql` in SSMS
5. Run each section step by step (select + F5)

---

## 👩‍💻 Author

**Manisha Kasula**  
Aspiring Data Analyst | SQL • Excel • Tableau  
🔗 [https://www.linkedin.com/in/manishakasula/] | 📧 [manishakasul2.mk@gmail.com]

---
