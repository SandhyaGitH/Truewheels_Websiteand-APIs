using Microsoft.ApplicationBlocks.Data;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TrueWheels.BEL;

namespace TrueWheels.DAL
{
    public class UserDetailsDAL
    {
        string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ConnectionString;
        Transaction transaction = new Transaction();

        public UserDetailsBEL FunAuthenticateUser(UserDetailsBEL Ubal)
        {
            UserDetailsBEL Userdetail = new UserDetailsBEL();
            //SqlConnection conn = new SqlConnection();
            DataSet ds = null;
            try
            {
                SqlParameter[] SqlParms = new SqlParameter[6];

                SqlParms[0] = new SqlParameter("@User_Id", SqlDbType.NVarChar, 50);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = Ubal.User_ID;

                SqlParms[1] = new SqlParameter("@Phone_No1", SqlDbType.NVarChar, 50);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = Ubal.Phone_No1;


                SqlParms[2] = new SqlParameter("@Email_Id", SqlDbType.NVarChar, 50);
                SqlParms[2].Direction = ParameterDirection.Input;
                SqlParms[2].Value = Ubal.Email_Id;


                SqlParms[3] = new SqlParameter("@Password", SqlDbType.NVarChar, 500);
                SqlParms[3].Direction = ParameterDirection.Input;
                SqlParms[3].Value = Secure.Encrypt(Ubal.Password);



                SqlParms[4] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[4].Direction = ParameterDirection.Output;

                SqlParms[5] = new SqlParameter("@UserId", SqlDbType.NVarChar, 20);
                SqlParms[5].Direction = ParameterDirection.Output;



                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "SP_LoginUser", SqlParms);
                //&& Convert.ToString(SqlParms[5].Value) != "0"
                if (Convert.ToString(SqlParms[4].Value) == string.Empty)
                {
                    Userdetail.User_ID = ds.Tables[0].Rows[0]["User_ID"].ToString();
                    // Userdetail.Alternate_Email_Id = ds.Tables[0].Rows[0]["Alternate_Email_Id"].ToString();
                    Userdetail.Email_Id = ds.Tables[0].Rows[0]["Email_Id"].ToString();
                    // Userdetail.First_Name = ds.Tables[0].Rows[0]["First_Name"].ToString();
                    Userdetail.Last_Login = ds.Tables[0].Rows[0]["Last_Login"].ToString();
                    // Userdetail.Last_Name = ds.Tables[0].Rows[0]["Last_Name"].ToString();
                    //Userdetail.Owner_Address = ds.Tables[0].Rows[0]["Owner_Address"].ToString();
                    Userdetail.Phone_No1 = ds.Tables[0].Rows[0]["Phone_No1"].ToString();
                    //  Userdetail.Phone_No2 = ds.Tables[0].Rows[0]["Phone_No2"].ToString();
                    // Userdetail.SignUp_Mode_ID = ds.Tables[0].Rows[0]["SignUp_Mode_ID"].ToString();
                    Userdetail.User_Name = ds.Tables[0].Rows[0]["User_Name"].ToString();
                    Userdetail.ErrorMessage = string.Empty;

                    // ResultDTO. = Convert.ToString(SqlParms[5].Value);
                }
                else
                {
                    Userdetail.User_Name = "";
                    Userdetail.User_ID = "0";
                    Userdetail.ErrorMessage = Convert.ToString(SqlParms[4].Value);
                }

            }
            catch (Exception ex)
            {
                Userdetail.User_Name = "";
                Userdetail.User_ID = "0";
                Userdetail.ErrorMessage = ex.Message.ToString();

            }
            return Userdetail;

        }
        
