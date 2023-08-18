package net.blaxstar.components {
  
  import flash.display.DisplayObjectContainer;
  
  public class SuggestionList extends List {
    private var _suggestionGenerator:Suggestitron;
    private var _suggestions:Vector.<Suggestion>;
    
    public function SuggestionList(parent: DisplayObjectContainer = null, xpos: Number = 0, ypos: Number = 0) {
      _suggestionGenerator = new Suggestitron();
      super(parent, xpos, ypos, false);
    }
    
    public function displaySuggestions(inputText:String):void {
      if (_suggestions.length > 0) {
      
      } else {
        _suggestions = _suggestionGenerator.generateSuggestions(inputText, 5);
        
      }
      
      
      if (_lastInput == _textField.text) {
        if (!_suggestionList.parent) addChild(_suggestionList);
      } else {
        _suggestionList.clear();
        _suggestionCache = _suggenerator.generateSuggestions(_textField.text, _suggestionLimit);
    
        if (!_suggestionCache.length) {
          if (_suggestionList.parent) removeChild(_suggestionList);
          return;
        } else {
          for (var i:uint = 0; i < _suggestionCache.length; i++) {
            var currentSuggestion:Suggestion = _suggestionCache[i];
            var item:ListItem                = _suggestionList.getCachedItemByID(currentSuggestion.linkageid);
            if (item) {
              _suggestionList.addItem(item);
            } else {
              item = new ListItem(_suggestionList, 0, 0, currentSuggestion);
              item.linkageid = currentSuggestion.linkageid;
              item.label = currentSuggestion.label;
              item.onClick.add(onSuggestionSelect);
            }
          }
        }
      }
      _suggestionList.y = _textFieldUnderline.y + 1;
      _suggestionList.width = _width_;
    }
  }
}
