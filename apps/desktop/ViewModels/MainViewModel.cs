using CommunityToolkit.Mvvm.ComponentModel;

namespace ironbook.ViewModels;

public partial class MainViewModel : ViewModelBase
{
    [ObservableProperty]
    public partial string Greeting { get; set; } = "Welcome to IronBook!";
}
