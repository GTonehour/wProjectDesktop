using System;
using System.Text;
using System.Runtime.InteropServices;

public class Win32
{
    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(IntPtr hWnd, StringBuilder strText, int maxCount);
    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool IsWindowVisible(IntPtr hWnd);

    public static bool WindowExists(string titleSubstring)
    {
        bool found = false;
        EnumWindows(delegate(IntPtr hWnd, IntPtr lParam)
        {

            StringBuilder sb = new StringBuilder(256);
            GetWindowText(hWnd, sb, sb.Capacity);
            string windowTitle = sb.ToString();
    
            if (windowTitle.Equals(titleSubstring, StringComparison.OrdinalIgnoreCase))
            {
                found = true;
                return false; // Stop
            }
            return true; // Continue
        }, IntPtr.Zero);
        return found;
    }
}
