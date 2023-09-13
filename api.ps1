# Load .NET HttpListener class
Add-Type -TypeDefinition @"
using System;
using System.Net;
using System.Threading;
public class HttpServer
{
    private HttpListener _listener;
    private int _port;

    public HttpServer(int port)
    {
        _port = port;
        _listener = new HttpListener();
    }

    public void Start()
    {
        _listener.Prefixes.Add(String.Format("http://*:{0}/", _port));
        _listener.Start();
        Console.WriteLine("Listening on port {0}...", _port);

        while (true)
        {
            try
            {
                HttpListenerContext context = _listener.GetContext();
                HttpListenerRequest request = context.Request;
                HttpListenerResponse response = context.Response;

                string responseString = "hello-world-test";
                byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);

                response.ContentLength64 = buffer.Length;
                System.IO.Stream output = response.OutputStream;
                output.Write(buffer, 0, buffer.Length);
                output.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: {0}", ex.ToString());
            }
        }
    }
}
"@

# Create and start the server
$server = New-Object HttpServer(8080)
$server.Start()
