using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TVP_Test
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            int customerId = 100;
            DateTime orderDate = System.DateTime.Now;


            var details = new DataTable();
            details.Columns.Add("ProductId", typeof(int));
            details.Columns.Add("Quantity", typeof(decimal));
            details.Columns.Add("Price", typeof(int));

            details.Rows.Add(new object[] { 100, 2, 100000 });
            details.Rows.Add(new object[] { 101, 20, 300000 });
            details.Rows.Add(new object[] { 102, 7, 20000 });
            details.Rows.Add(new object[] { 103, 10, 40000 });



            using (var conn = new SqlConnection(@"Data Source=.\SQLServer2017;Initial Catalog=Temp_Test;Integrated Security=True;"))
            {
                conn.Open();
                using (var cmd = new SqlCommand("InsertOrders", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@CustomerId", customerId);
                    cmd.Parameters.AddWithValue("@OrderDate", orderDate);

                    var detailsParam = cmd.Parameters.AddWithValue("@OrderDetails", details);
                    detailsParam.SqlDbType = SqlDbType.Structured;


                    cmd.ExecuteNonQuery();
                }
                conn.Close();
            }
        }
    }
}
