QfavEditor = {};

QfavEditor.E = function() {
    this.__defineGetter__("rootElement", this.getRootElement);
    this.__defineGetter__("changeDisabled", this.getDisableChanged);
}

QfavEditor.E.prototype._ignoredChangeCount = 0;

QfavEditor.E.prototype._noRestoringSelectionOnNextFocus = false;

QfavEditor.E.prototype.getRootElement = function getRootElement() {
    var qfavEditor = document.getElementById("QfavEditor");
    return qfavEditor ? qfavEditor : document.body;
};

QfavEditor.E.prototype.getDisableChanged = function(){
    return this._ignoredChangeCount > 0;
}

QfavEditor.E.prototype._bindEvents = function() {
    this.rootElement.addEventListener('DOMSubtreeModified', this._onDomSubtreeModified, false);
    this.rootElement.addEventListener('focus', this._onFocus, true);
    this.rootElement.addEventListener('focusout', this._onFocusOut, true);
    this.rootElement.addEventListener('touchend', this._onTapEnd, true);
    document.addEventListener("paste", this._onPaste, false);
}

QfavEditor.E.prototype._onDomSubtreeModified = function(e){
    var self = QfavEditor._editor;

    QfavUtil.log('_onDomSubtreeModified _ignoredChangeCount:' + self._ignoredChangeCount);
    
    if (!self.changeDisabled) {
        QfavUtil.notify('domSubtreeModifiedFromJs');
        self.tellSelectionRect(false);
    }
}

QfavEditor.E.prototype._onPaste = function(e) {
    setTimeout(function(){
        QfavUtil.notify('pasteFromJs');
    }, 0);
}

QfavEditor.E.prototype._onFocus = function(e) {
    QfavUtil.log('_onFocus');
    var self = QfavEditor._editor;
    if (!self._noRestoringSelectionOnNextFocus) {
        QfavEditor._editor.restoreSelection();
    } else {
        self._noRestoringSelectionOnNextFocus = false;
    }
}

QfavEditor.E.prototype._onFocusOut = function(e) {
    QfavUtil.log('_onFocusOut');
    QfavEditor._editor.storeCurrentSelection();
}

QfavEditor.E.prototype._onTapEnd = function(e) {
    QfavUtil.log('_onTapEnd');
    QfavEditor._editor.storeCurrentSelection();
}

QfavEditor.E.prototype.ignoreChange = function(igore) {
    if(igore) {
        this._ignoredChangeCount++;
    } else {
        this._ignoredChangeCount--;
    }
}

QfavEditor.E.prototype.getClientSize = function() {
    var eb = document.body;
    var ed = document.documentElement;
    QfavUtil.log('bsw=%d, bow=%d, dcw=%d, dsw=%d, dow=%d', eb.scrollWidth, eb.offsetWidth, ed.clientWidth, ed.scrollWidth, ed.offsetWidth);
    QfavUtil.log('bsh=%d, boh=%d, dch=%d, dsh=%d, doh=%d', eb.scrollHeight, eb.offsetHeight, ed.clientHeight, ed.scrollHeight, ed.offsetHeight);
    QfavUtil.log('root-sw=%d, root-sh=%d', this.rootElement.scrollWidth, this.rootElement.scrollHeight);
    //var w = Math.max(eb.scrollWidth, eb.offsetWidth, ed.clientWidth, ed.scrollWidth, ed.offsetWidth);
    //var h = Math.max(eb.scrollHeight, eb.offsetHeight, ed.clientHeight, ed.scrollHeight, ed.offsetHeight);
    return {w : this.rootElement.scrollWidth, h : this.rootElement.scrollHeight};
}

QfavEditor.E.prototype.storeCurrentSelection = function storeCurrentSelection() {
    QfavUtil.log('before storeCurrentSelection');
    var sel = window.getSelection();
    if (sel.rangeCount > 0) {
        this._currentRange = sel.getRangeAt(0);
    } else {
        QfavUtil.log('sel.rangeCount == 0');
    }
    QfavUtil.log('after storeCurrentSelection');
};

QfavEditor.E.prototype.restoreSelection = function restoreSelection(invalidateEnd) {
    QfavUtil.log('before restoreSelection');
    var sel = window.getSelection();
    if (this._currentRange) {
        sel.removeAllRanges();
        sel.addRange(this._currentRange);
    }
    QfavUtil.log('after restoreSelection');
};

