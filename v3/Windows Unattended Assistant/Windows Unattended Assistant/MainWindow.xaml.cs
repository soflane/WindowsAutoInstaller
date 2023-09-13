/// https://zetcode.com/csharp/yaml/
/// https://stackoverflow.com/questions/40890869/accessing-key-from-yamldotnet-deserializer
/// https://wpf-tutorial.com/listview-control/listview-data-binding-item-template/
/// https://itecnote.com/tecnote/c-find-windows-drive-letter-of-a-removable-disk-from-usb-vid-pid/
/// 
/// https://help.syncfusion.com/windowsforms/combobox/selection#:~:text=the%20SelectedIndex%20property.-,Getting%20the%20selected%20value,the%20property%20bind%20to%20DisplayMember.
/// 
///using System;
///using System.Collections.Generic;
///using System.Linq;
///using System.Text;
///using System.Threading.Tasks;
using System.IO;
using System;
using System.Windows;
using System.Windows.Controls;
using YamlDotNet.RepresentationModel;
using System.Reflection;
using System.Collections.Generic;
using System.Collections;
using YamlDotNet.Serialization;
using System.Data;
using System.Collections.ObjectModel;
using YamlDotNet.Serialization.NamingConventions;
using System.Linq;
using System.Xml.Linq;
using System.Security.Policy;
using System.Windows.Documents;
using System.Windows.Shapes;
using System.Management;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Windows.Media.Animation;
using System.IO.Compression;
///using System.Windows.Controls;
///using System.Windows.Data;
///using System.Windows.Documents;
///using System.Windows.Input;
///using System.Windows.Media;
///using System.Windows.Media.Imaging;
///using System.Windows.Navigation;
///using System.Windows.Shapes;
///using YamlDotNet.Serialization;

namespace Windows_Unattended_Assistant
{
    public class CmBoxItem
    {
        public string Text { get; set; }
        public object Value { get; set; }

        public CmBoxItem(string Text, string Value) { 
            this.Text = Text;  
            this.Value = Value; 
        }
        public override string ToString()
        {
            return Text;
        }
    }
    public class Yaml
    {
        public String Hostname { get; set; }
        public Config Config { get; set; }
        public Wireless Wireless { get; set; }
        public User User { get; set; }
        public Features Features { get; set; }

        public List<string> ChocoApps { get; set; }
        public List<string> WingetApps { get; set; }
        public List<string> WinStoreApps { get; set; }
        public Yaml(string host, Config config, Wireless wireless, User user, Features features, WindowsTweaks tweaks, List<string> ChocoApps, List<string> WingetApps, List<string> WinStoreApps)
        {
            this.Hostname = host;
            this.Config = config;
            this.Wireless = wireless;
            this.User = user;
            this.Features = features;
            this.ChocoApps = ChocoApps;
            this.WingetApps = WingetApps;
            this.WinStoreApps = WinStoreApps;

        }
    }
    public class Config
    {
        public bool debug { get; set; }
        public string Lang { get; set; }
        public string VCLibs_URL { get; set; }
        public string WinGet_URL { get; set; }
        public string XAML_Runtime_URL { get; set; }

        public Config(bool debug, string lang, string VCLibs_URL, string WinGet_URL, string XAML_Runtime_URL) { 
            this.debug = debug;
            this.Lang = lang;
            this.VCLibs_URL = VCLibs_URL;
            this.WinGet_URL = WinGet_URL;
            this.XAML_Runtime_URL = XAML_Runtime_URL;
        }

    }

    public class Wireless
        {
        public bool connect { get; set; }
        public string SSID { get; set; }
        public string Password { get; set; }
        public string Encryption { get; set; }
        public string Authentication { get; set; }

