namespace mock_api;

public class ResponseModel
{
   public int StatusCode { get; set; }
   public string StatusDescription { get; set; }
   public string Header { get; set; }
   public string Body { get; set; }
}