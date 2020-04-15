using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using TrueWheels.BEL;
using TrueWheels.DAL;
using TrueWheels.Web.Models;
using Newtonsoft.Json.Linq;
using System.Web;

namespace TrueWheels.Web.Controllers
{
    public class UserDashBoardAPIController : ApiController
    {
        [Route("api/ViewProfile/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage ViewProfile(string User_id)
        {
            string json = string.Empty;
            var res = new HttpResponseMessage();
            JObject jContent;
            if (!string.IsNullOrEmpty(User_id))
            {
                try
                {
                    UserDetailsDAL objUserDAL = new UserDetailsDAL();
                    List<DashBoardBEL> UserMenus = objUserDAL.GetMenuMapping(User_id);
                    PersonalinfoBEL objPersonalInfo = objUserDAL.GetProfileInfo(User_id);
                    objPersonalInfo.profilePic_Path = objPersonalInfo.User_Id + ".png";
                    objPersonalInfo.Full_Name = objPersonalInfo.First_Name + " " + objPersonalInfo.Last_Name;
                    objPersonalInfo.MenuList = UserMenus;
                    if (objPersonalInfo.User_Id == 0)
                    {
                        res.StatusCode = HttpStatusCode.Unauthorized;
                        jContent = new JObject(
                                            new JProperty("Success", false),
                                            new JProperty("result",
                                                new JObject(

                                                    new JProperty("Message", ""),
                                                    new JProperty("ErrorMessage", objPersonalInfo.ErrorMessage == null ? "" : objPersonalInfo.ErrorMessage),
                                                    new JProperty("UserId", "0"))));
                    }
                    else
                    {
                        json = JsonConvert.SerializeObject(objPersonalInfo);
                        res.StatusCode = HttpStatusCode.Accepted;
                        //res.Content = new StringContent(json);
                        jContent = JObject.Parse(json);
                        jContent = new JObject(new JProperty("Success", true),
                                               new JProperty("result",
                                                   new JObject(JObject.Parse(json))));
                    }
                    //jContent = new JObject(res.Content);
                    // return res;
                }
                catch (Exception ex)
                {
                    res.StatusCode = HttpStatusCode.BadRequest;
                    jContent = new JObject(
                                                  new JProperty("Success", false),
                                                  new JProperty("result",
                                                  new JObject(
                                                   new JProperty("Message", ex.Message),
                                                   new JProperty("ErrorMessage", ex.InnerException.ToString()),
                                                   new JProperty("UserId", null))));

                    //  return res;
                }
            }
            //throw new HttpResponseException(HttpStatusCode.BadRequest);
            else
            {
                res.StatusCode = HttpStatusCode.Unauthorized;
                jContent = new JObject(
                                    new JProperty("Success", false),
                                    new JProperty("result",
                                        new JObject(

                                            new JProperty("Message", "Invalid Input"),
                                            new JProperty("ErrorMessage", "User_id is Either empty or null"),
                                            new JProperty("UserId", "0"))));
                // res.Content = new StringContent(jContent.ToString());
            }
            res.Content = new StringContent(jContent.ToString());
            return res;



        }



        [Route("api/upateprofile/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage UpateProfile(PersonalinfoBEL profileInfo)//, HttpPostedFileBase profilePic
        {
            string json = string.Empty;
            var res = new HttpResponseMessage();
            JObject jContent;
            if (ModelState.IsValid)
            {
                try
                {
                    UserDetailsDAL objUserDAL = new UserDetailsDAL();
                    // List<DashBoardBEL> UserMenus = objUserDAL.GetMenuMapping((((TrueWheels.Web.Models.UserLoginDetailsViewModel)(Session["userDetail"])).User_ID).ToString());
                    if (profileInfo.NewPassword == null)
                    {
                        profileInfo.NewPassword = profileInfo.Password;
                    }
                    //if (profileInfo.MobileNo == null)
                    //{
                    //    profileInfo.NewPassword = profileInfo.Password;
                    //}

                    UserMaintenanceViewModel objUserMaintenance = new UserMaintenanceViewModel();

                    objUserMaintenance.Personalinfo = objUserDAL.UpdateProfileInfo(profileInfo);
                    objUserMaintenance.Personalinfo.profilePic_Path = objUserMaintenance.Personalinfo.User_Id + ".png";
                    objUserMaintenance.Personalinfo.Full_Name = objUserMaintenance.Personalinfo.First_Name + " " + objUserMaintenance.Personalinfo.Last_Name;
                    // ViewBag.DashBoardMenu = UserMenus;
                    if (!string.IsNullOrEmpty(objUserMaintenance.Personalinfo.ErrorMessage))
                    {
                        res.StatusCode = HttpStatusCode.Unauthorized;
                        jContent = new JObject(
                                            new JProperty("Success", false),
                                            new JProperty("result",
                                                new JObject(

                                                    new JProperty("Message", "Error Occured"),
                                                    new JProperty("ErrorMessage", objUserMaintenance.Personalinfo.ErrorMessage),
                                                    new JProperty("UserId", "0"))));
                    }
                    else
                    {
                        json = JsonConvert.SerializeObject(objUserMaintenance);
                        res.StatusCode = HttpStatusCode.Accepted;
                        //res.Content = new StringContent(json);
                        jContent = JObject.Parse(json);
                        jContent = new JObject(new JProperty("Success", true),
                                               new JProperty("result",
                                                   new JObject(JObject.Parse(json))));
                    }


                }
                catch (Exception ex)
                {
                    res.StatusCode = HttpStatusCode.BadRequest;
                    jContent = new JObject(
                                           new JProperty("result",
                                               new JObject(
                                                   new JProperty("Success", false),
                                                   new JProperty("Message", ex.Message),
                                                   new JProperty("ErrorMessage", ex.InnerException.ToString()),
                                                   new JProperty("Transation", null))));

                }
            }
            else
            {
                var errorList = (from item in ModelState
                                 where item.Value.Errors.Any()
                                 select item.Value.Errors[0].ErrorMessage).ToList();
                res.StatusCode = HttpStatusCode.BadRequest;
                jContent = new JObject(
                                       new JProperty("result",
                                           new JObject(
                                               new JProperty("Success", false),
                                               new JProperty("Message", "Invalid Input"),
                                               new JProperty("ErrorMessage", errorList),
                                               new JProperty("Transation", null))));
            }
            res.Content = new StringContent(jContent.ToString());
            return res;

        }
    }
}

