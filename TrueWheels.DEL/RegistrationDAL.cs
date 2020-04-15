using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.DAL
{
    public class RegistrationDAL
    {
        private string connectionString = string.Empty;
        public RegistrationDAL()
        {
            connectionString = ConfigurationManager.ConnectionStrings["conStr"].ConnectionString;
            // later a different project will be build where  encrypted connection will maintained.
        }
    }
}
