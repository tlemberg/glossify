define ->


	_staticCss =
		'global':
			'header':
				'background-color': '#333333';
				'height': '40px';
				'color': '#ffffff';
				'text-align': 'center';
				'font-size': '20px';
				'padding-top': '10px';
			'content':
				'background-color': '#cccccc';
				'overflow-y': 'scroll';
			'footer':
				'position': 'absolute';
				'bottom': '0px';
				'width': '100%';
				'background-color': '#333333';
				'color': '#ffffff';
		'login':
			'header':
				'background-color': '#333333';
				'height': '40px';
				'color': '#ffffff';
				'text-align': 'center';
				'font-size': '20px';
				'padding-top': '10px';
			'container':
				'background-color': '#cccccc';
				'height': '100%';
			'input-container-top':
				'margin-top': '20px';
			'input-container':
				'margin-bottom': '3px';
				'text-align': 'center';
			'text-input':
				'width': '100%';
			'btn-div':
				'background-color': '#00ff00';
				'height': '40px';
				'color': '#ffffff';
				'text-align': 'center';
				'font-size': '20px';
				'padding-top': '10px';
				'cursor': 'pointer';
			'or':
				'text-align': 'center';
				'font-style': 'italic';
				'margin-top': '12px';
				'margin-bottom': '12px';
			'error':
				'text-align': 'center';
				'margin-top': '20px';
		'signup':
			'header':
				'background-color': '#333333';
				'height': '40px';
				'color': '#ffffff';
				'text-align': 'center';
				'font-size': '20px';
				'padding-top': '10px';
			'container':
				'background-color': '#cccccc';
				'height': '100%';
			'input-container-top':
				'margin-top': '20px';
			'input-container':
				'margin-bottom': '3px';
				'text-align': 'center';
			'text-input':
				'width': '100%';
			'btn-div':
				'background-color': '#00ff00';
				'height': '40px';
				'color': '#ffffff';
				'text-align': 'center';
				'font-size': '20px';
				'padding-top': '10px';
				'cursor': 'pointer';
			'or':
				'text-align': 'center';
				'font-style': 'italic';
				'margin-top': '12px';
				'margin-bottom': '12px';
			'error':
				'text-align': 'center';
				'margin-top': '20px';
		'overview':
			'picker':
				'max-height': '100%';
				'background-color': '#cccccc';
				'overflow-y': 'scroll';
			'tile':
				'float': 'left';
				'background-color': '#999999';
				'border-radius': '6px';
			'tile-text':
				'position': 'relative';
				'top': '50%';
				'-webkit-transform': 'translateY(-50%)';
				'-ms-transform': 'translateY(-50%)';
				'transform': 'translateY(-50%)';
				'text-align': 'center';
				'display': 'block';
				'font-size': '30';
			'btn-left':
				'float': 'left';
				'cursor': 'pointer';
			'btn-right':
				'float': 'right';
				'cursor': 'pointer';
			'display':
				'text-align': 'center';
				'float': 'left';
			'picker-container':
				'background-color': '#999999';
			'block':
				'padding': '10px'
				'border-radius': '20px';
			'block-header':
				'padding': '10px'
				'padding-top': '20px';
				'padding-bottom': '20px';
				'background-color': '#999999';
				'border-top-left-radius': '14px';
				'border-top-right-radius': '14px';
			'block-row':
				'padding': '10px'
				'padding-top': '20px';
				'padding-bottom': '20px';
				'background-color': '#ffffff';
				'border-bottom-style': 'solid';
				'border-width': '1px';
				'border-color': '#999999';
			'block-sample':
				'font-style': 'italic';
			'block-row-link':
				'cursor': 'pointer';

		'study':
			'header':
				'background-color': '#333333'
				'height': '50px'
			'back-btn':
				'color': '#ffffff';
				'height': '100%';
				'padding': '8px';
				'font-size': '26px';
				'cursor': 'pointer';
				'float': 'left';
			'progress-counter':
				'color': '#ffffff';
				'height': '20px';
				'padding': '8px';
				'padding-top': '5px';
				'font-size': '20px';
				'float': 'right';
				'border-radius': '8px';
				'margin': '7px';
			'flip-button':
				'color': '#ffffff';
				'height': '100%';
				'padding': '8px';
				'font-size': '26px';
				'cursor': 'pointer';
				'text-align': 'center';
			'container':
				'background-color': '#666666';
				'padding': '16px';
			'content':
				'background-color': '#ffffff';
				'border-radius': '25px'
				'border-style': 'solid';
				'border-width': '5px';
			'half':
				'background-color': '#ffffff';
				'display': 'flex';
				'justify-content': 'center';
				'flex-direction': 'column';
				'text-align': 'center';
				'height': '50%';
				'border-radius': '25px';
				'padding-left': '20px';
				'padding-right': '20px';
			'footer':
				'position': 'absolute';
				'bottom': '0px';
				'width': '100%';
				'background-color': '#333333';
			'btn':
				'float': 'left';
				'margin': '0px';
				'cursor': 'pointer';
			'btn-text':
				'position': 'relative';
				'top': '50%';
				'-webkit-transform': 'translateY(-50%)';
				'-ms-transform': 'translateY(-50%)';
				'transform': 'translateY(-50%)';
				'text-align': 'center';
				'display': 'block';
				'font-size': '30';


	_getStaticCss = (page, sel, attr) ->
		_staticCss[page][sel][attr]


	_refreshStaticCss = () ->
		for page in Object.keys(_staticCss)
			for sel in Object.keys(_staticCss[page])
				for attr, v of _staticCss[page][sel]
					$(".#{ page }-#{ sel }").css(attr, v)


	return {

		getStaticCss: (page, sel, attr) -> _getStaticCss(page, sel, attr)

		refreshStaticCss: (sel) -> _refreshStaticCss(sel)

	}

