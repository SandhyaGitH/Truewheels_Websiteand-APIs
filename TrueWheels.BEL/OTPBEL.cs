using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
   public class OTPBEL
    {
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
              // data.Close();
               //reader.Close();

           }

       }

       public List<string> GetAndSendOTP(long number)
       {
           
               List<string> OTP = new List<string>();
               Random rnd = new Random();
               int _OTPNO = rnd.Next(100000, 999999);
               long _number = Convert.ToInt64(number);
               bool MessageSent = false;
               // for later ---string _message = Convert.ToString(_OTPNO) + " is your Registration OTP. Treat this  as confidential. Sharing it with anyone gives them full access to your TrueWheels Wallet. TrueWheels never calls to verify your OTP.";
               string _message = Convert.ToString(_OTPNO)+ " is your Registration OTP. Treat this  as confidential. Sharing it with anyone gives them full access to your TrueWheels Account. TrueWheels never calls to verify your OTP.";
               OTP.Add(_OTPNO.ToString());
               OTP.Add(_number.ToString());
               
               //Session["OTP"] = OTP;
               if (sendMessage(_number, _message))
               {
                   MessageSent=true;
                   OTP.Add(Convert.ToString(MessageSent));
                   return OTP;
               }
               else
               {
                   OTP.Add(Convert.ToString(MessageSent));
                   return OTP;
                   // = string.Format("OTP sinding failed try again, Make sure your phone must be in network coverage\n OR try another phone");
               }
               
           
       }
    }
}
