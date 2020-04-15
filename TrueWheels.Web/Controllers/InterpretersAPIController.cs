using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using TrueWheels.BEL;
using TrueWheels.DAL;
using TrueWheels.Web.Models;


namespace TrueWheels.Web.Controllers
{

    public class abcd
    {
        public string phone { get; set; }
    }

    public class InterpretesAPIController : ApiController
    {
        // POST /api/notatwitterapi
        /*  public HttpResponseMessage <SignupViewModel> Post(SignupViewModel value)
          {
              if (ModelState.IsValid)
              {
                  notatweetRepository.InsertOrUpdate(value);
                  notatweetRepository.Save();

                  //Created!
                  var response = new HttpResponseMessage<NotATweet>(value, HttpStatusCode.Created);

                  //Let them know where the new NotATweet is
                  string uri = Url.Route(null, new { id = value.ID });
                  response.Headers.Location = new Uri(Request.RequestUri, uri);

                  return response;

              }
              throw new HttpResponseException(HttpStatusCode.BadRequest);
          }*/
        [Route("api1/signup/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage Signup(SignupViewModel vm)
        {
            var res = new HttpResponseMessage();
            JObject jContent = new JObject();
            Random ran = new Random();
            if (vm != null)
            {
                vm.Password = Secure.Encrypt(vm.Password);// Secure.Encrypt("TWuser@" + Convert.ToString(ran.Next(1000, 9999)));
                vm.ConfirmPassword = Secure.Encrypt(vm.Password);
                if (ModelState.IsValid)
                {
                    try
                    {
                        UserDetailsBEL objUserBEL = new UserDetailsBEL();

                        objUserBEL.Email_Id = vm.EmailId;
                        objUserBEL.Password = vm.Password;
                        objUserBEL.First_Name = vm.FirstName;
                        objUserBEL.Last_Name = vm.LastName;
                        objUserBEL.Phone_No1 = vm.Mobile;

                        UserDetailsDAL objUserDAL = new UserDetailsDAL();
                        UserLoginDetailsViewModel ulvm = new UserLoginDetailsViewModel(objUserDAL.AddUserDetails(objUserBEL));

                        if (ulvm.User_ID != "0")
                        {
                            res.StatusCode = HttpStatusCode.Created;
                            jContent = new JObject(
                                                new JProperty("result",
                                                    new JObject(
                                                        new JProperty("Success", true),
                                                        new JProperty("Message", "User added successfully"),
                                                        new JProperty("Transation", ulvm.User_ID))));
                        }
                        else
                        {
                            res.StatusCode = HttpStatusCode.BadRequest;
                            jContent = new JObject(
                                                new JProperty("result",
                                                    new JObject(
                                                        new JProperty("Success", false),
                                                        new JProperty("Message", ulvm.ErrorMessage),
                                                        new JProperty("ErrorMessage", ulvm.ErrorMessage),
                                                        new JProperty("Transation", ulvm.User_ID))));
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
            }
            res.Content = new StringContent(jContent.ToString());
            return res;

        }

        [Route("api1/login/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage Login(UserLogin vm)
        {
            var res = new HttpResponseMessage();
            JObject jContent;
            if (ModelState.IsValid)
            {


                try
                {
                    UserDetailsBEL objUserBEL = new UserDetailsBEL();

                    objUserBEL.Email_Id = vm.Email;
                    objUserBEL.Password = vm.Password;
                    objUserBEL.Phone_No1 = vm.Mobile;
                    objUserBEL.User_Name = vm.UserName;

                    UserDetailsDAL objUserDAL = new UserDetailsDAL();
                    UserLoginDetailsViewModel lvm = new UserLoginDetailsViewModel(objUserDAL.FunAuthenticateUser(objUserBEL));

                    if (lvm.User_ID != "0")
                    {
                        res.StatusCode = HttpStatusCode.Accepted;
                        jContent = new JObject(
                                            new JProperty("result",
                                                new JObject(
                                                    new JProperty("Success", true),
                                                    new JProperty("Email", lvm.Email_Id),
                                                    new JProperty("Mobile", lvm.Phone_No1),
                                                    new JProperty("Username", lvm.User_Name),
                                                    new JProperty("LastLogin", lvm.Last_Login),
                                                    new JProperty("UserId", lvm.User_ID))));
                    }
                    else
                    {
                        res.StatusCode = HttpStatusCode.Unauthorized;
                        jContent = new JObject(
                                            new JProperty("result",
                                                new JObject(
                                                    new JProperty("Success", false),
                                                    new JProperty("Message", lvm.ErrorMessage),
                                                    new JProperty("ErrorMessage", lvm.ErrorMessage),
                                                    new JProperty("UserId", lvm.User_ID))));
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
                                                   new JProperty("UserId", null))));

                }

                //return Request.CreateResponse<string>(HttpStatusCode.OK, mystring);


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


        [Route("api1/getAllPosts/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage GetAllPosts()
        {
            var res = new HttpResponseMessage();
            JObject jContent = new JObject();
            string json = string.Empty;

            try
            {
                UserDetailsBEL objUserBEL = new UserDetailsBEL();

                UserDetailsDAL objUserDAL = new UserDetailsDAL();


                json = JsonConvert.SerializeObject(objUserDAL.GetAllPosts());
                if (!string.IsNullOrEmpty(json))
                {
                    res.StatusCode = HttpStatusCode.Accepted;
                    var jsonArray = JArray.Parse(json);
                    //jContent = JObject.Parse(json);
                    jContent = new JObject(new JProperty("Success", true),
                                           new JProperty("result",
                                               jsonArray));
                    // return Json(locations, JsonRequestBehavior.AllowGet);

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
                                               new JProperty("UserId", null))));

            }

            //return Request.CreateResponse<string>(HttpStatusCode.OK, mystring);



            res.Content = new StringContent(jContent.ToString());

            return res;
        }

        [Route("api1/addPost/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage AddPost(AddPostViewModel vm)
        {
            var res = new HttpResponseMessage();
            JObject jContent = new JObject();
            Random ran = new Random();
            if (vm != null)
            {
                // vm.Password = Secure.Encrypt(vm.Password);// Secure.Encrypt("TWuser@" + Convert.ToString(ran.Next(1000, 9999)));
                //  vm.ConfirmPassword = Secure.Encrypt(vm.Password);
                if (ModelState.IsValid)
                {
                    try
                    {
                        PostsBEL objPostBEL = new PostsBEL();

                        objPostBEL.userId = vm.UserId;
                        objPostBEL.postName = vm.PostName;
                        objPostBEL.postDescription = vm.PostDescription;
                        objPostBEL.avatar = vm.Avatar;
                        // objPostBEL. = vm.Mobile;

                        UserDetailsDAL objUserDAL = new UserDetailsDAL();
                        PostsBEL ulvm = new PostsBEL(objUserDAL.AddNewPost(objPostBEL));

                        if (ulvm.postId != "0")
                        {
                            res.StatusCode = HttpStatusCode.Created;
                            jContent = new JObject(
                                                new JProperty("result",
                                                    new JObject(
                                                        new JProperty("Success", true),
                                                        new JProperty("Message", "Post added successfully"),
                                                        new JProperty("PostId", ulvm.postId))));
                        }
                        else
                        {
                            res.StatusCode = HttpStatusCode.BadRequest;
                            jContent = new JObject(
                                                new JProperty("result",
                                                    new JObject(
                                                        new JProperty("Success", false),
                                                        new JProperty("Message", ulvm.ErrorMessage),
                                                        new JProperty("ErrorMessage", ulvm.ErrorMessage),
                                                        new JProperty("PostId", ulvm.postId))));
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
                                                       new JProperty("PostId", null))));

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
                                                   new JProperty("PostId", null))));
                }
            }
            res.Content = new StringContent(jContent.ToString());
            return res;

        }

        [Route("api1/addComment/")]
        [HttpPost, HttpGet]
        public HttpResponseMessage AddComment(AddCommentViewModel vm)
        {
            var res = new HttpResponseMessage();
            JObject jContent = new JObject();
            Random ran = new Random();
            if (vm != null)
            {
                // vm.Password = Secure.Encrypt(vm.Password);// Secure.Encrypt("TWuser@" + Convert.ToString(ran.Next(1000, 9999)));
                //  vm.ConfirmPassword = Secure.Encrypt(vm.Password);
                if (ModelState.IsValid)
                {
                    try
                    {
                        CommentsBEL objCommentBEL = new CommentsBEL();

                        objCommentBEL.userId = vm.userId;
                        objCommentBEL.postId = vm.postId;
                        objCommentBEL.commentText = vm.commentText;
                        objCommentBEL.avatar = vm.Avatar;
                        // objPostBEL. = vm.Mobile;

                        UserDetailsDAL objUserDAL = new UserDetailsDAL();
                        CommentsBEL ulvm = new CommentsBEL(objUserDAL.AddComment(objCommentBEL));

                        if (ulvm.commentId != "0")
                        {
                            res.StatusCode = HttpStatusCode.Created;
                            jContent = new JObject(
                                                new JProperty("result",
                                                    new JObject(
                                                        new JProperty("Success", true),
                                                        new JProperty("Message", "Post added successfully"),
                                                        new JProperty("CommentId", ulvm.commentId))));
                        }
                        else
                        {
                            res.StatusCode = HttpStatusCode.BadRequest;
                            jContent = new JObject(
                                                new JProperty("result",
                                                    new JObject(
                                                        new JProperty("Success", false),
                                                        new JProperty("Message", ulvm.ErrorMessage),
                                                        new JProperty("ErrorMessage", ulvm.ErrorMessage),
                                                        new JProperty("CommentId", ulvm.commentId))));
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
                                                       new JProperty("CommentId", null))));

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
                                                   new JProperty("CommentId", null))));
                }
            }
            res.Content = new StringContent(jContent.ToString());
            return res;

        }




        [Route("api/IsRegistered/")]
        [HttpPost, HttpGet]

        public HttpResponseMessage IsRegistered(string Phone_no)
        {
            // string Phone_no = av.Mobile; //this.Request.Content.ReadAsStringAsync().Result;
            var res = new HttpResponseMessage();
            JObject jContent;
            if (!string.IsNullOrEmpty(Phone_no))//(ModelState.IsValid)
            {
                try
                {
                    UserDetailsDAL objUserDAL = new UserDetailsDAL();
                    UserLoginDetailsViewModel lvm = new UserLoginDetailsViewModel(objUserDAL.CheckPhoneNoExists(Phone_no));

                    if (lvm.User_ID != "0")
                    {
                        res.StatusCode = HttpStatusCode.Accepted;
                        jContent = new JObject(
                                           new JProperty("result",
                                               new JObject(
                                                   new JProperty("Success", true),
                                                   new JProperty("Email", lvm.Email_Id),
                                                   new JProperty("Mobile", lvm.Phone_No1),
                                                   new JProperty("Username", lvm.User_Name),
                                                   new JProperty("LastLogin", lvm.Last_Login),
                                                   new JProperty("UserId", lvm.User_ID),
                                                   new JProperty("Alternate_Email_Id", lvm.Alternate_Email_Id))));

                    }
                    else
                    {
                        res.StatusCode = HttpStatusCode.Unauthorized;
                        jContent = new JObject(
                                            new JProperty("result",
                                                new JObject(
                                                    new JProperty("Success", false),
                                                    new JProperty("Message", lvm.ErrorMessage),
                                                    new JProperty("ErrorMessage", lvm.ErrorMessage),
                                                    new JProperty("UserId", lvm.User_ID))));
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
                                                   new JProperty("UserId", null))));

                }

                //return Request.CreateResponse<string>(HttpStatusCode.OK, mystring);

            }
            else
            {
                res.StatusCode = HttpStatusCode.BadRequest;
                jContent = new JObject(
                                       new JProperty("result",
                                           new JObject(
                                               new JProperty("Success", false),
                                               new JProperty("Message", "Invalid Input"),
                                               new JProperty("ErrorMessage", "Phone_no Either null or Empty"),
                                               new JProperty("UserId", null))));
            }
            res.Content = new StringContent(jContent.ToString());
            return res;
            //throw new HttpResponseException(HttpStatusCode.BadRequest);
        }


