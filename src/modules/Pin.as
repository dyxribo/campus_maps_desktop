package modules {
  import net.blaxstar.starlib.components.LED;
  import structs.MappableItem;
  import flash.display.DisplayObjectContainer;

  public class Pin extends LED {
    private var _linked_item:MappableItem;

    public function Pin(parent:DisplayObjectContainer=null, linked_item:MappableItem=null) {
      if (linked_item) {
        _linked_item = linked_item;
      }
      super(parent);
    }

    public function get linked_item():MappableItem {
      return _linked_item;
    }

    public function set linked_item(value:MappableItem):void {
      _linked_item = value;
    }
  }
}
