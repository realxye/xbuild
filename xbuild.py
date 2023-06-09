import os
import re
import subprocess
import sys
import pathlib
import platform

# Global Variables
kUserHomeDir=pathlib.Path(os.environ["UserProfile"]).as_posix()
kXBuildHomeDir=pathlib.Path(os.path.dirname(__file__).lower()).as_posix()
if kXBuildHomeDir[1] == ':':
    kXBuildHomeDir="/" + kXBuildHomeDir[0] + kXBuildHomeDir[2:]

def GetArgc(argv:list[str]):
    if argv != None:
        return len(argv)
    else:
        return 0

class BuildCommon:
    """XBuild Common Tool"""
    def ListToString(self, arr)->str:
        s=""
        for v in arr:
            if s != "":
                s = s + " "
            s = s + v
        return s
    
    def GetListItem(self, arr, i)->str:
        s=""
        if arr == None:
            return ""
        if len(arr) == 0:
            return ""
        return arr[0]
    
    def GetHostOS(self)->str:
        """Get host OS name: Windows, Darwin, Linux"""
        return platform.system()
    
    def GetHostArch(self)->str:
        """Get host Arch name: x86, x64, arm, arm64"""
        machine=platform.machine().lower()
        if machine.startswith('arm'):
            if machine == "arm":
                return "arm"
            else:
                return "arm64"
        else:
            if machine.endswith("64"):
                return "x64"
            else:
                return "x86"

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

    msvcVersions=[]
    msvcDefault=""
    
    def __init__(self, ver):
        self.name="MSVC"
        self.version=ver
        self.path=self.queryInstallDir()
        if not self.path=="":
            msvcDir=os.path.join(self.path, "VC\\Tools\\MSVC")
            if not os.path.isdir(msvcDir):
                return
            pMsvcVer=re.compile("d+\\.\\d+\\.\\d+")
            for file in os.listdir(msvcDir):
                #if not pMsvcVer.match(file):
                #    continue
                dVer = os.path.join(msvcDir, file)
                if not os.path.isdir(dVer):
                    continue
                self.msvcVersions.append(file)
            self.msvcVersions.sort(reverse=True)
            if len(self.msvcVersions) > 0:
                self.msvcDefault=self.msvcVersions[0]

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

    def Create(self, target):
        result = 0
        if target == None or target == "profile":
            result = self.CreateProfile()
            if result != 0:
                return
        if target == None or target == "alias":
            result = self.CreateAlias()
            if result != 0:
                return
        print("SUCCEEDED: xbuild has been initialized. Extra steps:")
        print("  - (Optional) Edit '~/xbuild.profile' to set extra environment variables (e.g. set default workspace path)")
        print("  - (Optional) Edit '~/xbuild.alias' to add your own alias")
        print("  - (Optional) Use 'xbuild-help` command to get more information")
        print("  - Run 'source xbuild.bashrc' to upate current bash session (or simply restart bash)")

    def CreateProfile(self):
        file = os.path.join(self.userHomeDir, "xbuild.profile")
        ret = 0
        try:
            with open(file, 'w') as f:
                f.write("# XBuild user profile\n")
                f.write("\n")
                f.write("# Workspace\n")
                f.write("#   - Root\n")
                f.write("export XBUILD_WORKSPACE_ROOT=\"" + kXBuildHomeDir + "\"\n")
                f.write("\n")
                f.write("# HOST\n")
                f.write("export XBUILD_HOST_OSNAME=" + common.GetHostOS() + "\n")
                f.write("export XBUILD_HOST_OSARCH=" + common.GetHostArch() + "\n")
                f.write("\n")
                f.write("# Toochain\n")
                defaultVS=""
                # Visual Studio 2017
                if self.vs2017.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2017=\"" + pathlib.Path(self.vs2017.path).as_posix() + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2017_MSVC_VERSIONS=\"" + common.ListToString(self.vs2017.msvcVersions) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2017_MSVC_DEFAULT=" + self.vs2017.msvcDefault + "\n")
                    defaultVS="vs2017"
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2017=\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2017_MSVC_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2017_MSVC_DEFAULT=\n")
                # Visual Studio 2019
                if self.vs2019.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\"" + pathlib.Path(self.vs2019.path).as_posix() + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2019_MSVC_VERSIONS=\"" + common.ListToString(self.vs2019.msvcVersions) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2019_MSVC_DEFAULT=" + self.vs2019.msvcDefault + "\n")
                    defaultVS="vs2019"
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2019=\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2019_MSVC_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2019_MSVC_DEFAULT=\n")
                # Visual Studio 2022
                if self.vs2022.Exist():
                    f.write("export XBUILD_TOOLCHAIN_VS2022=\"" + pathlib.Path(self.vs2022.path).as_posix() + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2022_MSVC_VERSIONS=\"" + common.ListToString(self.vs2022.msvcVersions) + "\"\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT=" + self.vs2022.msvcDefault + "\n")
                    defaultVS="vs2022"
                else:
                    f.write("export XBUILD_TOOLCHAIN_VS2022=\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2022_MSVC_VERSIONS=\n")
                    f.write("export XBUILD_TOOLCHAIN_VS2022_MSVC_DEFAULT=\n")
                # Default Visual Studio
                f.write("export XBUILD_TOOLCHAIN_DEFAULT_VS=" + defaultVS + "\n")
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
            print("Fail to create xbuild environment profile")
            ret = 1
        return ret
            
    def CreateAlias(self):
        file = os.path.join(self.userHomeDir, "xbuild.alias")
        ret = 0
        if os.path.isfile(file):
            return ret
        try:
            with open(file, 'w') as f:
                f.write("# XBuild alias profile\n")
                f.write("\n")
                f.write("#\n")
                f.write("# XBuild Commands\n")
                f.write("#\n")
                f.write("alias xbuild='python $XBUILDROOT/xbuild.py'\n")
                f.write("alias xmake='make'\n")
                f.write("alias xmake-release-x86='make config=release arch=x86'\n")
                f.write("alias xmake-debug-x86='make config=debug arch=x86'\n")
                f.write("alias xmake-release-x64='make config=release arch=x64'\n")
                f.write("alias xmake-debug-x64='make config=debug arch=x64'\n")
                f.write("alias xmake-release-arm='make config=release arch=arm'\n")
                f.write("alias xmake-debug-arm='make config=debug arch=arm'\n")
                f.write("alias xmake-release-arm64='make config=release arch=arm64'\n")
                f.write("alias xmake-debug-arm64='make config=debug arch=arm64'\n")
                f.write("\n")
                f.write("#\n")
                f.write("# Path\n")
                f.write("#\n")
                f.write("alias cdx='cd $XBUILDROOT'\n")
                f.write("alias cdw='cd $XBUILD_WORKSPACE_ROOT'\n")
                f.write("\n")
                f.write("#\n")
                f.write("# Git Commands\n")
                f.write("#\n")
                f.write("alias gits='git status'\n")
                f.write("alias gita='git add --'\n")
                f.write("alias gitaa='git add -A'\n")
                f.write("alias gitc='git commit -m'\n")
                f.write("alias gitcloneall='git clone --recurse-submodules'\n")
                f.write("alias gitpullupper='git pull upstream master'\n")
                f.write("alias gitpullall='git pull --recurse-submodules'\n")
                f.write("alias gitshowlog='git log --pretty=\"%H - %an, %ad : %s\"'\n")
                f.write("alias gitshowfilelog='git log --follow --pretty=\"%H - %an, %ad : %s\" --'\n")
                f.write("alias gitshowcommit='git show commit'\n")
                f.write("alias gitfixcommitmsg='git commit --amend -m'\n")
                f.write("alias gitundocommit='git reset --soft HEAD~1'\n")
                f.write("alias gitdropcommit='git reset --hard HEAD~1'\n")
        except FileNotFoundError:
            ret = 1
            print("Fail to create xbuild alias profile file")
        return ret

