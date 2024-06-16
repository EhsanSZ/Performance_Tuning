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

namespace DBSample
{
    public partial class frmAdhocWorkLoads : Form
    {
        public frmAdhocWorkLoads()
        {
            InitializeComponent();
        }
        public string ConnectionString = @"Integrated Security=SSPI;Initial Catalog=AdventureWorks2017;Data Source=.\SQLSERVER2017";

        private void btnTest_Click(object sender, EventArgs e)
        {
            string SalesOrderDetailID = "";
            string queryText = "";
            lstQuery.Items.Clear();
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                for (int i = 1; i < int.Parse(txtCounter.Text); i++)
                {
                    using (SqlCommand command = new SqlCommand(queryText, connection))
                    {
                        SalesOrderDetailID = i.ToString();
                        queryText = "SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderDetailID =" + SalesOrderDetailID;
                        lstQuery.Items.Add(queryText);
                        command.CommandText = queryText;
                        using (var sqlQueryResult = command.ExecuteReader()) { }
                    }
                }
            }
        }
    }
}
