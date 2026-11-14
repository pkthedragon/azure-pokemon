if (-not ('AzurePrivateBattleProcess' -as [type])) {
  Add-Type -TypeDefinition @'
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public sealed class AzurePrivateBattleProcess : IDisposable
{
    private const uint DesktopCreateWindow = 0x0002;
    private const uint CreateUnicodeEnvironment = 0x0400;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct StartupInfo
    {
        public int Size;
        public string Reserved, Desktop, Title;
        public int X, Y, Width, Height, Columns, Rows, FillAttribute, Flags;
        public short ShowWindow, ReservedSize;
        public IntPtr ReservedBytes, StdInput, StdOutput, StdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct ProcessInfo
    {
        public IntPtr Process, Thread;
        public int ProcessId, ThreadId;
    }

    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern IntPtr CreateDesktop(string name, IntPtr device, IntPtr mode,
        uint flags, uint access, IntPtr security);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool CloseDesktop(IntPtr desktop);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern bool CreateProcess(string application, IntPtr commandLine,
        IntPtr processSecurity, IntPtr threadSecurity, bool inheritHandles, uint flags,
        IntPtr environment, string directory, ref StartupInfo startup, out ProcessInfo process);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool CloseHandle(IntPtr handle);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool TerminateProcess(IntPtr process, uint exitCode);

    private IntPtr desktop;
    public Process Process { get; private set; }

    private AzurePrivateBattleProcess(Process process, IntPtr desktop)
    {
        Process = process;
        this.desktop = desktop;
    }

    public static AzurePrivateBattleProcess Start(string path, string directory, Hashtable overrides)
    {
        var variables = new SortedDictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (DictionaryEntry variable in Environment.GetEnvironmentVariables())
            variables[(string)variable.Key] = (string)variable.Value;
        foreach (DictionaryEntry variable in overrides)
        {
            string name = variable.Key.ToString();
            if (variable.Value == null)
                variables.Remove(name);
            else
                variables[name] = variable.Value.ToString();
        }
        var block = new StringBuilder();
        foreach (var variable in variables)
            block.Append(variable.Key).Append('=').Append(variable.Value).Append('\0');
        // The string marshaler adds the second terminating NUL.
        IntPtr environment = Marshal.StringToHGlobalUni(block.ToString());

        IntPtr desktop = IntPtr.Zero;
        ProcessInfo child = new ProcessInfo();
        bool started = false;
        try
        {
            string name = "AzureBattle-" + Guid.NewGuid().ToString("N");
            desktop = CreateDesktop(name, IntPtr.Zero, IntPtr.Zero, 0, DesktopCreateWindow, IntPtr.Zero);
            if (desktop == IntPtr.Zero)
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Could not create the private battle desktop.");
            var startup = new StartupInfo { Desktop = name, Size = Marshal.SizeOf(typeof(StartupInfo)) };
            if (!CreateProcess(path, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, false,
                CreateUnicodeEnvironment, environment, directory, ref startup, out child))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Could not start the battle engine on the private desktop.");
            var run = new AzurePrivateBattleProcess(Process.GetProcessById(child.ProcessId), desktop);
            started = true;
            return run;
        }
        finally
        {
            Marshal.FreeHGlobal(environment);
            if (child.Thread != IntPtr.Zero)
                CloseHandle(child.Thread);
            if (child.Process != IntPtr.Zero)
            {
                if (!started)
                    TerminateProcess(child.Process, 1);
                CloseHandle(child.Process);
            }
            if (!started && desktop != IntPtr.Zero)
                CloseDesktop(desktop);
        }
    }

    public void Dispose()
    {
        if (desktop == IntPtr.Zero)
            return;
        try
        {
            if (!Process.HasExited)
            {
                try { Process.Kill(); }
                catch (InvalidOperationException) { if (!Process.HasExited) throw; }
                if (!Process.WaitForExit(5000))
                    throw new TimeoutException("The private battle engine did not terminate.");
            }
        }
        finally
        {
            Process.Dispose();
            CloseDesktop(desktop);
            desktop = IntPtr.Zero;
        }
    }
}
'@
}

function Start-AzurePrivateBattleProcess {
  param(
    [Parameter(Mandatory)][string]$FilePath,
    [Parameter(Mandatory)][string]$WorkingDirectory,
    [Parameter(Mandatory)][hashtable]$Environment
  )
  [AzurePrivateBattleProcess]::Start($FilePath, $WorkingDirectory, $Environment)
}

function Stop-AzurePrivateBattleProcess {
  param([Parameter(Mandatory)]$Run)
  $Run.Dispose()
}
