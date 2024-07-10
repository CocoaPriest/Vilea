# Vilea Coding Challenge

This project is a simple iOS application that helps drivers of electric cars to find nearby charging stations and show their availability status in real time.

## Dependencies

The project does not have any external dependencies.

## Architecture Overview

The main components are:

- **StationRepository**: fetching and managing the station data, both from the remote API and the local cache. It processes the data and emits updates through a `@Published` property.
- **StationRemoteRepository**: handles the network requests to fetch data from the remote API.
- **StationLocalRepository**: manages the local cache using Core Data.
- **MainTabViewModel**: the main view model for the app, also handles location management and connectivity checks. On the app launch, it checks the network connectivity and either fetches the station data from the remote API or loads the cached data from the local repository.
