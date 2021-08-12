var _parentWindow = window.parent;
var _parentDocument = window.parent.document;

function windowManagerPluginInit() {
  var el = _parentDocument.getElementById(window.flutterApp.windowId);

  var pos1 = 0;
  var pos2 = 0;
  var pos3 = 0;
  var pos4 = 0;
  if (_parentDocument.getElementById(window.flutterApp.windowHeaderId)) {
    // if present, the header is where you move the DIV from:
    _parentDocument.getElementById(
      window.flutterApp.windowHeaderId
    ).onmousedown = dragMouseDown;
  } else {
    // otherwise, move the DIV from anywhere inside the DIV:
    el.onmousedown = dragMouseDown;
  }

  function dragMouseDown(e) {
    e = e || _parentWindow.event;
    e.preventDefault();
    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    _parentDocument.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    _parentDocument.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || _parentWindow.event;
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position:
    el.style.top = el.offsetTop - pos2 + "px";
    el.style.left = el.offsetLeft - pos1 + "px";
  }

  function closeDragElement() {
    // stop moving when mouse button is released:
    _parentDocument.onmouseup = null;
    _parentDocument.onmousemove = null;
  }
}

function windowManagerPluginGetFrame() {
  var el = _parentDocument.getElementById(window.flutterApp.windowId);

  var elRect = el.getBoundingClientRect();

  return {
    origin: { x: elRect.top, y: elRect.left },
    size: { width: el.offsetWidth, height: el.offsetHeight },
  };
}

function windowManagerPluginSetFrame(frame) {
  var el = _parentDocument.getElementById(window.flutterApp.windowId);

  if (frame.size != null) {
    el.style.width = `${frame.size.width}px`;
    el.style.height = `${frame.size.height}px`;
  }
  if (frame.origin != null) {
    el.style.top = `${frame.origin.x}px`;
    el.style.left = `${frame.origin.y}px`;
  }
}
