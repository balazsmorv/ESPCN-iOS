# ESPCN-iOS
Porting and integrating the ESPCN super-resolution network into an iOS app.


## Models
Both the Keras saved model and the mlmodel are contained in the `model` folder. The `Keras model -> mlpackage` conversion can be done by running the `iOS-port.ipynb` notebook. 

The model training code and can be found in my other repository [AACS2023](https://github.com/balazsmorv/AACS2023).

## App
The `ESPCN` folder contains the iOS app. Requires the OpenCV framework from [here](https://opencv.org/releases/). Tested with version 4.7.0. 

