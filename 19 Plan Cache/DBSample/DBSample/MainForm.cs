/*
Performance Tuning In SQL Server 2012
Site:        www.NikAmooz.com
Email:       Info@NikAmooz.com
Forum:       forum.NikAmooz.com
Created By:  Masoud Taheri
*/
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DBSample
{
    public partial class MainForm : Form
    {

        //public string ConnectionString = @"Provider=SQLNCLI11.1;Server=.;Database=Northwind;Uid=sa;Pwd=123456;";
        public string ConnectionString = @"Integrated Security=SSPI;Initial Catalog=Northwind;Data Source=.\SQLSERVER2017";
        //public string ConnectionString = @"Driver={SQL Server Native Client 11.1};Server=.;Trusted_Connection=Yes;Database=Northwind";


        public MainForm()
        {
            InitializeComponent();
        }

        //Ad-Hoc Query
        private void btnAdhocQuery_Click(object sender, EventArgs e)
        {
            string orderID = txtOrderID.Text.Trim();
            string queryText = "SELECT * FROM Orders WHERE OrderID=" + orderID;
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(queryText, connection))
                {
                    var sqlDataAdapter = new SqlDataAdapter(command);
                    var ds = new DataSet();
                    sqlDataAdapter.Fill(ds);
                    dataGridView1.DataSource = ds.Tables[0];
                }
            }
        }

        //SQL Parameter
        private void btnSQLParameter_Click(object sender, EventArgs e)
        {
            string orderID = txtOrderID.Text.Trim();
            var sqlCS = new SqlConnectionStringBuilder();
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand("SELECT * FROM Orders WHERE OrderID=@OrderID", connection))
                {
                   // command.Parameters.AddWithValue("OrderID", orderID);

                    //command.Parameters.AddWithValue("OrderID", int.Parse(orderID));
                    
                    
                    command.Parameters.Add("OrderID", SqlDbType.Int);
                    command.Parameters["OrderID"].Value = orderID;

                    
                   // command.Prepare();

                    var sqlDataAdapter = new SqlDataAdapter(command);
                    var ds = new DataSet();
                    sqlDataAdapter.Fill(ds);
                    dataGridView1.DataSource = ds.Tables[0];
                }
            }
        }

        //Stored Procedure
        private void btnStoredProcedure_Click(object sender, EventArgs e)
        {
            /*
                USE Northwind
                GO
                CREATE PROCEDURE usp_GetOrders
                (
	                @OrderID INT
                )
                AS
	                SELECT * FROM Orders
		                WHERE OrderID=@OrderID
                GO             
            */
            string orderID = txtOrderID.Text.Trim();
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand())
                {
                    command.Connection = connection;
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandText = "usp_GetOrders";
                    command.Parameters.Add(new SqlParameter("OrderID", orderID));
                    var sqlDataAdapter = new SqlDataAdapter(command);
                    var ds = new DataSet();
                    sqlDataAdapter.Fill(ds);
                    dataGridView1.DataSource = ds.Tables[0];
                }
            }
        }

        //Entity Framework
        private void btnEF_Click(object sender, EventArgs e)
        {
            int orderID = int.Parse(txtOrderID.Text.Trim());
            var northwindEntities = new NorthwindEntities();
            var ordersList = northwindEntities.Orders.Where(q => q.OrderID == orderID).ToList();
            dataGridView1.DataSource = ordersList;
        }

        private void btnSQLParameterWithPrepare_Click(object sender, EventArgs e)
        {
            string orderID = txtOrderID.Text.Trim();
            var sqlCS = new SqlConnectionStringBuilder();
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand("SELECT * FROM Orders WHERE OrderID=@OrderID", connection))
                {
                    command.Parameters.Add("OrderID", SqlDbType.Int);
                    command.Parameters["OrderID"].Value = orderID;
                    command.Prepare();
                    var sqlDataAdapter = new SqlDataAdapter(command);
                    var ds = new DataSet();
                    sqlDataAdapter.Fill(ds);
                    dataGridView1.DataSource = ds.Tables[0];
                }
            }
        }
    }
}
