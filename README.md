# AlertController
iOS AlertController

<img src="http://i.imgur.com/uDlPwyJ.png" width="400">
<img src="http://i.imgur.com/es3bVwu.png" width="400">

## Example
```swift
// Create a new AlertController
let alertController = AlertController(
	title: "Title", 
	message: "Lorem Ipsum", 
	icon: UIImage(named: "Icon"), 
	preferredStyle: .alert, 
	blurStyle: .dark
)
      
// Adding Buttons
alertController.addAction(
	AlertAction(title: "Default", style: .default)
)

alertController.addAction(
	AlertAction(
		title: "Cancel", 
		style: .cancel, 
		handler: { action in
			// Cancel something
		}
	)
)

alertController.addAction(
	AlertAction(
		title: "Destructive", 
		style: .destructive, 
		handler: { action in
			// Destroy everything
		}
	)
)

// Adding Text Field
alertController.addTextFieldWithConfigurationHandler { textField  in
	// Configure textField
}

// Present Alert Controller
present(alertController, animted: true)

```