        #region GetAllPosts
        public List<PostsBEL> GetAllPosts()
        {
            List<PostsBEL> Posts = new List<PostsBEL>();
            try
            {

                DataSet ds = null;

                SqlParameter[] SqlParms = new SqlParameter[1];
               
                SqlParms[0] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[0].Direction = ParameterDirection.Output;

                //SqlParms[7] = new SqlParameter("@UserId", SqlDbType.NVarChar, 20);
                //SqlParms[7].Direction = ParameterDirection.Output;



                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Get_AllPosts", SqlParms);

                if (ds != null && ds.Tables[0].Rows.Count > 0)
                {
                    CommentsBEL c = new CommentsBEL();
                    /*Posts = (from DataRow Post in ds.Tables[0].Rows
                                  
                                 select new PostsBEL
                                 {
                                     /* userId = Convert.ToString(parkingrow["User_id"]),
                                      postId = Convert.ToString(parkingrow["Menu_id"]),
                                      postDescription = Convert.ToString(parkingrow["Menu_description"]),
                      
                                    post.a Comments

                                     Success = true,
                                     ErrorMessage = "",
                                 }
                                    ).ToList<PostsBEL>(); 
                */
                    PostsBEL post;// = new PostsBEL();
                    List<CommentsBEL> comments;// = new List<CommentsBEL>();
                    for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                    {
                        post = new PostsBEL();
                        comments = new List<CommentsBEL>();
                        post.postId = ds.Tables[0].Rows[i]["Post_id"].ToString();
                        post.postName = ds.Tables[0].Rows[i]["PostName"].ToString();
                        post.postDescription = ds.Tables[0].Rows[i]["PostDescription"].ToString();
                        post.postedByUName = ds.Tables[0].Rows[i]["postedby"].ToString();
                        post.userId = ds.Tables[0].Rows[i]["postedByUid"].ToString();
                        post.dateCreated = ds.Tables[0].Rows[i]["PostCreatedOn"].ToString();
                        post.avatar = ds.Tables[0].Rows[i]["PostAvatar"].ToString();
                        post.likes = ds.Tables[0].Rows[i]["likes"].ToString();
                        post.Success = true;
                        //c = new CommentsBEL();
                        for (int k = i; k < ds.Tables[0].Rows.Count; k++)
                        {  if (post.postId == ds.Tables[0].Rows[k]["CPostId"].ToString())
                            { c = new CommentsBEL();
                                c.commentId = ds.Tables[0].Rows[k]["Comment_id"].ToString();
                                c.commentText = ds.Tables[0].Rows[k]["comment"].ToString();
                                c.CommentedByUName = ds.Tables[0].Rows[k]["CommentedByName"].ToString();
                                c.userId = ds.Tables[0].Rows[k]["commentedByUid"].ToString();
                                c.likes = ds.Tables[0].Rows[k]["Commentlikes"].ToString();
                                c.avatar = ds.Tables[0].Rows[k]["CommentAvatar"].ToString();
                                c.dateCreated = ds.Tables[0].Rows[k]["CommentDate"].ToString();
                                c.postId= ds.Tables[0].Rows[k]["CPostid"].ToString();
                                comments.Add(c);
                               
                                i = k;
                            }
                            
                        }
                        post.Comments = comments;
                        // i = k;
                        //po
                        Posts.Add(post);

                    }

                    return Posts;

                }
                else
                {
                    Posts.Add(new PostsBEL() { Success = false, ErrorMessage = Convert.ToString(SqlParms[1].Value) });
                    return Posts;
                }

            }
            catch (Exception ex)
            {
                Posts.Add(new PostsBEL() { Success = false, ErrorMessage = Convert.ToString(ex.Message.ToString()) });
                return Posts;
            }

            //  return AvailableParkings;
        }
        #endregion


        #region Add new Post
        public PostsBEL AddNewPost(PostsBEL postBEL)
        {
            PostsBEL PostDetails = new PostsBEL();
            DataSet ds = null;
            try
            {

                SqlParameter[] SqlParms = new SqlParameter[6];

                SqlParms[0] = new SqlParameter("@UserId", SqlDbType.NVarChar, 50);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = postBEL.userId;

                SqlParms[1] = new SqlParameter("@PostText", SqlDbType.NVarChar, 1500);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = postBEL.postDescription;

                SqlParms[2] = new SqlParameter("@PostName", SqlDbType.NVarChar, 500);
                SqlParms[2].Direction = ParameterDirection.Input;
                SqlParms[2].Value = postBEL.postName;

                SqlParms[3] = new SqlParameter("@Avatar", SqlDbType.NVarChar, 800);
                SqlParms[3].Direction = ParameterDirection.Input;
                SqlParms[3].Value = postBEL.avatar;

                SqlParms[4] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[4].Direction = ParameterDirection.Output;

                SqlParms[5] = new SqlParameter("@PostID", SqlDbType.NVarChar, 20);
                SqlParms[5].Direction = ParameterDirection.Output;

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Add_NewPost", SqlParms);
                //&& Convert.ToString(SqlParms[5].Value) != "0"
                if (ds == null && ds.Tables.Count <= 0)
                {
                    PostDetails.postName = "";
                    PostDetails.postId = "0";
                    PostDetails.ErrorMessage = Convert.ToString(SqlParms[4].Value) + " Data Not Found";
                }
                else if (Convert.ToString(SqlParms[4].Value) == string.Empty)
                {
                    PostDetails.postId = ds.Tables[0].Rows[0]["Post_ID"].ToString();
                    PostDetails.userId = ds.Tables[0].Rows[0]["User_Id"].ToString();
                    PostDetails.postDescription = ds.Tables[0].Rows[0]["Text"].ToString();
                    PostDetails.postName = ds.Tables[0].Rows[0]["PostName"].ToString();
                    PostDetails.avatar = ds.Tables[0].Rows[0]["Avatar"].ToString();
                    PostDetails.likes = "0";
                    PostDetails.ErrorMessage = string.Empty;

                    // ResultDTO. = Convert.ToString(SqlParms[5].Value);
                }
                else
                {
                    PostDetails.postName = "";
                    PostDetails.postId = "0";
                    PostDetails.ErrorMessage = Convert.ToString(SqlParms[4].Value);
                }

            }
            catch (Exception ex)
            {
                PostDetails.postName = "";
                PostDetails.postId = "0";
                PostDetails.ErrorMessage = "DataBase Error Occured : " + ex.Message;

            }

            return PostDetails;
        }
        #endregion

