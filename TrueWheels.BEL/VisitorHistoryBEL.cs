using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
    public class VisitorHistoryBEL
    {
        public int VisitorNumber { get; set; }
        public string VisitorID { get; set; }
        public string VisitorMailID { get; set; }
        public string SourceAddress { get; set; }
        public string DestinationAddress { get; set; }
        public DateTime DatetimeStamp { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }

        //public bool saveVisitorHistory(string source = null, string destination = null, string fromdatetime = null, string todatetime = null)
        //{

        //    string visitorid = "";
        //    string visitormailid = "";
        //    if (!(Session["userDetail"] == null))
        //    {
        //        visitorid = ((UserLoginDetailsViewModel)Session["userDetail"]).User_ID.ToString();
        //        visitormailid = ((UserLoginDetailsViewModel)Session["userDetail"]).Email_Id.ToString();
        //    }

        //    VisitorHistoryDAL visitorHistoryDAL = new VisitorHistoryDAL();
        //    VisitorHistoryBEL visitorHistoryBEL = new VisitorHistoryBEL();

        //    visitorHistoryBEL.VisitorID = visitorid;
        //    visitorHistoryBEL.VisitorMailID = visitormailid;
        //    visitorHistoryBEL.SourceAddress = source;
        //    visitorHistoryBEL.DestinationAddress = destination;
        //    visitorHistoryBEL.FromDate = fromdatetime;
        //    visitorHistoryBEL.ToDate = todatetime;

        //    Boolean flag = visitorHistoryDAL.VisitorHistory(visitorHistoryBEL);
        //    return flag;

        //}
    }
}
