using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using TrueWheels.BEL;
using TrueWheels.DAL;
using TrueWheels.Web.Models;

namespace TrueWheels.Web.Controllers
{
    public class ForgotPasswordController : Controller
    {
        //
        // GET: /ForgotPassword/
        private static string className = "ForgotPasswordController";
        public ActionResult ChangePassword(UpdateCred UP)
        {
            UserDetailsBEL objUserBEL = new UserDetailsBEL();
            if (Session["ForgotMobleNum"] != null)
            {
                objUserBEL.Phone_No1 = Convert.ToString(Session["ForgotMobleNum"]);
                Session["ForgotMobleNum"] = null;
                objUserBEL.Password = Secure.Encrypt(UP.Password);
                UserDetailsDAL objUserDAL = new UserDetailsDAL();
                Transaction tr = objUserDAL.UpdateCred(objUserBEL);
                if (tr.Success == true)
                {
                    return RedirectToAction("Login", "TrueWheelsUser");
                    //return RedirectToAction("Index", "UserDashbaord");
                }
                else
                {
                    ModelState.AddModelError("", tr.Success.ToString());
                }
            }
            return View("Index","ForgotPassword");
        }


        //  [HttpPost]
        //public ActionResult ForgotPassword(UserLogin ul)
        //{
        //    UserDetailsBEL objUserBEL = new UserDetailsBEL();

        //    if (ul.UserName.Contains('@'))
        //        objUserBEL.Email_Id = ul.UserName;
        //    else
        //        objUserBEL.Phone_No1 = ul.UserName;
        //    objUserBEL.Password = ul.Password;
        //    UserDetailsDAL objUserDAL = new UserDetailsDAL();

        //    if (ModelState.IsValid)
        //    {
        //        Transaction tr  = objUserDAL.UpdateCred(objUserBEL);
        //        if (tr.Success == true)
        //        {
        //            FormsAuthentication.SetAuthCookie(objUserBEL.User_ID, true);
        //            return RedirectToAction("Index", "UserDashbaord");
        //        }
        //        else
        //        {
        //            ModelState.AddModelError("", tr.Success.ToString());
        //        }
        //    }
        //    else
        //    {
        //        ModelState.AddModelError("", "Login data is incorrect!");
        //    }
        //    return View();
        //}
	}
}