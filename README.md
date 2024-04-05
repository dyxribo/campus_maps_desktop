# CAMPUS MAPS DESKTOP

_An application for navigating and finding resources in (corporate) buildings._

### NOTE: this application is a work-in-progress.

Campus Maps is an application that uses JSON and [custom components, utilities](https://github.com/blaxstar/starlib) and data structures in order to navigate any map, given its data.

The application allows for an Admin mode where, given the proper credentials, a user would be able to make changes such as add assets and users to a map. This will be authorized and authenticated via JWTs retrieved from an API endpoint of your choice.

The application is able to save the layout and positioning as a single JSON file and read it into the application on start up. 

This app was originally created to interface with SQL, but is being revised to interface with any custom REST API instead.

 Searching for items by id is the default, but it currently also supports usernames for users. support for near-matches to come soon.
for lookups by ID and username, searching is done in O(1) time, through the use of a custom map class that reads in the items at app init.

## Preview
![image](https://github.com/dyxribo/campus_maps_desktop/assets/6477128/1bb4df56-547b-4e03-97c9-e387a68c0bfe)
![image](https://github.com/dyxribo/campus_maps_desktop/assets/6477128/dbfde832-aeef-4591-bbdd-3eeaf1b46f97)
![image](https://github.com/dyxribo/campus_maps_desktop/assets/6477128/f2f0be82-cd07-41fb-a46b-5d80b173fe1c)

## Building the app

- download the Harman AIR sdk from [here](https://airsdk.harman.com/download).
- clone the repo to a local folder using `git clone --recurse-submodules`, and open the folder in [VSCode](https://code.visualstudio.com/).
- install [this extension](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-nextgenas) to your vscode install.
- build the app with the included `BUILD & RUN` launch task.
