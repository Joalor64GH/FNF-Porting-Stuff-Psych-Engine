package android;

import android.flixel.FlxHitbox;
import android.flixel.FlxVirtualPad;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

class AndroidControls extends FlxSpriteGroup
{
	public var virtualPad:FlxVirtualPad;
	public var hitbox:FlxHitbox;

	public function new()
	{
		super();

		switch (AndroidControls.getMode())
		{
			case 'Pad-Right':
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Left':
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Custom':
				virtualPad = AndroidControls.getCustomMode(new FlxVirtualPad(RIGHT_FULL, NONE));
				add(virtualPad);
			case 'Pad-Duo':
				virtualPad = new FlxVirtualPad(BOTH_FULL, NONE);
				add(virtualPad);
			case 'Hitbox':
				hitbox = new FlxHitbox();
				add(hitbox);
			case 'Keyboard': // do nothing
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (hitbox != null)
		{
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
	}

	public static function setOpacity(opacity:Float = 0.6):Void
	{
		FlxG.save.data.androidControlsOpacity = opacity;
		FlxG.save.flush();
	}

	public static function getOpacity():Float
	{
		if (FlxG.save.data.androidControlsOpacity == null)
		{
			FlxG.save.data.androidControlsOpacity = 0.6;
			FlxG.save.flush();
		}

		return FlxG.save.data.androidControlsOpacity;
	}

	public static function setMode(mode:String = 'Pad-Right'):Void
	{
		FlxG.save.data.androidControlsMode = mode;
		FlxG.save.flush();
	}

	public static function getMode():String
	{
		if (FlxG.save.data.androidControlsMode == null)
		{
			FlxG.save.data.androidControlsMode = 'Pad-Right';
			FlxG.save.flush();
		}

		return FlxG.save.data.androidControlsMode;
	}

	public static function setCustomMode(virtualPad:FlxVirtualPad):Void
	{
		if (FlxG.save.data.buttons == null)
		{
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		FlxG.save.flush();
	}

	public static function getCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		var tempCount:Int = 0;

		if (FlxG.save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad)
		{
			buttons.x = FlxG.save.data.buttons[tempCount].x;
			buttons.y = FlxG.save.data.buttons[tempCount].y;
			tempCount++;
		}

		return virtualPad;
	}
}
