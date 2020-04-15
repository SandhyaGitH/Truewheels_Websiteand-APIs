using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
    public class RegsiterParkingAreaResult
    {
        public int Parking_Id { get; set; }

        public string ErrorMessage { get; set; }
        public bool Success { get; set; }
    }
}
