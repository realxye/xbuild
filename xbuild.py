import os
import re
import subprocess
import sys
import pathlib
#from pathlib import Path

# Global Variables
kUserHomeDir=os.environ["UserProfile"]
kXBuildHomeDir=os.path.dirname(__file__)

class BuildCommon:
    """XBuild Common Tool"""
    def ListToString(self, arr)->str:
        s=""
        for v in arr:
            if s != "":
                s = s + " "
            s = s + v
        return s
    
    def GetListItem(self, arr, i):
        s=""
        if arr == None:
            return ""
        if len(arr) == 0:
            return ""
        return arr[0]

common=BuildCommon()

class BuildToolchain:
    name=""
    version=""
    path=""

    def Empty(self):
        return self.name == ""

    def Exist(self):
        # If name/version/path are valid and the path is a dir
        return self.name != "" and self.version != "" and self.path != "" and os.path.isdir(self.path)

class BuildToolchainMSVC(BuildToolchain):
    
    def __init__(self, ver):
        self.name="MSVC"
        self.version=ver
        self.path=self.queryInstallDir()

    def queryInstallDir(self):
        verrange=""
        vswhere=os.environ["ProgramFiles(x86)"] + "\\Microsoft Visual Studio\\Installer\\vswhere.exe"
        if not os.path.exists(vswhere):
            return ""
        if self.version == "2017":
            verrange="[15.0,16.0)"
        elif self.version == "2019":
            verrange="[16.0,17.0)"
        elif self.version == "2022":
            verrange="[17.0,18.0)"
        else:
            return ""
        cmd=[vswhere, '-nologo', '-version', verrange, '-property','installationPath']
        result=subprocess.run(cmd, stdout=subprocess.PIPE)
        if result.returncode != 0:
            return ""
        return result.stdout.decode('utf-8').split("\r\n")[0]