class Helper:
    def __init__(self):
        return
    
    def Help(argv:list[str]):
        argc=GetArgc(argv)
        print("XBuild Help")
        print("python.exe xbuild.py <COMMAND> [OPTIONS]")
        print("COMMAND: help [COMMAND]")
        print("         Show help information for specific command")
        print("COMMAND: init [--reset]")
        print("         Initialize XBUILD. It must be called once before using xbuild")
    
    def HelpBasic():
        print("XBuild Help")
        print("python.exe xbuild.py <COMMAND> [OPTIONS]")
        print("Available COMMANDs:")
        print("  help [COMMAND]: show help information.")
        print("  init [--reset]: initialize XBUILD. It must be called once before using xbuild")

def CommandInit(argv:list[str]):
    argc=GetArgc(argv)
    target = None
    if argc > 0:
        target = argv[0]
    initializer=BuildInitializer()
    initializer.Create(target)

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
            print("    VS2022:")
            print("      - Path: " + pathlib.Path(vs2022.path).as_posix())
            print("      - MSVC Versions: " + common.ListToString(vs2022.msvcVersions))
            print("      - MSVC default: " + vs2022.msvcDefault)
        if vs2019.Exist():
            print("    VS2019:")
            print("      - Path: " + pathlib.Path(vs2019.path).as_posix())
            print("      - MSVC Versions: " + common.ListToString(vs2019.msvcVersions))
            print("      - MSVC default: " + vs2019.msvcDefault)
        if vs2017.Exist():
            print("    VS2017:")
            print("      - Path: " + pathlib.Path(vs2017.path).as_posix())
            print("      - MSVC Versions: " + common.ListToString(vs2017.msvcVersions))
            print("      - MSVC default: " + vs2017.msvcDefault)
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
