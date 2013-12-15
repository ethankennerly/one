package com.finegamedesign.one
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.getTimer;

    import org.flixel.plugin.photonstorm.API.FlxKongregate;

    public dynamic class Main extends MovieClip
    {
        public var detonator:MovieClip;
        public var feedback:MovieClip;
        public var highScore_txt:TextField;
        public var level_txt:TextField;
        public var kill_txt:TextField;
        public var maxLevel_txt:TextField;
        public var maxKill_txt:TextField;
        public var mobs:MovieClip;
        public var room:MovieClip;
        public var score_txt:TextField;

        private var elapsed:Number;
        private var highScore:int;
        private var inTrial:Boolean;
        private var isMouseDown:Boolean;
        private var mouseJustPressed:Boolean;
        private var level:int;
        private var maxLevel:int;
        private var model:Model;
        private var previousTime:int;
        private var score:int;
        private var view:View;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }

        public function init(event:Event=null):void
        {
            inTrial = false;
            score = 0;
            highScore = 0;
            level = 1;
            maxLevel = Model.levelDiagrams.length;
            previousTime = getTimer();
            elapsed = 0;
            mouseJustPressed = false;
            isMouseDown = false;
            model = new Model();
            view = new View();
            trial(level);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
        }

        private function mouseDown(event:MouseEvent):void
        {
            mouseJustPressed = Boolean(!isMouseDown);
            isMouseDown = true;
            if (mouseJustPressed) {
                model.detonator.solid = true;
                model.detonator.alive = true;
            }
        }

        private function mouseUp(event:MouseEvent):void
        {
            mouseJustPressed = false;
            isMouseDown = false;
        }

        public function trial(level:int):void
        {
            inTrial = true;
            mouseChildren = true;
            model.kill = 0;
            model.maxKill = 0;
            model.populate(Model.levelDiagrams[level - 1]);
            view.populate(model, mobs, room, detonator);
        }

        private function updateHudText():void
        {
            // trace("updateHudText: ", score, highScore);
            score_txt.text = score.toString();
            highScore_txt.text = highScore.toString();
            level_txt.text = level.toString();
            maxLevel_txt.text = maxLevel.toString();
            kill_txt.text = model.kill.toString();
            maxKill_txt.text = model.maxKill.toString();
        }

        private function update(event:Event):void
        {
            var now:int = getTimer();
            elapsed = (now - previousTime) * 0.001;
            previousTime = now;
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
            if (inTrial) {
                var win:int = model.update(elapsed);
                view.update(model);
                result(win);
            }
            else {
                if ("next" == feedback.currentLabel) {
                    next();
                }
            }
            updateHudText();
        }

        private function result(win:int):void
        {
            if (!inTrial) {
                return;
            }
            if (win <= -1) {
                wrong();
            }
            else if (1 <= win) {
                correct();
            }
        }

        private function correct():void
        {
            inTrial = false;
            scoreUp();
            level++;
            if (Model.levelDiagrams.length < level) {
                level = 0;
                feedback.gotoAndPlay("complete");
            }
            else {
                feedback.gotoAndPlay("correct");
            }
            FlxKongregate.api.stats.submit("Score", score);
        }

        private function wrong():void
        {
            inTrial = false;
            FlxKongregate.api.stats.submit("Score", score);
            mouseChildren = false;
            feedback.gotoAndPlay("wrong");
            level = 0;
        }

        public function next():void
        {
            feedback.gotoAndPlay("none");
            mouseChildren = true;
            if (currentFrame < totalFrames) {
                nextFrame();
            }
            if (level <= 0) {
                restart();
            }
            else {
                trial(level);
            }
        }

        private function scoreUp():void
        {
            score += model.kill;
            if (highScore < score) {
                highScore = score;
            }
        }

        public function restart():void
        {
            score = 0;
            level = 1;
            trial(level);
            mouseChildren = true;
            gotoAndPlay(1);
        }
    }
}
