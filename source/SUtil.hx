package;

#if android
import android.Hardware;
import android.Permissions;
import android.os.Environment;
#end
import flash.system.System;
import flixel.FlxG;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */
class SUtil
{
	/**
	 * A simple function that checks for storage permissions and game files/folders
	 */
	public static function check()
	{
		#if android
		if (!Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE)
			&& !Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE))
		{
			Permissions.requestPermissions([PermissionsList.WRITE_EXTERNAL_STORAGE, PermissionsList.READ_EXTERNAL_STORAGE]);

			/**
			 * Basically for now i can't force the app to stop while its requesting a android permission, so this makes the app to stop while its requesting the specific permission
			 */
			Application.current.window.alert('If you accepted the permissions you are all good!' + "\nIf you didn't then expect a crash"
				+ 'Press Ok to see what happens',
				'Permissions?');
		}

		if (Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE)
			&& Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE))
		{
			if (!FileSystem.exists(SUtil.getPath()))
				FileSystem.createDirectory(SUtil.getPath());

			if (!FileSystem.exists(SUtil.getPath() + 'assets') && !FileSystem.exists(SUtil.getPath() + 'mods'))
			{
				Application.current.window.alert("Whoops, seems like you didn't extract the files from the .APK!\nPlease watch the tutorial by pressing OK.",
					'Error!');
				FlxG.openURL('https://youtu.be/zjvkTmdWvfU');
				System.exit(1);
			}
			else if ((FileSystem.exists(SUtil.getPath() + 'assets') && !FileSystem.isDirectory(SUtil.getPath() + 'assets'))
				&& (FileSystem.exists(SUtil.getPath() + 'mods') && !FileSystem.isDirectory(SUtil.getPath() + 'mods')))
			{
				Application.current.window.alert("Why did you create two files called assets and mods instead of copying the folders from the .APK?, expect a crash.",
					'Error!');
				System.exit(1);
			}
			else
			{
				if (!FileSystem.exists(SUtil.getPath() + 'assets'))
				{
					Application.current.window.alert("Whoops, seems like you didn't extract the assets/assets folder from the .APK!\nPlease watch the tutorial by pressing OK.",
						'Error!');
					FlxG.openURL('https://youtu.be/zjvkTmdWvfU');
					System.exit(1);
				}
				else if (FileSystem.exists(SUtil.getPath() + 'assets') && !FileSystem.isDirectory(SUtil.getPath() + 'assets'))
				{
					Application.current.window.alert("Why did you create a file called assets instead of copying the assets directory from the .APK?, expect a crash.",
						'Error!');
					System.exit(1);
				}

				if (!FileSystem.exists(SUtil.getPath() + 'mods'))
				{
					Application.current.window.alert("Whoops, seems like you didn't extract the assets/mods folder from the .APK!\nPlease watch the tutorial by pressing OK.",
						'Error!');
					FlxG.openURL('https://youtu.be/zjvkTmdWvfU');
					System.exit(1);
				}
				else if (FileSystem.exists(SUtil.getPath() + 'mods') && !FileSystem.isDirectory(SUtil.getPath() + 'mods'))
				{
					Application.current.window.alert("Why did you create a file called mods instead of copying the mods directory from the .APK?, expect a crash.",
						'Error!');
					System.exit(1);
				}
			}
		}
		#end
	}

	/**
	 * This returns the external storage path that the game will use
	 */
	public static function getPath():String
	{
		#if android
		return Environment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
		#else
		return '';
		#end
	}

	/**
	 * Uncaught error handler, original made by: sqirra-rng
	 */
	public static function uncaughtErrorHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case CFunction:
						errMsg += '(a C function)\n';
					case Module(m):
						errMsg += '(module ' + m + ')\n';
					case FilePos(s, file, line, column):
						errMsg += '(' + file + ' line ' + line + ' column ' + column == null ? "<unknown>" : column + ')\n';
					case Method(cname, meth):
						errMsg += '(' + cname == null ? "<unknown>" : cname + '.' + meth + ')\n';
					case LocalFunction(n):
						errMsg += "(local function #" + n + ')\n';
				}
			}

			errMsg += u.error;

			Sys.println(errMsg);
			Application.current.window.alert(errMsg, 'Error!');

			try
			{
				if (!FileSystem.exists(SUtil.getPath() + 'logs'))
					FileSystem.createDirectory(SUtil.getPath() + 'logs');

				File.saveContent(SUtil.getPath() + 'logs/' + Application.current.meta.get('file') + '_'
					+ Date.now().toString().replace(" ", "-").replace(":", "'") + '.log',
					errMsg + "\n");
			}
			#if android
			catch (e:Dynamic)
				Hardware.toast("Error!\nClouldn't save the crash dump because:\n" + e, 2);
			#end

			System.exit(1);
		});
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot to add something in your code')
	{
		try
		{
			if (!FileSystem.exists(SUtil.getPath() + 'saves'))
				FileSystem.createDirectory(SUtil.getPath() + 'saves');

			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
			Hardware.toast("File Saved Successfully!", 2);
		}
		#if android
		catch (e:Dynamic)
			Hardware.toast("Error!\nClouldn't save the file because:\n" + e, 2);
		#end
	}

	public static function copyContent(copyPath:String, savePath:String)
	{
		try
		{
			if (!FileSystem.exists(savePath) && OpenFlAssets.exists(copyPath))
				File.saveBytes(savePath, OpenFlAssets.getBytes(copyPath));
		}
		#if android
		catch (e:Dynamic)
			Hardware.toast("Error!\nClouldn't copy the file because:\n" + e, 2);
		#end
	}
}
