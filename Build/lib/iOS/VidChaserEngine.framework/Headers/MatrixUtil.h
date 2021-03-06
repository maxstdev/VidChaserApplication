﻿/*
* Copyright 2017 Maxst, Inc. All Rights Reserved.
*/
#pragma once

#include "vecmath.h"

class MatrixUtil
{
public:
	static void GetImageCoordFromScreenCoord(int screenWidth, int screenHeight, int imageWidth, int imageHeight,
		int screenX, int screenY, int & imageX, int & imageY)
	{
		float widthRatio = (float)screenWidth / imageWidth;
		float heightRatio = (float)screenHeight / imageHeight;

		// When image's upper and lower part cropped.
		float ratio = widthRatio;

		// When image's left and right part cropped.
		if (widthRatio < heightRatio)
		{
			ratio = heightRatio;
		}

		imageX = (screenX - screenWidth / 2) / ratio + imageWidth / 2;
		imageY = -(screenHeight / 2 - screenY) / ratio + imageHeight / 2;
	}

	static void GetGLCoordFromScreenCoord(
		int screenWidth, int screenHeight, int imageWidth, int imageHeight,
		int screenX, int screenY, float & glX, float & glY)
	{
		float widthRatio = (float)screenWidth / imageWidth;
		float heightRatio = (float)screenHeight / imageHeight;

		int screenCenterX = screenWidth / 2;
		int screenCenterY = screenHeight / 2;

		float ratio = widthRatio;

		glX = (float)screenX - screenCenterX;
		glY = (float)screenCenterY - screenY;

		// When image's left and right part cropped.
		if (widthRatio < heightRatio)
		{
			ratio = heightRatio;
		}

		glX = ((float)screenX - screenCenterX) / ratio;
		glY = ((float)screenCenterY - screenY) / ratio;
	}

	static void GetGLCoordinateFromTouchPoint(
		int surfaceWidth, int surfaceHeight, int imageWidth, int imageHeight, int touchX, int touchY,
		float & resultGLX, float & resultGLY)
	{
		float wr = (float)surfaceWidth / imageWidth;
		float hr = (float)surfaceHeight / imageHeight;

		int cx = surfaceWidth / 2;
		int cy = surfaceHeight / 2;

		// image w / h ratio is greater than screen w / h ratio
		if (wr > hr)
		{
			float convertSW = surfaceWidth / wr;
			float convertSH = surfaceHeight / wr;

			float diffH = imageHeight - convertSH;

			resultGLX = (float)touchX - cx;
			resultGLY = (float)cy - touchY;

			resultGLX = resultGLX / wr;
			resultGLY = resultGLY / wr;
		}
		// Screen w / h ratio is greater than image w / h ratio
		else
		{
			float convertSW = surfaceWidth / hr;
			float convertSH = surfaceHeight / hr;

			float diffW = imageWidth - convertSW;

			resultGLX = (float)touchX - cx;
			resultGLY = (float)cy - touchY;

			resultGLX = resultGLX / hr;
			resultGLY = resultGLY / hr;
		}
	}

	static void GetTransformMatrix44F(
		int imageWidth, int imageHeight, gl_helper::Mat3 inputTransformMatrix33F, gl_helper::Mat4 & resultTransformMatrix44F)
	{
		gl_helper::Mat3 fullTransform3x3;
		/*if (isPortrait = false) { //이부분 인자로 받아서 portrait 처리 해야함. 
			//portrait
			gl_helper::Mat3 convertGLToImage = gl_helper::Mat3::Zero();
			convertGLToImage.Ptr()[1] = -1.0f;
			convertGLToImage.Ptr()[3] = -1.0f;
			convertGLToImage.Ptr()[6] = imageWidth / 2.0f;
			convertGLToImage.Ptr()[7] = imageHeight / 2.0f;
			convertGLToImage.Ptr()[8] = 1.0f;

			gl_helper::Mat3 transformOrientation = gl_helper::Mat3::Zero();
			transformOrientation.Ptr()[1] = 1.0f;
			transformOrientation.Ptr()[3] = -1.0f;
			transformOrientation.Ptr()[6] = imageHeight;
			transformOrientation.Ptr()[8] = 1.0f;

			gl_helper::Mat3 convertImageToGL = gl_helper::Mat3::Identity();
			convertImageToGL.Ptr()[4] = -1.0f;
			convertImageToGL.Ptr()[6] = -imageHeight / 2.0f;
			convertImageToGL.Ptr()[7] = imageWidth / 2.0f;

			fullTransform3x3 = convertImageToGL * transformOrientation * inputTransformMatrix33F * convertGLToImage;
		}
		else {*/
			//landscape
			gl_helper::Mat3 convertGLToImage = gl_helper::Mat3::Identity();
			convertGLToImage.Ptr()[6] = imageWidth / 2.0f;
			convertGLToImage.Ptr()[4] = -1.0f;
			convertGLToImage.Ptr()[7] = imageHeight / 2.0f;

			gl_helper::Mat3 convertImageToGL = gl_helper::Mat3::Identity();
			convertImageToGL.Ptr()[6] = -imageWidth / 2.0f;
			convertImageToGL.Ptr()[4] = -1.0f;
			convertImageToGL.Ptr()[7] = imageHeight / 2.0f;

			fullTransform3x3 = convertImageToGL * inputTransformMatrix33F * convertGLToImage;
		//}

		resultTransformMatrix44F.Ptr()[0] = fullTransform3x3.Ptr()[0] / fullTransform3x3.Ptr()[8];
		resultTransformMatrix44F.Ptr()[1] = fullTransform3x3.Ptr()[1] / fullTransform3x3.Ptr()[8];
		resultTransformMatrix44F.Ptr()[2] = 0.0f;
		resultTransformMatrix44F.Ptr()[3] = fullTransform3x3.Ptr()[2] / fullTransform3x3.Ptr()[8];

		resultTransformMatrix44F.Ptr()[4] = fullTransform3x3.Ptr()[3] / fullTransform3x3.Ptr()[8];
		resultTransformMatrix44F.Ptr()[5] = fullTransform3x3.Ptr()[4] / fullTransform3x3.Ptr()[8];
		resultTransformMatrix44F.Ptr()[6] = 0.0f;
		resultTransformMatrix44F.Ptr()[7] = fullTransform3x3.Ptr()[5] / fullTransform3x3.Ptr()[8];

		resultTransformMatrix44F.Ptr()[8] = 0.0f;
		resultTransformMatrix44F.Ptr()[9] = 0.0f;
		resultTransformMatrix44F.Ptr()[10] = 1.0f;
		resultTransformMatrix44F.Ptr()[11] = 0.0f;

		resultTransformMatrix44F.Ptr()[12] = fullTransform3x3.Ptr()[6] / fullTransform3x3.Ptr()[8];
		resultTransformMatrix44F.Ptr()[13] = fullTransform3x3.Ptr()[7] / fullTransform3x3.Ptr()[8];
		resultTransformMatrix44F.Ptr()[14] = 0.0f;
		resultTransformMatrix44F.Ptr()[15] = fullTransform3x3.Ptr()[8] / fullTransform3x3.Ptr()[8];
	}
};