package com.finegamedesign.one
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;

    public class View
    {
        internal var room:DisplayObjectContainer;
        internal var detonator:MovieClip;
        internal var tileWidth:int = 80;
        internal var grenades:Array;


        public function View()
        {
            grenades = [];
        }

        /**
         * Position and scale to fit.
         */
        internal function populate(model:Model, mobs:DisplayObjectContainer, room:DisplayObjectContainer, detonator:MovieClip):void
        {
            this.room = room;
            room.width = model.columnCount * tileWidth;
            room.height = model.rowCount * tileWidth;
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
            this.detonator = detonator;
            this.detonator.visible = false;
        }

        internal function position(obj:DisplayObject, mob:Mob, model:Model):void
        {
            obj.x = tileWidth * (0.5 + mob.column - model.columnCount * 0.5);
            obj.y = tileWidth * (0.5 + mob.row - model.rowCount * 0.5);
            obj.rotation = mob.rotation;
        }

        internal function columnAt(roomX:Number, columnCount):int
        {
            return roomX / tileWidth + columnCount * 0.5;
        }

        internal function rowAt(roomY:Number, rowCount:int):int
        {
            return roomY / tileWidth + rowCount * 0.5;
        }

        private function updateDetonator(model:Model):void
        {
            if (!model.detonator.solid) {
                model.detonator.column = columnAt(
                    room.scaleX * room.mouseX, 
                    model.columnCount);
                model.detonator.row = rowAt(
                    room.scaleY * room.mouseY, 
                    model.rowCount);
                position(detonator, model.detonator, model);
                detonator.x += room.x;
                detonator.y += room.y;
            }
            var label:String = model.detonator.solid ? 
                (model.detonator.alive ? "active" : "consumed") : 
                
                "preview";
            if (label != detonator.currentLabel) {
                detonator.gotoAndPlay(label);
            }
            detonator.visible = 
                (0 <= model.detonator.column) 
                && (0 <= model.detonator.row)
                && (model.detonator.column < model.columnCount) 
                && (model.detonator.row < model.rowCount);
        }

        internal function update(model:Model):void
        {
            for (var g:int = 0; g < model.grenades.length; g++){
                var grenade:GrenadeClip = new GrenadeClip();
                position(grenades[g], model.grenades[g], model);
            }
            updateDetonator(model);
        }
    }
}

