using System;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using NeumorphicEngine.Helpers;

namespace NeumorphicEngine
{
    public sealed partial class MainWindow : Window
    {
        private bool _isDraggingKnob = false;
        private bool _isPinned = false;
        private double _currentVolumePercent = 72.0;

        public MainWindow()
        {
            this.InitializeComponent();

            this.Title = "Neumorphic OS Companion HUD";
            this.AppWindow.Resize(new Windows.Graphics.SizeInt32(420, 680));

            IntPtr hWnd = WinRT.Interop.WindowNative.GetWindowHandle(this);
            WindowHelper.EnableNeumorphicDarkBackdrop(hWnd);

            UpdateVisualizer(72.0);
        }

        private void Header_PointerPressed(object sender, PointerRoutedEventArgs e)
        {
            IntPtr hWnd = WinRT.Interop.WindowNative.GetWindowHandle(this);
            WindowHelper.DragWindow(hWnd);
        }

        private void PinButton_Click(object sender, RoutedEventArgs e)
        {
            _isPinned = !_isPinned;
            IntPtr hWnd = WinRT.Interop.WindowNative.GetWindowHandle(this);
            WindowHelper.SetAlwaysOnTop(hWnd, _isPinned);
            PinText.Text = _isPinned ? "📌 Pinned" : "📌 Pin";
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Knob_PointerPressed(object sender, PointerRoutedEventArgs e)
        {
            _isDraggingKnob = true;
            ((UIElement)sender).CapturePointer(e.Pointer);
            UpdateKnobFromPointer(sender as FrameworkElement, e.GetCurrentPoint(sender as UIElement).Position);
        }

        private void Knob_PointerMoved(object sender, PointerRoutedEventArgs e)
        {
            if (_isDraggingKnob)
            {
                UpdateKnobFromPointer(sender as FrameworkElement, e.GetCurrentPoint(sender as UIElement).Position);
            }
        }

        private void Knob_PointerReleased(object sender, PointerRoutedEventArgs e)
        {
            _isDraggingKnob = false;
            ((UIElement)sender).ReleasePointerCapture(e.Pointer);
        }

        private void UpdateKnobFromPointer(FrameworkElement? element, Windows.Foundation.Point pos)
        {
            if (element == null) return;

            double centerX = element.ActualWidth / 2.0;
            double centerY = element.ActualHeight / 2.0;

            double deltaX = pos.X - centerX;
            double deltaY = pos.Y - centerY;

            // Compute angle in degrees (-180 to 180)
            double radians = Math.Atan2(deltaY, deltaX);
            double degrees = radians * (180.0 / Math.PI) + 90.0;
            if (degrees < 0) degrees += 360.0;

            // Map [0, 360] to volume percent [0, 100]
            double percent = Math.Clamp(degrees / 360.0 * 100.0, 0.0, 100.0);
            _currentVolumePercent = percent;

            KnobRotateTransform.Angle = degrees;
            UpdateVisualizer(percent);
        }

        private void UpdateVisualizer(double percent)
        {
            VolumePercentText.Text = $"{(int)percent}%";

            // Calculate approximate dB: 0% = -inf (-48dB), 100% = 0dB
            double db = (percent <= 0) ? -60.0 : 20.0 * Math.Log10(percent / 100.0);
            DbText.Text = $"{db:0.0} dB";

            // Update 12 LED Segmented bars
            Border[] bars = new[] { Bar1, Bar2, Bar3, Bar4, Bar5, Bar6, Bar7, Bar8, Bar9, Bar10, Bar11, Bar12 };
            int activeThreshold = (int)Math.Round((percent / 100.0) * bars.Length);

            SolidColorBrush activeBrush = (SolidColorBrush)Application.Current.Resources["NeumorphicAccentCyanBrush"];
            SolidColorBrush inactiveBrush = (SolidColorBrush)Application.Current.Resources["NeumorphicInsetBrush"];

            for (int i = 0; i < bars.Length; i++)
            {
                if (bars[i] != null)
                {
                    bars[i].Background = (i < activeThreshold) ? activeBrush : inactiveBrush;
                    bars[i].Opacity = (i < activeThreshold) ? 1.0 : 0.35;
                }
            }
        }
    }
}
