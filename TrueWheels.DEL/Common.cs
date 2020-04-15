using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;

namespace TrueWheels.DAL
{

    public class Transaction
    {
        public int Id { get; set; }
        public string Message { get; set; }
        public bool Success { get; set; }
        public string ErrorMessage { get; set; }
        public string TransactionId { get; set; }
    }
    public class Location
    {
        public string statusCode { get; set; }
        public string statusMessage { get; set; }
        public string ipAddress { get; set; }
        public string countryCode { get; set; }
        public string countryName { get; set; }
        public string regionName { get; set; }
        public string cityName { get; set; }
        public string zipCode { get; set; }
        public string latitude { get; set; }
        public string longitude { get; set; }
        public string timeZone { get; set; }
    }
    public class Message
    {
        public Message()
        {
            this.getFileName();
        }
        public string username { get; set; }
        public string userid { get; set; }
        public string from { get; set; }
        public string password { get; set; }
        public string to { get; set; }
        public string[] cc { get; set; }
        public string[] bcc { get; set; }
        public List<string> message { get; set; }
        public string host { get; set; }
        public string subject { get; set; }
        public string filename { get; set; }
        public string filepath { get; set; }
        public string error { get; set; }
        public string mode { get; set; }

        public string getFileName()
        {
            string day = DateTime.Now.Day.ToString();
            if (Convert.ToInt32(day) < 10)
            {
                day = "0" + day;
            }
            string month = DateTime.Now.Month.ToString();
            if (Convert.ToInt32(month) < 10)
            {
                month = "0" + month;
            }
            string year = DateTime.Now.Year.ToString();
            this.filename = "Log/Log" + day + month + year;

            return this.filename + ".txt";

        }
        public string getFilePath()
        {

            return this.filepath + this.getFileName();
        }
        public void CreateMessage(Message messages)
        {
            string filePath = ConfigurationManager.AppSettings["appPath"].ToString();
            //Message messages = new Message();
            string[] _message = new string[] { messages.error };
            List<string> _messageList = new List<string>();
            for (int i = 0; i < _message.Length; i++)
            {
                _messageList.Add(_message[i]);
            }
            messages.message = _messageList;
            messages.filepath = filePath;
            Log log = new Log();
            log.CreateLog(messages);
        }

    }
    public class Log
    {
        public void CreateLog(Message messages)
        {
            string filePath = messages.filepath + messages.filename + ".txt";
            StreamWriter w = null;
            try
            {

                if (!File.Exists(filePath))
                {
                    w = File.CreateText(filePath);
                }
                else
                {
                    w = File.AppendText(filePath);
                }

                for (int i = 0; i < messages.message.Count; i++)
                {
                    w.WriteLine(messages.message[i] + " ");
                }
                w.Flush();
                w.Close();

                sendMessage(messages);

            }
            catch (Exception ex)
            {

            }
            finally
            {
                if (!(w == null))
                {
                    //w.Flush();
                    //w.Close();
                }
            }
        }
        public void CreateLog(string[] Message, string Path, string filename)
        {

            string filePath = Path + filename + ".txt";
            StreamWriter w;
            if (!File.Exists(filePath))
            {
                w = File.CreateText(filePath);
            }
            else
            {
                w = File.AppendText(filePath);
            }
            for (int i = 0; i < Message.Length; i++)
            {
                w.WriteLine(Message[i] + " ");
            }
            w.Flush();
            w.Close();
        }
        public void CreateLog(string Message, string Path, string filename)
        {

            string filePath = Path + filename + ".txt";
            StreamWriter w;
            if (!File.Exists(filePath))
            {
                w = File.CreateText(filePath);
            }
            else
            {
                w = File.AppendText(filePath);
            }

            w.WriteLine(Message);

            w.Flush();
            w.Close();
        }
        public void sendMessage(Message messages)
        {

            messages.from = ConfigurationManager.AppSettings["UserName"].ToString();
            messages.password = ConfigurationManager.AppSettings["Password"].ToString();
            messages.host = ConfigurationManager.AppSettings["Host"].ToString();
            messages.to = ConfigurationManager.AppSettings["ToMail"].ToString();
            messages.cc = ConfigurationManager.AppSettings["cc"].ToString().Split(',');
            messages.bcc = ConfigurationManager.AppSettings["Bcc"].ToString().Split(',');
            messages.subject = ConfigurationManager.AppSettings["Subject"].ToString();

            Mail mail = new Mail();
            mail.Send(messages);
        }

    }
    public class Mail
    {
        public bool Send(Message messages)
        {
            Boolean flag = false;
            string from = messages.from;
            string password = messages.password;
            string to = messages.to;
            MailMessage mail = new MailMessage();


            mail.From = new MailAddress(from);
            mail.To.Add(to);
            mail.Subject = messages.subject;
            mail.IsBodyHtml = true;
            mail.Body = getMessageBody(messages.message);

            SmtpClient SmtpServer = new SmtpClient("smtp.gmail.com");
            //SmtpClient SmtpServer = new SmtpClient("relay-hosting.secureserver.net");
            SmtpServer.Port = 587;
            //SmtpServer.Port = 25;
            SmtpServer.Credentials = new NetworkCredential(from, password);
            //SmtpServer.EnableSsl = true;
            SmtpServer.EnableSsl = true;

            string fileName = messages.getFilePath();
            if (!String.IsNullOrEmpty(fileName))
            {
                Attachment attachment = new Attachment(fileName);
                if (attachment != null)
                {
                    mail.Attachments.Add(attachment);
                }
            }

            try
            {
                SmtpServer.Send(mail);
                flag = true;
            }
            catch (Exception ex)
            {
                flag = false;
            }
            finally
            {
                mail.Dispose();
            }

            return flag;
            //MessageBox.Show("mail Send");
        }
        private string getMessageBody(List<string> message)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("<table><tr font-size='16'><td>{0}</td></tr><tr><td>{1}</td></tr></table>", "Error Report", message[0]);
            return sb.ToString();
        }
    }
    public class ErrorLog
    {
        public static void Log(string className, string methodName, string message)
        {
            Message messages = new Message();
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("Class Name: {0}, Method Name : {1}, Error Message: {2}, Error Log Time : {3}", className, methodName, message, 
                DateTime.Now.ToString());
            messages.error = sb.ToString();

            if (System.Diagnostics.Debugger.IsAttached)
            {
                messages.mode = "Debug";
            }
            else
            {
                messages.mode = "Release";
            }
            messages.CreateMessage(messages);
        }
    }
}