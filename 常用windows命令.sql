cmd > wmic
wmic:root\cli>product get /?

属性获取操作。
用法:

GET [<属性列表>] [<获取开关>]
注意: <属性列表> ::= <属性名称> | <属性名称>,  <属性列表>

可以使用以下属性:
属性                            类型                    操作
========                                ====                    =========
Description                             N/A                     N/A
IdentifyingNumber                       N/A                     N/A
InstallDate                             N/A                     N/A
InstallLocation                         N/A                     N/A
InstallState                            N/A                     N/A
Name                                    N/A                     N/A
PackageCache                            N/A                     N/A
SKUNumber                               N/A                     N/A
Vendor                                  N/A                     N/A
Version                                 N/A                     N/A

可以使用以下 GET 开关:

/VALUE                       - 返回值。
/ALL(默认)                - 返回属性的数据和元数据。
/TRANSLATE:<表名称>      - 通过 <表名称> 中的值转换输出。
/EVERY:<间隔> [/REPEAT:<重复计数>] - 如果 /REPEAT 已指定命令执行 <重复计数> 次，则每(X 间隔)秒返回值。
/FORMAT:<格式说明符>   - 处理 XML 结果的关键字/XSL 文件名。

注意: /TRANSLATE 和 /FORMAT 开关的顺序会影响输出外观。
第一种情况: 如果 /TRANSLATE 位于 /FORMAT 之前，则编排格式会跟在结果转换之后。
第二种情况: 如果 /TRANSLATE 位于 /FORMAT 之后，则转换已编排了格式的结果。
\


wmic:root\cli>product where name='xshell 5'
AssignmentType  Caption   Description  HelpLink                                       HelpTelephone      IdentifyingNumber                       InstallDate  InstallDate2  InstallLocation                             InstallSource                                                              InstallState  Language  LocalPackage                       Name      PackageCache                       PackageCode                             PackageName   ProductID  RegCompany  RegOwner  SKUNumber  Transforms                                                            URLInfoAbout              URLUpdateInfo                                    Vendor                    Version   WordCount
1               Xshell 5  Xshell 5     http://www.netsarang.com/support/support.html  +1 (408) 432-5087  {F3FDFD5A-A201-407B-887F-399484764ECA}  20180222                   C:\Program Files (x86)\NetSarang\Xshell 5\  C:\Users\rgwei\AppData\Local\Temp\{080ED2FD-81E7-4640-BA05-8BF85E91CE76}\  5             0         C:\WINDOWS\Installer\29f7a7b4.msi  Xshell 5  C:\WINDOWS\Installer\29f7a7b4.msi  {4C99938F-338B-4441-BBBA-A4384FED3CFB}  Xshell 5.msi                                              C:\WINDOWS\Installer\{F3FDFD5A-A201-407B-887F-399484764ECA}\2052.MST  http://www.netsarang.com  http://www.netsarang.com/download/download.html  NetSarang Computer, Inc.  5.0.1339  0


wmic:root\cli>product get name,version,helplink,URLInfoAbout
HelpLink                                          Name                                                                                                              URLInfoAbout                                      Version
                                                  Shared Add-in Extensibility Update for Microsoft .NET Framework 2.0 (KB908002)                                                                                      1.0.0
                                                  Microsoft Visual C++ Compiler Package for Python 2.7                                                                                                                9.0.1.30729
                                                  MySQL Connector C 6.0.2                                                                                                                                             6.0.2
                                                  Microsoft Office Professional Plus 2010                                                                                                                             14.0.4763.1000
                                                  Microsoft Office OneNote MUI (Chinese (Simplified)) 2010                                                                                                            14.0.4763.1000
                                                  Microsoft Office InfoPath MUI (Chinese (Simplified)) 2010                                                                                                           14.0.4763.1000
                                                  Microsoft Office 2010 Primary Interop Assemblies                                                                                                                    14.0.4763.1024
                                                  Microsoft Office Access MUI (Chinese (Simplified)) 2010                                                                                                             14.0.4763.1000
                                                  Microsoft Office Excel MUI (Chinese (Simplified)) 2010                                                                                                              14.0.4763.1000
                                                  Microsoft Office PowerPoint MUI (Chinese (Simplified)) 2010                                                                                                         14.0.4763.1000
                                                  Microsoft Office IME (Chinese (Simplified)) 2010                                                                                                                    14.0.4763.1000
                                                  Microsoft Office IME (Chinese (Simplified)) 2010                                                                                                                    14.0.4763.1000
                                                  Microsoft Office Publisher MUI (Chinese (Simplified)) 2010                                                                                                          14.0.4763.1000
                                                  Microsoft Office Outlook MUI (Chinese (Simplified)) 2010                                                                                                            14.0.4763.1000
                                                  Microsoft Office Office 64-bit Components 2010                                                                                                                      14.0.4763.1000
                                                  Microsoft Office Shared 64-bit MUI (Chinese (Simplified)) 2010                                                                                                      14.0.4763.1000
                                                  Microsoft Office Groove MUI (Chinese (Simplified)) 2010                                                                                                             14.0.4763.1000
                                                  Microsoft Office Word MUI (Chinese (Simplified)) 2010                                                                                                               14.0.4763.1000
                                                  Microsoft Office Proofing (Chinese (Simplified)) 2010                                                                                                               14.0.4763.1000
                                                  Microsoft Office Shared MUI (Chinese (Simplified)) 2010                                                                                                             14.0.4763.1000
                                                  Microsoft Office Proof (Chinese (Simplified)) 2010                                                                                                                  14.0.4763.1000
                                                  Microsoft Office Proof (English) 2010                                                                                                                               14.0.4763.1000
