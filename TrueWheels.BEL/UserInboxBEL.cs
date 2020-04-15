using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
    public class UserInboxBEL
    {

       public int Notification_ID { get; set; }

       public int User_Id { get; set; }

       public string Subject { get; set; }

       public string Message { get; set; }

       public char READYN { get; set; }

        public char UserSpecific { get; set; }

        public char ActiveYN { get; set; }

        public DateTime Dt_Created { get; set; }

        public string ErrorMessage { get; set; }

        public bool Success { get; set; }

    }
}
