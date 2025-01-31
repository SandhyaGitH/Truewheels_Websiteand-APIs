USE [TrueWheels]
GO
/****** Object:  StoredProcedure [dbo].[Get_MenuList]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[Get_MenuList]
	--parameters
	 @user_id  varchar(100),
     @Error varchar(Max) Output
     
AS
BEGIN
--begin transaction t1
   
	set @Error=''
    Begin Try
	if  exists(select * from UserMenuMapping where [User_id]=@user_id)
	begin
    	
		select MenuDetail.Menu_id,MenuDetail.Menu_description,MenuDetail.Menu_Url, UserMenuMapping.[User_id] from MenuDetail inner join UserMenuMapping
		on MenuDetail.Menu_id=  UserMenuMapping.Menu_id and [User_id] =@user_id 

		--set @VisitorNumber = @@IDENTITY

	 	Return
    end
	else
	begin
	   set @Error = 'No Menu Bind for this user'
	-- set @UserId=0
	end
    	
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END


GO
/****** Object:  StoredProcedure [dbo].[Insert_BookedParking]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Insert_BookedParking]
	--parameters
	
     @User_id int, --mac/ip add/ user id
	 @Parking_Id nvarchar(100), 
	 @InDateTime datetime,
	 @outdatetime datetime,
	 @CheckedInDateTime datetime,
	 @CheckedOutDateTime datetime,
     @Error varchar(Max) Output,
     @Booked_Id varchar(Max) Output
AS
BEGIN
--begin transaction t1
   
	set @Error=''
    Begin Try
	--if not exists(select user_Id from UserLogin where Phone_No1=@Phone_No1)
--	begin
    	Insert into    BookedParking
    	(
    		 [User_id] ,Parking_Id,InDateTime,outdatetime 
    	)
    	values
    	(
    	      @User_id ,@Parking_Id,@InDateTime,@outdatetime 
    	)
		set @Booked_Id = @@IDENTITY

		update AvailableParkingArea set No_Of_Space_Avaiable= No_Of_Space_Avaiable-1 where Parking_Id=@Parking_Id

	 	Return
 --   end
	--else
	--begin
	--set @Error = 'Phone_No alreay registered'
	-- set @UserId=0
	--end
    	
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END

GO
/****** Object:  StoredProcedure [dbo].[Insert_RegParkingArea]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Insert_RegParkingArea]
	@owner_id int ,
    @Space_type varchar(10), --(master table),
    @Property_type varchar(10),--(master table),
	@No_of_space int, 
	@VechileType  varchar(10), --(master table) Enum hashback/sedan/SUV
	@PropertyVerifiedStatus char, --(master table)
	@FacilityGroupId varchar(5),
	@PropertyAddress varchar(200),
	@PropertyPinCode int,
	@PropertyZone varchar(100),
	@PropertyLandMark varchar(100),
	 @OwnerComments varchar(300),
	 @lattitude DECIMAL(12,9) ,--DECIMAL(12,9)
	@longitude DECIMAL(12,9),
	 @Error varchar(Max) Output,
     @Parking_id varchar(Max) Output
	--@GeoLoc geography , --primary key,
	 --Status char,
	 --ParkingRating int
	 
    
    
AS
BEGIN
--begin transaction t1
   
	set @Error=''
    Begin Try
	declare @Space_Code varchar(15)
	declare @Vehicle_Code varchar(15)
	declare @Property_Code varchar(15)
	set @Space_Code = ( select sys_code from System_Code where Sys_description =@Space_type)
	set @Property_Code = ( select sys_code from System_Code where Sys_description =@Property_type)
	set @Vehicle_Code = ( select sys_code from System_Code where Sys_description =@VechileType)
	
	--if exists(select 1 from UserDetails where [User_id]=@owner_id and OwnerVerificationStatus ='Y' )
	if exists(select 1 from UserDetails where [User_id]=@owner_id  )
	   begin
	   if not exists(select parking_id from ParkingArea where owner_id=@owner_id and lattitude=@lattitude and longitude=@longitude)
	begin
    	Insert into    ParkingArea
    	(
    		 owner_id , Space_type ,Property_type ,No_of_space ,VechileType ,PropertyVerifiedStatus ,FacilityGroupId,
	         PropertyAddress ,PropertyPinCode,PropertyZone ,PropertyLandMark ,OwnerComments ,lattitude ,longitude,GeoLoc
    	)
    	values
    	(
    	      @owner_id ,@Space_Code ,@Property_Code ,@No_of_space ,@Vehicle_Code ,@PropertyVerifiedStatus ,@FacilityGroupId,
	          @PropertyAddress ,@PropertyPinCode,@PropertyZone ,@PropertyLandMark ,@OwnerComments ,@lattitude ,@longitude, geography::Point(@lattitude, @longitude,4326)
    	)
		set @Parking_id=SCOPE_IDENTITY()

		IF @Parking_id!='' OR @Parking_id!=0 BEGIN
		insert into AvailableParkingArea
		(
		Parking_id,parking_address,lattitude,longitude,GeoLoc,DateTimeTo,DateTimeFrom,No_Of_Space_Avaiable,BasicCharge,dt_created,dt_updated,ParkingClass
		)
		 values(
		 @Parking_id,@PropertyAddress,@lattitude,@longitude,  geography::Point(@lattitude, @longitude,4326),
		 GETDATE(),GETDATE()+100,@No_of_space,'50',GETDATE(),GETDATE(),'PC_A')
		 --select * from system_code
  END

  
		--update AvailableParkingArea set No_Of_Space_Avaiable= No_Of_Space_Avaiable-1 where Parking_Id=@Parking_Id
	
	 	Return
    end
	else
	begin
	set @Error = 'Already Registered'
	 set @Parking_id=0
	end
       end
	else
		begin
		set @Error = 'Register the owner first' 
		end
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END

GO
/****** Object:  StoredProcedure [dbo].[Insert_UserLogin]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Insert_UserLogin]
	--parameters
--@User_Name nvarchar(100),
@First_Name nvarchar(50),
@Last_Name nvarchar(50),
@Password nvarchar(500) ,
@Phone_No1 nvarchar(50) ,
@Email_Id nvarchar(50),
@SignUp_Mode_ID nvarchar(2),
@Other_FB_GG_ID bigint =null,
@Error varchar(Max) Output,
@UserId varchar(Max) Output
AS
BEGIN
--begin transaction t1
    declare @User_Name nvarchar(100)
	set @User_Name =ltrim(rtrim(isnull(@First_Name,''))) +' ' + ltrim(rtrim(isnull(@Last_Name,''))) 
	set @Error=''
    Begin Try
	if @SignUp_Mode_ID='FB'
			begin
			if not exists(select [user_Id] from UserLogin where FB_ID=@Other_FB_GG_ID)
			begin
    			Insert into UserLogin
    			(
    				[User_Name],[Password], Email_Id, Dt_Created,Dt_Updated,Status,FB_ID --column list
    			)
    			values
    			(
    				   @User_Name,@Password,@Email_Id, GETDATE(),GETDATE(),'A',@Other_FB_GG_ID
    			)
				set @UserId = SCOPE_IDENTITY()

				insert into UserDetails
				(
				[User_id],First_Name,Last_Name,Agreement_Accepted,Phone_No1,Email_id,Dt_Created,Dt_Updated,Status,SignUp_Mode_ID
				)
				values
    			(
    				  @UserId, @First_Name,@Last_Name,'Y','NA',@Email_id, GETDATE(),GETDATE(),'A',@SignUp_Mode_ID
    			)

				 select * from UserLogin where [user_id] = @UserId
    			Return
			end
			else
			begin
			--set @Error = 'Already registered'
			select * from UserLogin where FB_ID=@Other_FB_GG_ID
			--select @UserId= user_Id from UserLogin where FB_ID=@Other_FB_GG_ID
			
			end
			end
	else
			begin
			if not exists(select [user_Id] from UserLogin where Phone_No1=@Phone_No1 or Email_Id=@Email_Id)
			begin
    			Insert into UserLogin
    			(
    				[User_Name],[Password],Phone_No1, Email_Id, Dt_Created,Dt_Updated,Status --column list
    			)
    			values
    			(
    				   @User_Name,@Password,@Phone_No1,@Email_Id, GETDATE(),GETDATE(),'A'
    			)
				--set @UserId = IDENT_CURRENT( 'UserLogin' )
				set @UserId = SCOPE_IDENTITY()

				insert into UserDetails
				(
				[User_id],First_Name,Last_Name,Agreement_Accepted,Phone_No1,Email_id,Dt_Created,Dt_Updated,Status,SignUp_Mode_ID
				)
				values
    			(
    				 @UserId, @First_Name,@Last_Name,'Y',@Phone_No1,@Email_id, GETDATE(),GETDATE(),'A',@SignUp_Mode_ID
    			)

				select * from UserLogin where [user_id] = @UserId
    			Return
			end
			else
			begin
			set @Error = 'Phone_No already registered'
			 set @UserId='0'
			end
			end 
		
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_VisitorHistory]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Insert_VisitorHistory]
	--parameters
	 @Visitor_id  varchar(100), --mac/ip add/ user id
	 @Visitor_email_id nvarchar(100), 
	 @Source_Address nvarchar(300),	 
	 @destination_address nvarchar(300),	 
	 @DatetimeStamp nvarchar(19),
     @Error varchar(Max) Output,
     @VisitorNumber varchar(Max) Output
AS
BEGIN
--begin transaction t1
   
	set @Error=''
    Begin Try
	--if not exists(select user_Id from UserLogin where Phone_No1=@Phone_No1)
--	begin
    	Insert into    VisitorHstory
    	(
    		 Visitor_id ,Visitor_email_id ,Source_Address ,destination_address,DatetimeStamp 
    	)
    	values
    	(
    	       @Visitor_id,@Visitor_email_id,@Source_Address,@destination_address, GETDATE()
    	)
		set @VisitorNumber = @@IDENTITY

	 	Return
 --   end
	--else
	--begin
	--set @Error = 'Phone_No alreay registered'
	-- set @UserId=0
	--end
    	
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END

GO
/****** Object:  StoredProcedure [dbo].[IsMobileVerified]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[IsMobileVerified]
	--parameters
@Phone_No1 varchar(50) ,
@UserId int ,

--@Email_Id varchar(50),
@Error varchar(Max) Output,
@IsVerified char Output
AS
BEGIN
--begin transaction t1
    
	set @Error=''
    Begin Try
	if(@UserId  <>'')    
	 
	if exists(select [USER_ID] from UserLogin where  [User_Id] =@UserId)
	begin
		if  exists( select  [user_Id]  from UserLogin where [User_Id]=@UserId  and IsMobileVarified='Y'  )
	begin    	
		  set @Error=''
		  set @IsVerified ='Y'
		Return
    end
	else
	begin
	set @Error = ''
	set @IsVerified ='N'
	end
    end
	else
	begin
	   set @Error='Invalid User ID'
		  set @IsVerified =''
		Return
	end
	
	else if(@Phone_No1  <>'') 
	
	  if exists(select [USER_ID] from UserLogin where  Phone_No1= @Phone_No1)
	begin
		if  exists( select  [user_Id]  from UserLogin where Phone_No1=@Phone_No1  and IsMobileVarified='Y'  )
	begin    	
		  set @Error=''
		  set @IsVerified ='Y'
		Return
    end
	else
	begin
	set @Error = ''
	set @IsVerified ='N'
	end
    end
	else
	begin
	   set @Error='Invalid phone number'
		  set @IsVerified =''
		Return
	end
	   
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END



GO
/****** Object:  StoredProcedure [dbo].[SP_GetAllLocationName]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[SP_GetAllLocationName]
	--parameters
@LocationTerm varchar(100) = NULL,
@Error varchar(Max) Output

AS
BEGIN

   set @Error=''
    Begin Try 
	    select PropertyAddress from ParkingArea 
    	return
    End Try
    Begin Catch
    	set @Error = Error_Message()
           -- rollback transaction t1
            return
			
    End Catch
Return;
END


GO
/****** Object:  StoredProcedure [dbo].[SP_GetAvaiolableParking]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery1.sql|7|0|C:\Users\Sanhya\AppData\Local\Temp\~vs9A4C.sql


CREATE PROCEDURE [dbo].[SP_GetAvaiolableParking]
	--parameters
@Latitude varchar(50) = NULL,
@Longitude varchar(50) = NULL,
@distance int = 10,
@FromDateTime varchar(19) ,
@ToDateTime varchar(19) ,
@ParkingClass varchar(19)  ,
@OrderBy varchar(40),
@Error varchar(Max) Output

AS
BEGIN
--begin transaction t1
    declare @User_Name nvarchar(100)
	DECLARE @SQLQuery AS NVARCHAR(500)
	DECLARE @strParkingClass AS NVARCHAR(100)
	set @Error=''
	DECLARE @s AS NVARCHAR(500)
	
    Begin Try
	
	--if(@ParkingClass='PC_A') 
 --   set @strParkingClass = ''''+ 'PC_G' + '''' +','+''''+'PC_S'+''''+','+''''+'PC_D' + ''''+','+''''+'PC_P' +''''
	--else
	 set @strParkingClass= ''''+ @ParkingClass + ''''

if @Latitude = '0' or @Longitude = '0' 
   if( @FromDateTime = '0')
	 SET @SQLQuery = ' select a.*,p.*,0 as distance from AvailableParkingArea a inner join  ParkingArea p on a.Parking_id=p.parking_id  where No_Of_Space_Avaiable >0 and DateTimeFrom <= getdate()  and ParkingClass in ('+ @strParkingClass + ') order by ' + @OrderBy
	else
	SET @SQLQuery = 'select a.*,p.*, 0 as distance from AvailableParkingArea a inner join  ParkingArea p on a.Parking_id=p.parking_id where No_Of_Space_Avaiable >0 and DateTimeFrom <='+''''+ @FromDateTime+'''' + ' and ParkingClass in ( '+ @strParkingClass + ') order by ' + @OrderBy
else
   if( @FromDateTime = '0')
	  SET @SQLQuery = ' select a.*,p.*, cast ((geography::Point('+cast(@Latitude as varchar)+','+cast(@Longitude as varchar)+',4326)).STDistance(a.GeoLoc)/1000 as int) as distance from AvailableParkingArea a inner join  ParkingArea p on a.Parking_id=p.parking_id  where 
     (geography::Point('+cast(@Latitude as varchar)+','+cast(@Longitude as varchar)+',4326)).STDistance(a.GeoLoc)/1000<'+cast(@distance as varchar) + ' and No_Of_Space_Avaiable >0 and DateTimeFrom<= GetDate()  and ParkingClass in('+ @strParkingClass + ') order by ' + @OrderBy --and DateTimeTo>=@ToDateTime
  else
	SET @SQLQuery = ' select a.*,p.*, cast ((geography::Point('+cast(@Latitude as varchar)+','+cast(@Longitude as varchar)+',4326)).STDistance(a.GeoLoc)/1000 as int) as distance from AvailableParkingArea a inner join  ParkingArea p on a.Parking_id=p.parking_id  where 
       (geography::Point('+cast(@Latitude as varchar)+','+cast(@Longitude as varchar)+',4326)).STDistance(a.GeoLoc)/1000<'+cast(@distance as varchar) +' and No_Of_Space_Avaiable >0 and DateTimeFrom<= '+ ''''+@FromDateTime+'''' + '  and ParkingClass in ('+ @strParkingClass + ') order by ' + @OrderBy --and DateTimeTo>=@ToDateTime
 
  EXECUTE(@SQLQuery)

    End Try
    Begin Catch
    	set @Error = Error_Message()
           -- rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END


GO
/****** Object:  StoredProcedure [dbo].[SP_LoginUser]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_LoginUser]
	--parameters
@User_ID nvarchar(100),
@Password nvarchar(500) ,
@Phone_No1 nvarchar(50) ,
@Email_Id nvarchar(50),
--@SignUp_Mode_ID char,
@Error varchar(Max) Output,
@UserId varchar(Max) Output
AS
BEGIN
--begin transaction t1
    declare @User_Name nvarchar(100)
	
	set @Error=''
    Begin Try
	if  exists( select  [user_Id]  from UserLogin where (Phone_No1=@Phone_No1 and  [password]=@Password) or ([user_id]=@User_ID and  [password]=@Password) or (Email_Id=@Email_Id and  [password]=@Password))
	begin    	
		  --select @UserId = [user_Id] from UserLogin where (Phone_No1=@Phone_No1 and  [password]=@Password) or ([user_id]=@User_ID and  [password]=@Password) or (Email_Id=@Email_Id and  [password]=@Password) 		
		  select * from UserLogin where (Phone_No1=@Phone_No1 and  [password]=@Password) or ([user_id]=@User_ID and  [password]=@Password) or (Email_Id=@Email_Id and  [password]=@Password) 		
    	Return
    end
	else
	begin
	set @Error = 'Invalid User_id or password'
	 set @UserId=0
	end
    	
    End Try
    Begin Catch
    	set @Error = Error_Message()
           -- rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END

GO
/****** Object:  StoredProcedure [dbo].[Upate_Password]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Upate_Password]
	--parameters
@Phone_No1 varchar(50) ,
@Password varchar(500) ,

--@Email_Id varchar(50),
@Error varchar(Max) Output,
@UserId varchar(Max) Output
AS
BEGIN
--begin transaction t1
    
	set @Error=''
    Begin Try
		if  exists( select  [user_Id]  from UserLogin where Phone_No1=@Phone_No1   )
	begin    	
		  select @UserId = [user_Id]  from UserLogin where Phone_No1=@Phone_No1   	
    	  update UserLogin set  [password]=@Password where  [user_Id]  = @UserId
		Return
    end
	else
	begin
	set @Error = 'Invalid Phone Number'
	 set @UserId=0
	end
    	
    End Try
    Begin Catch
    	set @Error = Error_Message()
          --  rollback transaction t1
            return
			
    End Catch
--commit transaction t1
Return;
END

GO
/****** Object:  Table [dbo].[AvailableParkingArea]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AvailableParkingArea](
	[Parking_id] [int] NOT NULL,
	[parking_address] [nvarchar](500) NOT NULL,
	[street] [nvarchar](200) NULL,
	[city] [nvarchar](50) NULL,
	[state] [nvarchar](50) NULL,
	[lattitude] [decimal](12, 9) NOT NULL,
	[longitude] [decimal](12, 9) NOT NULL,
	[GeoLoc] [geography] NULL,
	[DateTimeTo] [datetime] NULL,
	[DateTimeFrom] [datetime] NULL,
	[No_Of_Space_Avaiable] [int] NULL,
	[Detail_ID] [int] NULL,
	[BasicCharge] [int] NOT NULL,
	[dt_created] [datetime] NULL,
	[dt_updated] [datetime] NULL,
	[ParkingClass] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BookedParking]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookedParking](
	[Booked_Id] [int] IDENTITY(1,1) NOT NULL,
	[User_id] [int] NULL,
	[Parking_Id] [nvarchar](100) NULL,
	[InDateTime] [datetime] NULL,
	[outdatetime] [datetime] NULL,
	[CheckedInDateTime] [datetime] NULL,
	[CheckedOutDateTime] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MenuDetail]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MenuDetail](
	[Menu_id] [int] NOT NULL,
	[Menu_description] [nvarchar](100) NOT NULL,
	[Menu_Url] [nvarchar](300) NOT NULL,
	[Parent_Menu_id] [int] NOT NULL,
	[AdminMenu] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ParkingArea]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ParkingArea](
	[parking_id] [int] IDENTITY(1,1) NOT NULL,
	[owner_id] [int] NULL,
	[Space_type] [varchar](15) NULL,
	[Property_type] [varchar](15) NULL,
	[No_of_space] [int] NULL,
	[VechileType] [varchar](15) NULL,
	[PropertyVerifiedStatus] [char](1) NULL,
	[FacilityGroupId] [varchar](5) NULL,
	[PropertyAddress] [varchar](300) NULL,
	[PropertyPinCode] [int] NULL,
	[PropertyZone] [varchar](100) NULL,
	[PropertyLandMark] [nvarchar](100) NULL,
	[OwnerComments] [nvarchar](300) NULL,
	[lattitude] [decimal](12, 9) NOT NULL,
	[longitude] [decimal](12, 9) NOT NULL,
	[GeoLoc] [geography] NULL,
	[Status] [char](1) NULL,
	[ParkingRating] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[System_Code]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System_Code](
	[Seq_no] [int] IDENTITY(1,1) NOT NULL,
	[MasterType] [nvarchar](100) NOT NULL,
	[Sys_Code] [nvarchar](50) NOT NULL,
	[Sys_description] [nvarchar](150) NULL,
 CONSTRAINT [PK_MTSCode] PRIMARY KEY CLUSTERED 
(
	[MasterType] ASC,
	[Sys_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[System_Code1]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[System_Code1](
	[Seq_no] [int] IDENTITY(1,1) NOT NULL,
	[MasterType] [nvarchar](100) NOT NULL,
	[Sys_Code] [nvarchar](50) NOT NULL,
	[Sys_description] [nvarchar](150) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserDetails]    Script Date: 9/23/2016 12:19:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserDetails](
	[User_id] [int] NULL,
	[First_Name] [nvarchar](50) NOT NULL,
	[Last_Name] [nvarchar](50) NULL,
	[User_Type] [char](1) NULL,
	[Agreement_Accepted] [char](1) NOT NULL,
	[Owner_Address] [nvarchar](500) NULL,
	[Phone_No1] [nvarchar](50) NOT NULL,
	[Phone_No2] [nvarchar](50) NULL,
	[OwnerVerificationStatus] [char](1) NULL,
	[Email_id] [nvarchar](50) NOT NULL,
	[Alternate_Email_Id] [nvarchar](50) NULL,
	[Dt_Created] [datetime] NULL,
	[Dt_Updated] [datetime] NULL,
	[Status] [char](1) NULL,
	[SignUp_Mode_ID] [nvarchar](2) NULL,
	[Driving_License] [nvarchar](50) NULL,
	[PAN] [nvarchar](50) NULL,
	[Pin_code] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserLogin]    Script Date: 9/23/2016 12:19:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserLogin](
	[User_Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Name] [nvarchar](100) NULL,
	[Password] [nvarchar](500) NULL,
	[Phone_No1] [nvarchar](50) NULL,
	[Email_Id] [nvarchar](50) NULL,
	[Last_Login] [datetime] NULL,
	[Dt_Created] [datetime] NULL,
	[Dt_Updated] [datetime] NULL,
	[Status] [char](1) NULL,
	[FB_ID] [bigint] NULL,
	[IsMobileVarified] [char](1) NULL,
 CONSTRAINT [PrimKey_user_id_tblUserLogin] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserMenuMapping]    Script Date: 9/23/2016 12:19:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMenuMapping](
	[User_id] [int] NULL,
	[Menu_id] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VehicleDetail]    Script Date: 9/23/2016 12:19:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VehicleDetail](
	[User_id] [int] NOT NULL,
	[Vehicle_num] [nvarchar](50) NOT NULL,
	[Vehicle_type] [char](1) NOT NULL,
	[Model] [nvarchar](50) NULL,
	[Specification] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VisitorHstory]    Script Date: 9/23/2016 12:19:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VisitorHstory](
	[VisitorNumber] [int] IDENTITY(1,1) NOT NULL,
	[Visitor_id] [varchar](100) NULL,
	[Visitor_email_id] [nvarchar](100) NULL,
	[Source_Address] [nvarchar](300) NULL,
	[destination_address] [nvarchar](300) NULL,
	[DatetimeStamp] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (12, N'MG Road, gurgaon', NULL, NULL, NULL, CAST(28.479518000 AS Decimal(12, 9)), CAST(77.080616000 AS Decimal(12, 9)), 0xE6100000010CE4D70FB1C17A3C4033E202D028455340, CAST(0x0000A65C00C5093E AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 250, NULL, 50, CAST(0x0000A65C00C5093E AS DateTime), CAST(0x0000A65C00C5093E AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (13, N'Connaught Place, New Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.631451200 AS Decimal(12, 9)), CAST(77.216667200 AS Decimal(12, 9)), 0xE6100000010C1C052DC9A6A13C406B871AE0DD4D5340, CAST(0x0000A65C00C50978 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 87, NULL, 50, CAST(0x0000A65C00C50978 AS DateTime), CAST(0x0000A65C00C50978 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (14, N'Sector 18, Noida, Uttar Pradesh, India', NULL, NULL, NULL, CAST(28.570317000 AS Decimal(12, 9)), CAST(77.321819600 AS Decimal(12, 9)), 0xE6100000010C535A7F4B00923C408E4D3CB198545340, CAST(0x0000A65F018AE2D9 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 560, NULL, 50, CAST(0x0000A65F018AE2D9 AS DateTime), CAST(0x0000A65F018AE2D9 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (15, N'Ghaziabad New Bus Stand, Ghaziabad, Uttar Pradesh, India', NULL, NULL, NULL, CAST(28.670269600 AS Decimal(12, 9)), CAST(77.415313600 AS Decimal(12, 9)), 0xE6100000010CC580DBC996AB3C4061657E7F945A5340, CAST(0x0000A65F018AE840 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 230, NULL, 50, CAST(0x0000A65F018AE840 AS DateTime), CAST(0x0000A65F018AE840 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (16, N'Manesar, Gurgaon, Haryana, India', NULL, NULL, NULL, CAST(28.354285200 AS Decimal(12, 9)), CAST(76.939819500 AS Decimal(12, 9)), 0xE6100000010CF274536FB25A3C402829B000263C5340, CAST(0x0000A65F018AE849 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 670, NULL, 50, CAST(0x0000A65F018AE849 AS DateTime), CAST(0x0000A65F018AE849 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (17, N'Nehru Place, South Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.550331400 AS Decimal(12, 9)), CAST(77.250189300 AS Decimal(12, 9)), 0xE6100000010C3FF6C484E28C3C40C953FB1903505340, CAST(0x0000A65F018AE853 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 10, NULL, 50, CAST(0x0000A65F018AE853 AS DateTime), CAST(0x0000A65F018AE853 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (18, N'Faridabad, Faridabad, Haryana, India', NULL, NULL, NULL, CAST(28.408912300 AS Decimal(12, 9)), CAST(77.317789400 AS Decimal(12, 9)), 0xE6100000010CA16EFB79AE683C40FD005AA956545340, CAST(0x0000A65F018AE862 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 1, NULL, 50, CAST(0x0000A65F018AE862 AS DateTime), CAST(0x0000A65F018AE862 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (19, N'Rohini Sector 8 Road, Rohini, New Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.701880400 AS Decimal(12, 9)), CAST(77.122716400 AS Decimal(12, 9)), 0xE6100000010C12B4136FAEB33C40B42BE395DA475340, CAST(0x0000A65F018AE879 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 65, NULL, 50, CAST(0x0000A65F018AE879 AS DateTime), CAST(0x0000A65F018AE879 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (20, N'Batra Bus Stand, New Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.711349400 AS Decimal(12, 9)), CAST(77.215053600 AS Decimal(12, 9)), 0xE6100000010C7B0789FE1AB63C40C6B82C70C34D5340, CAST(0x0000A65F018AE884 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 23, NULL, 50, CAST(0x0000A65F018AE884 AS DateTime), CAST(0x0000A65F018AE884 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (21, N'MG Road, gurgaon', NULL, NULL, NULL, CAST(28.479518000 AS Decimal(12, 9)), CAST(77.080616000 AS Decimal(12, 9)), 0xE6100000010CE4D70FB1C17A3C4033E202D028455340, CAST(0x0000A665017F6277 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 250, NULL, 50, CAST(0x0000A665017F6277 AS DateTime), CAST(0x0000A665017F6277 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (22, N'MG Road, gurgaon', NULL, NULL, NULL, CAST(28.479518000 AS Decimal(12, 9)), CAST(77.080616000 AS Decimal(12, 9)), 0xE6100000010CE4D70FB1C17A3C4033E202D028455340, CAST(0x0000A67200AF2DF9 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 250, NULL, 50, CAST(0x0000A67200AF2DF9 AS DateTime), CAST(0x0000A67200AF2DF9 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (23, N'Connaught Place, New Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.631451200 AS Decimal(12, 9)), CAST(77.216667200 AS Decimal(12, 9)), 0xE6100000010C1C052DC9A6A13C406B871AE0DD4D5340, CAST(0x0000A67200AF2F20 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 87, NULL, 50, CAST(0x0000A67200AF2F20 AS DateTime), CAST(0x0000A67200AF2F20 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (24, N'Sector 18, Noida, Uttar Pradesh, India', NULL, NULL, NULL, CAST(28.570317000 AS Decimal(12, 9)), CAST(77.321819600 AS Decimal(12, 9)), 0xE6100000010C535A7F4B00923C408E4D3CB198545340, CAST(0x0000A67200AF3069 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 560, NULL, 50, CAST(0x0000A67200AF3069 AS DateTime), CAST(0x0000A67200AF3069 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (25, N'Ghaziabad New Bus Stand, Ghaziabad, Uttar Pradesh, India', NULL, NULL, NULL, CAST(28.670269600 AS Decimal(12, 9)), CAST(77.415313600 AS Decimal(12, 9)), 0xE6100000010CC580DBC996AB3C4061657E7F945A5340, CAST(0x0000A67200AF3168 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 230, NULL, 50, CAST(0x0000A67200AF3168 AS DateTime), CAST(0x0000A67200AF3168 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (26, N'Manesar, Gurgaon, Haryana, India', NULL, NULL, NULL, CAST(28.354285200 AS Decimal(12, 9)), CAST(76.939819500 AS Decimal(12, 9)), 0xE6100000010CF274536FB25A3C402829B000263C5340, CAST(0x0000A67200AF323C AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 670, NULL, 50, CAST(0x0000A67200AF323C AS DateTime), CAST(0x0000A67200AF323C AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (27, N'Nehru Place, South Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.550331400 AS Decimal(12, 9)), CAST(77.250189300 AS Decimal(12, 9)), 0xE6100000010C3FF6C484E28C3C40C953FB1903505340, CAST(0x0000A67200AF32FB AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 10, NULL, 50, CAST(0x0000A67200AF32FB AS DateTime), CAST(0x0000A67200AF32FB AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (28, N'Faridabad, Faridabad, Haryana, India', NULL, NULL, NULL, CAST(28.408912300 AS Decimal(12, 9)), CAST(77.317789400 AS Decimal(12, 9)), 0xE6100000010CA16EFB79AE683C40FD005AA956545340, CAST(0x0000A67200AF33CC AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 1, NULL, 50, CAST(0x0000A67200AF33CC AS DateTime), CAST(0x0000A67200AF33CC AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (29, N'Rohini Sector 8 Road, Rohini, New Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.701880400 AS Decimal(12, 9)), CAST(77.122716400 AS Decimal(12, 9)), 0xE6100000010C12B4136FAEB33C40B42BE395DA475340, CAST(0x0000A67200AF3489 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 65, NULL, 50, CAST(0x0000A67200AF3489 AS DateTime), CAST(0x0000A67200AF3489 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (30, N'Batra Bus Stand, New Delhi, Delhi, India', NULL, NULL, NULL, CAST(28.711349400 AS Decimal(12, 9)), CAST(77.215053600 AS Decimal(12, 9)), 0xE6100000010C7B0789FE1AB63C40C6B82C70C34D5340, CAST(0x0000A67200AF3611 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 23, NULL, 50, CAST(0x0000A67200AF3611 AS DateTime), CAST(0x0000A67200AF3611 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (31, N'sahara mall gurgaon', NULL, NULL, NULL, CAST(28.479619000 AS Decimal(12, 9)), CAST(77.086628000 AS Decimal(12, 9)), 0xE6100000010C4C8A8F4FC87A3C40BFBA2A508B455340, CAST(0x0000A67200AF36E4 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 23, NULL, 50, CAST(0x0000A67200AF36E4 AS DateTime), CAST(0x0000A67200AF36E4 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (32, N'Chakkarpur', NULL, NULL, NULL, CAST(28.475479000 AS Decimal(12, 9)), CAST(77.086761000 AS Decimal(12, 9)), 0xE6100000010C4EEFE2FDB8793C405E64027E8D455340, CAST(0x0000A67200AF37AC AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 1, NULL, 50, CAST(0x0000A67200AF37AC AS DateTime), CAST(0x0000A67200AF37AC AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (33, N'sarawati Vihar, Guragon', NULL, NULL, NULL, CAST(28.477576000 AS Decimal(12, 9)), CAST(77.082038000 AS Decimal(12, 9)), 0xE6100000010CC05AB56B427A3C40DFC14F1C40455340, CAST(0x0000A67200AF386D AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 83, NULL, 50, CAST(0x0000A67200AF386D AS DateTime), CAST(0x0000A67200AF386D AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (34, N'Maruti Vihar, Gurgaon', NULL, NULL, NULL, CAST(28.475825000 AS Decimal(12, 9)), CAST(77.080550000 AS Decimal(12, 9)), 0xE6100000010C849ECDAACF793C4057EC2FBB27455340, CAST(0x0000A67200AF3935 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 34, NULL, 50, CAST(0x0000A67200AF3935 AS DateTime), CAST(0x0000A67200AF3935 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (35, N'iffco chowk, metro', NULL, NULL, NULL, CAST(28.472165000 AS Decimal(12, 9)), CAST(77.072512000 AS Decimal(12, 9)), 0xE6100000010CDB5031CEDF783C4053245F09A4445340, CAST(0x0000A67200AF399A AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 67, NULL, 50, CAST(0x0000A67200AF399A AS DateTime), CAST(0x0000A67200AF399A AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (36, N'huda city centre metro gurgaon', NULL, NULL, NULL, CAST(28.459269000 AS Decimal(12, 9)), CAST(77.072419000 AS Decimal(12, 9)), 0xE6100000010C0E1137A792753C40FA264D83A2445340, CAST(0x0000A67200AF3A95 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 12, NULL, 50, CAST(0x0000A67200AF3A95 AS DateTime), CAST(0x0000A67200AF3A95 AS DateTime), N'PC_A')
INSERT [dbo].[AvailableParkingArea] ([Parking_id], [parking_address], [street], [city], [state], [lattitude], [longitude], [GeoLoc], [DateTimeTo], [DateTimeFrom], [No_Of_Space_Avaiable], [Detail_ID], [BasicCharge], [dt_created], [dt_updated], [ParkingClass]) VALUES (37, N'mgf metropolitan gurgaon', NULL, NULL, NULL, CAST(28.480854000 AS Decimal(12, 9)), CAST(77.080224000 AS Decimal(12, 9)), 0xE6100000010C9A266C3F197B3C40AD16D86322455340, CAST(0x0000A67200AF3B09 AS DateTime), CAST(0x0000A684015A2A00 AS DateTime), 45, NULL, 50, CAST(0x0000A67200AF3B09 AS DateTime), CAST(0x0000A67200AF3B09 AS DateTime), N'PC_A')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (1, N'View Profile', N'/jk', 0, N'N')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (2, N'Bookings', N'/jk', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (3, N'My Wallet', N'/jk', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (4, N'Transactions', N'/jk', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (5, N'Parking Space', N'/jk', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (6, N'Upload Bulk Space', N'~/RentSpace/UploadSpace', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (7, N'Update User', N'', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (8, N'Update Space', N'', 0, N'Y')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (9, N'Dashboard', N'/jk', 0, N'N')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (10, N'Inbox', N'/jk', 0, N'N')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (11, N'Invite friend', N'/jk', 0, N'N')
INSERT [dbo].[MenuDetail] ([Menu_id], [Menu_description], [Menu_Url], [Parent_Menu_id], [AdminMenu]) VALUES (12, N'Follow us', N'/jk', 0, N'N')
SET IDENTITY_INSERT [dbo].[ParkingArea] ON 

INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (12, 9, N'ST_MTR', NULL, 250, N'VT_HB', N'Y', N'NULL', N'MG Road, gurgaon', 122002, N'NULL', N'NULL', N'NULL', CAST(28.479518000 AS Decimal(12, 9)), CAST(77.080616000 AS Decimal(12, 9)), 0xE6100000010CE4D70FB1C17A3C4033E202D028455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (13, 9, N'ST_MTR', NULL, 87, N'VT_SD', N'N', N'NULL', N'Connaught Place, New Delhi, Delhi, India', 110001, N'', N'NULL', N'NULL', CAST(28.631451200 AS Decimal(12, 9)), CAST(77.216667200 AS Decimal(12, 9)), 0xE6100000010C1C052DC9A6A13C406B871AE0DD4D5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (14, 9, N'ST_MTR', N'PT_HM', 560, N'VT_HB', N'Y', N'NULL', N'Sector 18, Noida, Uttar Pradesh, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.570317000 AS Decimal(12, 9)), CAST(77.321819600 AS Decimal(12, 9)), 0xE6100000010C535A7F4B00923C408E4D3CB198545340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (15, 9, N'ST_MTR', NULL, 230, N'VT_HB', N'Y', N'NULL', N'Ghaziabad New Bus Stand, Ghaziabad, Uttar Pradesh, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.670269600 AS Decimal(12, 9)), CAST(77.415313600 AS Decimal(12, 9)), 0xE6100000010CC580DBC996AB3C4061657E7F945A5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (16, 9, N'ST_MTR', NULL, 670, N'VT_SD', N'Y', N'NULL', N'Manesar, Gurgaon, Haryana, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.354285200 AS Decimal(12, 9)), CAST(76.939819500 AS Decimal(12, 9)), 0xE6100000010CF274536FB25A3C402829B000263C5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (17, 9, N'ST_MTR', NULL, 10, N'VT_SD', N'Y', N'NULL', N'Nehru Place, South Delhi, Delhi, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.550331400 AS Decimal(12, 9)), CAST(77.250189300 AS Decimal(12, 9)), 0xE6100000010C3FF6C484E28C3C40C953FB1903505340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (18, 9, N'ST_MTR', N'PT_HM', 1, N'VT_SUV', N'Y', N'NULL', N'Faridabad, Faridabad, Haryana, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.408912300 AS Decimal(12, 9)), CAST(77.317789400 AS Decimal(12, 9)), 0xE6100000010CA16EFB79AE683C40FD005AA956545340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (19, 9, N'ST_MCD', NULL, 65, N'VT_HB', N'N', N'NULL', N'Rohini Sector 8 Road, Rohini, New Delhi, Delhi, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.701880400 AS Decimal(12, 9)), CAST(77.122716400 AS Decimal(12, 9)), 0xE6100000010C12B4136FAEB33C40B42BE395DA475340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (20, 9, N'ST_MCD', NULL, 23, N'VT_HB', N'Y', N'NULL', N'Batra Bus Stand, New Delhi, Delhi, India', 110012, N'NULL', N'NULL', N'NULL', CAST(28.711349400 AS Decimal(12, 9)), CAST(77.215053600 AS Decimal(12, 9)), 0xE6100000010C7B0789FE1AB63C40C6B82C70C34D5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (21, 999, N'ST_MCD', NULL, 250, N'VT_HB', N'Y', N'NULL', N'MG Road, gurgaon', 122002, N'NULL', N'NULL', N'NULL', CAST(28.479518000 AS Decimal(12, 9)), CAST(77.080616000 AS Decimal(12, 9)), 0xE6100000010CE4D70FB1C17A3C4033E202D028455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (22, 10, N'ST_MCD', NULL, 250, N'VT_HB', N'Y', N'NULL', N'MG Road, gurgaon', 122002, N'NULL', N'NULL', N'NULL', CAST(28.479518000 AS Decimal(12, 9)), CAST(77.080616000 AS Decimal(12, 9)), 0xE6100000010CE4D70FB1C17A3C4033E202D028455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (23, 10, N'ST_MCD', NULL, 87, N'VT_SD', N'N', N'NULL', N'Connaught Place, New Delhi, Delhi, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.631451200 AS Decimal(12, 9)), CAST(77.216667200 AS Decimal(12, 9)), 0xE6100000010C1C052DC9A6A13C406B871AE0DD4D5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (24, 10, N'ST_MCD', N'PT_HM', 560, N'VT_HB', N'Y', N'NULL', N'Sector 18, Noida, Uttar Pradesh, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.570317000 AS Decimal(12, 9)), CAST(77.321819600 AS Decimal(12, 9)), 0xE6100000010C535A7F4B00923C408E4D3CB198545340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (25, 10, N'ST_MTR', NULL, 230, N'VT_HB', N'Y', N'NULL', N'Ghaziabad New Bus Stand, Ghaziabad, Uttar Pradesh, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.670269600 AS Decimal(12, 9)), CAST(77.415313600 AS Decimal(12, 9)), 0xE6100000010CC580DBC996AB3C4061657E7F945A5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (26, 10, N'ST_MCD', NULL, 670, N'VT_SD', N'Y', N'NULL', N'Manesar, Gurgaon, Haryana, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.354285200 AS Decimal(12, 9)), CAST(76.939819500 AS Decimal(12, 9)), 0xE6100000010CF274536FB25A3C402829B000263C5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (27, 10, N'ST_MCD', NULL, 10, N'VT_SD', N'Y', N'NULL', N'Nehru Place, South Delhi, Delhi, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.550331400 AS Decimal(12, 9)), CAST(77.250189300 AS Decimal(12, 9)), 0xE6100000010C3FF6C484E28C3C40C953FB1903505340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (28, 10, N'ST_MCD', N'PT_HM', 1, N'VT_SUV', N'Y', N'NULL', N'Faridabad, Faridabad, Haryana, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.408912300 AS Decimal(12, 9)), CAST(77.317789400 AS Decimal(12, 9)), 0xE6100000010CA16EFB79AE683C40FD005AA956545340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (29, 10, N'ST_MCD', NULL, 65, N'VT_HB', N'N', N'NULL', N'Rohini Sector 8 Road, Rohini, New Delhi, Delhi, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.701880400 AS Decimal(12, 9)), CAST(77.122716400 AS Decimal(12, 9)), 0xE6100000010C12B4136FAEB33C40B42BE395DA475340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (30, 10, N'ST_MCD', NULL, 23, N'VT_HB', N'Y', N'NULL', N'Batra Bus Stand, New Delhi, Delhi, India', 122002, N'NULL', N'NULL', N'NULL', CAST(28.711349400 AS Decimal(12, 9)), CAST(77.215053600 AS Decimal(12, 9)), 0xE6100000010C7B0789FE1AB63C40C6B82C70C34D5340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (31, 10, N'ST_MCD', NULL, 23, N'VT_SD', N'N', N'NULL', N'sahara mall gurgaon', 122001, N'NULL', N'NULL', N'NULL', CAST(28.479619000 AS Decimal(12, 9)), CAST(77.086628000 AS Decimal(12, 9)), 0xE6100000010C4C8A8F4FC87A3C40BFBA2A508B455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (32, 10, N'ST_PPL', NULL, 1, N'VT_HB', N'Y', N'NULL', N'Chakkarpur', 122001, N'NULL', N'NULL', N'NULL', CAST(28.475479000 AS Decimal(12, 9)), CAST(77.086761000 AS Decimal(12, 9)), 0xE6100000010C4EEFE2FDB8793C405E64027E8D455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (33, 10, N'ST_PG', N'PT_HM', 83, N'VT_HB', N'Y', N'NULL', N'sarawati Vihar, Guragon', 122001, N'NULL', N'NULL', N'NULL', CAST(28.477576000 AS Decimal(12, 9)), CAST(77.082038000 AS Decimal(12, 9)), 0xE6100000010CC05AB56B427A3C40DFC14F1C40455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (34, 10, N'ST_PG', NULL, 34, N'VT_HB', N'Y', N'NULL', N'Maruti Vihar, Gurgaon', 122001, N'NULL', N'NULL', N'NULL', CAST(28.475825000 AS Decimal(12, 9)), CAST(77.080550000 AS Decimal(12, 9)), 0xE6100000010C849ECDAACF793C4057EC2FBB27455340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (35, 10, N'ST_PG', NULL, 67, N'VT_SD', N'N', N'NULL', N'iffco chowk, metro', 122001, N'NULL', N'NULL', N'NULL', CAST(28.472165000 AS Decimal(12, 9)), CAST(77.072512000 AS Decimal(12, 9)), 0xE6100000010CDB5031CEDF783C4053245F09A4445340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (36, 10, N'ST_PG', N'PT_HM', 12, N'VT_SUV', N'Y', N'NULL', N'huda city centre metro gurgaon', 122001, N'NULL', N'NULL', N'NULL', CAST(28.459269000 AS Decimal(12, 9)), CAST(77.072419000 AS Decimal(12, 9)), 0xE6100000010C0E1137A792753C40FA264D83A2445340, NULL, NULL)
INSERT [dbo].[ParkingArea] ([parking_id], [owner_id], [Space_type], [Property_type], [No_of_space], [VechileType], [PropertyVerifiedStatus], [FacilityGroupId], [PropertyAddress], [PropertyPinCode], [PropertyZone], [PropertyLandMark], [OwnerComments], [lattitude], [longitude], [GeoLoc], [Status], [ParkingRating]) VALUES (37, 10, N'ST_PG', NULL, 45, N'VT_HB', N'N', N'NULL', N'mgf metropolitan gurgaon', 122001, N'NULL', N'NULL', N'NULL', CAST(28.480854000 AS Decimal(12, 9)), CAST(77.080224000 AS Decimal(12, 9)), 0xE6100000010C9A266C3F197B3C40AD16D86322455340, NULL, NULL)
SET IDENTITY_INSERT [dbo].[ParkingArea] OFF
SET IDENTITY_INSERT [dbo].[System_Code] ON 

INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (25, N'ParkingCategory', N'PC_A', N'All')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (20, N'ParkingCategory', N'PC_G', N'Gold')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (23, N'ParkingCategory', N'PC_P', N'Platinum')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (24, N'ParkingCategory', N'PC_PP', N'PlainParking')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (22, N'ParkingCategory', N'PC_S', N'Silver')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (19, N'PropertyType', N'PT_AI', N'Academic Institution')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (17, N'PropertyType', N'PT_CPL', N'Commercial Parking Lot')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (15, N'PropertyType', N'PT_HM', N'Home')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (14, N'PropertyType', N'PT_OFC', N'Office / Business')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (16, N'PropertyType', N'PT_POW', N'Place of worship')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (13, N'PropertyType', N'PT_PR', N'Private Residence ')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (18, N'PropertyType', N'PT_R', N'Retail')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (9, N'SpaceType', N'ST_ACPS', N'Allocated Car Park Space ')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (11, N'SpaceType', N'ST_AP', N'Airport Parking ')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (30, N'SpaceType', N'ST_MCD', N'MCD Parking Area')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (7, N'SpaceType', N'ST_MLPL', N'Multi Level parking Lot ')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (29, N'SpaceType', N'ST_MTR', N'Metro Parking Area')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (12, N'SpaceType', N'ST_O', N'Others')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (3, N'SpaceType', N'ST_PBD', N'Permission to Block Driveway ')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (1, N'SpaceType', N'ST_PD', N'Private Driveway')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (10, N'SpaceType', N'ST_PF', N'Private Field')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (4, N'SpaceType', N'ST_PG', N'Public garage')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (6, N'SpaceType', N'ST_PPL', N'Private parking Lot')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (5, N'SpaceType', N'ST_PVG', N'Private Garage')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (2, N'SpaceType', N'ST_SD', N'Shared Driveway')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (8, N'SpaceType', N'ST_SLPL', N'Single Level parking Lot')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (26, N'VehicleType', N'VT_HB', N'HatchBack')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (27, N'VehicleType', N'VT_SD', N'Sedan')
INSERT [dbo].[System_Code] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (28, N'VehicleType', N'VT_SUV', N'SUV')
SET IDENTITY_INSERT [dbo].[System_Code] OFF
SET IDENTITY_INSERT [dbo].[System_Code1] ON 

INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (25, N'ParkingCategory', N'PC_A', N'All')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (20, N'ParkingCategory', N'PC_G', N'Gold')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (23, N'ParkingCategory', N'PC_P', N'Platinum')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (24, N'ParkingCategory', N'PC_PP', N'PlainParking')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (22, N'ParkingCategory', N'PC_S', N'Silver')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (19, N'PropertyType', N'PT_AI', N'Academic Institution')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (17, N'PropertyType', N'PT_CPL', N'Commercial Parking Lot')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (15, N'PropertyType', N'PT_HM', N'Home')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (14, N'PropertyType', N'PT_OFC', N'Office / Business')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (16, N'PropertyType', N'PT_POW', N'Place of worship')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (13, N'PropertyType', N'PT_PR', N'Private Residence ')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (18, N'PropertyType', N'PT_R', N'Retail')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (11, N'SpaceType', N'ST_AP', N'Airport Parking ')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (9, N'SpaceType', N'ST_ACPS', N'Allocated Car Park Space ')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (7, N'SpaceType', N'ST_MLPL', N'Multi Level parking Lot ')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (12, N'SpaceType', N'ST_O', N'Others')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (3, N'SpaceType', N'ST_PBD', N'Permission to Block Driveway ')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (1, N'SpaceType', N'ST_PD', N'Private Driveway')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (10, N'SpaceType', N'ST_PF', N'Private Field')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (5, N'SpaceType', N'ST_PVG', N'Private Garage')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (6, N'SpaceType', N'ST_PPL', N'Private parking Lot')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (4, N'SpaceType', N'ST_PG', N'Public garage')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (2, N'SpaceType', N'ST_SD', N'Shared Driveway')
INSERT [dbo].[System_Code1] ([Seq_no], [MasterType], [Sys_Code], [Sys_description]) VALUES (8, N'SpaceType', N'ST_SLPL', N'Single Level parking Lot')
SET IDENTITY_INSERT [dbo].[System_Code1] OFF
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (9, N'sandhya', NULL, N'T', N'Y', NULL, N'1234567890', NULL, N'N', N'sany@gmail.com', NULL, CAST(0x0000A62F016700B7 AS DateTime), CAST(0x0000A62F016700B7 AS DateTime), N'A', N'D', NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (10, N'sandhya', NULL, N'T', N'Y', NULL, N'1234587890', NULL, N'N', N'sany@gmail.com', NULL, CAST(0x0000A62F0168BDCA AS DateTime), CAST(0x0000A62F0168BDCA AS DateTime), N'A', N'D', NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (11, N'sandhya', NULL, N'T', N'Y', NULL, N'1234555590', NULL, N'N', N'sany@gmail.com', NULL, CAST(0x0000A63000ED6C9C AS DateTime), CAST(0x0000A63000ED6C9C AS DateTime), N'A', N'D', NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (12, N'First Name', N'Last Name', N'T', N'Y', NULL, N'Mobile ', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A638009874F8 AS DateTime), CAST(0x0000A638009874F8 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (13, N'ssfsf', N'j.bnnbn', N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'san@1234', NULL, CAST(0x0000A6380098A35B AS DateTime), CAST(0x0000A6380098A35B AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (14, N'sandhya', N'Last Name', N'T', N'Y', NULL, N'hjh', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A63800BCDD40 AS DateTime), CAST(0x0000A63800BCDD40 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (15, N'First Name', N'Last Name', N'T', N'Y', NULL, N'hjgh', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A63800BD28EB AS DateTime), CAST(0x0000A63800BD28EB AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (16, N'First Name', N'Last Name', N'T', N'Y', NULL, N't6u5gfj', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A63800BD3812 AS DateTime), CAST(0x0000A63800BD3812 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (62, N'rr', N'rr', N'T', N'Y', NULL, N'33333777', NULL, N'N', N'38844@gmail.com', NULL, CAST(0x0000A64E00C6A679 AS DateTime), CAST(0x0000A64E00C6A679 AS DateTime), N'A', N'M', NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (63, N'testotpp', N'otp', N'T', N'Y', NULL, N'8527654844', NULL, N'N', N'sann@gm.com', NULL, CAST(0x0000A64E016C0788 AS DateTime), CAST(0x0000A64E016C0788 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (19, N'neeraj', N'panday', N'T', N'Y', NULL, N'9818970065', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A638011D5E6F AS DateTime), CAST(0x0000A638011D5E6F AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (20, N'First Name', N'Last Name', N'T', N'Y', NULL, N'8787876767', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A63F002E8687 AS DateTime), CAST(0x0000A63F002E8687 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (23, N'Sandhya', N'Goswami', N'T', N'Y', NULL, N'NA', NULL, N'N', N'sandy.goswami2@gmail.com', NULL, CAST(0x0000A63F011CD2B5 AS DateTime), CAST(0x0000A63F011CD2B5 AS DateTime), N'A', N'F', NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (25, N'suraj', N'Goswami', N'T', N'Y', NULL, N'7827169222', NULL, N'N', N'suraj@gmail.com', NULL, CAST(0x0000A64100B8A6D0 AS DateTime), CAST(0x0000A64100B8A6D0 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (26, N'sauraj', N'Last Name', N'T', N'Y', NULL, N'2344321233', NULL, N'N', N'your@email.com ', NULL, CAST(0x0000A64100BA26B8 AS DateTime), CAST(0x0000A64100BA26B8 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (27, N'seema', N'Goswami', N'T', N'Y', NULL, N'9013946970', NULL, N'N', N'simswami@gmail.com', NULL, CAST(0x0000A64200BA5BC2 AS DateTime), CAST(0x0000A64200BA5BC2 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (29, N'Dinesh', N'Tiwari', N'T', N'Y', NULL, N'9182737412', NULL, N'N', N'Dany@gmail.com', NULL, CAST(0x0000A645010FC596 AS DateTime), CAST(0x0000A645010FC596 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (30, N'neeraj', N'pandey', N'T', N'Y', NULL, N'4204204209', NULL, N'N', N'neeraj@hsc.com', NULL, CAST(0x0000A6450114EB11 AS DateTime), CAST(0x0000A6450114EB11 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (64, N'sanotppp', N'otp', N'T', N'Y', NULL, N'8527654844', NULL, N'N', N'snnnnn@gmail.com', NULL, CAST(0x0000A64E016EC452 AS DateTime), CAST(0x0000A64E016EC452 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (65, N'otpfinaltest', NULL, N'T', N'Y', NULL, N'8527654844', NULL, N'N', N'fsd@gail.com', NULL, CAST(0x0000A64F00083E5B AS DateTime), CAST(0x0000A64F00083E5B AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (66, N'saneep', N'otp', N'T', N'Y', NULL, N'8527654844', NULL, N'N', N'hhggg@gmail.com', NULL, CAST(0x0000A64F000D2E56 AS DateTime), CAST(0x0000A64F000D2E56 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (67, N'jahOTP', N'otp', N'T', N'Y', NULL, N'8527654844', NULL, N'N', N'hgfsff@gm.com', NULL, CAST(0x0000A64F00151065 AS DateTime), CAST(0x0000A64F00151065 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (68, N'finalotp', N'test', N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'hgfg@hh.com', NULL, CAST(0x0000A64F0018E464 AS DateTime), CAST(0x0000A64F0018E464 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (69, N'tet', N'to', N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'gghsaf@gg.com', NULL, CAST(0x0000A64F001E25C1 AS DateTime), CAST(0x0000A64F001E25C1 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (70, N'hghg', N'njshnje', N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'bghbhgb@gmail.com', NULL, CAST(0x0000A64F00250BDB AS DateTime), CAST(0x0000A64F00250BDB AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (71, N'haha', N'hehe', N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'hahah@gm.com', NULL, CAST(0x0000A64F00B9AE46 AS DateTime), CAST(0x0000A64F00B9AE46 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (72, N'resnd', N'otp', N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'ghaahg@g.com', NULL, CAST(0x0000A64F00C18AB2 AS DateTime), CAST(0x0000A64F00C18AB2 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (73, N'Anurag', NULL, N'T', N'Y', NULL, N'8802906990', NULL, N'N', N'anurag04.pccs@gmail.com', NULL, CAST(0x0000A6500005C996 AS DateTime), CAST(0x0000A6500005C996 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (74, N'Anurag', NULL, N'T', N'Y', NULL, N'8802906990', NULL, N'N', N'sandy.goswami777@gmail.com', NULL, CAST(0x0000A650000C6B30 AS DateTime), CAST(0x0000A650000C6B30 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (75, N'DILEEP', NULL, N'T', N'Y', NULL, N'7007122997', NULL, N'N', N'info2tiwari@gmail.com', NULL, CAST(0x0000A65B00E2092F AS DateTime), CAST(0x0000A65B00E2092F AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (76, N'Administrator', NULL, N'T', N'Y', NULL, N'8527654844', NULL, N'N', N'admin@Gmail.com', NULL, CAST(0x0000A65D000835EB AS DateTime), CAST(0x0000A65D000835EB AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (77, N'Administrator', NULL, N'T', N'Y', NULL, N'7827169111', NULL, N'N', N'admin2@Gmail.com', NULL, CAST(0x0000A65D000D5FA2 AS DateTime), CAST(0x0000A65D000D5FA2 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (78, N'sandhya', NULL, N'T', N'Y', NULL, N'9818852302', NULL, N'N', N'sanghgh@gm.com', NULL, CAST(0x0000A65D0181BA90 AS DateTime), CAST(0x0000A65D0181BA90 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (79, N'poonam', NULL, N'T', N'Y', NULL, N'9838130243', NULL, N'N', N'poonam18octt@gmail.com', NULL, CAST(0x0000A677012612AC AS DateTime), CAST(0x0000A677012612AC AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (80, N'ASE', N'FGH', N'T', N'Y', NULL, N'9868429724', NULL, N'N', N'anuragkumar.sinha@gmail.com', NULL, CAST(0x0000A677014814C5 AS DateTime), CAST(0x0000A677014814C5 AS DateTime), N'A', NULL, NULL, NULL, NULL)
INSERT [dbo].[UserDetails] ([User_id], [First_Name], [Last_Name], [User_Type], [Agreement_Accepted], [Owner_Address], [Phone_No1], [Phone_No2], [OwnerVerificationStatus], [Email_id], [Alternate_Email_Id], [Dt_Created], [Dt_Updated], [Status], [SignUp_Mode_ID], [Driving_License], [PAN], [Pin_code]) VALUES (81, N'Ranjan', NULL, N'T', N'Y', NULL, N'9958987971', NULL, N'N', N'sandy.goswami2666@gmail.com', NULL, CAST(0x0000A68500D0E19F AS DateTime), CAST(0x0000A68500D0E19F AS DateTime), N'A', NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[UserLogin] ON 

INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (9, N'sandhya Goswami', N'sandypass', N'1234567890', N'sany@gmail.com', NULL, CAST(0x0000A62F016700B7 AS DateTime), CAST(0x0000A62F016700B7 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (10, N'sandhya sandhya', N'sandypass', N'1234587890', N'sany@gmail.com', NULL, CAST(0x0000A62F0168BDCA AS DateTime), CAST(0x0000A62F0168BDCA AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (11, N'sandhya sandhya', N'sandypass', N'1234555590', N'sany@gmail.com', NULL, CAST(0x0000A63000ED6C93 AS DateTime), CAST(0x0000A63000ED6C93 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (12, N'First Name First Name', N'Password ', N'Mobile ', N'your@email.com ', NULL, CAST(0x0000A638009874D1 AS DateTime), CAST(0x0000A638009874D1 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (13, N'ssfsf ssfsf', N'1234567', N'8523624342', N'san@1234', NULL, CAST(0x0000A6380098A35A AS DateTime), CAST(0x0000A6380098A35A AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (14, N'sandhya sandhya', N'678', N'hjh', N'your@email.com ', NULL, CAST(0x0000A63800BCDD13 AS DateTime), CAST(0x0000A63800BCDD13 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (15, N'First Name First Name', N'Password ', N'hjgh', N'your@email.com ', NULL, CAST(0x0000A63800BD28EB AS DateTime), CAST(0x0000A63800BD28EB AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (16, N'First Name First Name', N'Password ', N't6u5gfj', N'your@email.com ', NULL, CAST(0x0000A63800BD37BE AS DateTime), CAST(0x0000A63800BD37BE AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (17, N'First Name First Name', N'Password ', N'bhnbghgb', N'your@email.com ', NULL, CAST(0x0000A63800C1A656 AS DateTime), CAST(0x0000A63800C1A656 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (18, N'First Name First Name', N'1234567', N'8564545667', N'your@email.com ', NULL, CAST(0x0000A638011C68A1 AS DateTime), CAST(0x0000A638011C68A1 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (19, N'Neeraj Pandey', N'password', N'7292024469', N'NeerajPandey@email.com ', NULL, CAST(0x0000A638011D5E6C AS DateTime), CAST(0x0000A638011D5E6C AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (20, N'First Name Last Name', N'Password ', N'8787876767', N'your@email.com ', NULL, CAST(0x0000A63F002E865D AS DateTime), CAST(0x0000A63F002E865D AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (21, N'sanhya hhhh', N'sanhya@Truewheels', NULL, N'ss@gmail.com', NULL, CAST(0x0000A63F0102E72F AS DateTime), CAST(0x0000A63F0102E72F AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (22, N'sanhya hhhh', N'sanhya@Truewheels', NULL, N'ss@gmail.com', NULL, CAST(0x0000A63F011AE915 AS DateTime), CAST(0x0000A63F011AE915 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (23, N'Sandhya Goswami', N'Sandhya@Truewheels', N'NA', N'sandy.goswami2@gmail.com', NULL, CAST(0x0000A63F011CD2B2 AS DateTime), CAST(0x0000A63F011CD2B2 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (24, N'Sandhya Goswami', N'Sandhya@Truewheels', NULL, N'sandy.goswami2@gmail.com', NULL, CAST(0x0000A63F012307C3 AS DateTime), CAST(0x0000A63F012307C3 AS DateTime), N'A', 1546268625400346, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (25, N'suraj Goswami', N'123456789', N'7827169222', N'suraj@gmail.com', NULL, CAST(0x0000A64100B8A6D0 AS DateTime), CAST(0x0000A64100B8A6D0 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (26, N'sauraj Last Name', N'Password ', N'2344321233', N'your@email.com ', NULL, CAST(0x0000A64100BA26B8 AS DateTime), CAST(0x0000A64100BA26B8 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (27, N'seema Goswami', N'sim5050', N'9013946970', N'simswami@gmail.com', NULL, CAST(0x0000A64200BA5BAA AS DateTime), CAST(0x0000A64200BA5BAA AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (28, NULL, N'@Truewheels', NULL, NULL, NULL, CAST(0x0000A64300AAC19F AS DateTime), CAST(0x0000A64300AAC19F AS DateTime), N'A', 0, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (29, N'Dinesh Tiwari', N'1234567890', N'9182737412', N'Dany@gmail.com', NULL, CAST(0x0000A645010FC565 AS DateTime), CAST(0x0000A645010FC565 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (30, N'neeraj pandey', N'neer@121', N'4204204209', N'neeraj@hsc.com', NULL, CAST(0x0000A6450114EB0A AS DateTime), CAST(0x0000A6450114EB0A AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (31, N'testmenu', NULL, N'1233212332', NULL, NULL, NULL, NULL, NULL, NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (32, N'saneep jj', N'123123123', N'8787876769', NULL, NULL, CAST(0x0000A64501559435 AS DateTime), CAST(0x0000A64501559435 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (33, N'new gs', N'123321123', N'1212121212', N'sg@gmail.com', NULL, CAST(0x0000A64501590E96 AS DateTime), CAST(0x0000A64501590E96 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (34, N'hj b m', N'12332123', N'8888888888', N'nn@bn.com', NULL, CAST(0x0000A646000816C7 AS DateTime), CAST(0x0000A646000816C7 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (35, N'4 43', N'12121212', N'3434343434', N'cc@gg.com', NULL, CAST(0x0000A646000BE819 AS DateTime), CAST(0x0000A646000BE819 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (36, N'neer gos', N'123456789', N'7834343434', N'sa@gg.com', NULL, CAST(0x0000A64601387E52 AS DateTime), CAST(0x0000A64601387E52 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (37, N'test3 ji', N'123456789', N'7827169118', N'sf@gmail.com', NULL, CAST(0x0000A64800AD7509 AS DateTime), CAST(0x0000A64800AD7509 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (38, N'test2 fg', N'123123123', N'7676767612', N'as@gm.com', NULL, CAST(0x0000A64800B79620 AS DateTime), CAST(0x0000A64800B79620 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (39, N'testotp otp', N'123456789', N'7171717171', N'sas@gmail.com', NULL, CAST(0x0000A64801647B76 AS DateTime), CAST(0x0000A64801647B76 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (40, NULL, N'123456789', N'8181818181', N'gh@gmail.com', NULL, CAST(0x0000A6480166565F AS DateTime), CAST(0x0000A6480166565F AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (41, N'otptest otp', N'123456789', N'8282828282', N'sd@gmail.com', NULL, CAST(0x0000A6480185C257 AS DateTime), CAST(0x0000A6480185C257 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (42, N'gest jh', N'0000000', N'8767676767', N'hh@gmail.com', NULL, CAST(0x0000A648018710A4 AS DateTime), CAST(0x0000A648018710A4 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (43, N'otphh otp', N'123456', N'3838383883', N'jj@gmail.com', NULL, CAST(0x0000A648018B3690 AS DateTime), CAST(0x0000A648018B3690 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (44, N'er jh', N'123456', N'9812121212', NULL, NULL, CAST(0x0000A649000031A7 AS DateTime), CAST(0x0000A649000031A7 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (45, N'rr bb', N'888888', N'8777777777', NULL, NULL, CAST(0x0000A649000334C1 AS DateTime), CAST(0x0000A649000334C1 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (46, N'nerrajba sss', N'123456', N'7272727277', N'gg@gmail.com', NULL, CAST(0x0000A64C0137BD53 AS DateTime), CAST(0x0000A64C0137BD53 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (47, N'sanhyotp Goswami', N'123456', N'8527654344', N'sany@ggg.com', NULL, CAST(0x0000A64E002285F2 AS DateTime), CAST(0x0000A64E002285F2 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (48, N'ww ww', N'ww', N'6565656565', N'ww@gmail.com', NULL, CAST(0x0000A64E0029A5B7 AS DateTime), CAST(0x0000A64E0029A5B7 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (49, N'ww ww', N'ww', N'6666644444', N'wwff@gmail.com', NULL, CAST(0x0000A64E002C2AEE AS DateTime), CAST(0x0000A64E002C2AEE AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (50, N'gg ff', N'ff', N'8787989898', N'ffgh@gm.com', NULL, CAST(0x0000A64E002ED621 AS DateTime), CAST(0x0000A64E002ED621 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (51, N'gg ff', N'ff', N'8787919898', N'ff1gh@gm.com', NULL, CAST(0x0000A64E002F1F23 AS DateTime), CAST(0x0000A64E002F1F23 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (52, N'rr rr', N'8767876783', N'8767876783', N'8767876783@gmail.com', NULL, CAST(0x0000A64E00BF5127 AS DateTime), CAST(0x0000A64E00BF5127 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (53, N'rr rr', N'87678763', N'8767876653', N'87678783@gmail.com', NULL, CAST(0x0000A64E00BFE7C5 AS DateTime), CAST(0x0000A64E00BFE7C5 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (54, N'rr rr', N'87678763', N'8767844653', N'8767883@gmail.com', NULL, CAST(0x0000A64E00C0D359 AS DateTime), CAST(0x0000A64E00C0D359 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (55, N'rr rr', N'87678763', N'8767994653', N'876783@gmail.com', NULL, CAST(0x0000A64E00C19370 AS DateTime), CAST(0x0000A64E00C19370 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (56, N'rr rr', N'87611763', N'8711994653', N'811783@gmail.com', NULL, CAST(0x0000A64E00C3E9BD AS DateTime), CAST(0x0000A64E00C3E9BD AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (57, N'rr rr', N'87611763', N'8722994653', N'812283@gmail.com', NULL, CAST(0x0000A64E00C3F2DD AS DateTime), CAST(0x0000A64E00C3F2DD AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (58, N'rr rr', N'87611763', N'873322994653', N'83383@gmail.com', NULL, CAST(0x0000A64E00C3FD1B AS DateTime), CAST(0x0000A64E00C3FD1B AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (59, N'rr rr', N'87611763', N'8734422994653', N'8344383@gmail.com', NULL, CAST(0x0000A64E00C4057E AS DateTime), CAST(0x0000A64E00C4057E AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (60, N'rr rr', N'87611763', N'554422994653', N'8355383@gmail.com', NULL, CAST(0x0000A64E00C42E50 AS DateTime), CAST(0x0000A64E00C42E50 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (61, N'rr rr', N'87611763', N'3333333432', N'344@gmail.com', NULL, CAST(0x0000A64E00C43D9A AS DateTime), CAST(0x0000A64E00C43D9A AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (62, N'rr rr', N'87611763', N'33333777', N'38844@gmail.com', NULL, CAST(0x0000A64E00C6A515 AS DateTime), CAST(0x0000A64E00C6A515 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (63, N'testotpp otp', N'123456', N'8523654344', N'sann@gm.com', NULL, CAST(0x0000A64E016C074F AS DateTime), CAST(0x0000A64E016C074F AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (64, N'sanotppp otp', N'123456', N'8523654342', N'snnnnn@gmail.com', NULL, CAST(0x0000A64E016EC452 AS DateTime), CAST(0x0000A64E016EC452 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (65, NULL, N'123456', N'8523654362', N'fsd@gail.com', NULL, CAST(0x0000A64F00083D69 AS DateTime), CAST(0x0000A64F00083D69 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (66, N'saneep otp', N'123456', N'8523624362', N'hhggg@gmail.com', NULL, CAST(0x0000A64F000D2E3E AS DateTime), CAST(0x0000A64F000D2E3E AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (67, N'jahOTP otp', N'123456', N'8527054844', N'hgfsff@gm.com', NULL, CAST(0x0000A64F0015105E AS DateTime), CAST(0x0000A64F0015105E AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (68, N'finalotp test', N'0987654', N'8523324342', N'hgfg@hh.com', NULL, CAST(0x0000A64F0018E44C AS DateTime), CAST(0x0000A64F0018E44C AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (69, N'tet to', N'666666', N'852332342', N'gghsaf@gg.com', NULL, CAST(0x0000A64F001E258B AS DateTime), CAST(0x0000A64F001E258B AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (70, N'hghg njshnje', N'111111', N'852322342', N'bghbhgb@gmail.com', NULL, CAST(0x0000A64F00250BC9 AS DateTime), CAST(0x0000A64F00250BC9 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (71, N'haha hehe', N'111111', N'852312342', N'hahah@gm.com', NULL, CAST(0x0000A64F00B9AD97 AS DateTime), CAST(0x0000A64F00B9AD97 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (72, N'resnd otp', N'111111', N'8527004844', N'ghaahg@g.com', NULL, CAST(0x0000A64F00C18AB0 AS DateTime), CAST(0x0000A64F00C18AB0 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (73, NULL, N'123456', N'4441115551', N'anurag04.pccs@gmail.com', NULL, CAST(0x0000A6500005C8B0 AS DateTime), CAST(0x0000A6500005C8B0 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (74, N'Anurag ', N'123456', N'8802906990', N'sandy.goswami777@gmail.com', NULL, CAST(0x0000A650000C6AE3 AS DateTime), CAST(0x0000A650000C6AE3 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (75, N'DILEEP ', N'123456', N'7007122997', N'info2tiwari@gmail.com', NULL, CAST(0x0000A65B00E20869 AS DateTime), CAST(0x0000A65B00E20869 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (76, N'Administrator ', N'123456', N'8527654844', N'admin@Gmail.com', NULL, CAST(0x0000A65D00083482 AS DateTime), CAST(0x0000A65D00083482 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (77, N'Administrator ', N'b5hBVZ33F+Y=', N'7827169111', N'admin2@Gmail.com', NULL, CAST(0x0000A65D000D5F61 AS DateTime), CAST(0x0000A65D000D5F61 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (78, N'sandhya ', N'123456', N'9818852302', N'sanghgh@gm.com', NULL, CAST(0x0000A65D0181B8D5 AS DateTime), CAST(0x0000A65D0181B8D5 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (79, N'poonam ', N'b5hBVZ33F+Y=', N'9838130243', N'poonam18octt@gmail.com', NULL, CAST(0x0000A677012611C0 AS DateTime), CAST(0x0000A677012611C0 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (80, N'ASE FGH', N'b5hBVZ33F+Y=', N'9868429724', N'anuragkumar.sinha@gmail.com', NULL, CAST(0x0000A67701481388 AS DateTime), CAST(0x0000A67701481388 AS DateTime), N'A', NULL, N'N')
INSERT [dbo].[UserLogin] ([User_Id], [User_Name], [Password], [Phone_No1], [Email_Id], [Last_Login], [Dt_Created], [Dt_Updated], [Status], [FB_ID], [IsMobileVarified]) VALUES (81, N'Ranjan ', N'b5hBVZ33F+Y=', N'9958987971', N'sandy.goswami2666@gmail.com', NULL, CAST(0x0000A68500D0E000 AS DateTime), CAST(0x0000A68500D0E000 AS DateTime), N'A', NULL, N'N')
SET IDENTITY_INSERT [dbo].[UserLogin] OFF
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (9, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (9, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (9, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (9, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (9, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (24, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (24, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (24, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (31, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (31, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (31, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (31, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (31, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (32, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (32, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (32, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (32, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (32, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (33, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (33, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (33, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (33, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (33, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (34, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (34, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (34, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (34, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (34, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (35, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (35, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (35, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (35, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (35, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (36, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (36, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (36, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (36, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (36, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (37, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (37, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (37, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (37, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (37, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (38, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (38, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (38, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (38, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (38, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (39, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (39, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (39, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (39, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (39, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (40, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (40, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (40, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (40, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (40, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (41, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (41, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (41, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (41, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (41, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (42, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (42, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (42, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (42, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (42, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (43, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (43, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (43, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (43, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (43, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (44, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (44, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (44, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (44, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (44, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (45, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (45, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (45, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (45, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (45, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (46, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (46, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (46, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (46, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (46, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (47, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (47, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (47, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (47, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (47, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (48, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (48, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (48, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (48, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (48, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (49, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (49, 2)
GO
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (49, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (49, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (49, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (50, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (50, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (50, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (50, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (50, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (51, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (51, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (51, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (51, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (51, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (52, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (52, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (52, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (52, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (52, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (53, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (53, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (53, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (53, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (53, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (54, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (54, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (54, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (54, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (54, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (55, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (55, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (55, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (55, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (55, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (56, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (56, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (56, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (56, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (56, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (57, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (57, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (57, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (57, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (57, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (58, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (58, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (58, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (58, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (58, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (59, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (59, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (59, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (59, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (59, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (60, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (60, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (60, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (60, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (60, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (61, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (61, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (61, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (61, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (61, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (62, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (62, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (62, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (62, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (62, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (63, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (63, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (63, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (63, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (63, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (64, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (64, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (64, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (64, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (64, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (65, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (65, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (65, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (65, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (65, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (66, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (66, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (66, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (66, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (66, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (67, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (67, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (67, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (67, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (67, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (68, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (68, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (68, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (68, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (68, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (69, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (69, 2)
GO
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (69, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (69, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (69, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (70, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (70, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (70, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (70, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (70, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (71, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (71, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (71, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (71, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (71, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (72, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (72, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (72, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (72, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (72, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (73, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (73, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (73, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (73, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (73, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (74, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (74, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (75, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (75, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (75, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (75, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (75, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (76, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (76, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (76, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (76, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (76, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 6)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (78, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (78, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (78, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (78, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 7)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (77, 8)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (79, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (79, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (79, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (79, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (79, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (80, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (80, 2)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (80, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (80, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (80, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (81, 1)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (81, 9)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (81, 10)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (81, 11)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (81, 12)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (74, 3)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (74, 4)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (74, 5)
INSERT [dbo].[UserMenuMapping] ([User_id], [Menu_id]) VALUES (78, 1)
ALTER TABLE [dbo].[AvailableParkingArea] ADD  DEFAULT ((0)) FOR [No_Of_Space_Avaiable]
GO
ALTER TABLE [dbo].[MenuDetail] ADD  DEFAULT ('N') FOR [AdminMenu]
GO
ALTER TABLE [dbo].[UserDetails] ADD  DEFAULT ('T') FOR [User_Type]
GO
ALTER TABLE [dbo].[UserDetails] ADD  DEFAULT ('N') FOR [Agreement_Accepted]
GO
ALTER TABLE [dbo].[UserDetails] ADD  DEFAULT ('N') FOR [OwnerVerificationStatus]
GO
ALTER TABLE [dbo].[UserLogin] ADD  DEFAULT (NULL) FOR [FB_ID]
GO
ALTER TABLE [dbo].[UserLogin] ADD  DEFAULT ('N') FOR [IsMobileVarified]
GO
ALTER TABLE [dbo].[UserDetails]  WITH CHECK ADD  CONSTRAINT [Foregnkey_UserId_tblUseretails_tblUser] FOREIGN KEY([User_id])
REFERENCES [dbo].[UserLogin] ([User_Id])
GO
ALTER TABLE [dbo].[UserDetails] CHECK CONSTRAINT [Foregnkey_UserId_tblUseretails_tblUser]
GO
