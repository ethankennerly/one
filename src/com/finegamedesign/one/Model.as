package com.finegamedesign.one
{
    public class Model
    {
        [Embed(source="levels.txt", mimeType="application/octet-stream")]
        internal static var levelDiagramsClass:Class
        internal static var levelDiagrams:Array = parse(String(new levelDiagramsClass()));

        internal static function parse(levelDiagramsText:String):Array
        {
            return levelDiagramsText.split("\r").join("").split("\n\n");
        }

        internal var speed:Number = 1.0;
        internal var columnCount:int;
        internal var detonator:Mob;
        internal var diagram:String;
        internal var grenades:Array;
        internal var mobs:Array;
        internal var rowCount:int;
        internal var shrapnels:Array;
        internal var table:Array;

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
            grenades = [];
            shrapnels = [];
            mobs = [];
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
                        grenade = new Mob(column, row, 0);
                    }
                    else if ("U" == character) {
                        grenade = new Mob(column, row, 90);
                    }
                    else if ("C" == character) {
                        grenade = new Mob(column, row, 180);
                    }
                    else if ("A" == character) {
                        grenade = new Mob(column, row, -90);
                    }
                    if (null != grenade) {
                        grenades.push(grenade);
                        mobs.push(grenade);
                    }
                }
            }
            trace("Model.populate:\n" + diagram + "\n" + table);
            columnCount = table[0].length;
            rowCount = table.length;
            detonator = new Mob(-1, -1, 0, false);
        }

        internal function update(elapsed:Number):void
        {
            var distance:Number = elapsed * speed;
            for (var m:int = 0; m < mobs.length; m++) {
                var mob:Mob = mobs[m];
                var previousColumn:Number = mob.column;
                var previousRow:Number = mob.row;
                mob.column += distance * mob.velocity.x;
                mob.row += distance * mob.velocity.y;
                updateDetonator(mob, previousColumn, previousRow);
                if (mob.column < 0) {
                    mob.rotation -= 180;
                    mob.velocity.x *= -1;
                    mob.column *= -1;
                }
                else if (columnCount - 1 < mob.column) {
                    mob.rotation -= 180;
                    mob.velocity.x *= -1;
                    mob.column = columnCount - 1;
                }
                if (mob.row < 0) {
                    mob.rotation -= 180;
                    mob.velocity.y *= -1;
                    mob.row *= -1;
                }
                else if (rowCount - 1 < mob.row) {
                    mob.rotation -= 180;
                    mob.velocity.y *= -1;
                    mob.row = rowCount - 1;
                }
            }
        }

        private function updateDetonator(mob:Mob, previousColumn:Number, previousRow:Number):void
        {
            if (!detonator.solid) {
                return;
            }
            var min:Number;
            var max:Number;
            var position:Number;
            if (mob.velocity.x != 0) {
                if (previousColumn < mob.column) {
                    min = previousColumn;
                    max = mob.column;
                }
                else {
                    min = mob.column;
                    max = previousColumn;
                }
                position = detonator.column;
            }
            else if (mob.velocity.y != 0) {
                if (previousRow < mob.row) {
                    min = previousRow;
                    max = mob.row;
                }
                else {
                    min = mob.row;
                    max = previousRow;
                }
                position = detonator.row;
            }
            if (min < position && position < max) {
                detonator.alive = false;
            }
        }
    }
}

