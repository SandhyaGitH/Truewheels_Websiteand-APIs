using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{
    public class LocateParkingViewModel
    {
        public string StartLat { get; set; }
        public string StartLong { get; set; }
        public string EndLat { get; set; }
        public string EndtLat { get; set; }

        public string AddressName { get; set; }

        public string Discription { get; set; }

    }
}