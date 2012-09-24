package
{
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	[SWF(frameRate="30")]
	/**
	 * 
	 * @author jstander
	 * 
	 */
	public class Main extends Sprite
	{
		private const VIDEO:String = "baileys_5sec.mp4";
		
		public function Main()
		{
			super();
			init();
		}
		
		public function onMetaData(object:Object):void
		{
			trace(object);
		}
		
		public function onXMPData(object:Object):void
		{
			trace(object);
		}
		
		public function onPlayStatus(object:Object):void
		{
			trace(object);
		}
		
		private function init():void
		{
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = NativeApplication.nativeApplication.runtimeVersion;
			var format:TextFormat = textField.getTextFormat();
			format.size = 50;
			format.color = 0xFF0000;
			textField.setTextFormat(format);
			addChild(textField);
			
			var connection:NetConnection = new NetConnection();
			var netStatusHandler:Function = function(event:NetStatusEvent):void
			{
				switch(event.info.code)
				{
					case "NetConnection.Connect.Success":
						var stream:NetStream = new NetStream(NetConnection(event.target));
						stream.client = this;
						stream.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent):void
						{
							switch(event.info.code)
							{
								case "NetStream.Play.Stop":
									stream.seek(0);
									break;
							}
							trace(event.info.code);
						});
						
						if( stage.stageVideos.length > 0 )
						{
							trace("Using Stage Video");
							var video:StageVideo = stage.stageVideos[0];
							video.viewPort = new Rectangle(0,0,1280,720);
							video.attachNetStream(stream);
						}
						else
						{
							trace("Default Video");
							var cpu:Video = new Video(
								Screen.mainScreen.bounds.width,
								Screen.mainScreen.bounds.height);
							cpu.attachNetStream(stream);
							addChild(cpu);
						}
						stream.play(VIDEO);
						break;
					default:
						trace(event.info.code);
						break;
				}
			}
			connection.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
			connection.connect(null);
			
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		}
	}
}