        #region Add new Comment
        public CommentsBEL AddComment(CommentsBEL commentBEL)
        {
            CommentsBEL CommentsDetails = new CommentsBEL();
            DataSet ds = null;
            try
            {

                SqlParameter[] SqlParms = new SqlParameter[6];

                SqlParms[0] = new SqlParameter("@UserId", SqlDbType.NVarChar, 50);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = commentBEL.userId;

                SqlParms[1] = new SqlParameter("@PostId", SqlDbType.NVarChar, 50);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = commentBEL.postId;

                SqlParms[2] = new SqlParameter("@Comment", SqlDbType.NVarChar, 1500);
                SqlParms[2].Direction = ParameterDirection.Input;
                SqlParms[2].Value = commentBEL.commentText;

                SqlParms[3] = new SqlParameter("@Avatar", SqlDbType.NVarChar, 800);
                SqlParms[3].Direction = ParameterDirection.Input;
                SqlParms[3].Value = commentBEL.avatar;

                SqlParms[4] = new SqlParameter("@Error", SqlDbType.NVarChar, 500);
                SqlParms[4].Direction = ParameterDirection.Output;

                SqlParms[5] = new SqlParameter("@CommentID", SqlDbType.NVarChar, 50);
                SqlParms[5].Direction = ParameterDirection.Output;

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Add_NewComments", SqlParms);
                //&& Convert.ToString(SqlParms[5].Value) != "0"
                if (ds == null && ds.Tables.Count <= 0)
                {
                    CommentsDetails.userId = "";
                    CommentsDetails.commentId = "0";
                    CommentsDetails.ErrorMessage = Convert.ToString(SqlParms[4].Value) + " Data Not Found";
                }
                else if (Convert.ToString(SqlParms[4].Value) == string.Empty)
                {
                    CommentsDetails.postId = ds.Tables[0].Rows[0]["Post_ID"].ToString();
                    CommentsDetails.userId = ds.Tables[0].Rows[0]["User_Id"].ToString();
                    CommentsDetails.commentText = ds.Tables[0].Rows[0]["Text"].ToString();
                    CommentsDetails.commentId = ds.Tables[0].Rows[0]["Comment_id"].ToString();
                    CommentsDetails.avatar = ds.Tables[0].Rows[0]["Avatar"].ToString();
                    CommentsDetails.likes = "0";
                    CommentsDetails.ErrorMessage = string.Empty;

                    // ResultDTO. = Convert.ToString(SqlParms[5].Value);
                }
                else
                {
                    CommentsDetails.userId = "";
                    CommentsDetails.commentId = "0";
                    CommentsDetails.ErrorMessage = Convert.ToString(SqlParms[4].Value);
                }

            }
            catch (Exception ex)
            {
                CommentsDetails.userId = "";
                CommentsDetails.commentId = "0";
                CommentsDetails.ErrorMessage = "DataBase Error Occured : " + ex.Message;

            }

            return CommentsDetails;
        }
        #endregion



