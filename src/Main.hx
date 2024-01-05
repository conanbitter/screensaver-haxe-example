import Window;

class LinesWindow extends Window {
	var geometry:Geometry;

	public function new() {
		super("Lines", 1280, 720);
		geometry = new Geometry(this);
	}
}

class Main {
	static function main() {
		var wnd = new LinesWindow();
		wnd.run();
	}
}
