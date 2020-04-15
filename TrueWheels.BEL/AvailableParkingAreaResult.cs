using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
  public  class AvailableParkingAreaResult
    {
        public string Parking_id { get; set; }
        public string parking_address { get; set; }
        public string     street { get; set; }

        public string  city { get; set; }
        public string  state { get; set; }
        public string  lattitude { get; set; }
        public string  longitude { get; set; }
        public string  GeoLoc { get; set; }
        public string  DateTimeTo { get; set; }
        public string  DateTimeFrom { get; set; }
        public string  No_Of_Space_Avaiable { get; set; }
        public string  Detail_ID { get; set; }
        public int     BasicCharge { get; set; }
        public string  ParkingClass { get; set; }

        public string Distance { get; set; }
        public int Rating { get; set; }
        public string Description { get; set; }

        public string Facilities { get; set; }

        public string SpaceType { get; set; }

        public string PropertyType { get; set; }
        public string OrderBy { get; set; }

        public string ErrorMessage { get; set; }
        public bool Success { get; set; }

    }
}
