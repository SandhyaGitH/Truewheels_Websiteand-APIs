using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using TrueWheels.BEL;
using TrueWheels.DAL;
using TrueWheels.Web.Models;

namespace TrueWheels.Web.Controllers
{
    public class TrueWheelsUserController : Controller
    {
        //
        // GET: /TrueWheelsUser/
        public ActionResult Index()
        {
           // FormsAuthentication.
           // DLTrueWheelsUser dal = new DLTrueWheelsUser();
           // List<BETrueWheelsUser> employees = dal.Users.ToList();
            if (User.Identity.IsAuthenticated)
                return View();
            else
                return View("Index", "Home");

        }

        //User registration
        public ActionResult Create()
        {
            UserRegistrationViewModel user = new UserRegistrationViewModel();
            return View(user);
        }

        public ActionResult SignUp()
        {
            return View();
        }

        [HttpPost]
        public ActionResult SignUp(SignupViewModel vm)
        {
            UserDetailsBEL objUserBEL = new UserDetailsBEL();

            objUserBEL.Email_Id = vm.EmailId;
            objUserBEL.Password = Secure.Encrypt(vm.Password);
            objUserBEL.First_Name = vm.FirstName;
            objUserBEL.Last_Name = vm.LastName;
            objUserBEL.Phone_No1 = vm.Mobile;

            UserDetailsDAL objUserDAL = new UserDetailsDAL();
            List<string> OTPList = new List<string>();

            if (ModelState.IsValid)
            {

                UserLoginDetailsViewModel LDvm = new UserLoginDetailsViewModel(objUserDAL.AddUserDetails(objUserBEL));
                if (string.IsNullOrEmpty(LDvm.ErrorMessage)  && (LDvm.User_ID != "" || LDvm.User_ID != string.Empty))
                {
                    //FormsAuthentication.SetAuthCookie(objUserBEL.User_ID, true);
                    Session["userDetail"] = LDvm;
                   // return RedirectToAction("Index", "UserDashbaord");
                    OTPBEL OTPBel = new OTPBEL ();
                   OTPList= OTPBel.GetAndSendOTP(Convert.ToInt64(objUserBEL.Phone_No1));
                   if (OTPList != null)
                   {
                       if (Convert.ToBoolean(OTPList[2]))
                       {
                          // Session[OTPList[2]+"_OTP"] = OTPList[0];
                           Session["OTP"] = OTPList[0];
                       }
                   }
                       
                    return RedirectToAction("VerifyOTP", "OTP");
                  //  return RedirectToAction("Login", "TrueWheelsUser");
                }
                else
                {
                    ModelState.AddModelError("", LDvm.ErrorMessage.ToString());
                }

            }
            else
            {
               // Response.Write(ModelState.SelectMany(x => x.Value.Errors.Select(z => z.Exception)));
                ModelState.AddModelError("", "Data is incorrect!");
            }
            return View();
        }

        [HttpPost]
        public bool SignUpWithFB(string FirstName, string LastName, string EmailId, string Fb_id)
        {
            UserDetailsBEL objUserBEL = new UserDetailsBEL();

            objUserBEL.Email_Id = EmailId;
            objUserBEL.Password = FirstName + "@Truewheels";
            objUserBEL.First_Name = FirstName;
            objUserBEL.Last_Name = LastName;
            objUserBEL.SignUp_Mode_ID = "FB";
            objUserBEL.Phone_No1 = "NA";
            objUserBEL.Other_ID = Fb_id;

            UserDetailsDAL objUserDAL = new UserDetailsDAL();
            UserLoginDetailsViewModel LDvm = new UserLoginDetailsViewModel(objUserDAL.AddUserDetails(objUserBEL));
            if (string.IsNullOrEmpty(objUserBEL.ErrorMessage) && (objUserBEL.User_ID != "" || objUserBEL.User_ID != string.Empty))
            {
                //FormsAuthentication.SetAuthCookie(objUserBEL.User_ID, true);
                Session["userDetail"] = LDvm;
                return true;
               // return RedirectToAction("Index", "UserDashbaord");
            }
            else
            {
                return false;
                ModelState.AddModelError("", objUserBEL.ErrorMessage.ToString());
            }

                //UserDetailsBEL tr = objUserDAL.AddUserDetails(objUserBEL);
                //if (tr.ErrorMessage == "")
                //{

                //    //FormsAuthentication.SetAuthCookie(objUserBEL.User_ID, true);
                //    return true;
                //    //return RedirectToAction("Index", "UserDashbaord");
                //}
                //else
                //{
                //    return false;
                //    ModelState.AddModelError("", tr.ErrorMessage.ToString());
                //}
           
           // return View();
        }


