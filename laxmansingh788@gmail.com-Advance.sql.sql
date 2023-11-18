--SQL Advance Case Study


--Q1--BEGIN 
	
Select Distinct [State]
From DIM_LOCATION as L
Inner Join FACT_TRANSACTIONS as T
ON L.IdLocation = T.IdLocation
Where Year([Date]) >= 2005


--Q1--END

--Q2--BEGIN
	
Select Top 1 [State], Count(IDCustomer) as [No. of Cellphones bought]
From DIM_MANUFACTURER as M
Inner Join DIM_MODEL AS MO
ON M.IdManufacturer = MO. IdManufacturer
Inner Join FACT_TRANSACTIONS as T
ON MO.IdModel = T.IdModel
Inner Join DIM_LOCATION as L
ON T.IdLocation = L.IdLocation
Where Country= 'US'AND Manufacturer_Name = 'Samsung'
Group by [State]
Order by [No. of Cellphones bought] Desc



--Q2--END

--Q3--BEGIN      
	
Select IDModel, ZipCode, [State], Count(IDCustomer) as [No. of Transactions]
From FACT_TRANSACTIONS as T
Inner Join DIM_LOCATION as L
ON T.IdLocation = L.IdLocation
Group by IDModel, ZipCode, [State]


--Q3--END

--Q4--BEGIN

Select Top 1 Model_Name, Unit_price
From DIM_MODEL
Order by Unit_price Asc


--Q4--END

--Q5--BEGIN


Select IDManufacturer, IdModel, Avg(Unit_price) as Average_Price
From DIM_Model
Where IDManufacturer IN
(
Select Top 5 IDManufacturer
From FACT_TRANSACTIONS as T
Inner Join DIM_Model as M
ON T.IdModel = M.IdModel
Group by IDManufacturer
Order by Sum(Quantity) Desc
) 
Group by IDManufacturer, IDModel



--Q5--END

--Q6--BEGIN

Select Customer_Name, Avg(TotalPrice) as Average_amount_spent
From DIM_CUSTOMER as C
Inner Join FACT_TRANSACTIONS as M
ON C.IDCustomer = M.IDCustomer
Where Datepart(Year, [Date]) = 2009
Group by Customer_Name
Having Avg(TotalPrice) > 500




--Q6--END
	
--Q7--BEGIN  
	
Select * 
From
(Select Top 5 IDModel
From FACT_TRANSACTIONS
Where Datepart(Year, [Date]) = 2008
Group by IDModel
Order by Sum(Quantity) Desc
) as X
INTERSECT
Select *
From
(
Select Top 5 IDModel
From FACT_TRANSACTIONS
Where Datepart(Year, [Date]) = 2009
Group by IDModel
Order by Sum(Quantity) Desc
) as Y
INTERSECT
Select * 
From
(Select Top 5 IDModel
From FACT_TRANSACTIONS
Where Datepart(Year, [Date]) = 2010
Group by IDModel
Order by Sum(Quantity) Desc
) as Z



--Q7--END	
--Q8--BEGIN

Select IDManufacturer, Years, TotalPrice
From
(
Select IDManufacturer, TotalPrice, Datepart(Year, [Date]) as Years, 
Dense_Rank() Over (Partition by Datepart(Year, [Date]) Order by TotalPrice Desc) as Ranks
From DIM_MODEL as M
Inner Join FACT_TRANSACTIONS as T
ON M.IDModel = T.IDModel
Where Datepart(Year, [Date]) = 2009 OR Datepart(Year, [Date]) = 2010
) as X
Where Ranks = 2




--Q8--END
--Q9--BEGIN
	

Select IDManufacturer
From
(Select IDManufacturer, Datepart(Year, [Date]) as Years, Count(IDCustomer) as [Count of Cellphones_Sold]
From DIM_MODEL as M
Inner Join FACT_TRANSACTIONS as T
ON M.IDModel = T.IDModel
Where Datepart(Year, [Date]) = 2010
Group by IDManufacturer, Datepart(Year, [Date])
) as X
Except
Select IDManufacturer
From
(
Select IDManufacturer, Datepart(Year, [Date]) as Years, Count(IDCustomer) as [Count of Cellphones_Sold]
From DIM_MODEL as M
Inner Join FACT_TRANSACTIONS as T
ON M.IDModel = T.IDModel
Where Datepart(Year, [Date]) = 2009
Group by IDManufacturer, Datepart(Year, [Date])
) as Y


--Q9--END

--Q10--BEGIN
	
Select *,
((Average_spend- Previous_Average_spend)/Previous_Average_spend*100) as [Percentage change in spend]
From
(
Select IDCustomer, Datepart(Year, [Date]) as Years, 
Avg(TotalPrice) as Average_spend, Avg(Quantity) as Average_quantity,
Lag(Avg(TotalPrice), 1) Over (Partition by IDCustomer Order by Datepart(Year, [Date])) as Previous_Average_spend
From FACT_TRANSACTIONS
Where IDCustomer 
IN
(Select Top 10 IDCustomer
From FACT_TRANSACTIONS
Group by IDCustomer
Order by Sum(TotalPrice) Desc, Sum(Quantity) Desc
)
Group by Datepart(Year, [Date]), IDCustomer
) as X



--Q10--END
	