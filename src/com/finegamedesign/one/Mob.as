package com.finegamedesign.one
{
    import flash.geom.Point;

    public class Mob
    {
        internal var column:Number;
        internal var row:Number;
        internal var rotation:Number;
        internal var alive:Boolean;
        internal var solid:Boolean;
        internal var velocity:Point;

        public function Mob(column:int, row:int, rotation:Number, solid:Boolean=true)
        {
            this.column = column;
            this.row = row;
            this.rotation = Math.round(rotation);
            this.solid = solid;
            this.alive = true;
            velocity = new Point();
            velocity.x = Math.round(Math.cos(rotation * Math.PI / 180.0));
            velocity.y = Math.round(Math.sin(rotation * Math.PI / 180.0));
            trace("Mob: " + arguments + " " + velocity);
        }
    }
}