        #region User Registration
        public UserDetailsBEL AddUserDetails(UserDetailsBEL userDetailsBEL)
        {
            UserDetailsBEL Userdetail = new UserDetailsBEL();
            DataSet ds = null;
            try
            {

                SqlParameter[] SqlParms = new SqlParameter[9];

                SqlParms[0] = new SqlParameter("@First_Name", SqlDbType.NVarChar, 50);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = userDetailsBEL.First_Name;

                SqlParms[1] = new SqlParameter("@Last_Name", SqlDbType.NVarChar, 50);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = userDetailsBEL.Last_Name;

                SqlParms[2] = new SqlParameter("@Password", SqlDbType.NVarChar, 500);
                SqlParms[2].Direction = ParameterDirection.Input;
                SqlParms[2].Value = userDetailsBEL.Password;

                SqlParms[3] = new SqlParameter("@Phone_No1", SqlDbType.NVarChar, 50);
                SqlParms[3].Direction = ParameterDirection.Input;
                SqlParms[3].Value = userDetailsBEL.Phone_No1;

                SqlParms[4] = new SqlParameter("@Email_Id", SqlDbType.NVarChar, 50);
                SqlParms[4].Direction = ParameterDirection.Input;
                SqlParms[4].Value = userDetailsBEL.Email_Id;

                SqlParms[5] = new SqlParameter("@SignUp_Mode_ID", SqlDbType.NVarChar, 2);
                SqlParms[5].Direction = ParameterDirection.Input;
                SqlParms[5].Value = userDetailsBEL.SignUp_Mode_ID;

                SqlParms[6] = new SqlParameter("@Other_FB_GG_ID", SqlDbType.BigInt);
                SqlParms[6].Direction = ParameterDirection.Input;
                if (userDetailsBEL.Other_ID != string.Empty)
                    SqlParms[6].Value = Convert.ToUInt64(userDetailsBEL.Other_ID);
                else
                    SqlParms[6].Value = 0;

                SqlParms[7] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[7].Direction = ParameterDirection.Output;

                SqlParms[8] = new SqlParameter("@UserId", SqlDbType.NVarChar, 20);
                SqlParms[8].Direction = ParameterDirection.Output;

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Insert_UserLogin", SqlParms);
                //&& Convert.ToString(SqlParms[5].Value) != "0"
                if (ds == null && ds.Tables.Count <= 0)
                {
                    Userdetail.User_Name = "";
                    Userdetail.User_ID = "0";
                    Userdetail.ErrorMessage = Convert.ToString(SqlParms[7].Value) + " Data Not Found";
                }
                else if (Convert.ToString(SqlParms[7].Value) == string.Empty)
                {
                    Userdetail.User_ID = ds.Tables[0].Rows[0]["User_ID"].ToString();
                    Userdetail.Email_Id = ds.Tables[0].Rows[0]["Email_Id"].ToString();
                    Userdetail.Last_Login = ds.Tables[0].Rows[0]["Last_Login"].ToString();
                    Userdetail.Phone_No1 = ds.Tables[0].Rows[0]["Phone_No1"].ToString();
                    Userdetail.User_Name = ds.Tables[0].Rows[0]["User_Name"].ToString();
                    Userdetail.ErrorMessage = string.Empty;

                    // ResultDTO. = Convert.ToString(SqlParms[5].Value);
                }
                else
                {
                    Userdetail.User_Name = "";
                    Userdetail.User_ID = "0";
                    Userdetail.ErrorMessage = Convert.ToString(SqlParms[7].Value);
                }

            }
            catch (Exception ex)
            {
                Userdetail.User_Name = "";
                Userdetail.User_ID = "0";
                Userdetail.ErrorMessage = "DataBase Error Occured : " + ex.Message;

            }

            return Userdetail;
        }
        #endregion

        public Transaction UpdateCred(UserDetailsBEL Ubal)
        {
            Transaction ResultDTO = new Transaction();
            //SqlConnection conn = new SqlConnection();
            try
            {
                SqlParameter[] SqlParms = new SqlParameter[4];



                SqlParms[0] = new SqlParameter("@Phone_No1", SqlDbType.VarChar, 50);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = Ubal.Phone_No1;

                SqlParms[1] = new SqlParameter("@Password", SqlDbType.VarChar, 500);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = Ubal.Password;


                SqlParms[2] = new SqlParameter("@Error", SqlDbType.VarChar, 150);
                SqlParms[2].Direction = ParameterDirection.Output;

                SqlParms[3] = new SqlParameter("@UserId", SqlDbType.VarChar, 20);
                SqlParms[3].Direction = ParameterDirection.Output;



                SqlHelper.ExecuteNonQuery(connectionString, CommandType.StoredProcedure, "Upate_Password", SqlParms);

                if (Convert.ToString(SqlParms[2].Value) == string.Empty && Convert.ToString(SqlParms[3].Value) != "0")
                {
                    ResultDTO.Success = true;
                    ResultDTO.Message = "Valid User";
                    ResultDTO.TransactionId = Convert.ToString(SqlParms[3].Value);
                }
                else
                {
                    ResultDTO.Success = false;
                    ResultDTO.Message = "Failed";
                    ResultDTO.ErrorMessage = Convert.ToString(SqlParms[2].Value);
                }

            }
            catch (Exception ex)
            {
                ResultDTO.Success = false;
                ResultDTO.Message = "DataBase Error Occured";
                ResultDTO.ErrorMessage = ex.Message.ToString();
            }
            return ResultDTO;

        }

