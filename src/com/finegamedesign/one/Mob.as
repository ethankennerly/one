package com.finegamedesign.one
{
    import flash.geom.Point;

    public class Mob
    {
        internal var column:int;
        internal var row:int;
        internal var x:Number;
        internal var y:Number;
        internal var rotation:Number;
        internal var velocity:Point;

        public function Mob(column:int, row:int, rotation:Number)
        {
            this.column = column;
            this.row = row;
            this.rotation = Math.round(rotation);
            velocity = new Point();
            velocity.x = Math.round(Math.cos(rotation));
            velocity.y = Math.round(Math.sin(rotation));
            trace("Mob: " + arguments);
        }
    }
}

