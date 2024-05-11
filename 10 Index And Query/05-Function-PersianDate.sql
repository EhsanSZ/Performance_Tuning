
--فقط در ویندوز 10 و ویندوز سرور 2016 
-- در ویندوزCulture انجام تنظیمات 
--به بالا داشته باشیدSQL Server 2012 حتما هم 
DECLARE @date DATETIME=GETDATE()
SELECT FORMAT(@date,'yyyy/MM/dd','fa-IR')
SELECT FORMAT(@date,'yyyy/MM/dd HH:MM:ss','fa-IR')