        #region  RegistraParkingAreaBEL
        public List<DashBoardBEL> GetMenuMapping(string User_id)
        {
            List<DashBoardBEL> UserMenus = new List<DashBoardBEL>();
            try
            {

                DataSet ds = null;

                SqlParameter[] SqlParms = new SqlParameter[2];

                SqlParms[0] = new SqlParameter("@User_id", SqlDbType.NVarChar);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = User_id;


                SqlParms[1] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[1].Direction = ParameterDirection.Output;

                //SqlParms[7] = new SqlParameter("@UserId", SqlDbType.NVarChar, 20);
                //SqlParms[7].Direction = ParameterDirection.Output;



                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Get_MenuList", SqlParms);

                if (ds != null && ds.Tables[0].Rows.Count > 0 && Convert.ToString(SqlParms[1].Value) != "0")
                {
                    UserMenus = (from DataRow parkingrow in ds.Tables[0].Rows
                                 select new DashBoardBEL
                                 {
                                     User_id = Convert.ToString(parkingrow["User_id"]),
                                     Menu_id = Convert.ToString(parkingrow["Menu_id"]),
                                     Menu_description = Convert.ToString(parkingrow["Menu_description"]),
                                     Menu_Url = Convert.ToString(parkingrow["Menu_Url"]),

                                     Success = true,
                                     ErrorMessage = "",
                                 }
                                    ).ToList<DashBoardBEL>();

                    return UserMenus;

                }
                else
                {
                    UserMenus.Add(new DashBoardBEL() { Success = false, ErrorMessage = Convert.ToString(SqlParms[1].Value) });
                    return UserMenus;
                }

            }
            catch (Exception ex)
            {
                UserMenus.Add(new DashBoardBEL() { Success = false, ErrorMessage = Convert.ToString(ex.Message.ToString()) });
                return UserMenus;
            }

            //  return AvailableParkings;
        }
        #endregion

        //public UserDetailsBEL CheckPhoneNoExists(string Phone_No)
        //{
        //    UserDetailsBEL Userdetail = new UserDetailsBEL();
        //    //SqlConnection conn = new SqlConnection();
        //    DataSet ds = null;
        //    try
        //    {
        //        SqlParameter[] SqlParms = new SqlParameter[2];

        //        SqlParms[0] = new SqlParameter("@Phone_No", SqlDbType.VarChar, 10);
        //        SqlParms[0].Direction = ParameterDirection.Input;
        //        SqlParms[0].Value = Phone_No;

        //        SqlParms[1] = new SqlParameter("@Error", SqlDbType.VarChar, 150);
        //        SqlParms[1].Direction = ParameterDirection.Output;

        //        ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "TW_CheckPhoneNo", SqlParms);
        //        //&& Convert.ToString(SqlParms[5].Value) != "0"
        //        if (Convert.ToString(SqlParms[1].Value) == string.Empty)
        //        {
        //            Userdetail.User_ID = ds.Tables[0].Rows[0]["User_ID"].ToString();
        //            Userdetail.Alternate_Email_Id = ds.Tables[0].Rows[0]["Alternate_Email_Id"].ToString();
        //            Userdetail.Email_Id = ds.Tables[0].Rows[0]["Email_Id"].ToString();
        //            Userdetail.First_Name = ds.Tables[0].Rows[0]["First_Name"].ToString();
        //            Userdetail.Last_Login = ds.Tables[0].Rows[0]["Last_Login"].ToString();
        //            Userdetail.Last_Name = ds.Tables[0].Rows[0]["Last_Name"].ToString();
        //            //Userdetail.Owner_Address = ds.Tables[0].Rows[0]["Owner_Address"].ToString();
        //            Userdetail.Phone_No1 = ds.Tables[0].Rows[0]["Phone_No1"].ToString();
        //            Userdetail.Phone_No2 = ds.Tables[0].Rows[0]["Phone_No2"].ToString();
        //            // Userdetail.SignUp_Mode_ID = ds.Tables[0].Rows[0]["SignUp_Mode_ID"].ToString();
        //            //Userdetail.User_Name = ds.Tables[0].Rows[0]["User_Name"].ToString();
        //            Userdetail.ErrorMessage = string.Empty;
        //            Userdetail.User_Name = ds.Tables[0].Rows[0]["First_Name"].ToString() + " " + ds.Tables[0].Rows[0]["Last_Name"].ToString(); ;
        //            // Userdetail.Last_Login = 

        //            // ResultDTO. = Convert.ToString(SqlParms[5].Value);
        //        }
        //        else
        //        {
        //            Userdetail.User_Name = "";
        //            Userdetail.User_ID = "0";
        //            Userdetail.ErrorMessage = Convert.ToString(SqlParms[4].Value);
        //        }

        //    }
        //    catch (Exception ex)
        //    {
        //        Userdetail.User_Name = "";
        //        Userdetail.User_ID = "0";
        //        Userdetail.ErrorMessage = ex.Message.ToString();

        //    }
        //    return Userdetail;

        //}


