using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TrueWheels.Web.Models
{
    public class OTPViewModel
    {
        public OTPViewModel()
        {
           // CallingSource = callingSource;
        }
        //public OTPViewModel( string callingSource)
        //{
        //    CallingSource = callingSource;
        //}
        public string OTP { get; set; }

        public string CallingSource { get; set; }
    }
}