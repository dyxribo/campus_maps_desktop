package models {
    import structs.location.Building;
    import structs.Map;
    import net.blaxstar.starlib.io.XLoader;
    import flash.display.Bitmap;
    import flash.utils.Dictionary;
    import geom.Point;

    public class MapModel {
        private var _current_location:Building;
        private var _buildings:Map;
        private var _image_loader:XLoader;
        private var _current_map_image:Bitmap;
        private var _bitmap_data_cache:Dictionary;
        private var _image_size:Point;
        private var _pan_position:Point;

        public function MapModel() {

        }
    }
}