        #region  UserDashboard
        public PersonalinfoBEL GetProfileInfo(string User_id)
        {
            PersonalinfoBEL personelInfo = new PersonalinfoBEL();

            try
            {

                DataSet ds = null;

                SqlParameter[] SqlParms = new SqlParameter[2];

                SqlParms[0] = new SqlParameter("@User_id", SqlDbType.NVarChar);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = User_id;


                SqlParms[1] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[1].Direction = ParameterDirection.Output;

                //SqlParms[7] = new SqlParameter("@UserId", SqlDbType.NVarChar, 20);
                //SqlParms[7].Direction = ParameterDirection.Output;

                //jfhjff

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Get_ProfileInfo", SqlParms);

                if (Convert.ToString(SqlParms[1].Value) == string.Empty)
                {
                    personelInfo.User_Id = Convert.ToInt32(ds.Tables[0].Rows[0]["User_id"]);
                    personelInfo.First_Name = ds.Tables[0].Rows[0]["First_Name"].ToString();
                    personelInfo.Last_Name = ds.Tables[0].Rows[0]["Last_Name"].ToString();
                    if (ds.Tables[0].Rows[0]["DOB"] != DBNull.Value)
                    {
                        personelInfo.DOB = Convert.ToDateTime(ds.Tables[0].Rows[0]["DOB"]);
                    }

                    personelInfo.Email_ID = ds.Tables[0].Rows[0]["Email_Id"].ToString();
                    personelInfo.Alternate_Email_Id = ds.Tables[0].Rows[0]["Alternate_Email_Id"].ToString();
                    personelInfo.MobileNo = ds.Tables[0].Rows[0]["Phone_No1"].ToString();
                    personelInfo.AlternateNo = ds.Tables[0].Rows[0]["Phone_No2"].ToString();
                    personelInfo.Driving_License = ds.Tables[0].Rows[0]["Driving_License"].ToString();
                    personelInfo.Pan_No = ds.Tables[0].Rows[0]["PAN"].ToString();
                    personelInfo.Owner_Address = ds.Tables[0].Rows[0]["Owner_Address"].ToString();
                    personelInfo.Owner_Verification_Status = Convert.ToChar(ds.Tables[0].Rows[0]["OwnerVerificationStatus"]);

                    personelInfo.Last_Login = ds.Tables[0].Rows[0]["Last_Login"].ToString();
                    personelInfo.Password = Secure.Decrypt(ds.Tables[0].Rows[0]["Password"].ToString());

                    return personelInfo;

                }
                else
                {
                    personelInfo.Success = false;
                    personelInfo.ErrorMessage = Convert.ToString(SqlParms[1].Value);
                    return personelInfo;
                }

            }
            catch (Exception ex)
            {
                personelInfo.Success = false;
                personelInfo.ErrorMessage = Convert.ToString(ex.Message.ToString());
                return personelInfo;
            }

            //  return AvailableParkings;
        }


