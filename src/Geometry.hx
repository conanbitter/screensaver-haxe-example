import haxe.ds.Vector;
import hl.Bytes;

class Vector2D {
	public var x:Single = 0;

	public var y:Single = 0;

	public function new(x:Single, y:Single) {
		this.x = x;
		this.y = y;
	}
}

class Color {
	public var r:Int;
	public var g:Int;
	public var b:Int;
	public var a:Int;

	public function new(r:Int, g:Int, b:Int, a:Int = 255) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public static final White:Color = new Color(255, 255, 255);
}

class Vertex {
	public var pos:Vector2D;
	public var color:Color;

	public function new(pos:Vector2D, color:Color) {
		this.pos = pos;
		this.color = color;
	}

	public function write(buffer:Bytes, offset:Int = 0) {
		buffer.setF32(offset, pos.x);
		buffer.setF32(offset + 4, pos.y);
		buffer.setUI8(offset + 8, color.r);
		buffer.setUI8(offset + 9, color.g);
		buffer.setUI8(offset + 10, color.b);
		buffer.setUI8(offset + 11, color.a);
	}

	public static final size:Int = 2 * 4 + 4;
}

class Geometry {
	static final FIGURE_COUNT = 2;
	static final VERTEX_PER_FIGURE = 4;

	static final VERTEX_SHADER:String = '
	#version 150

    uniform int width;
	uniform int height;

    in vec2 vert;
    in vec4 vertColor;

    out vec4 fragColor;

    void main() {
        gl_Position = vec4(vert.x/float(width)*2.0-1.0, vert.y/float(height)*2.0-1.0, 0.0, 1.0);
        fragColor = vertColor;
	}';

	static final FRAGMENT_SHADER:String = '
	#version 150

    in vec4 fragColor;

    out vec4 outputColor;

    void main() {
        outputColor = fragColor;
    }';

	var vertices = new Vector<Vertex>(VERTEX_PER_FIGURE * FIGURE_COUNT);
	var vertBuffer = new Bytes(VERTEX_PER_FIGURE * FIGURE_COUNT * Vertex.size);
}
