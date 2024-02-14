package views.forms {
  import net.blaxstar.starlib.components.VerticalBox;
  import net.blaxstar.starlib.components.InputTextField;
  import net.blaxstar.starlib.components.Dropdown;
  import net.blaxstar.starlib.components.PlainText;
  import net.blaxstar.starlib.components.Stepper;

  public class BaseNewItemForm extends VerticalBox {
    private var _item_name_field:InputTextField;
    private var _item_type_dropdown:Dropdown;
    private var _item_location_field:PlainText;

    public function BaseNewItemForm() {
      _item_name_field = new InputTextField(this,0,0,"ITEM NAME");
      _item_type_dropdown = new Dropdown(this,0,0,"SELECT A TYPE");
      _item_location_field = new PlainText(this,0,0,"ITEM LOCATION")
    }

    public function set name_field(name:String):void {
      _item_name_field.text = name;
    }

    public function get type():String {
      return _item_type_dropdown.value;
    }

    public function get location_field():String {
      return _item_location_field.text;
    }
  }
}
