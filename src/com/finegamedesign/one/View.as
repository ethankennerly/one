package com.finegamedesign.one
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;

    public class View
    {
        internal var detonator:MovieClip;
        internal var mobs:DisplayObjectContainer;
        internal var room:DisplayObjectContainer;
        internal var originalRoomHeight:int = -1;
        internal var originalRoomWidth:int = -1;
        internal var originalTileWidth:int = 80;
        internal var scale:Number;
        internal var tileWidth:int;
        internal var grenades:Array;
        internal var shrapnels:Array;

        public function View()
        {
            grenades = [];
            shrapnels = [];
        }

        /**
         * Position and scale to fit.
         */
        internal function populate(model:Model, mobs:DisplayObjectContainer, room:DisplayObjectContainer, detonator:MovieClip):void
        {
            this.room = room;
            this.mobs = mobs;
            if (originalRoomWidth <= 0) {
                originalRoomHeight = room.height;
                originalRoomWidth = room.width;
            }
            var heightPerTile:int = originalRoomHeight / model.rowCount;
            var widthPerTile:int = originalRoomWidth / model.columnCount;
            if (heightPerTile < widthPerTile) {
                tileWidth = heightPerTile;
            }
            else {
                tileWidth = widthPerTile;
            }
            scale = tileWidth / originalTileWidth;
            room.width = model.columnCount * tileWidth;
            room.height = model.rowCount * tileWidth;
            for (var c:int = mobs.numChildren - 1; 0 <= c; c--) {
                 mobs.removeChild(mobs.getChildAt(c));
            }
            grenades = [];
            shrapnels = [];
            for each(var mob:Mob in model.grenades){
                var grenade:GrenadeClip = new GrenadeClip();
                grenade.scaleX = scale;
                grenade.scaleY = scale;
                position(grenade, mob, model);
                mobs.addChild(grenade);
                // trace("View.populate grenade x " + grenade.x + " y " + grenade.y);
                grenades.push(grenade);
            }
            detonator.scaleX = scale;
            detonator.scaleY = scale;
            this.detonator = detonator;
        }

        internal function position(mc:MovieClip, mob:Mob, model:Model):void
        {
            mc.x = tileWidth * (0.5 + mob.column - model.columnCount * 0.5);
            mc.y = tileWidth * (0.5 + mob.row - model.rowCount * 0.5);
            mc.rotation = mob.rotation;
            var label:String = mob.solid ? 
                (mob.alive ? "alive" : "dead") : "preview";
            if (label != mc.currentLabel) {
                mc.gotoAndPlay(label);
            } 
            // trace("View.position: " + mc + ": " + mc.x.toFixed(1) + ", " + mc.y.toFixed(1) + " label " + label);
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
            }
            position(detonator, model.detonator, model);
            if (!model.willDetonate()) {
                if ("dead" != detonator.currentLabel) {
                    detonator.gotoAndPlay("dead");
                }
            }
            detonator.x += room.x;
            detonator.y += room.y;
            detonator.visible = 
                (0 <= model.detonator.column) 
                && (0 <= model.detonator.row)
                && (model.detonator.column < model.columnCount) 
                && (model.detonator.row < model.rowCount);
        }

        internal function update(model:Model):void
        {
            for (var g:int = 0; g < model.grenades.length; g++){
                position(grenades[g], model.grenades[g], model);
            }
            for (var s:int = 0; s < model.shrapnels.length; s++){
                if (shrapnels.length <= s) {
                    var shrapnel:ShrapnelClip = new ShrapnelClip();
                    shrapnel.scaleX = scale;
                    shrapnel.scaleY = scale;
                    shrapnels.push(shrapnel);
                    mobs.addChild(shrapnel);
                }
                position(shrapnels[s], model.shrapnels[s], model);
            }
            updateDetonator(model);
        }
    }
}