      //  [Route("api/GetLocationHint/")]
      //  [HttpPost, HttpGet]
        /*       public HttpResponseMessage GetLocations(string Searchterm)
               {
                   var res = new HttpResponseMessage();
                   JObject jContent;
                   string json = string.Empty;
                   if (!string.IsNullOrEmpty(Searchterm))//(ModelState.IsValid)
                   {
                       // List<string> locations;
                       ParkingAreaDAL Pdal = new ParkingAreaDAL();
                       json = JsonConvert.SerializeObject(Pdal.GetAllLocation(Searchterm.ToUpper()));
                       if (!string.IsNullOrEmpty(json))
                       {
                           res.StatusCode = HttpStatusCode.Accepted;
                           var jsonArray = JArray.Parse(json);
                           //jContent = JObject.Parse(json);
                           jContent = new JObject(new JProperty("Success", true),
                                                  new JProperty("result",
                                                      jsonArray));
                           // return Json(locations, JsonRequestBehavior.AllowGet);

                       }
                       else
                       {
                           res.StatusCode = HttpStatusCode.Unauthorized;
                           jContent = new JObject(new JProperty("Success", false),
                                               new JProperty("result",
                                                   new JObject(
                                                       new JProperty("Message", "Not Found"),
                                                       new JProperty("ErrorMessage", "No data found")
                                                       )));
                       }
                   }
                   else
                   {
                       res.StatusCode = HttpStatusCode.BadRequest;
                       jContent = new JObject(
                                              new JProperty("result",
                                                  new JObject(
                                                      new JProperty("Success", false),
                                                      new JProperty("Message", "Invalid Input"),
                                                      new JProperty("ErrorMessage", "Searchterm Either null or Empty"),
                                                      new JProperty("UserId", null))));
                   }
                   res.Content = new StringContent(jContent.ToString());
                   return res;
               }
       */


