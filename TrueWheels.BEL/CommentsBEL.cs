using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
    public class CommentsBEL
    {
        //  public string UserPicLink { get; set; }

        public string commentId { get; set; }
        public string postId { get; set; }
        public string userId { get; set; }
        public string CommentedByUName { get; set; }
        public string commentText { get; set; }
        public string avatar { get; set; }

        public string likes { get; set; }

        public string dateCreated { get; set; }

        public string ErrorMessage { get; set; }
        public bool Success { get; set; }

       
        public CommentsBEL CommentDetailBEL { get; set; }
        public CommentsBEL() { }
        public CommentsBEL(CommentsBEL newObj)
        {
            CommentDetailBEL = newObj;
            userId = newObj.userId;
            postId = newObj.postId;
            commentId = newObj.commentId;
            commentText = newObj.commentText;
            likes = newObj.likes;
            avatar = newObj.avatar;

            // Alternate_Email_Id = newObj.Alternate_Email_Id;
            // FullName = newObj.First_Name + " " + newObj.Last_Name;
            ErrorMessage = newObj.ErrorMessage;


        }

    }
}