        public Wireless(bool connect, string SSID, string Password, string Encryption, string Authentication) { 
            this.connect = connect;
            this.SSID = SSID;
            this.Password = Password;
            this.Encryption = Encryption;
            this.Authentication = Authentication;
        }

    }
    public class User
    {
        public string Name { get; set; }
        public string Display_Name { get; set; }
        public string Password { get; set; }
        public bool Uac_Ask_For_Password { get; set; }

        public User(string Name, string Display_Name, string Password, bool Uac_Ask_For_Password)
        {
            this.Name = Name;
            this.Display_Name = Display_Name;
            this.Password = Password;
            this.Uac_Ask_For_Password = Uac_Ask_For_Password;
        }

    }

    public class Features
    {
        public bool Install_Updates { get; set; }
        public bool Install_Drivers { get; set; }
        public bool Chocolatey { get; set; }
        public bool Winget { get; set; }
        public bool WinStore { get; set; }
        public bool WSL { get; set; }
        public int WSL_Version { get; set; }
        public string Anydesk_Custom_URL { get; set; }
        public string Anydesk_Password { get; set; }

        public Features(bool Install_Updates, bool Install_Drivers, bool Chocolatey, bool Winget, bool WinStore, bool WSL, int WSL_Version, string Anydesk_Custom_URL, string Anydesk_Password)
        {
            this.Install_Updates = Install_Updates;
            this.Install_Drivers = Install_Drivers;
            this.Chocolatey = Chocolatey;
            this.Winget = Winget;
            this.WinStore = WinStore;
            this.WSL = WSL;
            this.WSL_Version = WSL_Version;
            this.Anydesk_Custom_URL = Anydesk_Custom_URL;
            this.Anydesk_Password = Anydesk_Password;
        }
    }

    public class WindowsTweaks
    {
        public string Wallpaper_Path { get; set; }
        public bool Edge_Alt_Tab { get; set; }
        public string NewsAndInterest { get; set; }
        public bool NewsAndInterest_MouseHover { get; set; }
        public string SearchBox_Taskbar { get; set; }

        public WindowsTweaks(string Wallpaper_Path, bool Edge_Alt_Tab, string NewsAndInterest, bool NewsAndInterest_MouseHover, string SearchBox_Taskbar) { 
            this.Wallpaper_Path = Wallpaper_Path;
            this.Edge_Alt_Tab = Edge_Alt_Tab;
            this.NewsAndInterest = NewsAndInterest;
            this.NewsAndInterest_MouseHover = NewsAndInterest_MouseHover;
            this.SearchBox_Taskbar = SearchBox_Taskbar;
        }
    }

    class USBDeviceInfo
    {
        public USBDeviceInfo(string deviceCaption, string pnpDeviceID, string description, string driveLetters, string DrivePhysicalName)
        {
            this.deviceCaption = deviceCaption;
            this.PnpDeviceID = pnpDeviceID;
            this.Description = description;
            this.DriveLetters = driveLetters;
            this.DrivePhysicalName = DrivePhysicalName;
        }
        public string deviceCaption { get; private set; }

        public string PnpDeviceID { get; private set; }
        public string Description { get; private set; }
        public string DrivePhysicalName { get; private set; }


        public string DriveLetters { get; set; }

    }

    public class AppDetails
    {
        public bool IsSelected { get; set; }
        public string Name { get; set; }
        public string Category { get; set; }
        public string Id { get; set; }
        public AppDetails(string isSelected, string Category, string Name, string id)
        {
            string enable = isSelected.ToLower();
            if (enable.Equals("true") || enable.Equals("yes"))
            {
                this.IsSelected = true;
            }
            else
            {
                this.IsSelected = false;
            }
            this.Name = Name;
            this.Category = Category;
            this.Id = id;
        }
    }
   
    /// <summary>
    /// Logique d'interaction pour MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private ObservableCollection<AppDetails> ChocoItems = new ObservableCollection<AppDetails>();
        private ObservableCollection<AppDetails> WinGetItems = new ObservableCollection<AppDetails>();
        private ObservableCollection<AppDetails> WinStoreItems = new ObservableCollection<AppDetails>();

