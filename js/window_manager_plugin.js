var _window = window.parent;
var _document = window.parent.document;

function windowManagerPluginSetup(id) {
  var el = _document.getElementById(id);

  var pos1 = 0;
  var pos2 = 0;
  var pos3 = 0;
  var pos4 = 0;
  if (_document.getElementById(id + "_header")) {
    // if present, the header is where you move the DIV from:
    _document.getElementById(id + "_header").onmousedown = dragMouseDown;
  } else {
    // otherwise, move the DIV from anywhere inside the DIV:
    el.onmousedown = dragMouseDown;
  }

  function dragMouseDown(e) {
    e = e || _window.event;
    e.preventDefault();
    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    _document.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    _document.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || _window.event;
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
    _document.onmouseup = null;
    _document.onmousemove = null;
  }
}

function windowManagerPluginGetFrame(id) {
  var el = _document.getElementById(id);

  var elRect = el.getBoundingClientRect();

  return {
    origin: { x: elRect.top, y: elRect.left },
    size: { width: el.offsetWidth, height: el.offsetHeight },
  };
}

function windowManagerPluginSetFrame(id, frame) {
  var el = _document.getElementById(id);

  if (frame.size != null) {
    el.style.width = `${frame.size.width}px`;
    el.style.height = `${frame.size.height}px`;
  }
  if (frame.origin != null) {
    el.style.top = `${frame.origin.x}px`;
    el.style.left = `${frame.origin.y}px`;
  }
}
