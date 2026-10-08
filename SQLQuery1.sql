--Q1
Create table PatientIndexDemo
(
PatientId int, PatientName VarChar(100), DOB Date , WardId int
)

insert into PatientIndexDemo
Select Id,Name,DOB,WardId
from Patients

Create Clustered Index IX_PatientClusterdIndex
on PatientIndexDemo(PatientId)

--Q2
Select Id ,Name,Salary
into ConsultantIndexDemo
from Consultants

Create Clustered Index IX_ConsultantClusIndex
on ConsultantIndexDemo(Id)

--Q3
Create NonClustered Index IX_PatientsNonClusIndex
on Patients(WardId)

--Q4
Create NonClustered Index ConsultantsNonClusIndex
on Consultants(Salary)

--Q5
Create NonClustered Index IX_DANonClusIndex
on DrugAdministrations(PatientId,DrugCode)

--Q6
Create NonClustered Index IX_PatientsNonClusIndex1
on Patients(WardId)
Include(Name,DOB)

--Q7
Create Unique Index IX_UniqueConsultantsIndex
on Consultants(Name)

--Q8
Select
    PatientId,
    DrugCode,
    MIN(Date) AS Date
into PatientDrugAssignmentDemo
from DrugAdministrations
GROUP BY PatientId, DrugCode

Create Unique NonClustered Index IX_UniqueNonClusIndex
on PatientDrugAssignmentDemo(PatientId,DrugCode)

--Q9
insert into PatientDrugAssignmentDemo
values(200,123,'2005-01-01')

insert into PatientDrugAssignmentDemo
values(200,123,'2000-12-01')

--Q10
Exec sp_helpindex 'Patients'

--Q11
Select 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType
From sys.indexes i
JOIN sys.tables t
    ON i.object_id = t.object_id

--Q12
Drop index ConsultantsNonClusIndex
on Consultants

--Q13
Create NonClustered Index IX_PatientsNonClusIndex2
on Patients(WardId,DOB)

--Q14
Create NonClustered Index IX_DANonClusIndex1
on DrugAdministrations(PatientId,Date)
Include(DrugCode,Dosage,Quantity)


--=======================================================================================
--Last Assignment Complete
--Q13
Create or Alter Procedure dbo.InsertPatient @PatientId int,@Name VarChar(100),@DOB Date,@WardId int
As
Begin
Begin Try
Insert into Patients
Values(@PatientId,@Name,@DOB,@WardId)
print 'Patient Inserted Successfully'
End Try

Begin Catch
       print 'Error occurred'
       print ERROR_MESSAGE()

End Catch

End

exec dbo.InsertPatient 500,'Ali','2006-04-04',2

--Q14
Create Or Alter procedure dbo.UpdateSalary @ConsultantId int, @salary Decimal(18,0)
As
Begin Try
        Update Consultants
        set Salary = @salary
        where Id = @ConsultantId;
        print 'Salary Updated Successfully'

End Try
begin Catch
       print 'Error occurred'
       print ERROR_MESSAGE()
End Catch

--Q15
Create Or Alter Procedure dbo.DeletePatient @PatientId int
As
Begin Try
delete from Patients 
where id=@PatientId
End Try

Begin Catch
       print 'Error occurred'
       print ERROR_MESSAGE()
End Catch

--Q16
Create or Alter Procedure dbo.InsertNewPatient @PatientId int,@Name VarChar(100),@DOB Date,@WardId int
As
Insert into Patients
Values(@PatientId,@Name,@DOB,@WardId)

--Q17
Create Or Alter Procedure dbo.InsertNewConsultant @ConsultantId int,@Name VarChar(100),@Salary Decimal(18,0)
As
insert into Consultants
Values(@ConsultantId,@Name,@Salary)

--Q18
Create Or Alter Procedure dbo.AddNewMedicationAdministration @NurseId int,@DrugCode int,
                                            @PatientId int,@Dosage VarChar(50), @Date Date,@Time time,@Quantity int
As
insert into DrugAdministrations
values(@NurseId,@DrugCode,@PatientId,@Dosage,@Date,@Time,@Quantity)

--Q19
Create Or Alter Procedure dbo.UpdatePatientInfo @Id int, @Name VarChar(100)=Null,@DOB Date=Null,@WardId int=Null
As
Update Patients 
set Name=IsNull(@Name,Name),
DOB=ISNull(@DOB,DOB),
WardId=IsNull(@WardId,WardId)
where Id=@Id

