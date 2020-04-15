using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace TrueWheels.Web.Models
{
    public class SearchParking
    {
        [Required(ErrorMessage = "Please Enter the destination")]
        public string Destination { get; set; }
        public string FromDatetime { get; set; }
        public string ToDatetime { get; set; }

        public string ParkingClass { get; set; }
    }
}