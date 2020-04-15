using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{
    public class AddPostViewModel
    {
        [Required(ErrorMessage = "Please Enter Post Name")]
        [Display(Name = "Post Name")]
        public string PostName{ get; set;}

        [Required(ErrorMessage = "User Id is required field")]
        [Display(Name = "User Id")]
        public string UserId { get; set; }

        [Display(Name = "Post Description")]
        public string PostDescription { get; set; }


        [Display(Name = "Avatar")]
        public string Avatar { get; set; }

        

    }
}