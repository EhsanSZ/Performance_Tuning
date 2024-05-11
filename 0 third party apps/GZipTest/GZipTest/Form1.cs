using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace GZipTest
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string queryString =
                "SELECT top 1 Comments from Customers_Compress;";
            string connectionString = @"Data Source=.\SQLSERVER2017;Initial Catalog=NikAmoozDB2017;"
            + "Integrated Security=SSPI";

            using (SqlConnection connection =
                       new SqlConnection(connectionString))
            {
                SqlCommand command =
                    new SqlCommand(queryString, connection);
                connection.Open();

                SqlDataReader reader = command.ExecuteReader();

                // Call Read before accessing data.
                while (reader.Read())
                {
                    MemoryStream ms = new MemoryStream((byte[])reader["Comments"]);
                    GZipStream gz = new GZipStream(ms, CompressionMode.Decompress);
                    StreamReader sr = new StreamReader(gz);
                    MessageBox.Show(sr.ReadToEnd());
                }

                // Call Close when done reading.
                reader.Close();
            }
        }
    }


}
