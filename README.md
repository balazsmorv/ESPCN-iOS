# ESPCN-iOS

![example](https://github.com/balazsmorv/ESPCN-iOS/assets/42976408/d0ba8d79-1901-4e95-88b4-cfeec3684461)

Porting and integrating the ESPCN super-resolution network into an iOS app.


## Models
Both the Keras saved model and the mlmodel are contained in the `model` folder. The `Keras model -> mlpackage` conversion can be done by running the `iOS-port.ipynb` notebook. 

The model training code and can be found in my other repository [AACS2023](https://github.com/balazsmorv/AACS2023).

## App
The `ESPCN` folder contains the iOS app. Requires the OpenCV framework from [here](https://opencv.org/releases/). Tested with version 4.7.0. 