--Q20
Create Or Alter Procedure dbo.ChangeSalary @Id int, @NewSalary Decimal(18,0)
As
Update Consultants
set Salary =@NewSalary
Where Id=@Id

--Q21
Create Or Alter Procedure dbo.UpdateNursesSalary @Number int,@Percentage int
As
Update Nurses
Set Salary+=Salary*(@Percentage/100)
where Number=@Number

--Q22
Create Or Alter Procedure dbo.DeletePatientById @Id int
As
Delete From Patients 
where Id=@Id

--Q23
Create Or Alter Procedure dbo.DeleteConsultantById @Id int
As
Delete From Consultants
where Id=@Id

--Q24
Create Or Alter Procedure dbo.DeleteDAById @DrugCode int
As
Delete From DrugAdministrations
where @DrugCode=@DrugCode

--Q28
Create Table PatientAudit
(
    AuditId int Identity(1,1) Primary Key,
    PatientId int,
    Operation VarChar(10),
    OperationDate Date
)

--Q29
Create Or Alter Trigger TRG_PatientInserted
on Patients
After Insert
As
insert into PatientAudit
select Id,'insert',GETDATE()
from inserted

--Q30
Create Table ConsultantSalaryAudity
(
 AuditId int Identity(1,1) Primary Key,
 Id int ,OldSalary Decimal(18,0),NewSalary Decimal(18,0),
 ActionType VarChar(100)
 )

 Create Or Alter Trigger TRG_UpdateSalary
 On Consultants
 After Update
 As
 insert into ConsultantSalaryAudity
 Select I.Id,D.Salary,I.Salary,'Update'
 from inserted I Join deleted D
 on I.Id=D.Id

 --Q31
 create Table WardAudit
 (
 WardID int Identity(1,1) Primary Key,
 PatientId int,oldWard int,NewWard int,ActionType Varchar(100)
 )

 Create Or Alter Trigger TRG_UpdateWardId
 on Patients
 After Update
 As
 insert into WardAudit
 Select I.Id,D.WardId,I.WardId,'update'
 from deleted D join inserted I
 on D.Id=I.Id

 --Q32
 Create Table DeletedPatients
 (
  AuditId int Identity(1,1) Primary Key,
  Id int,ActionType VarChar(100),ActionDate Date
  )

Create Or Alter Trigger TRG_DeletePatients
on Patients
After Delete
As
insert into DeletedPatients
select Id,'Deleted',GETDATE()
from deleted

--Q33
 Create Table DeletedConsultant
 (
  AuditId int Identity(1,1) Primary Key,
  Id int,ActionType VarChar(100),ActionDate Date
  )

Create Or Alter Trigger TRG_DeleteConsultant
on Patients
After Delete
As
insert into DeletedConsultant
select Id,'Deleted',GETDATE()
from deleted

--Q34
 Create Or Alter Trigger TRG_UpdateSalary
 On Consultants
 After Update
 As
 Select I.Id,D.Salary OldSalary,I.Salary NewSalary
 from inserted I Join deleted D
 on I.Id=D.Id

 --Q35
 Create Or Alter Trigger TRG_UpdateWardId1
 on Patients
 After Update
 As
  Select
        I.Id AS PatientId,
        D.WardId AS OldWard,
        I.WardId AS NewWard
 from deleted D join inserted I
 on D.Id=I.Id

 --Q36
 Create Or Alter Trigger TRG_PatientInserted
on Patients
After Insert
As
insert into PatientAudit
select Id,'insert',GETDATE()
from inserted

Insert into Patients
Values(600,'Ahmed','2000-01-01',2),
      (601,'Khaled','2002-01-01',1),
      (602,'Safeia','2006-06-03',2)

--Q37
Create Or Alter Trigger TRG_InsteadOfInsert
on Patients
Instead Of insert
As
If Exists( select 1
from inserted 
where WardId =Null)
Begin
print'Inserted not allowed When WardId is Null'
return;
End
insert into PatientAudit
select Id,'insert',GETDATE()
from inserted

--Q38
Create Or Alter Trigger TRG_InsteadOfInsert
on Patients
Instead Of insert
As
If Exists( select 1
from inserted 
where DOB>'2026-11-01')
Begin
print'Inserted not allowed'
return;
End
insert into PatientAudit
select Id,'insert',GETDATE()
from inserted

