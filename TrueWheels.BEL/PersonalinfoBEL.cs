using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace TrueWheels.BEL
{
    public class PersonalinfoBEL
    {
        public int User_Id { get; set; }
        public string Full_Name { get; set; }
        [Required(AllowEmptyStrings =false,ErrorMessage ="First Name Required.")]
        public string First_Name { get; set; }
        [Required(AllowEmptyStrings = false, ErrorMessage = "Last Name Required.")]
        public string Last_Name { get; set; }

        public string Display_Name { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "DOB Required.")]
        [DisplayFormat(DataFormatString = "{0:dd MMM, yyyy}")] 
        public DateTime? DOB { get; set; }
    
    
        public string MobileNo { get; set; }

       // [Required(ErrorMessage = "Your must provide a PhoneNumber")]
        [Display(Name = "PhoneNo")]
        [DataType(DataType.PhoneNumber)]
        [RegularExpression(@"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$", ErrorMessage = "Not a valid Phone number")]
        public string AlternateNo { get; set; }

  
        public string Driving_License { get; set; }

        public string Pan_No { get; set; }

        [Required(ErrorMessage = "Email is Required")]
        [DataType(DataType.EmailAddress, ErrorMessage = "E-mail is not valid")]
        public string Email_ID { get; set; }

        [DataType(DataType.EmailAddress, ErrorMessage = "E-mail is not valid")]
        public string Alternate_Email_Id { get; set; }

        public string Last_Login { get; set; }

        public string Owner_Address{  get; set; }

        public char Owner_Verification_Status { get; set; }

        [DataType(DataType.Password)]
        [Required(ErrorMessage = "Password is Required")]
        public string Password { get; set; }


        [DataType(DataType.Password)]
        [Display(Name = "Old password")]
        public string MatchPassword { get; set; }

        
        [StringLength(100, ErrorMessage = "The password must be at least 6 characters long.")]
        [DataType(DataType.Password)]
        [Display(Name = "New Password")]
        public string NewPassword { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Confirm password")]
        [Compare("NewPassword", ErrorMessage = "The password and confirmation password do not match.")]
        public string Confirm_NewPassword { get; set; }

        public string profilePic_Path { get; set; }

        public HttpPostedFileBase profilePic { get; set; }

        public string ErrorMessage { get; set; }
        public bool Success { get; set; }

        public List<DashBoardBEL> MenuList { get; set; }
    }
}