import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class Main {
    static var ctx:CanvasRenderingContext2D;
    static var text:String = "こんにちは\nこれはUNDERTALE風のHaxe対話エンジンだよ。";
    static var index:Int = 0;
    static var timer:Float = 0;
    static var speed:Float = 0.03; // 文字速度
    static var shake:Bool = false;

    static function main() {
        var canvas:CanvasElement = cast Browser.document.getElementById("c");
        ctx = canvas.getContext2d();

        Browser.window.requestAnimationFrame(loop);
    }

    static function loop(t:Float) {
        timer += 0.016;

        if (timer >= speed && index < text.length) {
            index++;
            timer = 0;
        }

        draw();
        Browser.window.requestAnimationFrame(loop);
    }

    static function draw() {
        ctx.fillStyle = "#000";
        ctx.fillRect(0, 0, 800, 200);

        ctx.font = "24px JetBrains Mono";
        ctx.fillStyle = "#fff";

        var shown = text.substr(0, index);
        var lines = shown.split("\n");

        for (i in 0...lines.length) {
            var y = 40 + i * 30;

            var offsetX = 0;
            var offsetY = 0;

            if (shake) {
                offsetX = Std.random(3) - 1;
                offsetY = Std.random(3) - 1;
            }

            ctx.fillText(lines[i], 20 + offsetX, y + offsetY);
        }
    }
}
