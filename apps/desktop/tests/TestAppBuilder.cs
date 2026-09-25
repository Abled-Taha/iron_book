using Avalonia;
using Avalonia.Headless;
using ironbook; // Reference to your actual Avalonia project namespace

[assembly: AvaloniaTestApplication(typeof(tests.TestAppBuilder))]

namespace tests;

public class TestAppBuilder
{
    public static AppBuilder BuildAvaloniaApp() =>
        AppBuilder.Configure<App>() // Use your actual App.axaml class
            .UseHeadless(new AvaloniaHeadlessPlatformOptions
            {
                UseHeadlessDrawing = false
            });
}
