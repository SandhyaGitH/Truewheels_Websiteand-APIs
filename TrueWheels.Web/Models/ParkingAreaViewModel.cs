using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{

    public class ParkingAreaViewModel
    {

        public decimal Main_Latitude { get; set; }


        public decimal Main_Longitude { get; set; }


        public int Distance { get; set; }


        public string FromDateTime { get; set; }

        public string ToDateTime { get; set; }

        public string ParkingClass { get; set; }

        public string OrderBy { get; set; }
        public ParkingAreaViewModel()
        {

        }


    }

    public class ParkingAreaResultViewModel
    {

        public string Parking_id { get; set; }

        public string parking_address { get; set; }

        public string street { get; set; }

        public string city { get; set; }
        public string state { get; set; }
        public string lattitude { get; set; }
        public string longitude { get; set; }
        public string GeoLoc { get; set; }
        public string DateTimeTo { get; set; }
        public string DateTimeFrom { get; set; }
        public string No_Of_Space_Avaiable { get; set; }
        public string Detail_ID { get; set; }
        public int BasicCharge { get; set; }
        public string ParkingClass { get; set; }


        


    }
}