        private string _tempPath = Environment.GetEnvironmentVariable("TEMP") + @"\";
        private string _zipPath = Environment.GetEnvironmentVariable("TEMP") + @"\" + @"MyZip.zip";


        private void ExtractZip(char drive)
        {
            try
            {
                //write the resource zip file to the temp directory
                using (Stream stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("Windows_Unattended_Assistant.sources.zip"))
                {
                    using (FileStream bw = new FileStream(_zipPath, FileMode.Create))
                    {
                        //read until we reach the end of the file
                        while (stream.Position < stream.Length)
                        {
                            //byte array to hold file bytes
                            byte[] bits = new byte[stream.Length];
                            //read in the bytes
                            stream.Read(bits, 0, (int)stream.Length);
                            //write out the bytes
                            bw.Write(bits, 0, (int)stream.Length);
                        }
                    }
                    stream.Close();
                }

                //extract the contents of the file we created
                UnzipFile(_zipPath, _tempPath);
                //or
                ZipFile.ExtractToDirectory(_zipPath, drive +":\\");

            }
            catch (Exception e)
            {
                //handle the error
            }
        }



        public void UnzipFile(string zipPath, string folderPath)
        {
            try
            {
                if (!File.Exists(zipPath))
                {
                    throw new FileNotFoundException();
                }
                if (!Directory.Exists(folderPath))
                {
                    Directory.CreateDirectory(folderPath);
                }
                Shell32.Shell objShell = new Shell32.Shell();
                Shell32.Folder destinationFolder = objShell.NameSpace(folderPath);
                Shell32.Folder sourceFile = objShell.NameSpace(zipPath);
                foreach (var file in sourceFile.Items())
                {
                    destinationFolder.CopyHere(file, 4 | 16);
                }
            }
            catch (Exception e)
            {
                //handle error
            }
        }

        private void loadYamlFile(ListView lv, string yamlPath, ObservableCollection<AppDetails> Items)
        {
            /// Clearing ListView just in case 
            lv.Items.Clear();
            Items.Clear();
            string data = File.ReadAllText(yamlPath);
            var sr = new StringReader(data);
            var yaml = new YamlStream();
            yaml.Load(sr);
            int n = yaml.Documents.Count;
            for (int i = 0; i < n; i++)
            {
                YamlMappingNode root = (YamlMappingNode)yaml.Documents[i].RootNode;
                foreach (var e in root.Children)
                {
                    string category = (string)e.Key;
                    string name, id, enable;
                    name = id = enable = string.Empty;
                    bool isChecked = false;


                    YamlSequenceNode childs = (YamlSequenceNode)e.Value;
                    foreach (var param in childs)
                    {
                        name = param["Name"].ToString();
                        id = param["id"].ToString();
                        enable = param["Enabled"].ToString();
                        Items.Add(new AppDetails(enable, category, name, id));
                    }
                }
                lv.ItemsSource = Items;
            }
        }
        public string GetEmbeddedResource(string namespacename, string filename)
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = namespacename + "." + filename;

