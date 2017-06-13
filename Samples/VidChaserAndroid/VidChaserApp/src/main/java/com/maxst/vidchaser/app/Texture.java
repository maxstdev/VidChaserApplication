/*
 * Copyright 2016 Maxst, Inc. All Rights Reserved.
 */

package com.maxst.vidchaser.app;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;

public class Texture {

	private static final String TAG = Texture.class.getSimpleName();

	public int width;
	public int height;
	public byte [] data;

	public static Texture loadTextureFromApk(String fileName, AssetManager assets) {
		InputStream inputStream = null;
		try {
			inputStream = assets.open(fileName, AssetManager.ACCESS_BUFFER);

			BufferedInputStream bufferedStream = new BufferedInputStream(
					inputStream);
			Bitmap bitMap = BitmapFactory.decodeStream(bufferedStream);

			int[] data = new int[bitMap.getWidth() * bitMap.getHeight()];
			bitMap.getPixels(data, 0, bitMap.getWidth(), 0, 0,
					bitMap.getWidth(), bitMap.getHeight());

			int numPixels = bitMap.getWidth() * bitMap.getHeight();
			byte[] dataBytes = new byte[numPixels * 4];

			for (int p = 0; p < numPixels; ++p) {
				int colour = data[p];
				dataBytes[p * 4] = (byte) (colour >>> 16); // R
				dataBytes[p * 4 + 1] = (byte) (colour >>> 8); // G
				dataBytes[p * 4 + 2] = (byte) colour; // B
				dataBytes[p * 4 + 3] = (byte) (colour >>> 24); // A
			}

			Texture texture = new Texture();
			texture.width = bitMap.getWidth();
			texture.height = bitMap.getHeight();
			texture.data = dataBytes;

			return texture;
		} catch (IOException e) {
			Log.i(TAG, e.getMessage());
			return null;
		}
	}
}