        public PersonalinfoBEL UpdateProfileInfo(PersonalinfoBEL personelInfo)
        {
            DataSet ds = null;
            PersonalinfoBEL personelInfoUpdated = new PersonalinfoBEL();
            try
            {

                SqlParameter[] SqlParms = new SqlParameter[11];

                SqlParms[0] = new SqlParameter("@User_id", SqlDbType.Int);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = personelInfo.User_Id;

                SqlParms[1] = new SqlParameter("@First_Name", SqlDbType.NVarChar, 50);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = personelInfo.First_Name;

                SqlParms[2] = new SqlParameter("@Last_Name", SqlDbType.NVarChar, 50);
                SqlParms[2].Direction = ParameterDirection.Input;
                SqlParms[2].Value = personelInfo.Last_Name;

                SqlParms[3] = new SqlParameter("@Email_id", SqlDbType.NVarChar, 500);
                SqlParms[3].Direction = ParameterDirection.Input;
                SqlParms[3].Value = personelInfo.Email_ID;

                SqlParms[4] = new SqlParameter("@Alternate_Email_id", SqlDbType.NVarChar, 50);
                SqlParms[4].Direction = ParameterDirection.Input;
                SqlParms[4].Value = personelInfo.Alternate_Email_Id;

                SqlParms[5] = new SqlParameter("@DOB", SqlDbType.DateTime);
                SqlParms[5].Direction = ParameterDirection.Input;
                SqlParms[5].Value = personelInfo.DOB;

                SqlParms[6] = new SqlParameter("@Phone_No2", SqlDbType.NVarChar, 50);
                SqlParms[6].Direction = ParameterDirection.Input;
                SqlParms[6].Value = personelInfo.AlternateNo;

                SqlParms[7] = new SqlParameter("@Driving_License", SqlDbType.NVarChar, 50);
                SqlParms[7].Direction = ParameterDirection.Input;
                SqlParms[7].Value = personelInfo.Driving_License;

                SqlParms[8] = new SqlParameter("@PAN", SqlDbType.NVarChar, 50);
                SqlParms[8].Direction = ParameterDirection.Input;
                SqlParms[8].Value = personelInfo.Pan_No;

                SqlParms[9] = new SqlParameter("@Password", SqlDbType.NVarChar, 50);
                SqlParms[9].Direction = ParameterDirection.Input;
                SqlParms[9].Value = Secure.Encrypt(personelInfo.NewPassword);

                SqlParms[10] = new SqlParameter("@Error", SqlDbType.NVarChar, 50);
                SqlParms[10].Direction = ParameterDirection.Output;



                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Update_ProfileInfo", SqlParms);

                if (Convert.ToString(SqlParms[10].Value) == string.Empty)
                {
                    personelInfoUpdated.User_Id = Convert.ToInt32(ds.Tables[0].Rows[0]["User_id"]);
                    personelInfoUpdated.First_Name = ds.Tables[0].Rows[0]["First_Name"].ToString();
                    personelInfoUpdated.Last_Name = ds.Tables[0].Rows[0]["Last_Name"].ToString();
                    if (ds.Tables[0].Rows[0]["DOB"] != DBNull.Value)
                    {
                        personelInfoUpdated.DOB = Convert.ToDateTime(ds.Tables[0].Rows[0]["DOB"]);
                    }

                    personelInfoUpdated.Email_ID = ds.Tables[0].Rows[0]["Email_Id"].ToString();
                    personelInfoUpdated.Alternate_Email_Id = ds.Tables[0].Rows[0]["Alternate_Email_Id"].ToString();
                    personelInfoUpdated.MobileNo = ds.Tables[0].Rows[0]["Phone_No1"].ToString();
                    personelInfoUpdated.AlternateNo = ds.Tables[0].Rows[0]["Phone_No2"].ToString();
                    personelInfoUpdated.Driving_License = ds.Tables[0].Rows[0]["Driving_License"].ToString();
                    personelInfoUpdated.Pan_No = ds.Tables[0].Rows[0]["PAN"].ToString();
                    personelInfoUpdated.Owner_Address = ds.Tables[0].Rows[0]["Owner_Address"].ToString();
                    personelInfoUpdated.Owner_Verification_Status = Convert.ToChar(ds.Tables[0].Rows[0]["OwnerVerificationStatus"]);

                    personelInfoUpdated.Last_Login = ds.Tables[0].Rows[0]["Last_Login"].ToString();
                    personelInfoUpdated.Password = Secure.Encrypt(ds.Tables[0].Rows[0]["Password"].ToString());

                    return personelInfoUpdated;

                }
                else
                {
                    personelInfo.Success = false;
                    personelInfo.ErrorMessage = Convert.ToString(SqlParms[10].Value);
                    return personelInfo;
                }

            }
            catch (Exception ex)
            {
                personelInfo.Success = false;
                personelInfo.ErrorMessage = Convert.ToString(ex.Message.ToString());
                return personelInfo;
            }

            //  return AvailableParkings;
        }

        public List<UserInboxBEL> GetUserInbox(string User_id)
        {
            List<UserInboxBEL> UserInboxList = new List<UserInboxBEL>();

            try
            {

                DataSet ds = null;

                SqlParameter[] SqlParms = new SqlParameter[2];

                SqlParms[0] = new SqlParameter("@User_id", SqlDbType.NVarChar);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = User_id;


                SqlParms[1] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[1].Direction = ParameterDirection.Output;

                //SqlParms[7] = new SqlParameter("@UserId", SqlDbType.NVarChar, 20);
                //SqlParms[7].Direction = ParameterDirection.Output;

                //jfhjff

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Get_Notifications", SqlParms);


                if (ds != null && ds.Tables[0].Rows.Count > 0 && Convert.ToString(SqlParms[1].Value) != "0")
                {

                    for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                    {
                        UserInboxBEL UserInbox = new UserInboxBEL();

                        UserInbox.User_Id = Convert.ToInt32(ds.Tables[0].Rows[i]["User_id"]);
                        UserInbox.Notification_ID = Convert.ToInt32(ds.Tables[0].Rows[i]["Notification_ID"]);
                        UserInbox.Subject = ds.Tables[0].Rows[i]["Subject"].ToString();
                        UserInbox.Message = ds.Tables[0].Rows[i]["Message"].ToString();
                        if (ds.Tables[0].Rows[i]["Dt_Created"] != DBNull.Value)
                        {
                            UserInbox.Dt_Created = Convert.ToDateTime(ds.Tables[0].Rows[i]["Dt_Created"]);
                        }

                        UserInbox.READYN = Convert.ToChar(ds.Tables[0].Rows[i]["READYN"]);
                        UserInbox.UserSpecific = Convert.ToChar(ds.Tables[0].Rows[i]["UserSpecific"]);

                        UserInboxList.Add(UserInbox);
                    }

                    return UserInboxList;
                }

                else
                {

                    UserInboxBEL UserInbox = new UserInboxBEL();
                    UserInbox.Success = false;
                    UserInbox.ErrorMessage = Convert.ToString(SqlParms[1].Value);
                    UserInboxList.Add(UserInbox);
                    return UserInboxList;
                }


            }
            catch (Exception ex)
            {
                UserInboxBEL UserInbox = new UserInboxBEL();
                UserInbox.Success = false;
                UserInbox.ErrorMessage = Convert.ToString(ex.Message.ToString());
                UserInboxList.Add(UserInbox);
                return UserInboxList;
            }

            //  return AvailableParkings;
        }

