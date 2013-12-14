package com.finegamedesign.one
{
    import flash.display.DisplayObjectContainer;

    public class View
    {
        var tileWidth:int = 80;

        public function View()
        {
        }

        /**
         * Position and scale to fit.
         */
        internal function populate(model:Model, mobs:DisplayObjectContainer, room:DisplayObjectContainer):void
        {
            for (var c:int = mobs.numChildren - 1; 0 <= c; c--) {
                 mobs.removeChild(mobs.getChildAt(c));
            }
            for each(var mob:Mob in model.grenades){
                var grenade:GrenadeClip = new GrenadeClip();
                grenade.x = tileWidth * (mob.column - model.columnCount * 0.5);
                grenade.y = tileWidth * (mob.row - model.rowCount * 0.5);
                grenade.rotation = mob.rotation;
                mobs.addChild(grenade);
                trace("View.populate grenade x " + grenade.x + " y " + grenade.y);
            }
        }
    }
}

