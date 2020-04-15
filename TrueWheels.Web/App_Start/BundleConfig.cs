using System.Web;
using System.Web.Optimization;

namespace TrueWheels.Web
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                      "~/Content/js/vendor/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/Content/js").Include(
               "~/Content/js/vendor/jquery-1.10.2.min.js",
                "~/Content/js/vendor/jquery-ui.js",
                "~/Content/js/vendor/jquery.unobtrusive-ajax.js",
               "~/Content/js/vendor/modernizr-2.6.2.min.js", 
              "~/Content/js/bootstrap.min.js",
              "~/Content/js/owl.carousel.min.js",
              "~/Content/js/wow.js",
            "~/Content/js/main.js"
           ));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                     "~/Content/style.css",
                    "~/Content/responsive.css",
                    "~/Content/css/truewheels.css",
                    "~/Content/css/animate.css ",
                    "~/Content/css/bootstrap-theme.css ",
                    "~/Content/css/bootstrap.min.css",
                    "~/Content/css/font-awesome.min.css",
                    "~/Content/css/fontello.css",
                    "~/Content/css/normalize.css",
                    "~/Content/css/owl.carousel.css",
                    "~/Content/css/owl.theme.css",
                    "~/Content/jquery-ui.css"
                    ));
            bundles.Add(new StyleBundle("~/Content").Include(
                    "~/Content/style.css"));
        }
    }
}

