package modules {
  import flash.display.Sprite;
  import net.blaxstar.components.List;

  public class ContextMenu extends Sprite {
    private var _list:List;

    public function ContextMenu() {
      _list = new List(this);
    }
  }
}
