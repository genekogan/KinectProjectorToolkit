/**
 * Kinect Projector Toolkit
 * A utility for calibrating a depth camera to a projector, enabling automated projection mapping
 * http://www.genekogan.com
 *
 * Copyright (c) 2013 Gene Kogan http://www.genekogan.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author      Gene Kogan http://www.genekogan.com
 * @modified    01/13/2014
 * @version     1.0.0 (1)
 */

package KinectProjectorToolkit;

/**
 * KinectProjectorToolkit is a Processing library which facilitates
 * the calibrated alignment of a Kinect depth camera with a video
 * projector.
 *
 *  2013 by Gene Kogan
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 *
 * @author 		Gene Kogan (http://www.genekogan.com)
 * @modified	Jan 2014
 * @version		1.0
 * @example		TestBodyGraphics
 *
 */


import processing.core.*;
import processing.opengl.*;
import java.util.ArrayList;


public class KinectProjectorToolkit 
{	
	PApplet myParent;
	int width, height;
	float[] projectorMatrix;
	PVector[] depthMapRealWorld;
	PGraphics pgKinect;
	PShader userShader;
	float[] window;
	float totalWindow;
	int blobWindow, blobSkip;
	

	/**
	 * create a new instance of KinectProjectorToolkit
	 * 
	 * @example TestBodyGraphics
	 * @param theParent
	 * @param theWidth
	 * @param theHeight
	 */
	public KinectProjectorToolkit(PApplet theParent, int theWidth, int theHeight) {
		myParent = theParent;
		width = theWidth;
		height = theHeight;
		pgKinect = myParent.createGraphics(width, height, PApplet.P2D);
		userShader = myParent.loadShader("kinectUser.glsl");
		userShader.set("resolution", (float)pgKinect.width, (float)pgKinect.height);
		pgKinect.shader(userShader);
		setContourSmoothness(1);
		System.out.println("Kinect Projector Toolkit 1.0.0 by Gene Kogan http://www.genekogan.com");
	}
	
	/**
	 * load a previous calibration
	 * 
	 * @param filepath
	 *          path to calibration file
	 */
	public void loadCalibration(String filename) {
		String[] s = myParent.loadStrings(myParent.dataPath(filename));
		projectorMatrix = new float[s.length];
		for (int i=0; i<s.length; i++)
			projectorMatrix[i] = Float.parseFloat(s[i]);
	}

	/**
	 * get 2d projector point of a 3d real world kinect point
	 * 
	 * @param kinectPoint
	 *          3d point in Kinect real world space
	 * @return PVector
	 */
	public PVector convertKinectToProjector(PVector kinectPoint) {
		float denom = projectorMatrix[8]*kinectPoint.x + projectorMatrix[9]*kinectPoint.y + projectorMatrix[10]*kinectPoint.z + 1.0f;
		return new PVector(
			myParent.width  * (projectorMatrix[0]*kinectPoint.x + projectorMatrix[1]*kinectPoint.y + projectorMatrix[2]*kinectPoint.z + projectorMatrix[3]) / denom,
			myParent.height * (projectorMatrix[4]*kinectPoint.x + projectorMatrix[5]*kinectPoint.y + projectorMatrix[6]*kinectPoint.z + projectorMatrix[7]) / denom);
	}

	/**
	 * get 3d real world kinect point from 640x480 Kinect depth map
	 * 
	 * @param x
	 * @param y
	 * @return PVector
	 */
	public PVector getDepthMapAt(int x, int y) {
		return depthMapRealWorld[width * y + x];
	}

	/**
	 * update real world depth map
	 * 
	 * @param theDepthMapRealWorld
	 */
	public void setDepthMapRealWorld(PVector[] theDepthMapRealWorld) {
		depthMapRealWorld = theDepthMapRealWorld;
	}
	
	/**
	 * update kinect depth image
	 * 
	 * @param theKinectUserImage
	 */
	public void setKinectUserImage(PImage theKinectUserImage) {
		pgKinect.beginDraw();
		pgKinect.image(theKinectUserImage, 0, 0);
		pgKinect.endDraw();  
	}
	
	/**
	 * get kinect depth image
	 * 
	 * @param theKinectUserImage
	 */
	public PGraphics getImage() {
		return pgKinect;
	}
	
	/**
	 * sets smoothness of found contours 
	 * 
	 * @param smoothness number of contour points to average over
	 */
	public void setContourSmoothness(int smoothness) {
		blobSkip = PApplet.max(smoothness, 1);
		blobWindow = 2 * blobSkip;
		setupBlobWindow();
	}
	
	/**
	 * takes OpenCV body contours, returns projected contours
	 * 
	 * @param contourPoints blob contour points found by OpenCV
	 * @param blobDilate stretches bounding box of the contour (default 1.0 is no stretching)
	 * @return ProjectedContour
	 */
	public ProjectedContour getProjectedContour(ArrayList<PVector> contourPoints, float blobDilate) {
		ProjectedContour projectedContour = new ProjectedContour(contourPoints, this);
		projectedContour.calculateProjectedContour(blobDilate);
		return projectedContour;
	}
	
	private void setupBlobWindow() {
		totalWindow = 1.0f;
		window = new float[blobWindow+1];
		window[0] = 1.0f;
		for (int i=1; i<=blobWindow; i++) {
			window[i] = 1.0f - (i/(blobWindow+1));
			totalWindow += 2*window[i];
		}
	}
}