www.vmware.com/cn/support                         VMware Workstation                                                                                                                                                  12.5.2
                                                  MySQL Workbench 6.3 CE                                                                                            http://mysql.com/products/workbench/              6.3.9
http://go.microsoft.com/fwlink/?LinkId=133405     Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.21005                                                                                                          12.0.21005
http://go.microsoft.com/fwlink/?LinkId=133405     Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.21005                                                                                                       12.0.21005
                                                  Intel(R) Serial IO                                                                                                                                                  30.100.1633.03
                                                  Node.js                                                                                                                                                             10.4.0
http://go.microsoft.com/fwlink/?LinkId=133405     Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.23026                                                                                                       14.0.23026
                                                  Microsoft Visual J# 2.0 Redistributable Package                                                                                                                     2.0.50727
                                                  Intel(R) Management Engine Components                                                                                                                               1.0.0.0
                                                  Microsoft HEVC Media Extension Installation for Microsoft.HEVCVideoExtension_1.0.2512.0_x64__8wekyb3d8bbwe (x64)                                                    1.0.0.0
http://go.microsoft.com/fwlink/?LinkId=133405     Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.60610                                                                                                          11.0.60610
http://www.openoffice.org                         OpenOffice 4.1.2                                                                                                  http://www.openoffice.org                         4.12.9782
http://java.com/help                              Java 8 Update 181 (64-bit)                                                                                        http://java.com                                   8.0.1810.13
http://java.com/help                              Java SE Development Kit 8 Update 181 (64-bit)                                                                     http://java.com                                   8.0.1810.13
http://go.microsoft.com/fwlink/?LinkId=133405     Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026                                                                                                          14.0.23026
http://www.netsarang.com/support/support.html     Xftp 5                                                                                                            http://www.netsarang.com                          5.0.1235
                                                  Python 2.7.14 (64-bit)                                                                                                                                              2.7.14150
                                                  Intel(R) ME UninstallLegacy                                                                                                                                         1.0.1.0
                                                  Intel(R) Chipset Device Software                                                                                                                                    10.1.1.38
                                                  64 Bit HP CIO Components Installer                                                                                                                                  7.2.4
                                                  Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161                                                                                                      9.0.30729.6161
http://www.adobe.com/support/main.html            Adobe Acrobat X Pro - English, Fran鏰is, Deutsch                                                                  http://www.adobe.com                              10.0.0
                                                  Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161                                                                                                      9.0.30729.6161
http://go.microsoft.com/fwlink/?LinkId=133405     Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.60610                                                                                                       11.0.60610
                                                  腾讯QQ                                                                                                            http://www.tencent.com                            8.9.6.22427
                                                  Google Update Helper                                                                                                                                                1.3.33.17
http://www.netsarang.com/support/support.html     Xshell 5                                                                                                          http://www.netsarang.com                          5.0.1339
                                                  64 Bit HP CIO Components Installer                                                                                                                                  16.2.1
                                                  MySQL Installer - Community                                                                                                                                         1.4.20.0
                                                  Dolby Audio X2 Windows API SDK                                                                                                                                      0.8.4.83
                                                  英特尔(R) 无线 Bluetooth(R)                                                                                                                                         19.60.0
                                                  小米同步                                                                                                                                                            0.1.45
http://www.intel.com/support/go/wireless_support  Intel(R) PRO/Wireless Driver                                                                                      http://www.intel.com/support/go/wireless_support  19.70.0000.6491
http://go.microsoft.com/fwlink/?LinkId=146008     Microsoft Visual C++ 2010  x86 Redistributable - 10.0.30319                                                                                                         10.0.30319
http://support.webex.com/                         WebEx 快捷会议工具                                                                                                http://www.webex.com                              32.11.0.28
http://www.intel.com/support/go/wireless_support  Intel? PROSet/Wireless WiFi Software                                                                              http://www.intel.com/support/go/wireless_support  19.70.0.1040
                                                  Java Auto Updater                                                                                                                                                   2.8.181.13
                                                  Dolby Audio X2 Windows APP                                                                                                                                          0.7.2.62
