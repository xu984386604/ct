/**
 * selectFx.js v1.0.0
 * http://www.codrops.com
 *
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2014, Codrops
 * http://www.codrops.com
 */
;( function( window ) {

	'use strict';

	/**
	 * based on from https://github.com/inuyaksa/jquery.nicescroll/blob/master/jquery.nicescroll.js
	 */
	function hasParent( e, p ) {
		if (!e) return false;
		var el = e.target||e.srcElement||e||false;
		while (el && el != p) {
			el = el.parentNode||false;
		}
		return (el!==false);
	};

	/**
	 * extend obj function
	 */
	function extend( a, b ) {
		for( var key in b ) {
			if( b.hasOwnProperty( key ) ) {
				a[key] = b[key];
			}
		}
		return a;
	}

	/**
	 * SelectFx function
	 */
	function SelectFx( el, options ) {
		this.el = el;
		this.options = extend( {}, this.options );
		extend( this.options, options );
		this._init();
	}

	/**
	 * SelectFx options
	 */
	SelectFx.prototype.options = {
		// if true all the links will open in a new tab.
		// if we want to be redirected when we click an option, we need to define a data-link attr on the option of the native select element
		newTab : true,
		// when opening the select element, the default placeholder (if any) is shown
		stickyPlaceholder : true,
		// callback when changing the value
		onChange : function( val ) { return false; }
	}

	/**
	 * init function
	 * initialize and cache some vars
	 */
	SelectFx.prototype._init = function() {
		// check if we are using a placeholder for the native select box
		// we assume the placeholder is disabled and selected by default
		var selectedOpt = this.el.querySelector( 'option[selected]' );
		this.hasDefaultPlaceholder = selectedOpt && selectedOpt.disabled;

		// get selected option (either the first option with attr selected or just the first option)
		this.selectedOpt = selectedOpt || this.el.querySelector( 'option' );

		// create structure
		this._createSelectEl();

		// all options
		this.selOpts = [].slice.call( this.selEl.querySelectorAll( 'li[data-option]' ) );

		// total options
		this.selOptsCount = this.selOpts.length;

		// current index
		this.current = this.selOpts.indexOf( this.selEl.querySelector( 'li.cs-selected' ) ) || -1;

		// placeholder elem
		this.selPlaceholder = this.selEl.querySelector( 'span.cs-placeholder' );

		// init events
		this._initEvents();
	}

	/**
	 * creates the structure for the select element
	 */
	SelectFx.prototype._createSelectEl = function() {
		var self = this, options = '', createOptionHTML = function(el) {
			var optclass = '', classes = '', link = '';

			if( el.selectedOpt && !this.foundSelected && !this.hasDefaultPlaceholder ) {
				classes += 'cs-selected ';
				this.foundSelected = true;
			}
			// extra classes
			if( el.getAttribute( 'data-class' ) ) {
				classes += el.getAttribute( 'data-class' );
			}
			// link options
			if( el.getAttribute( 'data-link' ) ) {
				link = 'data-link=' + el.getAttribute( 'data-link' );
			}

			if( classes !== '' ) {
				optclass = 'class="' + classes + '" ';
			}
			return '<li ' + optclass + link + ' data-option data-value="' + el.value + '" data-ipaddress="'+el.dataset.ipaddress+'"><span>' + el.textContent + "</span></li>";
		};

		[].slice.call( this.el.children ).forEach( function(el) {
			if( el.disabled ) { return; }

			var tag = el.tagName.toLowerCase();

			if( tag === 'option' ) {
				options += createOptionHTML(el);
			}
			else if( tag === 'optgroup' ) {
				options += '<li class="cs-optgroup"><span>' + el.label + '</span><ul>';
				[].slice.call( el.children ).forEach( function(opt) {
					options += createOptionHTML(opt);
				} )
				options += '</ul></li>';
			}
		} );

		var opts_el = '<div class="cs-options"><ul>' + options + '</ul></div>';
		this.selEl = document.createElement( 'div' );
		this.selEl.className = this.el.className;
		this.selEl.tabIndex = this.el.tabIndex;
		console.log(this.selectedOpt);
		console.log(this.selectedOpt.dataset);
		this.selEl.innerHTML = '<span class="cs-placeholder" data-ipaddress="'+this.selectedOpt.dataset.ipaddress+'"> ' + this.selectedOpt.textContent + '</span>' + opts_el;
		this.el.parentNode.appendChild( this.selEl );
		this.selEl.appendChild( this.el );
	}

	/**
	 * initialize the events
	 */
	SelectFx.prototype._initEvents = function() {
		var self = this;

		// open/close select
		this.selPlaceholder.addEventListener( 'click', function() {
			self._toggleSelect();
		} );

		// clicking the options
		this.selOpts.forEach( function(opt, idx) {
			opt.addEventListener( 'click', function() {
				self.current = idx;
				self._changeOption();
				// close select elem
				self._toggleSelect();
			} );
		} );

		// close the select element if the target it´s not the select element or one of its descendants..
		document.addEventListener( 'click', function(ev) {
			var target = ev.target;
			if( self._isOpen() && target !== self.selEl && !hasParent( target, self.selEl ) ) {
				self._toggleSelect();
			}
		} );

		// keyboard navigation events
		this.selEl.addEventListener( 'keydown', function( ev ) {
			var keyCode = ev.keyCode || ev.which;

			switch (keyCode) {
				// up key
				case 38:
					ev.preventDefault();
					self._navigateOpts('prev');
					break;
				// down key
				case 40:
					ev.preventDefault();
					self._navigateOpts('next');
					break;
				// space key
				case 32:
					ev.preventDefault();
					if( self._isOpen() && typeof self.preSelCurrent != 'undefined' && self.preSelCurrent !== -1 ) {
						self._changeOption();
					}
					self._toggleSelect();
					break;
				// enter key
				case 13:
					ev.preventDefault();
					if( self._isOpen() && typeof self.preSelCurrent != 'undefined' && self.preSelCurrent !== -1 ) {
						self._changeOption();
						self._toggleSelect();
					}
					break;
				// esc key
				case 27:
					ev.preventDefault();
					if( self._isOpen() ) {
						self._toggleSelect();
					}
					break;
			}
		} );
	}

	/**
	 * navigate with up/dpwn keys
	 */
	SelectFx.prototype._navigateOpts = function(dir) {
		if( !this._isOpen() ) {
			this._toggleSelect();
		}

		var tmpcurrent = typeof this.preSelCurrent != 'undefined' && this.preSelCurrent !== -1 ? this.preSelCurrent : this.current;

		if( dir === 'prev' && tmpcurrent > 0 || dir === 'next' && tmpcurrent < this.selOptsCount - 1 ) {
			// save pre selected current - if we click on option, or press enter, or press space this is going to be the index of the current option
			this.preSelCurrent = dir === 'next' ? tmpcurrent + 1 : tmpcurrent - 1;
			// remove focus class if any..
			this._removeFocus();
			// add class focus - track which option we are navigating
			classie.add( this.selOpts[this.preSelCurrent], 'cs-focus' );
		}
	}

	/**
	 * open/close select
	 * when opened show the default placeholder if any
	 */
	SelectFx.prototype._toggleSelect = function() {
		// remove focus class if any..
		this._removeFocus();

		if( this._isOpen() ) {
			if( this.current !== -1 ) {
				// update placeholder text
				this.selPlaceholder.textContent = this.selOpts[ this.current ].textContent;
				console.log('this.selOpts[ this.current ].dataset.ipaddress');
				console.log(this.selOpts[ this.current ])
				this.selPlaceholder.dataset.ipaddress = this.selOpts[ this.current ].dataset.ipaddress;
			}
			classie.remove( this.selEl, 'cs-active' );
		}
		else {
			if( this.hasDefaultPlaceholder && this.options.stickyPlaceholder ) {
				// everytime we open we wanna see the default placeholder text
				this.selPlaceholder.textContent = this.selectedOpt.textContent;
				console.log('this.selectedOpt.dataset.ipaddress',this.selectedOpt.dataset.ipaddress);
				this.selPlaceholder.dataset.ipaddress = this.selectedOpt.dataset.ipaddress;
			}
			classie.add( this.selEl, 'cs-active' );
		}
	}

	/**
	 * change option - the new value is set
	 */
	SelectFx.prototype._changeOption = function() {
		// if pre selected current (if we navigate with the keyboard)...
		if( typeof this.preSelCurrent != 'undefined' && this.preSelCurrent !== -1 ) {
			this.current = this.preSelCurrent;
			this.preSelCurrent = -1;
		}

		// current option
		var opt = this.selOpts[ this.current ];

		// update current selected value
		this.selPlaceholder.textContent = opt.textContent;
		this.selPlaceholder.dataset.ipaddress = opt.dataset.ipaddress;
		//设置用户上次选择的缓存
		localStorage.setItem('lastipaddress',opt.dataset.ipaddress);

		// change native select element´s value
		this.el.value = opt.getAttribute( 'data-value' );

		// remove class cs-selected from old selected option and add it to current selected option
		var oldOpt = this.selEl.querySelector( 'li.cs-selected' );
		if( oldOpt ) {
			classie.remove( oldOpt, 'cs-selected' );
		}
		classie.add( opt, 'cs-selected' );

		// if there´s a link defined
		if( opt.getAttribute( 'data-link' ) ) {
			// open in new tab?
			if( this.options.newTab ) {
				window.open( opt.getAttribute( 'data-link' ), '_blank' );
			}
			else {
				window.location = opt.getAttribute( 'data-link' );
			}
		}

		// callback
		this.options.onChange( this.el.value );

		//yosang在这里响应环境变化的事件
		var ipstr = opt.dataset.ipaddress;
		var ipurl = 'http://'+ipstr+'/cu/iplogin/login.html?v=2';
		var authurl = 'http://'+ipstr+'/cu/index.php/Home/Auth/login.html';
		var locationurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php?code=';
        var registurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php#/regist';
        var forgeturl = 'http://'+ipstr+'/cu/Public/vue/build/index.php#/reset-password';
			//将按钮设置成loading状态
		$('.y-head-icon').addClass('y-hide');
        $('.ant-spin').removeClass('y-hide');
        if($('#username').length !== 0){
            // $('.insertbox').html('');
            $('.insertbox').css('display','none');
		}
		//点击的时候加载html到当前页面
			$.ajax({
					type:'get',
					url:ipurl,
					data:{},
					timeout : 2000
			})
			.then(function(res,status,xhr){
				if(xhr.status == 200){
					if($('.bugtip').length !== 0){
						$('.bugtip').remove();
					}
					setTimeout(function(){
                        $('.ant-spin').addClass('y-hide');
                        // $('.insertbox').html(res)
                        $('.insertbox').css('display','block');
                        $('.insertbox').addClass('animated fadeInRight')
                        $('.insertbox').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {

                            $('.insertbox').removeClass('animated fadeInRight');
                        })
						//替换注册和忘记密码的地址
						if($('.collapse').hasClass('in')){
							$('.collapse').removeClass('in');
						}
						localStorage.setItem('lastipaddress',ipstr);
						$('#username').val(localStorage.getItem('user'));
						//连接时发送ip地址
						var sendData = {
							url:ipstr,
							operation : 'setIp'
						}
						executeByTerminal(sendData);
						//点击登录按钮
						$('#login').click(function(){
							//获取用户的输入
							var username = $('#username').val();
							var password = $('#password').val();
							//这里要对密码进行加密
							var encryptedPassword =  encryptPassword(password);
							//将信息发给后台验证
							$.ajax({
								url : authurl,
								method : 'post',
								data : {
											// mac:mac/*终端mac地址*/,
											type:devicetype,
											username:username,
											password:encryptedPassword
										},
								timeout : 5000,
							})
							.then(function(res){
								if(res.code == 800){
									if($('.bugtip').length !== 0){
										$('.bugtip').remove();
									}
									//用localstorage存储是否自动登录的信息
									if($('.ant-checkbox-wrapper').hasClass('ant-checkbox-checked')){
										localStorage.setItem('autologin','true');
										//localStorage.setItem('ipaddress','')
									}else{
										localStorage.setItem('autologin','false')
									}
									//用localstorage存储上一次的ip地址信息
									localStorage.setItem('ipaddress',ipstr)
									//存localstorage为自动登录做准备
									localStorage.setItem('user',username);
									localStorage.setItem('enpw',encryptedPassword);
									//登录 进行地址跳转
									var sendData = {
										userID:res.data.userID,
										operation : 'setUserId'
									}
									executeByTerminal(sendData);
									window.location.href = locationurl+res.data.code;
								}else{
									errorconsole($('.loginbox'),CODE_MSG(res.code),0);
								}
							},function(err, status){
								if(status=='timeout'){//超时,status还有success,error等值的情况
									errorconsole($('.loginbox'),'登录超时',0);
								}else if(status=='error'){
									errorconsole($('.loginbox'),'登录失败',0);
								}
							})

						})
						$('.regist a').click(function(event){
							// console.log(event)
							event.preventDefault();
							window.location.href = registurl;
						})
						$('.reset-password a').click(function(event){
							event.preventDefault();
							window.location.href = forgeturl;
						})
						$('.exit a').click(function(event){
							event.preventDefault();
							//调用
							exit();
						})
					},300)
				}
			},function(err,status){
				if(status=='timeout' || status== 'error'){//超时,status还有success,error等值的情况
					if($('#username').length !== 0){
						// $('.insertbox').addClass('animated fadeOutRight')
						// $('.insertbox').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {
						// 	$('.insertbox').css('display',0);
							// $('.insertbox').removeClass('animated fadeOutRight');
							// $('.insertbox').html('');
							$('.ant-spin').addClass('y-hide');
							$('.y-head-icon').removeClass('y-hide');
							if(!$('.collapse').hasClass('in')){
								$('.collapse').addClass('in');
							}
						// })
					}else{
						setTimeout(function(){
							$('.ant-spin').addClass('y-hide');
							$('.y-head-icon').removeClass('y-hide');
							if(!$('.collapse').hasClass('in')){
								$('.collapse').addClass('in');
							}
						},300)
					}
						errorconsole($('.cs-placeholder'),'ip地址无法访问',1);

					return;
				}
			})
	}

	/**
	 * returns true if select element is opened
	 */
	SelectFx.prototype._isOpen = function(opt) {
		return classie.has( this.selEl, 'cs-active' );
	}

	/**
	 * removes the focus class from the option
	 */
	SelectFx.prototype._removeFocus = function(opt) {
		var focusEl = this.selEl.querySelector( 'li.cs-focus' )
		if( focusEl ) {
			classie.remove( focusEl, 'cs-focus' );
		}
	}

	/**
	 * add to global namespace
	 */
	window.SelectFx = SelectFx;

} )( window );
