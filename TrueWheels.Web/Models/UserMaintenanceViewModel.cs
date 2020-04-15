using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using TrueWheels.BEL;

namespace TrueWheels.Web.Models
{
    public class UserMaintenanceViewModel
    {
        public PersonalinfoBEL Personalinfo { get; set; }

        public List<UserInboxBEL> UserInboxList { get; set; }

        public HttpPostedFileBase profilePic { get; set; }
    }
}