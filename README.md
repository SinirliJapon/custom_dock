# Custom macOS Dock - Flutter

This project implements a custom macOS-style dock using Flutter, with interactive features like scaling icons on hover, dynamic item repositioning, and a smooth drag-and-drop interface. The dock is designed to mimic the look and feel of a macOS desktop dock, but with enhanced flexibility and customization options.

You can view a live demo of the dock at:  
[https://sinirlijapon.github.io/custom_dock/](https://sinirlijapon.github.io/custom_dock/)

## Features

- **Interactive Icons**: Icons scale up when hovered, providing a visually appealing effect.
- **Drag and Drop**: Users can drag and rearrange dock items.
- **Customizable Items**: Icons can be dynamically added, removed, or reordered in the dock.
- **Smooth Animation**: Transition effects for hover and dragging provide a fluid user experience.

## How It Works

The dock is implemented using the following Flutter features:
- **Stateful Widgets**: To manage the hover and drag states.
- **AnimatedContainer**: For smooth scaling and transformation effects.
- **MouseRegion**: To detect hover interactions.
- **Transform**: To apply scaling transformations for hover effects.

The `Dock` widget takes a list of items (icons) and provides a builder function to render each icon dynamically. The hover effects are calculated based on the proximity of the hovered icon to other icons.

## Demo

You can interact with the dock by:
1. Hovering over any icon to see it grow.
2. Dragging and rearranging the icons within the dock.
3. The entire dock layout adjusts dynamically based on user interaction.

## Setup Instructions

To run this project locally:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sinirlijapon/custom_dock.git
