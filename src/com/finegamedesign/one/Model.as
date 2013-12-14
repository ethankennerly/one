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

        internal var columnCount:int;
        internal var detonator:Mob;
        internal var diagram:String;
        internal var grenades:Array;
        internal var rowCount:int;
        internal var shrapnels:Array;
        internal var table:Array;

        public function Model()
        {
            grenades = [];
            shrapnels = [];
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
                    }
                }
            }
            trace("Model.populate:\n" + diagram + "\n" + table);
            columnCount = table[0].length;
            rowCount = table.length;
        }
    }
}

