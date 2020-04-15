using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Configuration;
using System.Web.Configuration;
using System.Web.Hosting;

namespace TrueWheels.Web
{
    public class MvcApplication : System.Web.HttpApplication
    {
        
        protected void Application_Start()
        {

            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            //Configuration config = WebConfigurationManager.OpenWebConfiguration(HttpRuntime.AppDomainAppVirtualPath);
            //config.AppSettings.Settings.Remove("appPath");
            //config.AppSettings.Settings.Add("appPath", HttpRuntime.AppDomainAppPath);
            //config.Save();
            //ConfigurationManager.AppSettings.Set("appPath", "AppSetting");
            
        }
    }
}
