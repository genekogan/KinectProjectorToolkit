#Kinect Projector Toolkit

Processing library for calibrating a kinect and a projector together, such that projected image is automatically aligned to the physical space it is projecting onto, facilitating the projection of images onto moving bodies and surfaces.

To see some applications of the software, see this [highlight video](http://vimeo.com/81914893) of a workshop applying the software to live dance.

The calibration methodology comes from this writeup by [Jan Hrdlička at 3dsense blog](http://blog.3dsense.org/programming/kinect-projector-calibration-human-mapping-2/). For other work on Projector/Kinect calibration, see works and code by [Elliot Woods, Kyle McDonald](https://github.com/elliotwoods/artandcode.Camera-and-projector-calibration), and [Daito Manabe](http://thecreatorsproject.vice.com/blog/projection-mapped-dance-performance-daito-manabe), as well as the OpenFrameworks addon [ofxCamaraLucida](http://chparsons.com.ar/#camara_lucida).


##Installation

The library requires [Processing 2.0+](http://www.processing.org), [SimpleOpenNI](https://code.google.com/p/simple-openni/), [ControlP5](http://www.sojamo.de/libraries/controlP5/), and [OpenCV](https://github.com/atduskgreg/opencv-processing).

To install the library, copy the entire contents of this repository into a folder called "KinectProjectorToolkit" inside your Processing libraries folder, as any other library.

The library comes with a number of demos in the "examples" folder, as well as a program called **CALIBRATION.pde** which is the application used for determining the fit between the projector and Kinect. Instructions for calibration follow below.


##Instructions for calibration

###*[Video tutorial for calibration](http://vimeo.com/84658886)*

###1) Room setup

After setting the projector, fix the Kinect to face the space onto which you are projecting. Ideally, the Kinect is tracking roughly the full space of the projection; if it is too close it may not see everything the projector sees, and if it is too far, it will be less precise. Unless you have a short-throw projector, the Kinect will probably be closer to the stage than the projector.

The Kinect and projector must be *totally immobilized* during calibration and after, because a calibration only works for that positioning of the two devices together.


###2) Software setup

Set your computer's display to extended/dual screen and project the secondary screen. Open up **CALIBRATION.pde** and make sure to set the `pWidth` and `pHeight` variables at the top to exactly match the resolution of the secondary display, e.g. 1024x768.

Finally, set the `calibFilename` variable to the exact path to which you want to save the calibration file to.

![Setting up display](http://www.genekogan.com/images/kinect-projector-toolkit/kpt_screen_1.jpg)


###3) Getting point pairs

The interface allows you to position a 5x4 chessboard which is being projected onto your stage/room. You can move its position using the XY grid on the right side of the interface, and resize it using the "size" slider. The "searching" button toggles whether the app is actively searching for a chessboard pattern. 

![Setting up display](http://www.genekogan.com/images/kinect-projector-toolkit/kpt_screen_2.jpg)

You need some sort of a flat, mobile panel (best if white) to project onto. Place the panel somewhere in front of the Kinect, and position the projected chessboard onto it. When the chessboard is visible in the Kinect RGB view on the left of the interface, toggle the "searching" button to have the program search for the chessboard. If it finds it, you should see 12 green circles pop up over the corners of the chessboard in the interface, and the "add pair" button becomes visible. If the green circles are not coming up, the chessboard can not be found in the image, which means the chessboard is too small or the lighting is not adequate. See the tutorial video for a good example. If the circles do appear, but some or all of them are red, it means the chessboard is either too close or too far from the Kinect and it can't read the depth; move it into an appropriate range. Only when 12 green circles are visible is the "add pair" button accessible. 

![Setting up display](http://www.genekogan.com/images/kinect-projector-toolkit/kpt_screen_3.jpg)

Repeat this process for a series of panel positions throughout your stage space. To get the best possible fit, you should sample the space as widely as possible. Move the board to at least two or three different depths (distance from the Kinect), and position the board at high and low positions as well. The more dispersed your board points are across all three spatial dimensions, the better your fit will be. If the points are mostly coplanar, the model may not generalize well to undersampled regions.


###4) Calibration

Depending on the demands of your application, you may need only a few board positions, or several dozen. Generally, 10-15 board positions gives a good fit, with each position contributing 12 point pairs. When you have a good amount of point pairs, click the "calibrate" button. This will generate a calibration. 

Once you have generated a calibration, you can toggle into "Testing mode" which allows you to test the fit. In testing mode, you can click anywhere on the Kinect image to place a red dot over a desired point in the camera image. A corresponding green point should then be projected onto that same location in your physical space. If the calibration is good, the red dot in the Kinect's image and the green one in the physical space should match. Try a few points at different locations to test the accuracy of the calibration.

If the calibration is satisfactory, click "Save." It will generate a text file containing the calibration parameters, which will be located in the path you specified in the `calibFilename` variable. 


##Using the calibration

The core function of the library is the ability to map any 3d point in physical space to the corresponding pixel  which falls on that point. The process goes as follows.

First, set up the Kinect and OpenCV. Make sure to run the Kinect's `alternativeViewPointDepthToImage()` so that the RGB and depth maps are aligned.

	kinect = new SimpleOpenNI(this); 
	kinect.enableDepth();
	kinect.alternativeViewPointDepthToImage();
	opencv = new OpenCV(this, kinect.depthWidth(), kinect.depthHeight());

Next, load your calibration file (replace `CALIBRATION_PATH` with the path to the calibration file saved from the process described above).

	kpt = new KinectProjectorToolkit(this, kinect.depthWidth(), kinect.depthHeight());
	kpt.loadCalibration(CALIBRATION_PATH);
	
In a frame, update the Kinect and then send its real world depth map to the KinectProjectorToolkit object.

	kinect.update();  
	kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 

Then, given a point from the real world depth map, you can obtain its pixel coordinate by running the `convertKinectToProjector()` method. The point can be, for example, the real world point of a tracked skeleton's hand. Make sure you are sampling from `depthMapRealWorld()` not `depthMap()`. So given real world PVector realWorldPoint, the projected coordinate is accessible via:

	PVector projectedPoint = kpt.convertKinectToProjector(realWorldPoint);

The toolkit has some higher level functions which automate some of this, depending on the specific task. For example, if you are tracking a skeleton and have an ArrayList of PVectors which correspond to a tracked object's contour points, you can convert all of them using the function `getProjectedContour(ArrayList<PVector> contourPoints)`. 

An optional second parameter "dilates" the projected contour, i.e. stretches or compresses it. For example, `getProjectedContour(ArrayList<PVector> contourPoints, 2.0)` will return a projected contour which has been stretched out to double its original dimensions; this can be useful, for example, in tracing a user's contour on the screen behind them. The default dilation is 1.0 (original size, no stretching).

The test applications in the library demonstrate some of these tasks.
	

##Test applications

The library contains a number of examples, prefixed "Test" which demonstrate various uses of the toolkit for creative projection. Demos include projecting an image onto a human body, projecting images onto specific tracked parts of a body, graphics projected onto background surfaces interacting with tracked bodies, etc. 

You must first make sure to go through the calibration process and generate the calibration file. Before running any of the demos, you must change the location of the loaded calibration file to the calibration you generated in the first step, and modify the line in the example accordingly.

	kpt.loadCalibration(YOUR_PATH_HERE);

Descriptions for test applications follow below:

###TestSkeleton, TestKrang, TestFireball
These demos are the simplest applications of the calibration. The Kinect tracks users and returns real world coordinates for their joints and limbs, and we project objects onto them. Skeleton projects the entire skeleton onto each person, Krang projects an image of [Krang](http://en.wikipedia.org/wiki/Krang) onto users' torsos. 

###TestBodyGraphics, TestBodyImage, TestBodyMovie, TestBodyShader
Show the process of projecting graphics onto a tracked human body, via the Kinect's userImage. They are identical, except for the content of the graphics, showing how to project a PGraphics object, a PImage, a Movie, and a shader, respectively.

###TestRibbons
Similar to the body projection examples, but instead projects ribbon-like lines around the contour of a body, tracing them onto the background behind the user.

###TestBackgroundFX
This example shows how a tracked user can manipulate background graphics projected behind them onto a screen or floor.

###TestFallingPolygons
Similar to TestBackgroundFX as it involves a user manipulating a background screen. A game in which polygons fall from the sky and a user can physically interact with them on a wall.

###RENDER
This is a high-level application combining the previous examples with a user interface for applying the effects. It is currently still under development.