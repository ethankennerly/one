package com.finegamedesign.one
{
    import flash.display.MovieClip;
    import flash.events.Event;
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

        private var kill:int;
        private var maxKill:int;
        private var highScore:int;
        private var level:int;
        private var maxLevel:int;
        private var inTrial:Boolean;
        private var score:int;

        public function Main()
        {
            inTrial = false;
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            score = 0;
            highScore = 0;
            level = 1;
            maxLevel = 1;
        }

        public function trial():void
        {
            stop();
            inTrial = true;
            mouseChildren = true;
            kill = 0;
            maxKill = 0;
        }

        public function restart():void
        {
            score = 0;
            gotoAndPlay(1);
            mouseChildren = true;
        }

        public function next():void
        {
            if (currentFrame < totalFrames) {
                play();
            }
            else {
                FlxKongregate.api.stats.submit("Score", score);
                restart();
            }
            mouseChildren = true;
        }

        private function scoreUp():void
        {
            score += kill;
            if (highScore < score) {
                highScore = score;
            }
        }

        private function updateHudText():void
        {
            // trace("updateHudText: ", score, highScore);
            score_txt.text = score.toString();
            highScore_txt.text = highScore.toString();
            level_txt.text = level.toString();
            maxLevel_txt.text = maxLevel.toString();
            kill_txt.text = kill.toString();
            maxKill_txt.text = maxKill.toString();
        }

        private function update(event:Event):void
        {
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
            if (inTrial) {
                // TODO: Update model.
            }
            else {
            }
            updateHudText();
        }

        private function answer(event:Event):void
        {
            var correct:Boolean = false;
            if (correct) {
                if (inTrial) {
                    scoreUp();
                }
                inTrial = false;
                mouseChildren = false;
                feedback.gotoAndPlay("correct");
            }
            else {
                wrong();
            }
        }

        private function wrong():void
        {
            FlxKongregate.api.stats.submit("Score", score);
            inTrial = false;
            mouseChildren = false;
            feedback.gotoAndPlay("wrong");
            level = Math.max(0, level - 1);
        }
    }
}
