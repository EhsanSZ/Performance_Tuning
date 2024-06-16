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

namespace SPTest
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (var con = new SqlConnection(@"Persist Security Info=False;User ID=Sa;Password=123456;Initial Catalog=NikAmoozDB2017;Data Source=.\SQLSERVER2017;Application Name=AccApp"))
            {
                try
                {
                    using (SqlCommand cmd = new SqlCommand("ShowMsg", con))
                    {
                        con.Open();
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@FirstName", "T1");
                        cmd.Parameters.AddWithValue("@LastName", "T2");
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("خطایی در سیستم رخ داده است " + Environment.NewLine + ex.ToString(), "اخطار", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                }
                finally
                {
                    con.Close();
                }
            }
        }
    }
}
