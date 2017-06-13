/*
 * Copyright 2017 Maxst, Inc. All Rights Reserved.
 */

package com.maxst.vidchaser.app;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioButton;

import butterknife.Bind;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class SettingsActivity extends Activity {

	@Bind(R.id.sd_resolution)
	RadioButton sdResolution;

	@Bind(R.id.hd_resolution)
	RadioButton hdResolution;

	@Bind(R.id.full_hd_resolution)
	RadioButton fullHdResolution;

	@Bind(R.id.image_yuv)
	RadioButton imageFormatYUV;

	@Bind(R.id.image_rgb888)
	RadioButton imageFormatRGB888;

	@Bind(R.id.image_rgba8888)
	RadioButton imageFormatRGBA8888;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);

		ButterKnife.bind(this);

		int resolution = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).getInt(VidChaserUtil.PREF_KEY_CAM_RESOLUTION, 0);
		switch (resolution) {
			case 0:
				sdResolution.setChecked(true);
				break;

			case 1:
				hdResolution.setChecked(true);
				break;

			case 2:
				fullHdResolution.setChecked(true);
				break;
		}

		int imageSaveFormat = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).getInt(VidChaserUtil.PREF_KEY_IMAGE_FORMAT, 0);
		switch (imageSaveFormat) {
			case 0:
				imageFormatRGBA8888.setChecked(true);
				break;

			case 1:
				imageFormatRGB888.setChecked(true);
				break;

			case 2:
				imageFormatYUV.setChecked(true);
				break;
		}
	}

	@Override
	public void onDestroy() {
		super.onDestroy();

		ButterKnife.unbind(this);
	}

	@OnClick({R.id.sd_resolution, R.id.hd_resolution, R.id.full_hd_resolution})
	public void onResolutionClick(View view) {
		switch (view.getId()) {
			case R.id.sd_resolution:
				SharedPreferences.Editor editor = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).edit();
				editor.putInt(VidChaserUtil.PREF_KEY_CAM_RESOLUTION, 0);
				editor.apply();
				break;

			case R.id.hd_resolution:
				editor = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).edit();
				editor.putInt(VidChaserUtil.PREF_KEY_CAM_RESOLUTION, 1);
				editor.apply();
				break;

			case R.id.full_hd_resolution:
				editor = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).edit();
				editor.putInt(VidChaserUtil.PREF_KEY_CAM_RESOLUTION, 2);
				editor.apply();
				break;
		}
	}

	@OnClick({R.id.image_yuv, R.id.image_rgb888, R.id.image_rgba8888})
	public void onImageFormatClick(View view) {
		switch (view.getId()) {
			case R.id.image_rgba8888:
				SharedPreferences.Editor editor = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).edit();
				editor.putInt(VidChaserUtil.PREF_KEY_IMAGE_FORMAT, 0);
				editor.apply();
				break;

			case R.id.image_rgb888:
				editor = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).edit();
				editor.putInt(VidChaserUtil.PREF_KEY_IMAGE_FORMAT, 1);
				editor.apply();
				break;

			case R.id.image_yuv:
				editor = getSharedPreferences(VidChaserUtil.PREF_NAME , Activity.MODE_PRIVATE).edit();
				editor.putInt(VidChaserUtil.PREF_KEY_IMAGE_FORMAT, 2);
				editor.apply();
				break;
		}
	}
}