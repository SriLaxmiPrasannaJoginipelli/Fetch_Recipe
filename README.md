# Fetch Recipes App

A SwiftUI application that displays recipes from a provided API endpoint, with proper image caching and error handling.

## Summary

![image](https://github.com/user-attachments/assets/c80bd471-181d-4e77-b0dd-f225cd3ddfbf)
![image](https://github.com/user-attachments/assets/31dd56f3-add2-45c4-af4a-0bf5a0f71b0b)
![image](https://github.com/user-attachments/assets/f80934f2-5350-469b-943f-bbf51b3feb86)
![image](https://github.com/user-attachments/assets/08e00b4d-8905-4ce2-9fb6-542835f7d544)


## Focus Areas

1. **Image Caching**: Implemented a custom disk and memory caching solution that properly persists images between app launches.

2. **Error Handling**: Comprehensive error handling for network issues, malformed data, and empty states.

3. **Modern SwiftUI**: Used SwiftUI best practices including `@MainActor`, `ObservableObject`, and modern concurrency with `async/await`.

4. **Testing**: Focused on unit testing core functionality including networking, caching, and view models.

## Additional Information

- Supports iOS 16+ as required
- Uses only Apple frameworks (no third-party dependencies)
- Fully implements async/await for all asynchronous operations
- Includes comprehensive unit tests for core functionality
