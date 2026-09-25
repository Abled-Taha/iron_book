using Avalonia.Controls;
using Avalonia.Headless;
using Avalonia.Headless.XUnit;
using Xunit;

namespace tests;

public class MyUiTests
{
    [AvaloniaFact]
    public void TextBox_Accepts_Keyboard_Input()
    {
        // Arrange
        var textBox = new TextBox();
        var window = new Window { Content = textBox };
        window.Show();

        // Act
        textBox.Focus();
        window.KeyTextInput("Hello World");

        // Assert
        Assert.Equal("Hello World", textBox.Text);
    }
}
