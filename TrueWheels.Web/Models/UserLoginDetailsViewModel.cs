using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using TrueWheels.DAL;

namespace TrueWheels.Web.Models
{
    public class UserLoginDetailsViewModel
    {

        public string User_ID { get; set; }
        public string User_Name { get; set; }

        public string Phone_No1 { get; set; }

        public string Email_Id { get; set; }
        public string FullName { get; set; }

        public string Last_Login { get; set; }
        public string ErrorMessage { get; set; }

        public string Alternate_Email_Id { get; set; }
       
        public UserDetailsBEL UserDetailObj { get; set; }

        public UserLoginDetailsViewModel(UserDetailsBEL newObj)
        {
            UserDetailObj = newObj;
            User_ID = newObj.User_ID;
            User_Name = newObj.User_Name;
            Phone_No1 = newObj.Phone_No1;
            Email_Id = newObj.Email_Id;
            Last_Login = newObj.Last_Login;
            Alternate_Email_Id = newObj.Alternate_Email_Id;
            FullName = newObj.First_Name + " " + newObj.Last_Name;
            ErrorMessage = newObj.ErrorMessage;
           
            
        }

    }
}