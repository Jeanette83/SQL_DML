


DROP TRIGGER IF EXISTS Lab4Q4 ;
DROP TRIGGER IF EXISTS Lab4Q3;
DROP TRIGGER IF EXISTS Lab4Q2;
DROP TRIGGER IF EXISTS Lab4Q1;



--1.	Create a trigger called Lab4Q1 to ensure that the Equipment PricePerDay will not increase by more than 15%. If this happens with any records, increase the cost to 15% only for those records and raise an error message informing the user that at least one records increase was capped at 15%. (4 Marks)


go
create trigger Lab4Q1
on Equipment
for update
as 
if @@ROWCOUNT>0and update(PricePerDay)
	begin
	if exists(select * from inserted inner join deleted on inserted.PricePerDay = deleted.PricePerDay
	where inserted.PricePerDay > deleted.PricePerDay*1.15)
		begin
		update equipment
		set PricePerDay = inserted.PricePerDay
		where inserted.PricePerDay > deleted.PricePerday*1.15
		raiserror('At least one record was capped at a 15% increase',16,1)
		end
	end
return



--2.	Create a trigger called Lab4Q2 to ensure that a staff member cannot be assigned to perform equipment service unless that staff member is a ‘Technician’ or ‘Manager’. If an attempt is made to do so, raise an error message and do not allow the assignment(s) to succeed.  (3 Marks)
 --Create a Trigger that ensures a staff's PID is 1 or 5

go
create trigger Lab4Q2
on EquipmentService
for update, insert
as 
if @@ROWCOUNT>0 and update(staffno)
	begin
	if exists(select * from staff inner join inserted on Staff.StaffNo = inserted.StaffNo 
				where pid != 1 or pid != 5)
		begin
		rollback transaction
		raiserror('Cannot assign this service to this person',16,1)
		end
	end
return



--3.	Create a trigger called Lab4Q3 to ensure that a piece of equipment cannot be rented out longer than 5 days. If an attempts is made to do so, raise an error message and do not allow that to happen.   (3 Marks)

go
Create trigger LAB4Q3
on AgreementEquipment
for insert, update
as
if @@ROWCOUNT > 0 and update(equipmentno)
	begin
	if exists(select * from AgreementEquipment inner join inserted on AgreementEquipment.EquipmentNo = inserted.EquipmentNo
	where agreementEquipment.DaysRented>5)  
		begin																	
		raiserror('Cannot rent out equipment for longer than 5 days', 16,1)								 
		end
	end
return


--4.	Create a trigger called Lab4Q4 to add record(s) to a LogPricePerDayChange table when the PricePerDay of equipment changes to a new value. The ERD for the table is shown below. The table has already been created in the lab4.sql file. (3 Marks)

go
Create trigger Lab4Q4 
on AgreementEquipment
for update
as 
if @@ROWCOUNT>0 and update(PricePerDay)
	begin 
	insert into LogPricePerDayChange(ChangeDateTime, EquipmentNo,OldPricePerDay, NewPricePerDay)                                                        
	select  getdate(), inserted.EquipmentNo, deleted.PricePerDay, inserted.PricePerDay from deleted 
	inner join inserted on inserted.EquipmentNo = deleted.EquipmentNo 
	where inserted.PricePerDay != deleted.PricePerDay
