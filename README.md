##Kinect Projector Toolkit

[Note: documentation is incomplete. Additions are coming soon]

Processing library for calibrating a kinect and a projector together, such that projector image is automatically aligned with the physical space it is projecting onto, facilitating the projection of images onto moving bodies and surfaces.

To see some applications of the software, please see [this highlight video](http://vimeo.com/81914893) of a workshop applying the software to live dancers.

The calibration methodology comes from this writeup by [Jan Hrdlička at 3dsense blog](http://blog.3dsense.org/programming/kinect-projector-calibration-human-mapping-2/).

For other work on Projector/Kinect calibration in OpenFrameworks/vvvv, see works by Elliot Woods, Kyle McDonald, and Daito Manabe, as well as the OpenFrameworks addon [ofxCamaraLucida](http://github.com/chparsons/ofxCamaraLucida).


##Software contents

To install the library, copy the entire contents of this repository into a folder called "KinectProjectorToolkit" inside your Processing libraries folder, as any other library.

The library comes with a number of demos in the "examples" folder, as well as a program called CALIBRATION.pde which is the application used for determining the calibration. Instructions for calibration follow below.


##Instructions for calibration

[Video tutorial for calibration](http://vimeo.com/84658886)

###1) Room setup

After setting the projector, fix the Kinect to face the space onto which you are projecting. Ideally, the Kinect is tracking roughly the full space of the projection -- if it is too close it may not see everything the projector sees, and if it is too far, it will be less precise. Unless you have a short-throw projector, the Kinect should be closer to the stage than the projector.

The Kinect and projector must be totally immobilized during calibration and after, because a calibration only works for that positioning of the two devices.

###2) Software setup

The library requires Processing 2.0+, [SimpleOpenNI](https://code.google.com/p/simple-openni/), and [OpenCV](https://github.com/atduskgreg/opencv-processing).

Set your computer's display to extended/dual screen and project the secondary screen. Open up CALIBRATION.pde and make sure to set the pWidth and pHeight variables at the top to match the resolution of the secondary display.

[screenshot1]

###3) Getting point pairs

The interface allows you to position a 5x4 chessboard being projected onto your stage, using the XY grid on the right side. The "size" slider controls the size of the chessboard. The "searching" button toggles whether the app is searching for a chessboard pattern. 

You need some sort of a flat, mobile panel (best if white) to project onto. Place the panel somewhere in front of the kinect, and position the chessboard onto it. When the chessboard is visible in your interface, toggle "searching" to have the program search for the chessboard. If it finds it, you should see 12 green circles pop up over the corners of the chessboard in the interface, and the "add pair" button becomes visible. If the green circles are not coming up, the chessboard can not be found in the image, which means the chessboard is too small or the lighting is not adequate. See the tutorial video for a good example. If the circles come up, but some or all of them are red, it means the chessboard is either too close or too far from the Kinect and it can't read the depth; move it into an appropriate range.

Repeat this process for a series of panel positions throughout your stage space. To get the best possible fit, you must sample the space as widely as possible. Move the board to at least two or three different depths (distance from the Kinect), and position the board at high and low positions as well. The more dispersed your board points are across all three spatial dimensions, the better your fit will be.

###4) Calibration

Depending on the demands of your application, you may need only a few board positions, or several dozen. Generally, 10-15 board positions gives a good fit, with each position contributing 12 point pairs. When you have a good amount of point pairs, click the "calibrate" button. This will generate a calibration. 

Once you have generated a calibration, you can toggle into "Testing mode" which allows you to test the fit. In testing mode, you can click anywhere on the kinect image to place a red dot over the point in the camera. A corresponding green point should be projected onto that same location in your physical space. If the calibration is properly fitted, the red dot in the Kinect's image and the green one in the physical space should match. Try a few points at different depths to test the accuracy of the calibration.

If the calibration is satisfactory, click "Save." It will generate a file called calibrate.txt which is located in the data folder of the calibration app. You may retrieve it and place it somewhere on your laptop, to use later in applications.


##Test applications

In order to run any of the demo applications (titled "Test____") in the examples folder, you must open the application and look for the line in which the calibration is loaded. Replace the file path with the full path to the calibration file you generated in your calibration process. Then run the program.

Descriptions for test applications TBD.