class BuildWinKits:
    """Windows Kits"""
    wdkroot=""
    sdks=[]
    ddks=[]
    umdfX86=[]
    umdfX64=[]
    umdfArm=[]
    umdfArm64=[]
    kmdfX86=[]
    kmdfX64=[]
    kmdfArm=[]
    kmdfArm64=[]
    
    def __init__(self):
        self.queryWinKitsVersions()

    def queryWinKitsVersions(self):
        self.sdks=[]
        self.ddks=[]
        self.umdfX86=[]
        self.umdfX64=[]
        self.umdfArm=[]
        self.umdfArm64=[]
        self.kmdfX86=[]
        self.kmdfX64=[]
        self.kmdfArm=[]
        self.kmdfArm64=[]
        progFiles86=os.environ["ProgramFiles(x86)"]
        self.wdkroot=os.path.join(progFiles86, "Windows Kits\\10")
        if not os.path.isdir(self.wdkroot):
            self.wdkroot=""
            return
        win10KitInclude=os.path.join(progFiles86, "Windows Kits\\10\\Include")
        win10KitLib=os.path.join(progFiles86, "Windows Kits\\10\\Lib")
        win10WdfInclude=os.path.join(progFiles86, "Windows Kits\\10\\Include\\wdf")
        win10UmdfInclude=os.path.join(progFiles86, "Windows Kits\\10\\Include\\wdf\\umdf")
        win10KmdfInclude=os.path.join(progFiles86, "Windows Kits\\10\\Include\\wdf\\kmdf")
        win10WdfLib=os.path.join(progFiles86, "Windows Kits\\10\\Lib\\wdf")
        win10UmdfLib=os.path.join(progFiles86, "Windows Kits\\10\\Lib\\wdf\\umdf")
        win10KmdfLib=os.path.join(progFiles86, "Windows Kits\\10\\Lib\\wdf\\kmdf")
        if not os.path.isdir(win10KitInclude):
            return
        if not os.path.isdir(win10KitLib):
            return
        # Get valid SDKs and DDKs
        pKits=re.compile("10\\.\\d+\\.\\d+\\.\\d+")
        for file in os.listdir(win10KitInclude):
            if not pKits.match(file):
                continue
            dinc = os.path.join(win10KitInclude, file)
            if not os.path.isdir(dinc):
                continue
            dlib = os.path.join(win10KitLib, file)
            if not os.path.isdir(dlib):
                continue
            dincUm = os.path.join(dinc, "um")
            dlibUm = os.path.join(dlib, "um")
            if os.path.isdir(dincUm) and os.path.isdir(dlibUm):
                self.sdks.append(file)
            dincKm = os.path.join(dinc, "km")
            dlibKm = os.path.join(dlib, "km")
            if os.path.isdir(dincKm) and os.path.isdir(dlibKm):
                self.ddks.append(file)
        self.sdks.sort(reverse=True)
        self.ddks.sort(reverse=True)
        # Check WDF Kits
        pWdfVer=re.compile("\\d+\\.\\d+")
        if not os.path.isdir(win10WdfInclude) or not os.path.isdir(win10WdfLib):
            return
        # Get valid UMDF kits
        pWdfVer=re.compile("\\d+\\.\\d+")
        for file in os.listdir(win10UmdfInclude):
            if not pWdfVer.match(file):
                continue
            dinc = os.path.join(win10UmdfInclude, file)
            if not os.path.isdir(dinc):
                continue
            # check x86 lib
            dlibx86 = os.path.join(win10UmdfLib, "x86")
            dlibx86 = os.path.join(dlibx86, file)
            if os.path.isdir(dlibx86):
                self.umdfX86.append(file)
            # check x64 lib
            dlibx64 = os.path.join(win10UmdfLib, "x64")
            dlibx64 = os.path.join(dlibx64, file)
            if os.path.isdir(dlibx64):
                self.umdfX64.append(file)
            # check ARM lib
            dlibarm = os.path.join(win10UmdfLib, "arm")
            dlibarm = os.path.join(dlibarm, file)
            if os.path.isdir(dlibarm):
                self.umdfArm.append(file)
            # check ARM 64 lib
            dlibarm64 = os.path.join(win10UmdfLib, "arm64")
            dlibarm64 = os.path.join(dlibarm64, file)
            if os.path.isdir(dlibarm64):
                self.umdfArm64.append(file)
        self.umdfX86.sort(reverse=True)
        self.umdfX64.sort(reverse=True)
        self.umdfArm.sort(reverse=True)
        self.umdfArm64.sort(reverse=True)
        # Get valid KMDF kits
        for file in os.listdir(win10KmdfInclude):
            if not pWdfVer.match(file):
                continue
            dinc = os.path.join(win10KmdfInclude, file)
            if not os.path.isdir(dinc):
                continue
            # check x86 lib
            dlibx86 = os.path.join(win10KmdfLib, "x86")
            dlibx86 = os.path.join(dlibx86, file)
            if os.path.isdir(dlibx86):
                self.kmdfX86.append(file)
            # check x64 lib
            dlibx64 = os.path.join(win10KmdfLib, "x64")
            dlibx64 = os.path.join(dlibx64, file)
            if os.path.isdir(dlibx64):
                self.kmdfX64.append(file)
            # check ARM lib
            dlibarm = os.path.join(win10KmdfLib, "arm")
            dlibarm = os.path.join(dlibarm, file)
            if os.path.isdir(dlibarm):
                self.kmdfArm.append(file)
            # check ARM 64 lib
            dlibarm64 = os.path.join(win10KmdfLib, "arm64")
            dlibarm64 = os.path.join(dlibarm64, file)
            if os.path.isdir(dlibarm64):
                self.kmdfArm64.append(file)
        self.kmdfX86.sort(reverse=True)
        self.kmdfX64.sort(reverse=True)
        self.kmdfArm.sort(reverse=True)
        self.kmdfArm64.sort(reverse=True)

