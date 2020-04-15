using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{
    public class UserLogin
    {
        [Display(Name="Username")]
        public string UserName { get; set; }

        [Display(Name = "Email")]
        public string Email { get; set; }
        [Display(Name = "Mobile")]
        public string Mobile { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "The {0} must be at least {2} characters long.", MinimumLength = 6)]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string Password { get; set; }
    }
}