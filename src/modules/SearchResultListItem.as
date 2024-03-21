package modules
{
  import net.blaxstar.starlib.components.ListItem;
  import flash.events.Event;
  import flash.display.Sprite;
  import flash.display.Graphics;

  public class SearchResultListItem extends ListItem {
    private var _background:Sprite;

    public function SearchResultListItem(label:String="New Item\nsearch@result.com\nNot an Officer") {
      data = {};
      _is_rounded = true;
      super(null,0,0,label);
    }
        override public function add_children():void {
          super.add_children();
        }
        override public function draw(e:Event = null):void {
            _width_ = label_component.width = 250;
            _height_ = label_component.height;
            if (!label_component.multiline) {
              label_component.multiline = true;
            }
            super.draw();
        }
  }
}
