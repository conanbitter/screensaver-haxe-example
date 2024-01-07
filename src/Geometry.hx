import Shaders.ShaderProgram;
import haxe.ds.Vector;
import hl.Bytes;
import sdl.GL;

class Vector2D {
	public var x:Single = 0;
	public var y:Single = 0;

	public function new(x:Single, y:Single) {
		this.x = x;
		this.y = y;
	}

	static public function getRandom(width:Int, height:Int):Vector2D {
		return new Vector2D(Math.random() * width, Math.random() * height);
	}

	static public function getRandomPolar():Vector2D {
		var angle = Math.random() * Math.PI * 2;
		return new Vector2D(Math.cos(angle), Math.sin(angle));
	}

	public function add(other:Vector2D):Vector2D {
		return new Vector2D(x + other.x, y + other.y);
	}

	public function scale(factor:Float):Vector2D {
		return new Vector2D(x * factor, y * factor);
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

	static public function getRandom(low:Int):Color {
		final range = 255 - low;
		return new Color(Std.int(Math.random() * range + low), Std.int(Math.random() * range + low), Std.int(Math.random() * range + low));
	}

	static function intLerp(v1:Int, v2:Int, factor:Float):Int {
		return v1 + Std.int((v2 - v1) * factor);
	}

	static public function lerp(c1:Color, c2:Color, factor:Float):Color {
		return new Color(intLerp(c1.r, c2.r, factor), intLerp(c1.g, c2.g, factor), intLerp(c1.b, c2.b, factor), intLerp(c1.a, c2.a, factor));
	}

	public static final White:Color = new Color(255, 255, 255);
}

class Vertex {
	public var pos:Vector2D;
	public var speed:Vector2D;
	public var color1:Color;
	public var color2:Color;

	public function new(pos:Vector2D, speed:Vector2D, color1:Color, color2:Color) {
		this.pos = pos;
		this.speed = speed;
		this.color1 = color1;
		this.color2 = color1;
	}

	public function write(buffer:Bytes, offset:Int = 0, factor:Float) {
		var color = Color.lerp(color1, color2, factor);

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

	static final VERT_BUFFER_LENGTH = VERTEX_PER_FIGURE * FIGURE_COUNT * Vertex.size;
	static final INDEX_BUFFER_SIZE = VERTEX_PER_FIGURE * FIGURE_COUNT * 2;
	static final COLOR_CHANGE_SPEED = 0.01;
	static final COLOR_MIN = 30;
	static final SPEED = 2.0;

	var vertices = new Vector<Vertex>(VERTEX_PER_FIGURE * FIGURE_COUNT);
	var vertBuffer = new Bytes(VERT_BUFFER_LENGTH);

	var vao:VertexArray;
	var vbo:Buffer;
	var program:ShaderProgram;
	var parent:Window;

	var colorFactor:Float = 0.0;

	public function new(parent:Window) {
		this.parent = parent;

		GL.disable(GL.DEPTH_TEST);
		GL.enable(GL.BLEND);

		vao = GL.createVertexArray();
		GL.bindVertexArray(vao);

		vbo = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, vbo);

		program = new ShaderProgram(VERTEX_SHADER, FRAGMENT_SHADER);
		program.use();
		program.setUniform("width", parent.width);
		program.setUniform("height", parent.height);
		GL.viewport(0, 0, parent.width, parent.height);

		final locPos = program.getAttribLocation("vert");
		GL.enableVertexAttribArray(locPos);
		GL.vertexAttribPointer(locPos, 2, GL.FLOAT, false, Vertex.size, 0);
		final locColor = program.getAttribLocation("vertColor");
		GL.enableVertexAttribArray(locColor);
		GL.vertexAttribPointer(locColor, 4, GL.UNSIGNED_BYTE, true, Vertex.size, 2 * 4);

		GL.bufferData(GL.ARRAY_BUFFER, VERT_BUFFER_LENGTH, vertBuffer, GL.DYNAMIC_DRAW);

		final ebo = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, ebo);
		final dataLength = INDEX_BUFFER_SIZE * 4;
		final indexData = new Bytes(dataLength);
		var curIndex = 0;
		var curBufferPos = 0;
		for (i in 0...FIGURE_COUNT) {
			var first = curIndex;
			for (j in 0...VERTEX_PER_FIGURE - 1) {
				indexData.setI32(curBufferPos, curIndex);
				curBufferPos += 4;
				curIndex++;
				indexData.setI32(curBufferPos, curIndex);
				curBufferPos += 4;
			}
			indexData.setI32(curBufferPos, curIndex);
			curBufferPos += 4;
			indexData.setI32(curBufferPos, first);
			curBufferPos += 4;
			curIndex++;
		}
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, dataLength, indexData, GL.STATIC_DRAW);

		var color1 = Color.getRandom(COLOR_MIN);
		var color2 = Color.getRandom(COLOR_MIN);
		for (i in 0...vertices.length) {
			vertices[i] = new Vertex(Vector2D.getRandom(parent.width - 1, parent.height - 1), Vector2D.getRandomPolar().scale(SPEED), color1, color2);
			color1 = color2;
			color2 = Color.getRandom(COLOR_MIN);
		}
	}

	public function draw() {
		for (i in 0...vertices.length) {
			vertices[i].write(vertBuffer, i * Vertex.size, colorFactor);
		}
		GL.bindVertexArray(vao);
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, vertBuffer, 0, VERT_BUFFER_LENGTH);

		GL.drawElements(GL.LINES, INDEX_BUFFER_SIZE, GL.UNSIGNED_INT, 0);
	}

	public function update() {
		colorFactor += COLOR_CHANGE_SPEED;
		if (colorFactor > 1.0) {
			colorFactor = 0.0;
			for (i in 0...vertices.length - 1) {
				vertices[i].color1 = vertices[i].color2;
				vertices[i].color2 = vertices[i + 1].color1;
			}
			vertices[vertices.length - 1].color1 = vertices[vertices.length - 1].color2;
			vertices[vertices.length - 1].color2 = Color.getRandom(COLOR_MIN);
		}

		for (vertex in vertices) {
			if (vertex.pos.x < 0 || vertex.pos.x > parent.width) {
				vertex.speed.x = -vertex.speed.x;
			}
			if (vertex.pos.y < 0 || vertex.pos.y > parent.height) {
				vertex.speed.y = -vertex.speed.y;
			}
			vertex.pos = vertex.pos.add(vertex.speed);
		}
	}
}
