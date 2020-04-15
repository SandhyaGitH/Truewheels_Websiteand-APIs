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

    public class DLTrueWheelsUser
    {
       /* public IEnumerable<BETrueWheelsUser> Users
        {
            get
            {
                string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ConnectionString;
                List<BETrueWheelsUser> users = new List<BETrueWheelsUser>();
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    SqlCommand cmd = new SqlCommand("USP_GetAllUsers", con);//USP_GetAllUsers is a procedure to get all employee
                    cmd.CommandType = CommandType.StoredProcedure;
                    //cmd.Parameters.AddWithValue("@DeptId", null);   
                    con.Open();
                    SqlDataReader rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        BETrueWheelsUser user = new BETrueWheelsUser();
                        user.ID = Convert.ToInt32(rdr["Id"]);
                        user.FullName = rdr["FullName"].ToString();
                        user.Gender = rdr["Gender"].ToString();
                        user.UserName = rdr["UserName"].ToString();
                        user.Password = rdr["Password"].ToString(); 
                        users.Add(user);
                    }
                }
                return users;
            }
        }*/
    }  
    
}
