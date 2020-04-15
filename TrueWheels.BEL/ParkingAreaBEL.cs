using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
  public  class ParkingAreaBEL
    {
        public decimal Main_Latitude { get; set; }


        public decimal Main_Longitude { get; set; }


        public int Distance { get; set; }


        public string FromDateTime { get; set; }

        public string ToDateTime { get; set; }

        public string ParkingClass { get; set; }

        public string OrderBy { get; set; }

        public string Description { get; set; }
      
     
    }
}