QfavEditor.E.prototype.getSelectionRect = function (absolute) {
    void(0);
    var sel = window.getSelection();
    var rect = null;
    var r = null;

    try {
    	var baseNode = sel.baseNode;
    	var baseOffset = sel.baseOffset;

        this.ignoreChange(true);

        if (sel.baseNode) {
            void(0);
            baseOffset = sel.baseOffset;
            var charRange = null;
            var txt = baseNode.textContent;
            var txtLen = txt.length;

            if (baseNode.nodeType == Node.TEXT_NODE) {
                void(0);
                if (baseOffset > 0) {
                    QfavUtil.log('TEXT_NODE baseOffset > 0');
                    void(0);
                    charRange = document.createRange();
                    charRange.setStart(baseNode, baseOffset - 1);
                    charRange.setEnd(baseNode, baseOffset);
                    rect = charRange.getBoundingClientRect();

                    QfavUtil.log('rect:' + rect.top + ' ' + rect.bottom + ' ' + baseOffset + ' ' + txtLen);
                    if (rect.bottom <= rect.top) {

                        if(baseOffset < txtLen - 3) {
                            charRange.setEnd(baseNode, baseOffset + 2);
                            rect = charRange.getBoundingClientRect();
                        } else if(baseOffset > 3){
                            charRange.setStart(baseNode, baseOffset - 2);
                            charRange.setEnd(baseNode, baseOffset);
                            rect = charRange.getBoundingClientRect();
                        }
                    } 

                    if(rect) {
                        rect = {left : rect.right - 1, top : rect.top, right : rect.right + 1, bottom : rect.bottom};
                    }
                } else if (txtLen > 0) {
                    QfavUtil.log('TEXT_NODE txtLen > 0');
                    void(0);
                    charRange = document.createRange();
                    charRange.setStart(baseNode, baseOffset);
                    charRange.setEnd(baseNode, baseOffset + 1);
                    rect = charRange.getBoundingClientRect();
                    if (rect) {
                        rect = {left : rect.right - 1, top : rect.top, right : rect.right + 1, bottom : rect.bottom};
                    }
                } else {
                    void(0);
                    rect = baseNode.parentElement.getBoundingClientRect();
                    if (rect) {
                        rect = {left : rect.right - 1, top : rect.top, right : rect.right + 1, bottom : rect.bottom};
                    }
                }
            } else  {
                this.ignoreChange(true);
                QfavUtil.log('begin getSelection base node not equal root');
                void(0);
                var tempDiv = document.createElement("div");
                var baseNodeStyle = window.getComputedStyle(sel.baseNode, '');
                var tempDivHeight = parseFloat(baseNodeStyle.getPropertyValue("font-size"));
                if (!tempDivHeight) {
                    tempDivHeight = 20;
                }
                tempDiv.style.cssText = "display: inline-block; position: relative; padding: 0px; margin: 0px; float: none; width: 0px; height: " + tempDivHeight + "px;";
                sel.baseNode.insertBefore(tempDiv, sel.baseNode.childNodes[sel.baseOffset]);
                rect = {left : tempDiv.offsetLeft, top : tempDiv.offsetTop, right : tempDiv.offsetLeft + tempDiv.offsetWidth, bottom : tempDiv.offsetTop + tempDiv.offsetHeight};
                tempDiv.parentNode.removeChild(tempDiv);
                QfavUtil.log('end getSelection base node not equal root');   
                this.ignoreChange(false);     
            }
        }

        QfavUtil.log('select baseNode:' + baseOffset);
        QfavUtil.log(baseNode);
        
    } catch (e) {
        void(0);
        void(0);
        QfavUtil.log(e.message);
    } finally {
        this.ignoreChange(false);
    }
    
    this.storeCurrentSelection();

    return rect ? rect : {left : 0, top : 0, right : 0, bottom : 0};
};

QfavEditor.E.prototype.notifySelectionRect = function() {
    var clientSize = this.getClientSize();
    QfavUtil.log('begin getClientSize');
    QfavUtil.log(clientSize);
    QfavUtil.log('end getClientSize');
    QfavUtil.log('begin getSelectionRect');
    var selRect = this.getSelectionRect(true);
    QfavUtil.log(selRect);
    QfavUtil.log('end getSelectionRect');
    QfavUtil.notify('selectionRectChangedFromJs', {w : clientSize.w, h : clientSize.h, sl : selRect.left, st : selRect.top, sr : selRect.right, sb :selRect.bottom });
}

QfavEditor.E.prototype.tellSelectionRect = function(sync) {
    if (this._selectionNotifyTimeID) {
        clearTimeout(this._selectionNotifyTimeID);
        this._selectionNotifyTimeID = null;
    }
    if (!sync) {
        var self = this;
        this._selectionNotifyTimeID = setTimeout(function() {self.notifySelectionRect();}, 100);
    } else {
        this.notifySelectionRect();
    }
}

QfavEditor.E.prototype.getInnerHtml = function() {
    return this.rootElement.innerHTML;
}

QfavEditor.E.prototype.getInnerText = function() {
    return this.rootElement.innerText;
}

QfavEditor._editor = new QfavEditor.E();


QfavEditor.start = function() {
    QfavEditor._editor.rootElement.setAttribute("contentEditable", true);
    QfavEditor._editor._bindEvents();
	QfavEditor._editor.rootElement.focus();
}

QfavEditor.excuteBridgeCallback = function() {
    QfavUtil.excuteCallback.apply(QfavUtil, [].slice.apply(arguments));
}

QfavEditor.getHtml = function() {
    return QfavEditor._editor.getInnerHtml();
}

QfavEditor.getText = function() {
    return QfavEditor._editor.getInnerText();
}

QfavEditor.insertHTML = function(value) {
    return document.execCommand("insertHTML", false, value);
}

QfavEditor.insertText = function(value) {
    return document.execCommand("insertText", false, value);
}

QfavEditor.setMinHeight = function(value) {
    var minHeight = QfavEditor._editor.rootElement.style.minHeight;
    if (minHeight != value) {
        QfavEditor._editor.rootElement.style.minHeight = value;
    }
}

QfavEditor.delete = function() {
    document.execCommand("delete");
}

QfavEditor.becomeFirstResponder = function(restore) {
    QfavEditor._editor._noRestoringSelectionOnNextFocus = !restore;
    QfavEditor._editor.rootElement.focus();
}

QfavEditor.resignFirstResponder = function() {
    QfavEditor._editor.rootElement.blur();
}

QfavEditor.retellSelectionRect = function() {
    QfavEditor._editor.tellSelectionRect(false);
}