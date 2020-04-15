using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using System.Web.Security;
using TrueWheels.BEL;
using TrueWheels.DAL;
//using TrueWheels.DEL;
using TrueWheels.Web.Models;

namespace TrueWheels.Web.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();

        }

        public ActionResult test()
        {
            return View();
        }

        public ActionResult UserDashBoard()
        {
            return View();
        }

        public ActionResult CreateSpace()
        {
            return View();
        }


        public static dynamic GEOCodeAddress(string Address, string country)
        {
            var address = String.Format("http://maps.google.com/maps/api/geocode/json?address={0}&sensor=true&components=country:{1}", Address.Replace(" ", "+"), country);
            var result = new System.Net.WebClient().DownloadString(address);
            JavaScriptSerializer jss = new JavaScriptSerializer();
            return jss.Deserialize<dynamic>(result);
        }



        [HttpPost]
        public ActionResult Index(string destination, string DateTimeFrom, string ToTimeFrom)
        {
            var lat = string.Empty;
            var lng = string.Empty;
            bool flag;
            string FDateTime = "0";
            string TDateTime = "0";
            string strOrderBy = "Space_Type";
            if (destination == string.Empty || DateTimeFrom == string.Empty || ToTimeFrom == string.Empty || DateTimeFrom == null)
            {
                if (destination == string.Empty)
                {
                    lat = "0";
                    lng = "0";
                }
                else
                {
                    GetLatLongByLocation(destination, ref lat, ref lng);
                }
                if ((DateTimeFrom != string.Empty && DateTimeFrom != null) || (ToTimeFrom != string.Empty && ToTimeFrom != null))
                {
                    FDateTime = DateTimeFrom;
                    TDateTime = ToTimeFrom;
                }

                ParkingAreaViewModel vm = new ParkingAreaViewModel
                {
                    Distance = Convert.ToInt32(ConfigurationManager.AppSettings["Searchdistance"].ToString()),
                    FromDateTime =FDateTime,
                    ToDateTime = TDateTime,
                    ParkingClass = "PC_A",
                    Main_Latitude = decimal.Parse(lat),
                    Main_Longitude = decimal.Parse(lng),
                    OrderBy = strOrderBy
                };

                TempData["ParkingAreaViewModel"] = vm;
                 return RedirectToAction("Index",
                            "ParkingArea",
                            vm);
            }
            else
            {
                GetLatLongByLocation(destination, ref lat, ref lng);

                ParkingAreaViewModel vm = new ParkingAreaViewModel
                {
                    Distance = Convert.ToInt32(ConfigurationManager.AppSettings["Searchdistance"].ToString()),
                    FromDateTime =DateTimeFrom,
                    ToDateTime = ToTimeFrom,
                    ParkingClass = "PC_A",
                    Main_Latitude = decimal.Parse(lat),
                    Main_Longitude = decimal.Parse(lng),
                };

                TempData["ParkingAreaViewModel"] = vm;
               // flag = saveVisitorHistory(DateTimeFrom, null, destination, null);
                return RedirectToAction("Index",
                            "ParkingArea",
                            vm);
            }



        }

        private static void GetLatLongByLocation(string destination, ref string lat, ref string lng)
        {
            try
            {
                var address = String.Format("http://maps.google.com/maps/api/geocode/json?address={0}&sensor=true&components=country:{1}", destination.Replace(" ", "+"), "India");
                var result = new System.Net.WebClient().DownloadString(address);
                var jo = JObject.Parse(result);
                result = jo["results"].ToString();
                var ja = JArray.Parse(result);
                jo = JObject.Parse(ja[0].ToString());
                result = jo["geometry"]["location"].ToString();
                var latObj = JObject.Parse(result.ToString());
                lat = latObj["lat"].ToString();
                lng = latObj["lng"].ToString();
            }
            catch
            { }
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

       /* public JsonResult GetLocations(string term)
        {
            List<string> locations;
            ParkingAreaDAL Pdal = new ParkingAreaDAL();
            locations = Pdal.GetAllLocation(term);
            return Json(locations, JsonRequestBehavior.AllowGet);
        }*/
    }
}