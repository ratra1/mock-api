using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Web;

namespace mock_api;

public class ResponseGenerator : IHttpHandler
{
   public void ProcessRequest(HttpContext context)
   {
      SaveRequest(context);

      var reqTimeoutSec = context.Request.QueryString["timeoutSec"];
      if (int.TryParse(reqTimeoutSec, out int timeoutSec) && timeoutSec > 0)
      {
         Thread.Sleep(timeoutSec * 1000);
      }

      var id = context.Request.QueryString["id"];
      var rm = GetResponseModel(id);
      var dict = JsonSerializer.Deserialize<Dictionary<string, string>>(rm.Header);

      context.Response.ClearHeaders();
      context.Response.SuppressDefaultCacheControlHeader = true;
      foreach (var kvp in dict)
      {
         context.Response.AddHeader(kvp.Key, kvp.Value);
      }

      context.Response.StatusCode = rm.StatusCode;
      context.Response.StatusDescription = rm.StatusDescription;
      context.Response.TrySkipIisCustomErrors = true;
      context.Response.Write(rm.Body);
   }

   public bool IsReusable => false;

   private ResponseModel GetResponseModel(string id)
   {
      const string command =
         """
         USE [TestAutomation];

         SELECT TOP (1)
           [StatusCode],
           [StatusDescription],
           [Header],
           [Body]
         FROM [dbo].[ResponseGenerator] WITH (NOLOCK)
         WHERE [Id] = @Id;
         """;
      var testAutomation = ConfigurationManager.ConnectionStrings["TestAutomation"].ToString();
      using var cnn = new SqlConnection(testAutomation);
      using var cmd = new SqlCommand(command, cnn);
      SqlParameter[] prm = [new("@Id", SqlDbType.Int) { Value = id }];
      cmd.Parameters.AddRange(prm);
      cnn.Open();
      using var rdr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
      var res = new ResponseModel();
      while (rdr.Read())
      {
         res.StatusCode = (int)rdr["StatusCode"];
         res.StatusDescription = rdr["StatusDescription"].ToString();
         res.Header = rdr["Header"].ToString();
         res.Body = rdr["Body"].ToString().Trim();
      }

      return res;
   }

   private void SaveRequest(HttpContext context)
   {
      var rm = new RequestModel
      {
         Method = context.Request.HttpMethod,
         URL = context.Request.Url.AbsoluteUri,
         Header = GetRequestHeader(context),
         Body = new StreamReader(context.Request.InputStream).ReadToEnd()
      };
      const string command =
         """
         USE [TestAutomation];

         INSERT INTO [dbo].[Request]
         (
           [Method],
           [URL],
           [Header],
           [Body]
         )
         VALUES
         (
           @Method,
           @URL,
           @Header,
           @Body
         );
         """;
      var testAutomation = ConfigurationManager.ConnectionStrings["TestAutomation"].ToString();
      using var cnn = new SqlConnection(testAutomation);
      using var cmd = new SqlCommand(command, cnn);
      SqlParameter[] prm =
      [
         new("@Method", SqlDbType.VarChar) { Value = rm.Method },
         new("@URL", SqlDbType.NVarChar) { Value = rm.URL },
         new("@Header", SqlDbType.NVarChar) { Value = rm.Header },
         new("@Body", SqlDbType.NVarChar) { Value = rm.Body }
      ];
      cmd.Parameters.AddRange(prm);
      cnn.Open();
      cmd.ExecuteNonQuery();
   }

   private string GetRequestHeader(HttpContext context)
   {
      var sb = new StringBuilder();
      foreach (var key in context.Request.Headers.AllKeys)
      {
         sb.AppendLine($"{key}: {context.Request.Headers.Get(key)}");
      }

      return sb.ToString();
   }
}