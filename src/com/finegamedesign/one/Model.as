package com.finegamedesign.one
{
    import flash.utils.Dictionary;

    public class Model
    {
        [Embed(source="levels.txt", mimeType="application/octet-stream")]
        internal static var levelDiagramsClass:Class
        internal static var levelDiagrams:Array = parse(String(new levelDiagramsClass()));

        internal static function parse(levelDiagramsText:String):Array
        {
            return levelDiagramsText.split("\r").join("").split("\n\n");
        }

        internal var kill:int;
        internal var maxKill:int;
        internal var speed:Number = 2.0;
        internal var columnCount:int;
        internal var detonator:Mob;
        internal var diagram:String;
        internal var grenades:Array;
        internal var rowCount:int;
        internal var shrapnels:Array;
        internal var shrapnelAlive:int;
        internal var table:Array;

        private var detonateColumns:Dictionary;
        private var detonateRows:Dictionary;

        public function Model()
        {
        }

        /**
         * Let text represent simple example of tiles:
         *     .    empty space
         *     D    grenade moving right
         *     A    grenade moving up
         *     U    grenade moving down
         *     C    grenade moving left
         */
        internal function populate(diagram:String):void
        {
            detonateColumns = new Dictionary();
            detonateRows = new Dictionary();
            grenades = [];
            shrapnels = [];
            this.diagram = diagram;
            table = diagram.split("\n\n").join("\n").split("\n");
            if (table[table.length - 1].length <= 0) {
                table.pop();
            }
            for (var row:int = 0; row < table.length; row++) {
                table[row] = table[row].split("");
                for (var column:int = 0; column < table[row].length; column++) {
                    var character:String = table[row][column];
                    var grenade:Mob = null;
                    if ("D" == character) {
                        if (!(row in detonateRows)) {
                            detonateRows[row] = column;
                        }
                        grenade = new Mob(column, row, 0);
                    }
                    else if ("U" == character) {
                        if (!(row in detonateColumns)) {
                            detonateColumns[column] = row;
                        }
                        grenade = new Mob(column, row, 90);
                    }
                    else if ("C" == character) {
                        if (!(row in detonateRows)) {
                            detonateRows[row] = column;
                        }
                        grenade = new Mob(column, row, 180);
                    }
                    else if ("A" == character) {
                        if (!(row in detonateColumns)) {
                            detonateColumns[column] = row;
                        }
                        grenade = new Mob(column, row, -90);
                    }
                    if (null != grenade) {
                        grenades.push(grenade);
                    }
                }
            }
            // trace("Model.populate:\n" + diagram + "\n" + table);
            columnCount = table[0].length;
            rowCount = table.length;
            detonator = new Mob(-1, -1, 0, false);
            kill = 0;
            maxKill = grenades.length;
        }

        internal function update(elapsed:Number):int
        {
            var distance:Number = elapsed * speed;
            for (var m:int = 0; m < grenades.length; m++) {
                var mob:Mob = grenades[m];
                if (mob.alive) {
                    var previousColumn:Number = mob.column;
                    var previousRow:Number = mob.row;
                    mob.column += distance * mob.velocity.x;
                    mob.row += distance * mob.velocity.y;
                    if (!updateContagion(mob, previousColumn, previousRow, detonator)) {
                        reflect(mob);
                        collideShrapnel(mob, previousColumn, previousRow, shrapnels);
                    }
                    // trace("Model.update:" + mob.column + ", " + mob.row);
                }
            }
            shrapnelAlive = moveShrapnel(shrapnels, distance);
            return win();
        }

        /**
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            var winning:int = 0;
            if (maxKill <= kill) {
                if (shrapnelAlive <= 0) {
                    winning = 1;
                }
            }
            else if (!detonator.alive) {
                if (shrapnelAlive <= 0) {
                    winning = -1;
                }
            }
            return winning;
        }

        private function rotate(mob:Mob, elasticity:Number=1.0):void
        {
            if (mob.rotation <= 0) {
                mob.rotation += 180.0 * elasticity;
            }
            else {
                mob.rotation -= 180.0 * elasticity;
            }
        }

        private function reflect(mob:Mob, elasticity:Number=1.0):Boolean
        {
            var reflected:Boolean = false;
            if (mob.column < 0) {
                rotate(mob, elasticity);
                mob.velocity.x *= -elasticity;
                mob.column = 0;
                reflected = true;
            }
            else if (columnCount - 1 < mob.column) {
                rotate(mob, elasticity);
                mob.velocity.x *= -elasticity;
                mob.column = columnCount - 1;
                reflected = true;
            }
            if (mob.row < 0) {
                rotate(mob, elasticity);
                mob.velocity.y *= -elasticity;
                mob.row = 0;
                reflected = true;
            }
            else if (rowCount - 1 < mob.row) {
                rotate(mob, elasticity);
                mob.velocity.y *= -elasticity;
                mob.row = rowCount - 1;
                reflected = true;
            }
            return reflected;
        }

        /**
         * @return count of alive shrapnel.
         */
        private function moveShrapnel(shrapnels:Array, distance:Number):int
        {
            var aliveCount:int = 0;
            for (var m:int = 0; m < shrapnels.length; m++) {
                var mob:Mob = shrapnels[m];
                mob.column += distance * mob.velocity.x;
                mob.row += distance * mob.velocity.y;
                if (reflect(mob, 0)) {
                    mob.alive = false;
                }
                aliveCount += mob.alive ? 1 : 0;
            }
            return aliveCount;
        }

        /**
         * @return collided
         */
        private function collideShrapnel(grenade:Mob, previousColumn:Number, previousRow:Number, shrapnels:Array):Boolean
        {
            if (grenade.alive) {
                for (var m:int = 0; m < shrapnels.length; m++) {
                    var shrapnel:Mob = Mob(shrapnels[m]);
                    var collided:Boolean = updateContagion(grenade, 
                            previousColumn, previousRow, shrapnel);
                    if (collided) {
                        /***#/
                        trace("Model.collideShrapnel: " + grenade.column.toFixed(2) + ", " + grenade.row.toFixed(2) 
                            + " shrapnel " + shrapnel.column.toFixed(2) + ", " + shrapnel.row.toFixed(2));
                        //*/
                        return true;
                    }
                }
            }
            return false;
        }

        /**
         * @return collided
         */
        private function updateContagion(mob:Mob, previousColumn:Number, previousRow:Number, detonator:Mob):Boolean
        {
            if (collide(mob, previousColumn, previousRow, detonator)) {
                kill++;
                detonator.alive = false;
                mob.alive = false;
                // mob.column = detonator.column;
                // mob.row = detonator.row;
                mob.velocity.x = 0.0;
                mob.velocity.y = 0.0;
                detonator.velocity.x = 0.0;
                detonator.velocity.y = 0.0;
                for (var rotation:Number = 90.0; -180.0 <= rotation; rotation -= 90.0) {
                    var shrapnel:Mob = new Mob(detonator.column, detonator.row, rotation);
                    shrapnels.push(shrapnel);
                }
                return true;
            }
            return false;
        }

        private function collide(mob:Mob, previousColumn:Number, previousRow:Number, detonator:Mob):Boolean
        {
            if (!detonator.solid || !detonator.alive || !mob.solid || !mob.alive) {
                return false;
            }
            var margin:Number = 0.375;
            var max:Number = Number.NEGATIVE_INFINITY;
            var maxSide:Number = Number.NEGATIVE_INFINITY;
            var min:Number;
            var minSide:Number;
            var position:Number = Number.POSITIVE_INFINITY;
            var positionSide:Number = Number.POSITIVE_INFINITY;
            if (margin < Math.abs(mob.velocity.x)) {
                if (previousColumn < mob.column) {
                    min = previousColumn - margin;
                    max = mob.column;
                }
                else {
                    min = mob.column;
                    max = previousColumn + margin;
                }
                position = detonator.column;
                positionSide = detonator.row;
                minSide = mob.row - margin;
                maxSide = mob.row + margin;
            }
            else if (margin < Math.abs(mob.velocity.y)) {
                if (previousRow < mob.row) {
                    min = previousRow - margin;
                    max = mob.row;
                }
                else {
                    min = mob.row;
                    max = previousRow + margin;
                }
                position = detonator.row;
                positionSide = detonator.column;
                minSide = mob.column - margin;
                maxSide = mob.column + margin;
            }
            var collision:Boolean = min < position && position < max
                    && minSide < positionSide && positionSide < maxSide;
            if (collision) {
                /***#/
                trace("Model.collide: " + min.toFixed(2) + " < " + position.toFixed(2) + " < " + max.toFixed(2) 
                    + " and " + minSide.toFixed(2) + " < " + positionSide.toFixed(2) + " < " + maxSide.toFixed(2)
                    + " mob " + mob.column.toFixed(2) + ", " + mob.row.toFixed(2) 
                    + " detonator " + detonator.column.toFixed(2) + ", " + detonator.row.toFixed(2) 
                        );
                //*/
            }
            return collision;
        }

        internal function willDetonate():Boolean
        {
            var column:int = Math.round(detonator.column);
            var row:int = Math.round(detonator.row);
            if ((column in detonateColumns)
                || (row in detonateRows)) {
                    return true;
            }
            return false;
        }

        internal function detonate():Boolean
        {
            var detonating:Boolean = willDetonate();
            if (detonating) {
                detonator.solid = true;
                detonator.alive = true;
            }
            return detonating;
        }
    }
}