        [HttpPost]
        public ActionResult Login(UserLogin ul)
       {
            
            UserDetailsBEL objUserBEL = new UserDetailsBEL();
                 
         
           
            if (ModelState.IsValid)
            {
                if (ul.UserName.Contains('@'))
                    objUserBEL.Email_Id = ul.UserName;
                else
                    objUserBEL.Phone_No1 = ul.UserName;
                objUserBEL.Password = Secure.Encrypt(ul.Password);


                UserDetailsDAL objUserDAL = new UserDetailsDAL();
                //UserDetailsBEL tr = 
                UserLoginDetailsViewModel vm = new UserLoginDetailsViewModel(objUserDAL.FunAuthenticateUser(objUserBEL));
                //UserLoginDetailsViewModel vm = new UserLoginDetailsViewModel(objUserDAL.CheckPhoneNoExists(objUserBEL.Phone_No1));
                if (vm.ErrorMessage==string.Empty)
                {
                    FormsAuthentication.SetAuthCookie(objUserBEL.User_ID,true);
                    Session["userDetail"] = vm;
                    Session["userPhoneNo/Email"] =!string.IsNullOrWhiteSpace(vm.Phone_No1)? vm.Phone_No1: vm.Email_Id;

                    string tempdata;
                    if (TempData["RequestedUrl"] != null)
                    {
                        tempdata=Convert.ToString(TempData["RequestedUrl"]);
                        TempData["RequestedUrl"] = null;
                        //need to modify later
                        return Redirect("http://localhost/"+tempdata);
                       // return  RedirectToAction(tempdata, "parkingArea"); 
                    }
                    else
                        return RedirectToAction("Index", "UserDashbaord");
                }
                else
                {
                    ModelState.AddModelError("", vm.ErrorMessage.ToString());
                }
            }
            else
            {
                ModelState.AddModelError("", "Login data is incorrect!");
            }
            return View();

        }

        public ActionResult Login()
        {
            return View("Login");
        }
        [HttpPost]
        public ActionResult ForgotPassword(UpdateCred UP)
        {
            List<string> OTPList = new List<string>(); 
            OTPBEL OTPBel = new OTPBEL();
           // OTPViewModel ovm = new OTPViewModel("ForgotPassword");
            TempData["OTPSource"] = "ForgotPassword";
            OTPList = OTPBel.GetAndSendOTP(Convert.ToInt64(UP.Mobile));
            if (OTPList != null)
            {
                if (Convert.ToBoolean(OTPList[2]))
                {
                    // Session[OTPList[2]+"_OTP"] = OTPList[0];
                    Session["OTP"] = OTPList[0];
                }
                Session["ForgotMobleNum"] = UP.Mobile;
            }

            return RedirectToAction("VerifyOTP", "OTP");
            //return View();
        }
        [HttpGet]
        public ActionResult ForgotPassword()
        {
            return View();
        }
        public ActionResult LogOff()
        {
            Session.Clear();
            //ResultExecutingContext filterContext;
            //filterContext.HttpContext.Response.RemoveOutputCacheItem();//.HttpContext.Response.RemoveOutputCacheItem();
            //Response.Cache.SetExpires(DateTime.Now);
            return RedirectToAction("Login", "TrueWheelsUser");
        }
	}
}