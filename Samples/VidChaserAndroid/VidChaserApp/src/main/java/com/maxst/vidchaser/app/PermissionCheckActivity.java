/*
 * Copyright 2016 Maxst, Inc. All Rights Reserved.
 */

package com.maxst.vidchaser.app;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.gun0912.tedpermission.PermissionListener;
import com.gun0912.tedpermission.TedPermission;

import java.util.ArrayList;

public class PermissionCheckActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		checkPermission();
	}

	private void checkPermission() {
		PermissionListener permissionlistener = new PermissionListener() {
			@Override
			public void onPermissionGranted() {
				startActivity(new Intent(PermissionCheckActivity.this, MainActivity.class));
				finish();
			}

			@Override
			public void onPermissionDenied(ArrayList<String> deniedPermissions) {
				finish();
			}
		};

		new TedPermission(this)
				.setPermissionListener(permissionlistener)
				.setPermissions(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA)
				.check();
	}
}
