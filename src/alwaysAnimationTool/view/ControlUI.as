package alwaysAnimationTool.view {
	import caurina.transitions.Tweener;

	import hires.debug.Stats;

	import uk.co.soulwire.gui.SimpleGUI;

	import utils.CustomEvent;
	import utils.TextFieldUtils;

	import com.bit101.components.Component;
	import com.bit101.components.List;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.registerClassAlias;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	/**
	 * @author acolling
	 */
	public class ControlUI extends Sprite {
		private var _holder : Sprite;
		private var _gui : SimpleGUI;
		private var _total : *;
		private var _format : TextFormat;
		public var sketchParams : SketchParams;
		// all circles
		public var totalCirles : uint;
		public var dotsPerCircle : uint;
		public var initialCircleRadius : uint;
		public var spaceBetweenCircles : uint;
		// dots
		public var smallestDotRadius : uint;
		public var dotRadiusIncrement : uint;
		// movement
		public var rotateSpeed : uint;
		private var _stats : Stats;
		private var _timer : Timer;
		public var presets : Array;
		private var _presetCombo : Component;
		public var _presetIndex : int = 0;
		private var _data : String;
		//private var _dataFile : Fil;
		private var fr : FileReference;
		private var _list : List;
		// lists and button
		private var clearButton : Sprite;
		public var availableItems : List;
		private var selectedItemList : List;
		private var _availableItemsDP : Array;
		private var _animOrder : TextField;
		private var _animLabels : Array;
		private var _textFormat : TextFormat;
		private var _animIndex : int;
		public var _animDuration : Number = 2;
		private var _animStartTimer : Timer;
		
		public var explodeAtEnd:Boolean;

		public function ControlUI() {
			init();
		}

		private function init() : void {
			presets = [];
			sketchParams = new SketchParams();
			_holder = new Sprite();
			addChild(_holder);
			createControls();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

		
			// createList();
		}

		// ///////////////////////////////
		private function mouseDownHandler(event : MouseEvent) : void {
			var sprite : Sprite = Sprite(event.target);
			sprite.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			if (sprite.name == "instance24" || sprite.name == "instance11") {
				this.startDrag();
			}
		}

		private function mouseUpHandler(event : MouseEvent) : void {
			var sprite : Sprite = Sprite(event.target);
			sprite.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			this.stopDrag();
		}

		private function mouseMoveHandler(event : MouseEvent) : void {
			event.updateAfterEvent();
		}

		private function createControls() : void {
			_gui = new SimpleGUI(this, "PRESS 'C' TO SHOW/HIDE CONTROLS- DRAG TO MOVE CONTROLS", "C");

			_gui.addGroup("All CIRCLES");
			_gui.addSlider("sketchParams.totalCirles", 1, 10, {label:"Total Circles", width:370, tick:1, value:5, callback:valueUpdated});

			_gui.addSlider("sketchParams.dotsPerCircle", 1, 40, {label:"Dots per Circle", width:370, tick:1, callback:valueUpdated});
			_gui.addSlider("sketchParams.initialCircleRadius", 1, 300, {label:"Initial Circle Radius", width:370, tick:1, value:200, callback:valueUpdated});
			_gui.addSlider("sketchParams.spaceBetweenCircles", 1, 150, {label:"Space Between Circles", width:370, tick:1, callback:valueUpdated});

			_gui.addGroup("DOT PARAMETERS");
			_gui.addSlider("sketchParams.smallestDotRadius", .5, 200, {label:"Smallest Dot Size", width:370, tick:.5, callback:valueUpdated});
			_gui.addSlider("sketchParams.dotRadiusIncrement", .5, 100, {label:"Dot Size Increment", width:370, tick:.5, callback:valueUpdated});
			_gui.addSlider("sketchParams.dotAlpha", 0, 1, {label:"Dot Alpha", width:370, tick:.1, callback:valueUpdated, value:1});
			_gui.addColour("sketchParams.dotColor", {label:"Dot Color", callback:valueUpdated});
			_gui.addToggle("sketchParams.showCircles", {label:"Show Circles", callback:valueUpdated});

			_gui.addGroup("MOVEMENT");
			_gui.addSlider("sketchParams.rotateSpeed", -2, 2, {label:"Rotate Speed", width:370, tick:.1, callback:valueUpdated});

			_gui.addGroup("FILTER PARAMS");
			// _gui.addComboBox("sketchParams.filterType", [{data:"blur", label:"blur"}, {label:"glow", data:"glow"}], {label:'Filter Type', callback:valueUpdated});
			/*	_gui.addComboBox("sketchParams.filterType", [

			{label:"blur",	data:"blur"},
			{label:"glow",	data:"glow"}
	
	
	
			], {label:"Filter Type", callback:valueUpdated});*/
			_gui.addSlider("sketchParams.filterSize", 0, 20, {label:"Filter Size", width:370, tick:.5, callback:valueUpdated});
			_gui.addSlider("sketchParams.filterStrength", 0, 255, {label:"Filter Strength", width:370, tick:1, callback:valueUpdated});
			_gui.addSlider("sketchParams.filterAlpha", 0, 1, {label:"Filter Alpha", width:370, tick:.05, callback:valueUpdated});
			_gui.addColour("sketchParams.filterColor", {label:"Filter Color", callback:valueUpdated});

			_gui.addColumn("EXPLOSION");
			_gui.addSlider("sketchParams.explosionPower", 0, 200, {label:"Explosion Power", width:370, tick:.5, callback:valueUpdated});
			_gui.addSlider("sketchParams.expansionRate", 0, 1000, {label:"Expansion Rate", width:370, tick:10, callback:valueUpdated});
			_gui.addSlider("sketchParams.depth", 0, 300, {label:"Depth", width:370, tick:10, callback:valueUpdated});
			_gui.addSlider("sketchParams.epsilon", 0, 50, {label:"Epsilon", width:370, tick:1, callback:valueUpdated});
			_gui.addSlider("sketchParams.friction", 0, 1000, {label:"Friction", width:370, tick:5, callback:valueUpdated});
			_gui.addGroup("Animation Speed");
			_gui.addSlider("_animDuration", 0, 10, {label:"Duration", width:370, tick:.5, callback:valueUpdated});
		
			_gui.addColumn("Explode and reset");
			_gui.addButton("Explode!", {callback:makeExplosion});
			_gui.addButton("Restore Dots", {callback:startSimulation});

			_gui.addColumn("Preset Loading");

			_gui.addButton("Save Preset", {callback:savePreset});
			_gui.addButton("Load Preset", {callback:loadPreset});
			_gui.addButton("Clear List", {callback:clearList});
			_gui.addButton("Animate", {callback:animate});
			_gui.addToggle("explodeAtEnd");


			_gui.show();
			sketchParams.dotRadiusIncrement = 1;
			sketchParams.dotsPerCircle = 22;
			sketchParams.initialCircleRadius = 56;
			sketchParams.rotateSpeed = 1;
			sketchParams.smallestDotRadius = 1;
			sketchParams.spaceBetweenCircles = 21;
			sketchParams.totalCirles = 7;
			sketchParams.dotColor = 0xffffff;
			sketchParams.dotAlpha = .5;
			sketchParams.rotateSpeed = 0.6;
			sketchParams.filterType = {label:"glow", data:"glow"};
			sketchParams.filterSize = 3;
			sketchParams.filterColor = 0xffffff;
			sketchParams.filterStrength = 100;
			sketchParams.filterAlpha = .2;
			sketchParams.explosionPower = .5;
			sketchParams.expansionRate = 10;
			sketchParams.epsilon = 20;
			sketchParams.depth = 10;
			sketchParams.friction = 500;

			// _total = TextFieldUtils.createTextField();
			// _total.x = 750;
			// _total.y = 20;
			// addChild(_total);

			/*_format = TextFieldUtils.createTextFormat("HelveticaNeue", 0xffffff, 30);
			_total.defaultTextFormat = _format;
			_total.border = true;
			_total.autoSize = TextFieldAutoSize.LEFT;
			_total.text = "completed: 0";
			_total.borderColor = 0xffffff;*/

			_gui.update();
			createAnimOrder();
		}

		public function animate() : void {
			_animIndex = 0;
			//set to the first sketchparams			
			sketchParams = presets[0];
			valueUpdated();
			_animIndex = 1;
			_animStartTimer = new Timer(1000, 1);
			_animStartTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startAnim);
			_animStartTimer.start();
			 
			_gui.hide();
			
		}

		private function startAnim(event : TimerEvent) : void {
			_animStartTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, startAnim);
			_animStartTimer = null;
			tweenToValues(presets[_animIndex]);
			
		}
		
		public function tweenCompleted():void{
			trace("ControlUI.tweenCompleted()  ");
			if (_animIndex<presets.length-1){
				_animIndex++;
				tweenToValues(presets[_animIndex]);
			}else{
				if (explodeAtEnd){
					makeExplosion();
					
				}
			}
		}

		private function tweenToValues(newPreset : SketchParams) : void {
			
			sketchParams.filterType = newPreset.filterType;
			sketchParams.showCircles = newPreset.showCircles;
			Tweener.addTween(sketchParams, {  totalCirles:newPreset.totalCirles, time:_animDuration, onUpdate:update});
			Tweener.addTween(sketchParams, {  depth:newPreset.depth , time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  dotAlpha:newPreset.dotAlpha, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  dotColor:newPreset.dotColor, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  dotRadiusIncrement:newPreset.dotRadiusIncrement, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  dotsPerCircle:newPreset.dotsPerCircle, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  epsilon:newPreset.epsilon, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  expansionRate:newPreset.expansionRate, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  explosionPower:newPreset.explosionPower, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  filterAlpha:newPreset.filterAlpha, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  filterColor:newPreset.filterColor, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  filterSize:newPreset.filterSize, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  filterStrength:newPreset.filterStrength, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  friction:newPreset.friction, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  initialCircleRadius:newPreset.initialCircleRadius, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  rotateSpeed:newPreset.rotateSpeed, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  smallestDotRadius:newPreset.smallestDotRadius, time:_animDuration,  onUpdate:update});
			Tweener.addTween(sketchParams, {  spaceBetweenCircles:newPreset.spaceBetweenCircles, time:_animDuration, onUpdate:update, onComplete:tweenCompleted});
			
		}

		private function update() : void {
			valueUpdated();
		}

		private function createAnimOrder() : void {
			_animOrder = TextFieldUtils.createTextField(true, false,300);
			_animOrder.x = 700;
			_animOrder.y = 200;
			_textFormat = TextFieldUtils.createTextFormat("PF Ronda Seven", 0x0, 12);
			_animOrder.defaultTextFormat = _textFormat;
			_animOrder.text = "";
			_gui._container.addChild(_animOrder);
		}

		private function clearList() : void {
			presets = [];
			updateAnimList(presets);
		}

	

		// load all presets from the text file
		// to save a preset- append it to the text file, then re-load the text file and update the preset list
		private function completeHandler(data : String) : void {
			presets = parsePresets(data);
			addPresetsCombo(presets);
		}

		// parse the string back into a SketchParams object
		private function parsePresets(string : String) : Array {
			if (string.length < 1) return null;

			return null;
		}

		private function savePreset() : void {
			// var preset : String = sketchParams.savePreset();
			// trace("preset saved:" + preset);
			// writeToTextFile(preset);

			writeToTextFile();
		}

		public function loadPreset() : void {
			// create a file reference
			fr = new FileReference();

			// add events to FileReference for file select, and ready to open
			fr.addEventListener(Event.SELECT, selectFile);
			fr.addEventListener(Event.COMPLETE, readyToOpen);

			// create a file filter so the browse window only shows our custom file type
			var f : FileFilter = new FileFilter("Always Anim Preset (*.preset)", "*.preset");

			// initiate the browse window
			fr.browse([f]);
		}

		private function selectFile(e : Event) : void {
			// load the selected file
			fr.load();
		}

		// this event is fired when the file has finished loading
		public function readyToOpen(e : Event) : void {
			// pass the file's bytearray to the function below to read the data
			loadFile(fr.data);
		}

		private function loadFile(data : ByteArray) : void {
			registerClassAlias("alwaysAnimationTool.view", SketchParams);
			var eg2 : * = data.readObject();
			var tmpS : SketchParams = eg2 as SketchParams;
			sketchParams = tmpS;
			sketchParams.name = fr.name;
			presets.push(sketchParams)
			updateAnimList(presets);
			valueUpdated();
		}

		private function updateAnimList(ar : Array) : void {
			 _animOrder.text = "PRESET ANIMATION ORDER\n";
			// remove existing labels;
			for (var i : int = 0; i < ar.length; i++) {
				registerClassAlias("alwaysAnimationTool.view", SketchParams);
				var sketch : SketchParams = ar[i] as SketchParams;
				_animOrder.text += (i+1).toString()+": "+sketch.name + "\n";
			}
		}

		private function writeToTextFile() : void {
			registerClassAlias("alwaysAnimationTool.view", SketchParams);
			var ba : ByteArray = new ByteArray();
			ba.writeObject(sketchParams);
			ba.position = 0;

			var eg2 : * = ba.readObject();

			var d : Date = new Date();
			var s : String = d.time.toString();

			// set a file extension - could be what ever you want it to be
			var extension : String = ".preset";

			var fileRef:FileReference=new FileReference();
			fileRef.save(ba, "preset "+s+extension);

/*
			// create the file on the desktop
			var myFile : File = File.desktopDirectory.resolvePath("preset" + s + extension);

			// create a FileStream to write the file
			var fs : FileStream = new FileStream();

			// add a listener so you know when its finished saving
			fs.addEventListener(Event.CLOSE, fileWritten);

			// open the file
			fs.openAsync(myFile, FileMode.WRITE);

			// write the bytearray to it
			fs.writeBytes(ba);

			// close the file
			fs.close();*/
		}

		public function fileWritten(e : Event) : void {
			trace("File Saved to Desktop");
		}

		private function addPresetsCombo(presets : Array) : void {
			var addArr : Array = [];
			for (var i : int = 0; i < presets.length; i++) {
				addArr.push({label:"preset " + i.toString(), data:i});
			}

			if (!_presetCombo) {
				_presetCombo = _gui.addComboBox("presetIndex", [{label:"hi", data:1}]);
				// , [{label:"preset 0", data:0}]);
			}
			_presetCombo["items"] = addArr;
		}

		public function makeExplosion() : void {
			//trace("ControlUI.makeExplosion()  ");

			var e : CustomEvent = new CustomEvent("explode");
			dispatchEvent(e);
		}

		public function valueUpdated() : void {
			var e : CustomEvent = new CustomEvent("valueUpdated");
			dispatchEvent(e);
		}

		public function startSimulation() : void {
	//		trace("ControlUI.startSimulation()  ");
			var e : CustomEvent = new CustomEvent("removeParticles");
			dispatchEvent(e);
			valueUpdated();
		}

		public function reset() : void {
		//	trace("ControlUI.reset()  ");
		}

		public function get presetIndex() : int {
			return _presetIndex;
		}

		public function clone(source : SketchParams) : SketchParams {
			var clone : SketchParams = new SketchParams();
			clone.totalCirles = source.totalCirles             ;
			clone.dotsPerCircle = source.dotsPerCircle           ;
			clone.initialCircleRadius = source.initialCircleRadius     ;
			clone.spaceBetweenCircles = source.spaceBetweenCircles     ;
			clone.smallestDotRadius = source.smallestDotRadius       ;
			clone.dotRadiusIncrement = source.dotRadiusIncrement      ;
			clone.rotateSpeed = source.rotateSpeed             ;
			clone.dotColor = source.dotColor                ;
			clone.showCircles = source.showCircles             ;
			clone.dotAlpha = source.dotAlpha                ;
			clone.filterType = source.filterType              ;
			clone.filterSize = source.filterSize              ;
			clone.filterColor = source.filterColor             ;
			clone.filterStrength = source.filterStrength          ;
			clone.filterAlpha = source.filterAlpha             ;
			clone.explosionPower = source.explosionPower;
			clone.expansionRate = source.expansionRate;
			clone.depth = source.depth;
			clone.epsilon = source.epsilon;

			return clone
		}

		public function set presetIndex(presetIndex : int) : void {
			_presetIndex = presetIndex;

			sketchParams = presets[presetIndex] as SketchParams;
		}
	}
}