        public UserInboxBEL DeleteUserNotification(string User_id, string notification_id)
        {
            UserInboxBEL UserInbox = new UserInboxBEL();

            try
            {

                DataSet ds = null;

                SqlParameter[] SqlParms = new SqlParameter[3];

                SqlParms[0] = new SqlParameter("@User_id", SqlDbType.NVarChar);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = User_id;

                SqlParms[1] = new SqlParameter("@Notification_id", SqlDbType.NVarChar);
                SqlParms[1].Direction = ParameterDirection.Input;
                SqlParms[1].Value = notification_id;


                SqlParms[2] = new SqlParameter("@Error", SqlDbType.NVarChar, 150);
                SqlParms[2].Direction = ParameterDirection.Output;

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "Delete_Notification", SqlParms);

                if (Convert.ToString(SqlParms[2].Value) == string.Empty)
                {
                    UserInbox.Success = true;
                }
                else
                {
                    UserInbox.Success = false;
                }

                return UserInbox;

            }
            catch (Exception ex)
            {

                UserInbox.Success = false;
                UserInbox.ErrorMessage = Convert.ToString(ex.Message.ToString());

                return UserInbox;
            }
        }

        #endregion


        public UserDetailsBEL CheckPhoneNoExists(string Phone_No)
        {
            UserDetailsBEL Userdetail = new UserDetailsBEL();
            //SqlConnection conn = new SqlConnection();
            DataSet ds = null;
            try
            {
                SqlParameter[] SqlParms = new SqlParameter[2];

                SqlParms[0] = new SqlParameter("@Phone_No", SqlDbType.VarChar, 10);
                SqlParms[0].Direction = ParameterDirection.Input;
                SqlParms[0].Value = Phone_No;

                SqlParms[1] = new SqlParameter("@Error", SqlDbType.VarChar, 150);
                SqlParms[1].Direction = ParameterDirection.Output;

                ds = SqlHelper.ExecuteDataset(connectionString, CommandType.StoredProcedure, "TW_CheckPhoneNo", SqlParms);
                //&& Convert.ToString(SqlParms[5].Value) != "0"
                if (Convert.ToString(SqlParms[1].Value) == string.Empty)
                {
                    Userdetail.User_ID = ds.Tables[0].Rows[0]["User_ID"].ToString();
                    Userdetail.Alternate_Email_Id = ds.Tables[0].Rows[0]["Alternate_Email_Id"].ToString();
                    Userdetail.Email_Id = ds.Tables[0].Rows[0]["Email_Id"].ToString();
                    Userdetail.First_Name = ds.Tables[0].Rows[0]["First_Name"].ToString();
                    Userdetail.Last_Login = ds.Tables[0].Rows[0]["Last_Login"].ToString();
                    Userdetail.Last_Name = ds.Tables[0].Rows[0]["Last_Name"].ToString();
                    //Userdetail.Owner_Address = ds.Tables[0].Rows[0]["Owner_Address"].ToString();
                    Userdetail.Phone_No1 = ds.Tables[0].Rows[0]["Phone_No1"].ToString();
                    Userdetail.Phone_No2 = ds.Tables[0].Rows[0]["Phone_No2"].ToString();
                    // Userdetail.SignUp_Mode_ID = ds.Tables[0].Rows[0]["SignUp_Mode_ID"].ToString();
                    //Userdetail.User_Name = ds.Tables[0].Rows[0]["User_Name"].ToString();
                    Userdetail.ErrorMessage = string.Empty;
                    Userdetail.User_Name = ds.Tables[0].Rows[0]["First_Name"].ToString() + " " + ds.Tables[0].Rows[0]["Last_Name"].ToString(); ;
                    // Userdetail.Last_Login = 

                    // ResultDTO. = Convert.ToString(SqlParms[5].Value);
                }
                else
                {
                    Userdetail.User_Name = "";
                    Userdetail.User_ID = "0";
                    Userdetail.ErrorMessage = Convert.ToString(SqlParms[1].Value);
                }

            }
            catch (Exception ex)
            {
                Userdetail.User_Name = "";
                Userdetail.User_ID = "0";
                Userdetail.ErrorMessage = ex.Message.ToString();

            }
            return Userdetail;

        }
    }
}
