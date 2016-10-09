/*
 * Created by SharpDevelop.
 * User: BITL-Gaming
 * Date: 10/7/2016
 * Time: 3:01 PM
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using System.IO;

namespace RBXLegacyLauncher
{
	/// <summary>
	/// Description of MainForm.
	/// </summary>
	public partial class MainForm : Form
	{
		public MainForm()
		{
			//
			// The InitializeComponent() call is required for Windows Forms designer support.
			//
			InitializeComponent();
			
			//
			// TODO: Add constructor code after the InitializeComponent() call.
			//
		}
		void tabControl1_SelectedIndexChanged(object sender, EventArgs e)
		{
     		if (tabControl1.SelectedTab == tabControl1.TabPages["tabPage2"])//your specific tabname
     		{
        		string mapdir = GlobalVars.ClientDir + @"\\content\\Maps";
				DirectoryInfo dinfo = new DirectoryInfo(mapdir);
				FileInfo[] Files = dinfo.GetFiles("*.rbxl");
				foreach( FileInfo file in Files )
				{
   					this.listBox1.Items.Add(file.Name);
				}
				this.listBox1.SelectedIndex = 0;
     		}
     		else
     		{
     			this.listBox1.Items.Clear();
     		}
		}
		void Button1Click(object sender, EventArgs e)
		{
			string luafile = GlobalVars.ClientDir + @"\\content\\Scripts\\CSMPFunctions.lua";
			string rbxexe = GlobalVars.ClientDir + @"\\RobloxApp.exe";
			string quote = "\"";
			string args = "-script " + quote + "dofile('" + luafile + "');  _G.CSConnect(0,'" + GlobalVars.IP + "',53640,'Player');" + quote;
			System.Diagnostics.Process.Start(rbxexe, args);
			if (GlobalVars.CloseOnLaunch == true)
			{
				this.Close();
			}
		}
		
		void Button2Click(object sender, EventArgs e)
		{
			string luafile = GlobalVars.ClientDir + @"\\content\\Scripts\\CSMPFunctions.lua";
			string mapfile = GlobalVars.ClientDir + @"\\content\\Maps\\" + GlobalVars.Map;
			string rbxexe = GlobalVars.ClientDir + @"\\RobloxApp.exe";
			string quote = "\"";
			string args = "-script " + quote + "dofile('" + luafile + "'); _G.CSServer(53640); game:Load('" + mapfile + "');" + quote;
			System.Diagnostics.Process.Start(rbxexe, args);
			if (GlobalVars.CloseOnLaunch == true)
			{
				this.Close();
			}
		}
		
		void MainFormLoad(object sender, EventArgs e)
		{
			GlobalVars.ClientDir = Path.Combine(Environment.CurrentDirectory, @"client");
			GlobalVars.ClientDir = GlobalVars.ClientDir.Replace(@"\",@"\\");
			label5.Text = GlobalVars.ClientDir;
			label8.Text = Application.ProductVersion;
			GlobalVars.IP = "localhost";
    		GlobalVars.Map = "Baseplate.rbxl";
    		GlobalVars.CloseOnLaunch = true;
    		string[] lines = File.ReadAllLines("version.txt"); //File is in System.IO
			string version = lines[0];
    		label11.Text = version;
		}
		
		void TextBox1TextChanged(object sender, EventArgs e)
		{
			GlobalVars.IP = textBox1.Text;
		}
		
		void ListBox1SelectedIndexChanged(object sender, EventArgs e)
		{
			GlobalVars.Map = listBox1.SelectedItem.ToString();
		}
		
		void CheckBox1CheckedChanged(object sender, EventArgs e)
		{
			if (checkBox1.Checked == true)
			{
				GlobalVars.CloseOnLaunch = true;
			}
			else if (checkBox1.Checked == false)
			{
				GlobalVars.CloseOnLaunch = false;
			}
		}
		
		void Button3Click(object sender, EventArgs e)
		{
			MessageBox.Show("If you want to test out your place, you will have to save your place, then go to Tools->Execute Script in ROBLOX Studio, and then load 'Play Solo.lua' from '"+ GlobalVars.ClientDir + @"\\content\\scripts'. " + "To edit your place again, you must restart ROBLOX Studio and load your place again to edit it.","RBXLegacy Launcher - Launch ROBLOX Studio", MessageBoxButtons.OK, MessageBoxIcon.Information);
			string rbxexe = GlobalVars.ClientDir + @"\\RobloxApp.exe";
			System.Diagnostics.Process.Start(rbxexe);
			if (GlobalVars.CloseOnLaunch == true)
			{
				this.Close();
			}
		}
	}
}
