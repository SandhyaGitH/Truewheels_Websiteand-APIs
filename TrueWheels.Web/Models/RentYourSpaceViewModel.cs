using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace TrueWheels.Web.Models
{
    public class RentYourSpaceViewModel
    {
        [Display(Name = "User Name")]
        public string User_Name { get; set; }


        [Required(ErrorMessage = "Your must provide a PhoneNumber")]
        [Display(Name = "PhoneNo")]
        [DataType(DataType.PhoneNumber)]
        [RegularExpression(@"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$", ErrorMessage = "Not a valid Phone number")]
        public string Phone_No1 { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "The {0} must be at least {2} characters long.", MinimumLength = 6)]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Confirm password")]
        [Compare("Password", ErrorMessage = "The password and confirmation password do not match.")]
        public string ConfirmPassword { get; set; }

        [Display(Name = "Email Id")]
        public string Email_Id { get; set; }

        [Display(Name = "First Name")]
        public string First_Name { get; set; }

        [Display(Name = "Last Name")]
        public string Last_Name { get; set; }

        [Display(Name = "Address")]
        public string Owner_Address { get; set; }

        [Display(Name = "Alternate Phone No.")]
        public string Phone_No2 { get; set; }

        [Display(Name = "Alternate Email")]
        public string Alternate_Email_Id { get; set; }

        [Display(Name = "SignUp_Mode_ID")]
        public string SignUp_Mode_ID { get; set; }
    }
}