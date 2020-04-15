using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{
    public class AddCommentViewModel
    {
        

        [Required(ErrorMessage = "Post Id is required field")]
        [Display(Name = "Post Id")]
        public string postId { get; set; }

        [Required(ErrorMessage = "User Id is required field")]
        [Display(Name = "UserId")]
        public string userId { get; set; }

        [Display(Name = "Comment")]
        public string commentText { get; set; }


        [Display(Name = "Avatar")]
        public string Avatar { get; set; }

       

        [Display(Name = "Likes")]
        public string likes { get; set; }

      //  public string dateCreated { get; set; }

      //  public string ErrorMessage { get; set; }
      //  public bool Success { get; set; }



    }
}