            using (Stream stream = assembly.GetManifestResourceStream(resourceName))
            using (StreamReader reader = new StreamReader(stream))
            {
                string result = reader.ReadToEnd();
                return result;
            }
        }
        public Stream GetResourceStream(string namespacename, string filename)
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = namespacename + "." + filename;

            using (Stream stream = assembly.GetManifestResourceStream(resourceName))
            using (StreamReader reader = new StreamReader(stream))
            {
                return stream;
            }
        }
        private void loadYamlRessource(ListView lv, string yamlPath, ObservableCollection<AppDetails> Items)
        {
            /// Clearing ListView just in case 
            lv.Items.Clear();
            Items.Clear();
            string data = GetEmbeddedResource("Windows_Unattended_Assistant", yamlPath);
            var sr = new StringReader(data);
            var yaml = new YamlStream();
            yaml.Load(sr);
            int n = yaml.Documents.Count;
            for (int i = 0; i < n; i++)
            {
                YamlMappingNode root = (YamlMappingNode)yaml.Documents[i].RootNode;
                foreach (var e in root.Children)
                {
                    string category = (string)e.Key;
                    string name, id, enable;
                    name = id = enable = string.Empty;
                    bool isChecked = false;


                    YamlSequenceNode childs = (YamlSequenceNode)e.Value;
                    foreach (var param in childs)
                    {
                        name = param["Name"].ToString();
                        id = param["id"].ToString();
                        enable = param["Enabled"].ToString();
                        Items.Add(new AppDetails(enable, category, name, id));
                    }
                }
                lv.ItemsSource = Items;
            }
        }

        public MainWindow()
        {
            InitializeComponent();
            /// Read local config files if there is any 
            /// 
            
            if (File.Exists("Apps-Choco.yaml")) 
            { 
                Console.WriteLine("Specified file exists. Apps-Choco.yaml");
                loadYamlFile(Lv_ChocoPackages, "Apps-Choco.yaml", ChocoItems);
            } else
            {
                Console.WriteLine("Specified file does not exist in the current directory. Reading default file: config.choco.yaml");
                loadYamlRessource(Lv_ChocoPackages, "config.choco.yaml", ChocoItems);
            }
            if (File.Exists("Apps-WinGet.yaml"))
            {
                Console.WriteLine("Specified file exists. Apps-WinGet.yaml");
                loadYamlFile(Lv_WinGetPackages, "Apps-WinGet.yaml", WinGetItems);
            }
            else
            {
                Console.WriteLine("Specified file does not exist in the current directory. Reading default file: config.winget.yaml");
                loadYamlRessource(Lv_WinGetPackages, "config.winget.yaml", WinGetItems);
            }
            if (File.Exists("Apps-WinStore.yaml"))
            {
                Console.WriteLine("Specified file exists. Apps-WinStore.yaml ");
                loadYamlFile(Lv_WinStorePackages, "Apps-WinStore.yaml", WinStoreItems);
            }
            else
            {
                Console.WriteLine("Specified file does not exist in the current directory. Reading default file: config.winstore.yaml");
                loadYamlRessource(Lv_WinStorePackages, "config.winstore.yaml", WinStoreItems);
            }

            /// languages setting
            ///
            this.ComboBox_Language.Items.Add(new CmBoxItem("French (Belgium)", "fr_BE"));
            this.ComboBox_Language.Items.Add(new CmBoxItem("French (France)", "fr_FR"));
            this.ComboBox_Language.Items.Add(new CmBoxItem("Nederlands (België)", "nl_BE"));
            this.ComboBox_Language.SelectedIndex = 0;

            /// Ensure no Gui items are wrongly enabled
            /// 

            this.Label_SSID.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Label_WiFIPw.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Input_SSID.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Input_WiFiPW.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.ComboBox_WiFiEncryption.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.ComboBox_WirelessAuthentication.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Radio_WSL1.IsEnabled = (bool)this.CheckBox_InstallWSL.IsChecked;
            this.Radio_WSL2.IsEnabled = (bool)this.CheckBox_InstallWSL.IsChecked;
            ///this.Input_UserPw.IsEnabled = (bool)this.CheckBox_AskUACPassword.IsChecked;
            this.Lv_ChocoPackages.IsEnabled = (bool)this.CheckBox_Chocolatey.IsChecked;
            this.Lv_WinStorePackages.IsEnabled = (bool)this.CheckBox_WinStore.IsChecked;
            this.Lv_WinGetPackages.IsEnabled = (bool)this.CheckBox_WinGet.IsChecked;
            this.Input_AnyDesk_PW.IsEnabled = (bool)this.CheckBox_AnyDesk_PW.IsChecked;
            this.Input_AnyDesk_URL.IsEnabled = (bool)this.CheckBox_AnyDesk_URL.IsChecked;

        }

        private void CheckBox_WSL_Click(object sender, RoutedEventArgs e)
        {
            this.Radio_WSL1.IsEnabled = (bool) this.CheckBox_InstallWSL.IsChecked;
            this.Radio_WSL2.IsEnabled = (bool) this.CheckBox_InstallWSL.IsChecked;
            ///this.Radio_WSL2.Enabled = this.CheckBox_InstallWSL.Checked;
        }

        private void DataGrid_ChocoApps_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
        }

        private void CheckBox_UseWireless_Click(object sender, RoutedEventArgs e)
        {
            this.Label_SSID.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Label_WiFIPw.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Input_SSID.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.Input_WiFiPW.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.ComboBox_WiFiEncryption.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
            this.ComboBox_WirelessAuthentication.IsEnabled = (bool)this.CheckBox_UseWireless.IsChecked;
        }
        private void CheckBox_Anydesk_Click(object sender, RoutedEventArgs e)
        {
            this.Input_AnyDesk_PW.IsEnabled = (bool)this.CheckBox_AnyDesk_PW.IsChecked;
            this.Input_AnyDesk_URL.IsEnabled = (bool)this.CheckBox_AnyDesk_URL.IsChecked;
        }

        private void CheckBox_Chocolatey_Click(object sender, RoutedEventArgs e)
        {
            this.Lv_ChocoPackages.IsEnabled = (bool)this.CheckBox_Chocolatey.IsChecked;
        }

        private void CheckBox_WinGet_Click(object sender, RoutedEventArgs e)
        {
            this.Lv_WinGetPackages.IsEnabled = (bool)this.CheckBox_WinGet.IsChecked;
        }

        private void CheckBox_WinStore_Click(object sender, RoutedEventArgs e)
        {
            this.Lv_WinStorePackages.IsEnabled = (bool)this.CheckBox_WinStore.IsChecked;
        }

        private void Btn_Go_Click(object sender, RoutedEventArgs e)
        {
            Config conf = new Config(
                (bool)this.CheckBox_Debug.IsChecked,
                (string)(this.ComboBox_Language.SelectedItem as CmBoxItem).Value,
                "https://shurl.tech/VCLibs.x64",
                "https://aka.ms/getwinget",
                "https://shurl.tech/Microsoft.UI.Xaml"
                );
            Wireless net = new Wireless(
                (bool)this.CheckBox_UseWireless.IsChecked,
                (string)this.Input_SSID.Text, this.Input_WiFiPW.Password,
                (string)this.ComboBox_WiFiEncryption.Text,
                (string)this.ComboBox_WirelessAuthentication.Text
                );
            User user = new User(
                (string)this.Input_UserName.Text,
                (string)this.Input_User_FullName.Text,
                (string)this.Input_UserPw.Password,
                (bool)this.CheckBox_AskUACPassword.IsChecked
                );
            ///(bool Install_Updates, bool Install_Drivers, bool Chocolatey, bool Winget, bool WinStore, bool WSL, int WSL_Version, string Anydesk_Custom_URL, string Anydesk_Password)
            string AnyDeskURL = "";
            string AnyDeskPW = "";
            int wsl = 2;
            if ((bool)this.CheckBox_AnyDesk_URL.IsChecked)
            {
                AnyDeskURL = this.Input_AnyDesk_URL.Text;
            }
            if ((bool)this.CheckBox_AnyDesk_PW.IsChecked)
            {
                AnyDeskPW = this.Input_AnyDesk_PW.Password;
            }
            if ((bool)this.Radio_WSL1.IsChecked)
            {
                wsl = 1;
            }
            Features feat = new Features(
                (bool)this.CheckBox_WinUpdates.IsChecked,
                (bool)this.CheckBox_WinUpdatesDrivers.IsChecked,
                (bool)this.CheckBox_Chocolatey.IsChecked,
                (bool)this.CheckBox_WinGet.IsChecked,
                (bool)this.CheckBox_WinStore.IsChecked,
                (bool)this.CheckBox_InstallWSL.IsChecked,
                wsl,
                AnyDeskURL,
                AnyDeskPW
                );
            ///(string Wallpaper_Path, bool Edge_Alt_Tab, string NewsAndInterest, bool NewsAndInterest_MouseHover, string SearchBox_Taskbar)
            string newsInterest = "";
            if ((bool)this.Radio_Win10.IsChecked)
            {
                newsInterest = this.ComboBox_Tweaks_NewsInterest.Text;
            }
            WindowsTweaks tweaks = new WindowsTweaks(
                "",
                (bool)!this.CheckBox_DisableEdgeAltTab.IsChecked,
                newsInterest,
                (bool)!this.CheckBox_DisbableMouseHover.IsChecked,
                this.ComboBox_Tweaks_SearchBox.Text
                );


            List<string> WinGetappList = new List<string>(new string[] { });
            foreach (AppDetails item in this.Lv_WinGetPackages.ItemsSource)
            {
                if (item.IsSelected)
                {
                    Console.WriteLine(item.Id);
                    WinGetappList.Add(item.Id);
                }
            }
            List<string> WinStoreAppList = new List<string>(new string[] { });
            foreach (AppDetails item in this.Lv_WinStorePackages.ItemsSource)
            {
                if (item.IsSelected)
                {
                    Console.WriteLine(item.Id);
                    WinStoreAppList.Add(item.Id);
                }
            }
            List<string> ChocoAppList = new List<string>(new string[] { });
            foreach (AppDetails item in this.Lv_ChocoPackages.ItemsSource)
            {
                if (item.IsSelected)
                {
                    Console.WriteLine(item.Id);
                    ChocoAppList.Add(item.Id);
                }
            }

            Yaml app = new Yaml(
                this.Input_Hostname.Text,
                conf,
                net,
                user,
                feat,
                tweaks,
                ChocoAppList,
                WinGetappList,
                WinStoreAppList
                );
            char driveToCopy = (ComboBox_Drives.SelectedItem as CmBoxItem).Value.ToString()[0];
            ExtractZip(driveToCopy);
            string oobePath = driveToCopy + ":\\sources\\$OEM$\\$1\\Setup\\Config.yaml";
            ////Console.WriteLine(app)
            var writer = new StreamWriter(oobePath);
            var serializer = new YamlDotNet.Serialization.Serializer();
            serializer.Serialize(writer, app);
            writer.Close();
        }

        private void Btn_Refresh_USBList_Click(object sender, RoutedEventArgs e)
        {
            var usbDevices = GetUSBDevices();
            this.ComboBox_Drives.Items.Clear();
            foreach (var usbDevice in usbDevices)
            {
                Console.WriteLine(
                    $"Device Name:     {usbDevice.deviceCaption}");
                Console.WriteLine(
                    $"PNP Device ID:   {usbDevice.PnpDeviceID}");
                Console.WriteLine(
                    $"Description:     {usbDevice.Description}");
                Console.WriteLine(
                    $"Physical adress: {usbDevice.DrivePhysicalName}");
                foreach (var dev in usbDevice.DriveLetters)
                {
                    Console.WriteLine(
                    $"Drive: {dev}");
                }
                ///this.ComboBox_Drives.Items.Add("(" + usbDevice.DriveLetters[0] + ":) " + usbDevice.deviceCaption);
                this.ComboBox_Drives.Items.Add(new CmBoxItem("(" + usbDevice.DriveLetters[0] + ":) " + usbDevice.deviceCaption, usbDevice.DriveLetters[0].ToString())); 
            }
            if (usbDevices.Count > 0)
            {
                this.Btn_Go.IsEnabled = true;
            }
        }
        static List<USBDeviceInfo> GetUSBDevices()
        {
            List<USBDeviceInfo> devices = new List<USBDeviceInfo>();
            /// For USB Flash drives only
            var searcher = new ManagementObjectSearcher(
                @"Select * From Win32_PnPEntity Where DeviceID like 'USBSTOR%'");
            /// For all type of USB device
            ///var searcher = new ManagementObjectSearcher(
            ///    @"Select * From Win32_PnPEntity Where DeviceID like 'USB%'"); 
            ManagementObjectCollection collection = searcher.Get();
            foreach (var device in collection)
            {
                List<string> DriveLetters = new List<string>();
                foreach (ManagementObject drive in new ManagementObjectSearcher("SELECT DeviceID FROM Win32_DiskDrive WHERE PNPDeviceID='" +((string)device.GetPropertyValue("PNPDeviceID")).Replace(@"\", @"\\") + "'").Get())
                {
                    string devName = "";
                    foreach (PropertyData usb in drive.Properties)
                    {
                        if (usb.Value != null && usb.Value.ToString() != "")
                        {
                            ///Console.WriteLine("usb name : " + usb.Name + "=");
                            ///Console.WriteLine("usb Value : " + usb.Value + "\r\n");
                            devName = usb.Value.ToString();
                        }
                    }

                    // associate physical disks with partitions
                    foreach (ManagementObject partition in new ManagementObjectSearcher("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" + drive["DeviceID"] + "'} WHERE AssocClass=Win32_DiskDriveToDiskPartition").Get())
                    {
                        // associate partitions with logical disks (drive letter volumes)
                        foreach (ManagementObject disk in new ManagementObjectSearcher("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" + partition["DeviceID"] + "'} WHERE AssocClass=Win32_LogicalDiskToPartition").Get())
                        {
                            //Console.WriteLine("usb DeviceID : " + (string)disk["DeviceID"]);
                            ///DriveLetters.Add((string)disk["DeviceID"]);
                            ///
                            devices.Add(new USBDeviceInfo(
                            (string)device.GetPropertyValue("Caption"),
                            (string)device.GetPropertyValue("PNPDeviceID"),
                            (string)device.GetPropertyValue("Description"),
                            (string)disk["DeviceID"],
                            devName
                            ));
                        }
                    }
               
                }
                /*Console.WriteLine("---------------------------------------------------------------------------" );
                Console.WriteLine("Device Availability : " + (string)device.GetPropertyValue("Availability"));
                Console.WriteLine("Device NAME : " + (string)device.GetPropertyValue("Name"));
                Console.WriteLine("Device Caption : " + (string)device.GetPropertyValue("Caption"));
                Console.WriteLine("Device DeviceID : " + (string)device.GetPropertyValue("DeviceID"));
                Console.WriteLine("Device Description : " + (string)device.GetPropertyValue("Description"));
                Console.WriteLine("Device SystemName : " + (string)device.GetPropertyValue("SystemName"));
                Console.WriteLine("Device Status : " + (string)device.GetPropertyValue("Status"));
                Console.WriteLine("Device CreationClassName : " + (string)device.GetPropertyValue("CreationClassName"));
                Console.WriteLine("Device Description : " + (string)device.GetPropertyValue("Description"));
                Console.WriteLine("Device ErrorDescription : " + (string)device.GetPropertyValue("ErrorDescription"));
                Console.WriteLine("------------------------------------------------------------------------------");
                Console.WriteLine("ok");
                */
            }
            return devices;
        }

        private void Radio_Win10_Checked(object sender, RoutedEventArgs e)
        {
            this.ComboBox_Tweaks_NewsInterest.IsEditable = true;
            this.Label_Tweaks_NewsInterest.IsEnabled = true;
        }

        private void Radio_Win11_Checked(object sender, RoutedEventArgs e)
        {
            this.Label_Tweaks_NewsInterest.IsEnabled=false;
            this.ComboBox_Tweaks_NewsInterest.IsEnabled = false;
        }
    }
}
