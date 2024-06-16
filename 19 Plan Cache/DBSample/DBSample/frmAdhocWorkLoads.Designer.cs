namespace DBSample
{
    partial class frmAdhocWorkLoads
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
            this.btnTest = new System.Windows.Forms.Button();
            this.txtCounter = new System.Windows.Forms.TextBox();
            this.lblCounter = new System.Windows.Forms.Label();
            this.lstQuery = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // btnTest
            // 
            this.btnTest.Location = new System.Drawing.Point(212, 38);
            this.btnTest.Name = "btnTest";
            this.btnTest.Size = new System.Drawing.Size(185, 23);
            this.btnTest.TabIndex = 0;
            this.btnTest.Text = "تست";
            this.btnTest.UseVisualStyleBackColor = true;
            this.btnTest.Click += new System.EventHandler(this.btnTest_Click);
            // 
            // txtCounter
            // 
            this.txtCounter.Location = new System.Drawing.Point(212, 11);
            this.txtCounter.Name = "txtCounter";
            this.txtCounter.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.txtCounter.Size = new System.Drawing.Size(100, 21);
            this.txtCounter.TabIndex = 1;
            this.txtCounter.Text = "1000";
            // 
            // lblCounter
            // 
            this.lblCounter.AutoSize = true;
            this.lblCounter.Location = new System.Drawing.Point(318, 14);
            this.lblCounter.Name = "lblCounter";
            this.lblCounter.Size = new System.Drawing.Size(75, 13);
            this.lblCounter.TabIndex = 2;
            this.lblCounter.Text = "تعداد Order ID";
            // 
            // lstQuery
            // 
            this.lstQuery.FormattingEnabled = true;
            this.lstQuery.Location = new System.Drawing.Point(0, 70);
            this.lstQuery.Name = "lstQuery";
            this.lstQuery.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.lstQuery.Size = new System.Drawing.Size(409, 238);
            this.lstQuery.TabIndex = 3;
            // 
            // frmAdhocWorkLoads
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(409, 314);
            this.Controls.Add(this.lstQuery);
            this.Controls.Add(this.lblCounter);
            this.Controls.Add(this.txtCounter);
            this.Controls.Add(this.btnTest);
            this.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(178)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "frmAdhocWorkLoads";
            this.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
            this.Text = "تست برای تنظیمات optimize for ad hoc workloads";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnTest;
        private System.Windows.Forms.TextBox txtCounter;
        private System.Windows.Forms.Label lblCounter;
        private System.Windows.Forms.ListBox lstQuery;
    }
}