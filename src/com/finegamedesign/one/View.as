package com.finegamedesign.one
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    public class View
    {
        internal var room:DisplayObjectContainer;
        internal var tileWidth:int = 80;
        internal var grenades:Array;


        public function View()
        {
            grenades = [];
        }

        /**
         * Position and scale to fit.
         */
        internal function populate(model:Model, mobs:DisplayObjectContainer, room:DisplayObjectContainer):void
        {
            for (var c:int = mobs.numChildren - 1; 0 <= c; c--) {
                 mobs.removeChild(mobs.getChildAt(c));
            }
            grenades = [];
            for each(var mob:Mob in model.grenades){
                var grenade:GrenadeClip = new GrenadeClip();
                position(grenade, mob, model);
                mobs.addChild(grenade);
                // trace("View.populate grenade x " + grenade.x + " y " + grenade.y);
                grenades.push(grenade);
            }
        }

        internal function position(obj:DisplayObject, mob:Mob, model:Model):void
        {
            obj.x = tileWidth * (mob.column - model.columnCount * 0.5);
            obj.y = tileWidth * (mob.row - model.rowCount * 0.5);
            obj.rotation = mob.rotation;
            /*
            obj.scaleX = 0 <= mob.velocity.x ? 1.0 : -1.0;
            obj.scaleX = 0 <= mob.velocity.y ? 1.0 : -1.0;
             */
        }

        internal function update(model:Model):void
        {
            for (var g:int = 0; g < model.grenades.length; g++){
                var grenade:GrenadeClip = new GrenadeClip();
                position(grenades[g], model.grenades[g], model);
            }
        }
    }
}

