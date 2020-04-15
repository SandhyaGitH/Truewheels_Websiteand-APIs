using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{
    public class SignupViewModel
    {
        [Required(ErrorMessage = "Please Enter Your First Name")]
        [Display(Name = "First Name")]
        public string FirstName{ get; set;}

        [Display(Name = "Last Name")]
        public string LastName{get; set; }

        [Display(Name = "Email Id")]
        public string EmailId { get; set; }

        [Display(Name = "Mobile No.")]
        [Required(ErrorMessage = "You must provide a PhoneNumber")]
        [DataType(DataType.PhoneNumber)]
        [RegularExpression(@"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$", ErrorMessage = "Not a valid Phone number")]
        public string Mobile { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "The {0} must be at least {2} characters long.", MinimumLength = 6)]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string Password  {  get; set;  }

        [DataType(DataType.Password)]
        [Display(Name = "Confirm password")]
        [Compare("Password", ErrorMessage = "The password and confirmation password do not match.")]
        public string ConfirmPassword { get; set; }

        //[Required(ErrorMessage = "Please accept Term an conitions")]
        //public bool AgreementAccepted { get; set; }

        

    }
}