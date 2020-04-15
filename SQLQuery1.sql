Create procedure USP_GetAllUsers 
  
as  
Begin  
 Select U.Id,   U.FullName,U.UserName,U.Password, U.Gender  
 From TrueWheelsUser U 
 
End