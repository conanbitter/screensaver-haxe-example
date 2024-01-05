import sdl.Sdl;
import sdl.GL;

class Window {
	var window:sdl.Window;

	public var width(default, null):Int;
	public var height(default, null):Int;

	function initSDL(title:String) {
		Sdl.init();
		Sdl.setGLOptions(3, 2);

		window = new sdl.Window(title, width, height);
	}

	public function new(title:String, width:Int, height:Int) {
		this.width = width;
		this.height = height;

		initSDL(title);

		if (!GL.init()) {
			trace('OpenGL init failed');
			return;
		}

		trace('OpenGL ${GL.getParameter(GL.VERSION)}');
	}

	public function load() {}

	public function update() {}

	public function draw() {}

	public function unload() {}

	public function run() {
		var quit = false;
		load();

		while (!quit) {
			Sdl.processEvents((event) -> {
				switch (event.type) {
					case Quit:
						quit = true;
						return true;
					case KeyDown:
						if (event.keyCode == 27) quit = true;
					case _:
						return false;
				}
				return false;
			});

			update();
			GL.clear(GL.COLOR_BUFFER_BIT);
			draw();
			window.present();
		}

		unload();

		window.destroy();
		Sdl.quit();
	}
}