--Q39
Create Or Alter Trigger TRG_InsteadOfUpdate
on Consultants
Instead Of Update
As
If Exists( select 1
from inserted I join deleted D
on I.Id=D.Id
where I.Salary<D.Salary  )
Begin
print'Salary Can not e reduced'
return;
End
insert into ConsultantSalaryAudity
select I.Id,D.Salary,I.Salary,'Update'
from inserted I join deleted D
on I.Id=D.Id

--Q40
Create Or Alter Trigger TRG_InsteadOfUpdateWardId
on Patients
Instead Of Update
As
If Exists( select 1
from inserted I join deleted D
on I.Id=D.Id
Where I.Id !=I.Id )
Begin
print'Can not Be Updated'
return;
End
insert into WardAudit
 Select I.Id,D.WardId,I.WardId,'update'
 from deleted D join inserted I
 on D.Id=I.Id

 --Q41
 Create Or Alter Trigger TRG_InsteadOfDeletePatients
 on Patients
 Instead of Delete
 As
 print'Can not be deleted'

 --Q42*

Create Or Alter Trigger TRG_insteadOfDeletePatient
on Patients
Instead Of Delete
As
insert into DeletedPatients2
select Id,Name,DOB,WardId
from deleted

Delete From Patients
Where Id in(Select Id From deleted)

--Q43
Create or Alter Procedure dbo.InsertNewPatient @PatientId int,@Name VarChar(100),@DOB Date,@WardId int
As
Insert into Patients
Values(@PatientId,@Name,@DOB,@WardId)

Create Or Alter Trigger TRG_PatientInserted
on Patients
After Insert
As
insert into PatientAudit
select Id,'insert',GETDATE()
from inserted

exec dbo.InsertNewPatient 604,'Samy','2009-03-09',2

--Q44
Create Or Alter procedure dbo.UpdateSalary @ConsultantId int, @salary Decimal(18,0)
As
Begin Try
        Update Consultants
        set Salary = @salary
        where Id = @ConsultantId;
        print 'Salary Updated Successfully'
End Try
begin Catch
       print 'Error occurred'
       print ERROR_MESSAGE()
End Catch


Create Or Alter Trigger TRG_UpdateSalary
 On Consultants
 After Update
 As
 Select I.Id,D.Salary OldSalary,I.Salary NewSalary
 from inserted I Join deleted D
 on I.Id=D.Id

 --Q45
Create Or Alter Procedure dbo.DeletePatientById @Id int
As
Delete From Patients 
where Id=@Id


Create Or Alter Trigger TRG_DeletePatients
on Patients
After Delete
As
insert into DeletedPatients
select Id,'Deleted',GETDATE()
from deleted

--Q47
Create Or Alter Trigger TRG_PatientInserted
on Patients
After Insert
As
insert into PatientAudit
select Id,'insert',GETDATE()
from inserted


Create Or Alter Trigger TRG_UpdateWardId
 on Patients
 After Update
 As
 insert into WardAudit
 Select I.Id,D.WardId,I.WardId,'update'
 from deleted D join inserted I
 on D.Id=I.Id


Create Or Alter Trigger TRG_DeletePatients
on Patients
After Delete
As
insert into DeletedPatients
select Id,'Deleted',GETDATE()
from deleted

--Q49
Create Or Alter Procedure GetPatientTotalMedication
    @PatientId Int,
    @TotalQuantity Int Output
As
Begin
    Begin Try
        Select @TotalQuantity = Isnull(Sum(Quantity), 0)
        From DrugAdministrations
        Where PatientId = @PatientId;
    End Try

    Begin Catch
        Print Error_Message()
    End Catch
End

--Q50
Create Or Alter Procedure GetPatientSummary
    @PatientId Int
As
Begin
    Begin Try
        Select P.Id,P.Name,P.DOB,W.Name,
            Count(D.PatientId) As MedicationAdministrations,
            Sum(D.Quantity) As TotalMedicationQuantity
        From Patients P Join Wards W
            On P.WardId = W.Id
        Left Join DrugAdministrations D
            On P.Id = D.PatientId
        Where P.Id = @PatientId
        Group By P.Id,P.Name,P.DOB,W.Name;
    End Try

    Begin Catch
        Print Error_Message()
    End Catch
End