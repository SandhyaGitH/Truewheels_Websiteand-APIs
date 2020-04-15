using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
    public class PostsBEL
    {
        public string postId { get; set; }
        public string userId { get; set; }

        public string postDescription { get; set; }

        public string postName { get; set; }
        public string postedByUName { get; set; }

        public string avatar { get; set; }

        public string likes { get; set; }

        public string dateCreated { get; set; }

        public List<CommentsBEL> Comments { get; set; }

        public string ErrorMessage { get; set; }
        public bool Success { get; set; }

        //  public string UserPicLink { get; set; }
        public PostsBEL PostDetailsBEL { get; set; }
        //List<PostsBEL>

        public PostsBEL() { }
        public PostsBEL(PostsBEL newObj)
        {
              PostDetailsBEL = newObj;
              userId = newObj.userId;
              postId = newObj.postId;
               postName = newObj.postName;
              postDescription = newObj.postDescription;
              likes = newObj.likes;
             // Alternate_Email_Id = newObj.Alternate_Email_Id;
             // FullName = newObj.First_Name + " " + newObj.Last_Name;
              ErrorMessage = newObj.ErrorMessage;
             

        }


    }
}
