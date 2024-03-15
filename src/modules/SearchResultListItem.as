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
      super(null,0,0,label);
    }
        override public function add_children():void {
          super.add_children();
          label_component.multiline = true;

        }
        override public function draw(e:Event = null):void {
            _width_ = label_component.width = 250;
            _height_ = label_component.height;
            super.draw();
            dispatchEvent(new Event(Event.RESIZE));
        }
  }
}
