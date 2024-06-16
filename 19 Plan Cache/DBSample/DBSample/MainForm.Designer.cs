namespace DBSample
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnAdhocQuery = new System.Windows.Forms.Button();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.label1 = new System.Windows.Forms.Label();
            this.txtOrderID = new System.Windows.Forms.TextBox();
            this.btnSQLParameter = new System.Windows.Forms.Button();
            this.btnStoredProcedure = new System.Windows.Forms.Button();
            this.btnEF = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.btnSQLParameterWithPrepare = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // btnAdhocQuery
            // 
            this.btnAdhocQuery.Location = new System.Drawing.Point(12, 32);
            this.btnAdhocQuery.Name = "btnAdhocQuery";
            this.btnAdhocQuery.Size = new System.Drawing.Size(153, 23);
            this.btnAdhocQuery.TabIndex = 0;
            this.btnAdhocQuery.Text = "Ad-hoc Query";
            this.btnAdhocQuery.UseVisualStyleBackColor = true;
            this.btnAdhocQuery.Click += new System.EventHandler(this.btnAdhocQuery_Click);
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(12, 90);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.Size = new System.Drawing.Size(630, 177);
            this.dataGridView1.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(47, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Order ID";
            // 
            // txtOrderID
            // 
            this.txtOrderID.Location = new System.Drawing.Point(65, 6);
            this.txtOrderID.Name = "txtOrderID";
            this.txtOrderID.Size = new System.Drawing.Size(100, 20);
            this.txtOrderID.TabIndex = 3;
            // 
            // btnSQLParameter
            // 
            this.btnSQLParameter.Location = new System.Drawing.Point(171, 32);
            this.btnSQLParameter.Name = "btnSQLParameter";
            this.btnSQLParameter.Size = new System.Drawing.Size(153, 23);
            this.btnSQLParameter.TabIndex = 4;
            this.btnSQLParameter.Text = "SQL Parameter";
            this.btnSQLParameter.UseVisualStyleBackColor = true;
            this.btnSQLParameter.Click += new System.EventHandler(this.btnSQLParameter_Click);
            // 
            // btnStoredProcedure
            // 
            this.btnStoredProcedure.Location = new System.Drawing.Point(330, 32);
            this.btnStoredProcedure.Name = "btnStoredProcedure";
            this.btnStoredProcedure.Size = new System.Drawing.Size(153, 23);
            this.btnStoredProcedure.TabIndex = 5;
            this.btnStoredProcedure.Text = "Stored Procedure";
            this.btnStoredProcedure.UseVisualStyleBackColor = true;
            this.btnStoredProcedure.Click += new System.EventHandler(this.btnStoredProcedure_Click);
            // 
            // btnEF
            // 
            this.btnEF.Location = new System.Drawing.Point(489, 32);
            this.btnEF.Name = "btnEF";
            this.btnEF.Size = new System.Drawing.Size(153, 23);
            this.btnEF.TabIndex = 6;
            this.btnEF.Text = "Entity Framework";
            this.btnEF.UseVisualStyleBackColor = true;
            this.btnEF.Click += new System.EventHandler(this.btnEF_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.ForeColor = System.Drawing.Color.Blue;
            this.label2.Location = new System.Drawing.Point(12, 270);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(249, 52);
            this.label2.TabIndex = 7;
            this.label2.Text = "Site:        www.NikAmooz.com\r\nEmail:       Info@NikAmooz.com\r\nTelegram : https:/" +
    "/telegram.me/nikamooz\r\n\r\n";
            // 
            // btnSQLParameterWithPrepare
            // 
            this.btnSQLParameterWithPrepare.Location = new System.Drawing.Point(171, 61);
            this.btnSQLParameterWithPrepare.Name = "btnSQLParameterWithPrepare";
            this.btnSQLParameterWithPrepare.Size = new System.Drawing.Size(153, 23);
            this.btnSQLParameterWithPrepare.TabIndex = 8;
            this.btnSQLParameterWithPrepare.Text = "SQL Parameter With Prepare";
            this.btnSQLParameterWithPrepare.UseVisualStyleBackColor = true;
            this.btnSQLParameterWithPrepare.Click += new System.EventHandler(this.btnSQLParameterWithPrepare_Click);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(648, 331);
            this.Controls.Add(this.btnSQLParameterWithPrepare);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnEF);
            this.Controls.Add(this.btnStoredProcedure);
            this.Controls.Add(this.btnSQLParameter);
            this.Controls.Add(this.txtOrderID);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.btnAdhocQuery);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "MainForm";
            this.Text = "Query Tester";
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnAdhocQuery;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtOrderID;
        private System.Windows.Forms.Button btnSQLParameter;
        private System.Windows.Forms.Button btnStoredProcedure;
        private System.Windows.Forms.Button btnEF;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnSQLParameterWithPrepare;
    }
}