      //  [Route("api/SearchLocation/")]
     //   [HttpPost, HttpGet]
        /*  public HttpResponseMessage SearchLocation(SearchParking Svm)
          {
              var lat = string.Empty;
              var lng = string.Empty;
              bool flag;
              string FDateTime = "0";
              string TDateTime = "0";
              string strOrderBy = "Space_Type";
              ParkingAreaBEL parking = new ParkingAreaBEL();
              string json = string.Empty;
              var res = new HttpResponseMessage();
              JObject jContent;
              if (ModelState.IsValid)
              {
                  if (string.IsNullOrEmpty(Svm.Destination) || string.IsNullOrEmpty(Svm.FromDatetime) || string.IsNullOrEmpty(Svm.ToDatetime))
                  {
                      if (string.IsNullOrEmpty(Svm.Destination))
                      {
                          lat = "0";
                          lng = "0";
                      }
                      else
                      {
                          LatLong.GetLatLongByLocation(Svm.Destination, ref lat, ref lng);
                      }
                      if (!(string.IsNullOrEmpty(Svm.FromDatetime) || string.IsNullOrEmpty(Svm.ToDatetime)))
                      {
                          FDateTime = Svm.FromDatetime;
                          TDateTime = Svm.ToDatetime;
                      }

                      parking.Distance = Convert.ToInt32(ConfigurationManager.AppSettings["Searchdistance"].ToString());
                      parking.FromDateTime = FDateTime;
                      parking.ToDateTime = TDateTime;
                      if (string.IsNullOrEmpty(Svm.ParkingClass))
                          parking.ParkingClass = "PC_A";
                      else
                          parking.ParkingClass = Svm.ParkingClass;// "PC_A";
                      parking.Main_Latitude = decimal.Parse(lat);
                      parking.Main_Longitude = decimal.Parse(lng);
                      parking.OrderBy = strOrderBy;

                      ParkingAreaDAL parkingDal = new ParkingAreaDAL();
                      List<AvailableParkingAreaResult> availableParkingList = parkingDal.GetAvailableParking(parking);
                      if (availableParkingList.Count > 0)
                      {

                          json = JsonConvert.SerializeObject(availableParkingList.ToArray());
                          res.StatusCode = HttpStatusCode.Accepted;
                          var jsonArray = JArray.Parse(json);
                          //jContent = JObject.Parse(json);
                          jContent = new JObject(new JProperty("Success", true),
                                                 new JProperty("result",
                                                     jsonArray));

                      }
                      else
                      {
                          res.StatusCode = HttpStatusCode.Unauthorized;
                          jContent = new JObject(
                                              new JProperty("Success", false),
                                              new JProperty("result",
                                                  new JObject(

                                                      new JProperty("Message", "Error Occured"),
                                                      new JProperty("ErrorMessage", "No Parking available at or nearby this location")
                                                      // ,new JProperty("UserId", "0")
                                                      )));
                      }
                  }
                  else
                  {
                      LatLong.GetLatLongByLocation(Svm.Destination, ref lat, ref lng);
                      parking.Distance = Convert.ToInt32(ConfigurationManager.AppSettings["Searchdistance"].ToString());
                      parking.FromDateTime = FDateTime;
                      parking.ToDateTime = TDateTime;
                      parking.ParkingClass = Svm.ParkingClass;// "PC_A";
                      parking.Main_Latitude = decimal.Parse(lat);
                      parking.Main_Longitude = decimal.Parse(lng);
                      parking.OrderBy = strOrderBy;

                      ParkingAreaDAL parkingDal = new ParkingAreaDAL();
                      List<AvailableParkingAreaResult> availableParkingList = parkingDal.GetAvailableParking(parking);

                      if (availableParkingList.Count > 0)
                      {
                          json = JsonConvert.SerializeObject(availableParkingList);
                          res.StatusCode = HttpStatusCode.Accepted;
                          //res.Content = new StringContent(json);
                          var jsonArray = JArray.Parse(json);
                          jContent = new JObject(new JProperty("Success", true),
                                                new JProperty("result",
                                                    jsonArray));
                          // jContent = JObject.Parse(json);
                          //jContent = new JObject(new JProperty("Success", true),
                          //                       new JProperty("result",
                          //                           new JObject(JObject.Parse(json))));

                      }
                      else
                      {
                          res.StatusCode = HttpStatusCode.Unauthorized;
                          jContent = new JObject(
                                              new JProperty("Success", false),
                                              new JProperty("result",
                                                  new JObject(

                                                      new JProperty("Message", "Error Occured"),
                                                      new JProperty("ErrorMessage", "No Parking available at or nearby this location")
                                                      // ,new JProperty("UserId", "0")
                                                      )));
                      }
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
      */
     }
}