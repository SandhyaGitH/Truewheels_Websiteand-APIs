using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using TrueWheels.BEL;
using TrueWheels.DAL;
using TrueWheels.Web.Models;

namespace TrueWheels.Web.Controllers
{
    public class OTPController : Controller
    {
        //

        // GET: /OTP/
        public ActionResult VerifyOTP()
        {
            
            return View();
        }

        //
        // GET: /OTP/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        //
        // GET: /OTP/Create
        public ActionResult Create()
        {
            return View();
        }

        //
        // POST: /OTP/Create
        [HttpPost]
      //  [ValidateAntiForgeryToken]
        public ActionResult VerifyOTP(OTPViewModel OVM)
        {
            try
            {
               
                // TODO: Add insert logic here
                if (Session["OTP"] != null && OVM.OTP!=null &&OVM.OTP!=string.Empty)
                {
                    if (Session["OTP"].ToString() == OVM.OTP.ToString())
                    {
                        Session["OTPConfirmed"] = "True";
                        if (TempData["OTPSource"] != null && Convert.ToString(TempData["OTPSource"]) == "ForgotPassword")
                            return RedirectToAction("ForgotPassword","TrueWheelsUser");
                        else
                            return RedirectToAction("Index", "UserDashbaord");
                    }
                    else
                    {
                        ViewBag.Error = "Invalid OTP";
                        return View();
                        
                    }
                   // return RedirectToAction("Login", "TrueWheelsUser");
                }
                return View();
               
            }
            catch
            {
                return View();
            }
        }

        public ActionResult ResendOTP()
        {
            try
            {
                List<string> OTPList = new List<string>();
                OTPBEL OTPBel = new OTPBEL();
                OTPList = OTPBel.GetAndSendOTP(Convert.ToInt64(((TrueWheels.Web.Models.UserLoginDetailsViewModel)(Session["userDetail"])).Phone_No1));
                if (OTPList != null)
                {
                    if (Convert.ToBoolean(OTPList[2]))
                    {
                        // Session[OTPList[2]+"_OTP"] = OTPList[0];
                        Session["OTP"] = OTPList[0];
                    }
                }

                return RedirectToAction("VerifyOTP", "OTP");

                
               
            }
            catch
            {
                return RedirectToAction("VerifyOTP", "OTP");
            }
        }
        

        private void sendOTP()
        {

            String URI = "http://www.puretext.us" +
    "/service/sms/send?" +
      "fromNumber=" + "917292024469" +
      "&toNumber=" + "918527654844" +
      "&smsBody=" + System.Net.WebUtility.UrlEncode("Your OTP is 123456") +
      "&apiToken=" + "testaccount";

  try
  {
    WebRequest req = WebRequest.Create(URI);
    WebResponse resp = req.GetResponse();
    var sr = new System.IO.StreamReader(resp.GetResponseStream());
   // return sr.ReadToEnd().Trim();
 
        //        // SMSService4India 
        //SMSService4India.net.webservicex.www.SendSMS smsIndia= 
        //  new SMSService4India.net.webservicex.www.SendSMS();
        //SmsTest.com.webservicex.www.SendSMSWorld smsWorld =  
        //  new SmsTest.com.webservicex.www.SendSMSWorld();
        //if(rdoType.SelectedValue == "1")
        //  smsIndia.SendSMSToIndia(txtMobileNo.Text.Trim(), 
        //    txtEmailId.Text.Trim(), txtMessage.Text);
        //else 
        //  smsWorld.sendSMS(txtEmailId.Text.Trim(), 
        //   txtCountryCode.Text.Trim(), txtMobileNo.Text.Trim(), 
        //   txtMessage.Text);
        //lblMessage.Visible = true;
        //lblMessage.Text="Message Send Succesfully";
      }
      catch(Exception ex)
      {
          ErrorLog.Log(this.GetType().Name, MethodBase.GetCurrentMethod().Name, ex.Message.ToString(), Session["userPhoneNo/Email"] != null ? Session["userPhoneNo/Email"].ToString() : "");
        //lblMessage.Visible = true;
        //lblMessage.Text="Error in Sending message"+ex.ToString();
      }
   

        }

        public bool sendMessage(long number, string message)
        {
            Stream data = null;
            StreamReader reader = null;
            try
            {
                long _number = number;
                string _message = message;
                WebClient client = new WebClient();
                long phno = _number;
                string massage = _message;
                string baseurl = "http://bhashsms.com/api/sendmsg.php?user=lardeal&pass=123456&sender=LRDEAL&phone=" + _number + "&text=" + _message + "&priority=ndnd&stype=normal";
                data = client.OpenRead(baseurl);
                reader = new StreamReader(data); string s = reader.ReadToEnd();
                data.Close();
                reader.Close();
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
            finally
            {
                data.Close();
                reader.Close();

            }

        }
        //
        // GET: /OTP/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        //
        // POST: /OTP/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection)
        {
            try
            {
                // TODO: Add update logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        //
        // GET: /OTP/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        //
        // POST: /OTP/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                // TODO: Add delete logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

       
    }
}
