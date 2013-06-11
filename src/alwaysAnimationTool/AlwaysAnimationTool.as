package alwaysAnimationTool {
	
	
	import alwaysAnimationTool.view.ControlUI;
	import alwaysAnimationTool.view.DotsDisplay;

	import hires.debug.Stats;

	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;


	public class AlwaysAnimationTool extends Sprite {
		
		private var _controls : ControlUI;
		private var _holder : Sprite;
		private var _display : DotsDisplay;
		private var _bannerWidth:int  = 300;
		private var _bannerHeight:int = 250;
		
		
		
		public function AlwaysAnimationTool()
		{
			(stage) ? initApp() : addEventListener(Event.ADDED_TO_STAGE, initApp);
		}

		private function initApp(e:Event = null) : void {
			if (e) removeEventListener(Event.ADDED_TO_STAGE, initApp);
			stage.scaleMode = StageScaleMode.NO_SCALE;			
			_holder = new Sprite();
			_display = new DotsDisplay();	
			_display.x = 140;//500-(.5*_bannerWidth);
			_display.y = 50;// 400-(.5*_bannerHeight);
			
			
			_controls = new ControlUI();
			_controls.x = -230;
			_controls.y = -170;
			var stats:Stats = new Stats();
			stats.x = _display.x+_bannerWidth+300
			stats.y = _display.y+ _bannerHeight+ 00;
		//	_controls.addChild(stats);
			
			_holder.addChild(_display);
			_holder.addChild(_controls);
			
			addChild(_holder);
			
			addListeners();
			valueUpdatedListener(new Event("init"));
			
			 
		//	_stats = new Stats();
		}
		
	
		

		private function addListeners() : void {
			_controls.addEventListener("valueUpdated", valueUpdatedListener);
			_controls.addEventListener("explode", explodeListener);
			_controls.addEventListener("removeParticles", removeParticlesListener);
			
		}

		private function removeParticlesListener(e:Event) : void {
			//_display.removeParticles();			
		}

		private function valueUpdatedListener(e:Event) : void {
			
			_display.valuesSet(_controls.sketchParams);
		}
		
		private function explodeListener(e:Event) : void {
		
			
			_display.explode();
		}
		
	}
}