class BuildInitializer:
    """XBuild Initializer"""
    userHomeDir=os.environ["UserProfile"]
    vs2017 = None
    vs2019 = None
    vs2022 = None
    winkits = None
    
    def __init__(self):
        self.vs2017 = BuildToolchainMSVC("2017")
        self.vs2019 = BuildToolchainMSVC("2019")
        self.vs2022 = BuildToolchainMSVC("2022")
        self.winkits = BuildWinKits()

    def Create(self):
        file = os.path.join(self.userHomeDir, "xbuild.profile")
        try:
            with open(file, 'w') as f:
                f.write("# XBuild user profile\n")
                f.write("\n")
                f.write("# Toochain\n")
                vsPath=""
                if self.vs2017.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2017=\"" + pathlib.Path(self.vs2017.path).as_posix() + "\"\n")
                    vsPath=pathlib.Path(self.vs2017.path).as_posix()
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2017=\n")
                if self.vs2019.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\"" + pathlib.Path(self.vs2019.path).as_posix() + "\"\n")
                    vsPath=pathlib.Path(self.vs2019.path).as_posix()
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\n")
                if self.vs2022.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\"" + pathlib.Path(self.vs2022.path).as_posix() + "\"\n")
                    vsPath=pathlib.Path(self.vs2022.path).as_posix()
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2022=\n")
                if vsPath == "":
                    f.write("export XBUILD_TOOLCHAIN_VS=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS=\"" + vsPath + "\"\n")
                f.write("\n")
                f.write("# WDKs\n")
                f.write("#   - Root\n")
                if self.winkits.wdkroot == "":
                    f.write("export XBUILD_TOOLCHAIN_WDKROOT=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_WDKROOT=\"" + pathlib.Path(self.winkits.wdkroot).as_posix() + "\"\n")
                f.write("#   - SDK\n")
                if len(self.winkits.sdks) == 0:
                    f.write("export XBUILD_TOOLCHAIN_SDK_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_SDK_DEFAULT=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_SDK_VERSIONS=\"" + common.ListToString(self.winkits.sdks) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_SDK_DEFAULT=\"" + common.GetListItem(self.winkits.sdks, 0) + "\"\n")
                f.write("#   - DDK\n")
                if len(self.winkits.ddks) == 0:
                    f.write("export XBUILD_TOOLCHAIN_DDK_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_DDK_DEFAULT=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_DDK_VERSIONS=\"" + common.ListToString(self.winkits.ddks) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_DDK_DEFAULT=\"" + common.GetListItem(self.winkits.ddks, 0) + "\"\n")
                f.write("#   - UMDF\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X86_VERSIONS=\"" + common.ListToString(self.winkits.umdfX86) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X86_DEFAULT=" + common.GetListItem(self.winkits.umdfX86, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X64_VERSIONS=\"" + common.ListToString(self.winkits.umdfX64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X64_DEFAULT=" + common.GetListItem(self.winkits.umdfX64, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM_VERSIONS=\"" + common.ListToString(self.winkits.umdfArm) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM_DEFAULT=" + common.GetListItem(self.winkits.umdfArm, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM64_VERSIONS=\"" + common.ListToString(self.winkits.umdfArm64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM64_DEFAULT=" + common.GetListItem(self.winkits.umdfArm64, 0) + "\n")
                f.write("#   - KMDF\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X86_VERSIONS=\"" + common.ListToString(self.winkits.kmdfX86) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X86_DEFAULT=" + common.GetListItem(self.winkits.kmdfX86, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X64_VERSIONS=\"" + common.ListToString(self.winkits.kmdfX64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X64_DEFAULT=" + common.GetListItem(self.winkits.kmdfX64, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM_VERSIONS=\"" + common.ListToString(self.winkits.kmdfArm) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM_DEFAULT=" + common.GetListItem(self.winkits.kmdfArm, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM64_VERSIONS=\"" + common.ListToString(self.winkits.kmdfArm64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM64_DEFAULT=" + common.GetListItem(self.winkits.kmdfArm64, 0) + "\n")
        except FileNotFoundError:
            print("Fail to create xbuild profile")
            
    def SetStartBashrc(self):
        file = os.path.join(self.userHomeDir, ".bashrc")
        try:
            with open(file, 'a') as f:
                f.write("# XBuild user profile\n")
                f.write("\n")
                f.write("# Toochain\n")
                vsPath=""
                if self.vs2017.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2017=\"" + pathlib.Path(self.vs2017.path).as_posix() + "\"\n")
                    vsPath=pathlib.Path(self.vs2017.path).as_posix()
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2017=\n")
                if self.vs2019.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\"" + pathlib.Path(self.vs2019.path).as_posix() + "\"\n")
                    vsPath=pathlib.Path(self.vs2019.path).as_posix()
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\n")
                if self.vs2022.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\"" + pathlib.Path(self.vs2022.path).as_posix() + "\"\n")
                    vsPath=pathlib.Path(self.vs2022.path).as_posix()
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2022=\n")
                if vsPath == "":
                    f.write("export XBUILD_TOOLCHAIN_VS=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS=\"" + vsPath + "\"\n")
                f.write("\n")
                f.write("# WDKs\n")
                f.write("#   - Root\n")
                if self.winkits.wdkroot == "":
                    f.write("export XBUILD_TOOLCHAIN_WDKROOT=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_WDKROOT=\"" + pathlib.Path(self.winkits.wdkroot).as_posix() + "\"\n")
                f.write("#   - SDK\n")
                if len(self.winkits.sdks) == 0:
                    f.write("export XBUILD_TOOLCHAIN_SDK_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_SDK_DEFAULT=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_SDK_VERSIONS=\"" + common.ListToString(self.winkits.sdks) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_SDK_DEFAULT=\"" + common.GetListItem(self.winkits.sdks, 0) + "\"\n")
                f.write("#   - DDK\n")
                if len(self.winkits.ddks) == 0:
                    f.write("export XBUILD_TOOLCHAIN_DDK_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_DDK_DEFAULT=\n")
                else:
                    f.write("export XBUILD_TOOLCHAIN_DDK_VERSIONS=\"" + common.ListToString(self.winkits.ddks) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_DDK_DEFAULT=\"" + common.GetListItem(self.winkits.ddks, 0) + "\"\n")
                f.write("#   - UMDF\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X86_VERSIONS=\"" + common.ListToString(self.winkits.umdfX86) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X86_DEFAULT=" + common.GetListItem(self.winkits.umdfX86, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X64_VERSIONS=\"" + common.ListToString(self.winkits.umdfX64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_X64_DEFAULT=" + common.GetListItem(self.winkits.umdfX64, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM_VERSIONS=\"" + common.ListToString(self.winkits.umdfArm) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM_DEFAULT=" + common.GetListItem(self.winkits.umdfArm, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM64_VERSIONS=\"" + common.ListToString(self.winkits.umdfArm64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_UMDF_ARM64_DEFAULT=" + common.GetListItem(self.winkits.umdfArm64, 0) + "\n")
                f.write("#   - KMDF\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X86_VERSIONS=\"" + common.ListToString(self.winkits.kmdfX86) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X86_DEFAULT=" + common.GetListItem(self.winkits.kmdfX86, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X64_VERSIONS=\"" + common.ListToString(self.winkits.kmdfX64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_X64_DEFAULT=" + common.GetListItem(self.winkits.kmdfX64, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM_VERSIONS=\"" + common.ListToString(self.winkits.kmdfArm) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM_DEFAULT=" + common.GetListItem(self.winkits.kmdfArm, 0) + "\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM64_VERSIONS=\"" + common.ListToString(self.winkits.kmdfArm64) + "\"\n")
                f.write("export XBUILD_TOOLCHAIN_KMDF_ARM64_DEFAULT=" + common.GetListItem(self.winkits.kmdfArm64, 0) + "\n")
        except FileNotFoundError:
            print("Fail to create xbuild profile")

def GetArgc(argv:list[str]):
    if argv != None:
        return len(argv)
    else:
        return 0

def CommandInit(argv:list[str]):
    argc=GetArgc(argv)
    initializer=BuildInitializer()
    initializer.Create()

def CommandQuery(argv:list[str]):
    argc=GetArgc(argv)
    key=""
    option=""
    if argc > 0:
        key=argv[0].lower()
    if argc > 1:
        option=argv[1].lower()
    if key == "":
        print("Usage: python xbuild.py query <KEY>")
        print("KEY is one of following values:")
        print("    root")
        print("    toolchain")
        print("    devkits")
    elif key == "root":
        print("XBUILD_ROOT=" + os.path.dirname(__file__))
    elif key == "toolchain":
        vs2017 = BuildToolchainMSVC("2017")
        vs2019 = BuildToolchainMSVC("2019")
        vs2022 = BuildToolchainMSVC("2022")
        print("\nAvailable Toolchain")
        print("--------------------------------")
        if vs2022.Exist() and (option==None or option=="" or option=="vs2022"):
            print("[Visual Studio 2022] ")
            print("    Path: " + pathlib.Path(vs2022.path).as_posix())
        if vs2019.Exist() and (option==None or option=="" or option=="vs2019"):
            print("[Visual Studio 2019] ")
            print("    Path: " + pathlib.Path(vs2019.path).as_posix())
        if vs2017.Exist() and (option==None or option=="" or option=="vs2017"):
            print("[Visual Studio 2017] ")
            print("    Path: " + pathlib.Path(vs2017.path).as_posix())
    elif key == "devkits":
        winkits = BuildWinKits()
        print("\nAvailable Windows Kits")
        print("--------------------------------")
        print("SDKs: " + common.ListToString(winkits.sdks))
        print("DDKs: " + common.ListToString(winkits.ddks))
        print("UMDF (x86): " + common.ListToString(winkits.umdfX86))
        print("UMDF (x64): " + common.ListToString(winkits.umdfX64))
        print("UMDF (Arm): " + common.ListToString(winkits.umdfArm))
        print("UMDF (Arm64): " + common.ListToString(winkits.umdfArm64))
        print("KMDF (x86): " + common.ListToString(winkits.kmdfX86))
        print("KMDF (x64): " + common.ListToString(winkits.kmdfX64))
        print("KMDF (Arm): " + common.ListToString(winkits.kmdfArm))
        print("KMDF (Arm64): " + common.ListToString(winkits.kmdfArm64))
    else:
        print("Unknown query key")

def CommandTest(argv:list[str]):
    argc=GetArgc(argv)
    xRoot=os.path.dirname(__file__)
    print("XBUILD_ROOT: "+xRoot)
    if os.name == "nt":
        print("XBuild Test (Windows)")
        vs2017 = BuildToolchainMSVC("2017")
        vs2019 = BuildToolchainMSVC("2019")
        vs2022 = BuildToolchainMSVC("2022")
        print("Visual Studios")
        if vs2022.Exist():
            print("    VS2022: " + pathlib.Path(vs2022.path).as_posix())
        if vs2019.Exist():
            print("    VS2019: " + pathlib.Path(vs2019.path).as_posix())
        if vs2017.Exist():
            print("    VS2017: " + pathlib.Path(vs2017.path).as_posix())
        winkits = BuildWinKits()
        print("SDKs: " + common.ListToString(winkits.sdks))
        print("DDKs: " + common.ListToString(winkits.ddks))
        print("UMDF (x86): " + common.ListToString(winkits.umdfX86))
        print("UMDF (x64): " + common.ListToString(winkits.umdfX64))
        print("UMDF (Arm): " + common.ListToString(winkits.umdfArm))
        print("UMDF (Arm64): " + common.ListToString(winkits.umdfArm64))
        print("KMDF (x86): " + common.ListToString(winkits.kmdfX86))
        print("KMDF (x64): " + common.ListToString(winkits.kmdfX64))
        print("KMDF (Arm): " + common.ListToString(winkits.kmdfArm))
        print("KMDF (Arm64): " + common.ListToString(winkits.kmdfArm64))

def CommandHelp(argv:list[str]):
    argc=GetArgc(argv)
    print("XBuild Help")
    print("python.exe xbuild.py <COMMAND> [OPTIONS]")
    print("COMMAND: help [COMMAND]")
    print("         Show help information for specific command")
    print("COMMAND: init [--reset]")
    print("         Initialize XBUILD. It must be called once before using xbuild")
    print("COMMAND: create [--reset]")
    print("         Initialize XBUILD. It must be called once before using xbuild")

def main():
    args = sys.argv[1:]
    argc = len(args)
    if (argc == 0):
        CommandHelp(None)
        return
    if args[0] == "test":
        CommandTest(args[1:])
    elif args[0] == "help":
        CommandHelp(args[1:])
    elif args[0] == "query":
        CommandQuery(args[1:])
    elif args[0] == "init":
        CommandInit(args[1:])
    else:
        CommandHelp(None)

if __name__ == "__main__":
    main()
