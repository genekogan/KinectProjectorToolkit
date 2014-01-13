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

import processing.core.PApplet;
import processing.core.PVector;
import java.awt.Rectangle;
import java.util.ArrayList;

public class ProjectedContour 
{	
	KinectProjectorToolkit kpc;
	ArrayList<PVector> contourPoints;
	ArrayList<PVector> blobPoints;
	Rectangle boundingBox;
	
	/**
	 * create projected contours from a set of OpenCV contour points and an instance of KinectProjectorToolkit
	 * 
	 * @example TestBodyGraphics
	 * @param theContourPoints
	 * @param theKpc
	 */
	public ProjectedContour(ArrayList<PVector> theContourPoints, KinectProjectorToolkit theKpc) {
		contourPoints = theContourPoints;
		kpc = theKpc;
	}
		
	/**
	 * calculates the projected, dilated, and smoothed contour points
	 * 
	 * @example TestBodyGraphics
	 * @param blobDilate stretching factor of contour's bounding box (1.0 = no stretching)
	 */
	public void calculateProjectedContour(float blobDilate) 
	{
		ArrayList<PVector> projectedPoints = new ArrayList<PVector>();
		blobPoints = new ArrayList<PVector>();

		if (contourPoints.size() < 100)	{
			blobPoints = new ArrayList<PVector>();
			return;
		}
		
		PVector bbTL = new PVector(kpc.width, kpc.height);
	    PVector bbBR = new PVector(0, 0);    
	    for (PVector cp : contourPoints) {
	        cp.x = PApplet.constrain(cp.x, 0, kpc.width-1);
	        cp.y = PApplet.constrain(cp.y, 0, kpc.height-1);
	        
	        PVector kp = kpc.getDepthMapAt((int)cp.x, (int)cp.y);
	        PVector pp = kpc.convertKinectToProjector(kp);
	        projectedPoints.add(pp);
	        if      (pp.x < bbTL.x)  bbTL.x = pp.x;
	        else if (pp.x > bbBR.x)  bbBR.x = pp.x;
	        if      (pp.y < bbTL.y)  bbTL.y = pp.y;
	        else if (pp.y > bbBR.y)  bbBR.y = pp.y;    
	    }
	    
	    Rectangle bbOriginal = new Rectangle(
	    	(int)bbTL.x, (int)bbTL.y, 
	    	(int)(bbBR.x - bbTL.x), (int)(bbBR.y - bbTL.y));
	    Rectangle bbDilated = new Rectangle(
	    	(int) (bbTL.x - 0.5 * bbOriginal.width * (blobDilate - 1.0)), (int)(bbTL.y - 0.5 * bbOriginal.height * (blobDilate - 1.0)),
	    	(int) (bbOriginal.width * blobDilate), (int) (bbOriginal.height * blobDilate));
	    
	    // dilate bounding box
	    for (PVector pp : projectedPoints) {
	      pp.set(PApplet.map(pp.x, bbOriginal.x, bbOriginal.x + bbOriginal.width, bbDilated.x, bbDilated.x + bbDilated.width),
	    		 PApplet.map(pp.y, bbOriginal.y, bbOriginal.y + bbOriginal.height, bbDilated.y, bbDilated.y + bbDilated.height));
	    }

	    // smooth points and add to blobPoints
	    for (int i=0; i<projectedPoints.size(); i+=kpc.blobSkip) {
	      PVector bp = projectedPoints.get(i);
	      for (int k=1; k<=kpc.blobWindow; k++) {
	        int idx1 = (projectedPoints.size()+i-k) % projectedPoints.size();
	        int idx2 = (i+k) % projectedPoints.size();          
	        bp.x += (kpc.window[k]*projectedPoints.get(idx1).x + kpc.window[k]*projectedPoints.get(idx2).x);
	        bp.y += (kpc.window[k]*projectedPoints.get(idx1).y + kpc.window[k]*projectedPoints.get(idx2).y);
	      }
	      bp.x /= kpc.totalWindow;
	      bp.y /= kpc.totalWindow;
	      blobPoints.add(bp);
	    }
	    boundingBox = bbDilated;
	}
	
	/**
	 * calculates the projected, dilated, and smoothed contour points with no stretching
	 * 
	 * @example TestBodyGraphics
	 */
	public void calculateProjectedContour() {
		calculateProjectedContour(1.0f);
	}

	/**
	 * get projected contour points
	 * 
	 * @example TestBodyGraphics
	 * @return blobPoints
	 */
	public ArrayList<PVector> getProjectedContours() {		
		return blobPoints;
	}
	
	/**
	 * get projected contour's bounding box (requires java.awt.*)
	 * 
	 * @example TestBodyGraphics
	 * @return boundingBox
	 */
	public Rectangle getBoundingBox() {
		return boundingBox;
	}
	
	/**
	 * get a single contour point's coordinates for texture mapping
	 * 
	 * @example TestBodyGraphics
	 * @return PVector
	 */
	public PVector getTextureCoordinate(PVector p) {
		return new PVector((p.x - boundingBox.x) / boundingBox.width, 
						   (p.y - boundingBox.y) / boundingBox.height);
	}
}