import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.KeyboardEvent;
import js.Syntax;

typedef Message = {
    text: String,
    isShake: Bool
}

class Main {
    static var ctx:CanvasRenderingContext2D;
    static var audioCtx:Dynamic;
    
    // --- カスタマイズ設定 ---
    static var messages:Array<Message> = [
        { text: "これは テキスト送りの サンプルプログラムです。", isShake: false },
        { text: "Zキーを押すと 次のメッセージに 進みます。", isShake: false },
        { text: "揺れる演出を 入れることも 可能です！！", isShake: true },
        { text: "さあ、ここから 冒険を 始めましょう。", isShake: false }
    ];
    
    static var textSpeed:Float = 0.05;   // 通常の速さ
    static var waitSpeed:Float = 0.3;    // 句読点での停止時間
    // -----------------------

    static var msgIndex:Int = 0;
    static var charIndex:Int = 0;
    static var timer:Float = 0;
    static var currentWait:Float = 0.05;
    static var isFinished:Bool = false;
    static var isKeyPressed:Bool = false;

    static function main() {
        var canvas:CanvasElement = cast Browser.document.getElementById("c");
        canvas.width = 640;
        canvas.height = 240;
        ctx = canvas.getContext2d();

        Browser.window.addEventListener("keydown", onKeyDown);
        Browser.window.addEventListener("keyup", _ -> isKeyPressed = false);
        Browser.window.addEventListener("mousedown", initAudio);
        Browser.window.requestAnimationFrame(loop);
    }

    static function initAudio(_) {
        if (audioCtx == null) {
            var audioContextClass:Dynamic = Syntax.code("window.AudioContext || window.webkitAudioContext");
            if (audioContextClass != null) audioCtx = Type.createInstance(audioContextClass, []);
        }
        if (audioCtx != null && audioCtx.state == "suspended") audioCtx.resume();
    }

    static function onKeyDown(e:KeyboardEvent) {
        if (e.key.toLowerCase() == "z" && !isKeyPressed) {
            isKeyPressed = true;
            var current = messages[msgIndex];
            
            if (charIndex < current.text.length) {
                charIndex = current.text.length;
                isFinished = true;
            } else if (msgIndex < messages.length - 1) {
                msgIndex++;
                charIndex = 0;
                isFinished = false;
                currentWait = textSpeed;
            }
        }
    }

    static function loop(t:Float) {
        timer += 0.016; // 約60fps

        var current = messages[msgIndex];
        if (!isFinished && timer >= currentWait) {
            var char = current.text.charAt(charIndex);
            charIndex++;
            timer = 0;

            // 句読点なら少し待機時間を増やす
            if (char == "。" || char == "、" || char == "？" || char == "！") {
                currentWait = waitSpeed;
            } else {
                currentWait = textSpeed;
                if (char != " " && char != "　") playBeep();
            }

            if (charIndex >= current.text.length) isFinished = true;
        }

        draw();
        Browser.window.requestAnimationFrame(loop);
    }

    static function playBeep() {
        if (audioCtx == null) return;
        var osc = audioCtx.createOscillator();
        var gain = audioCtx.createGain();
        osc.type = "square";
        osc.frequency.setValueAtTime(140, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.05);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.05);
    }

    static function draw() {
        // 背景と外枠
        ctx.fillStyle = "#000";
        ctx.fillRect(0, 0, 640, 240);
        ctx.strokeStyle = "#fff";
        ctx.lineWidth = 4;
        ctx.strokeRect(10, 10, 620, 220);

        ctx.font = "22px 'Courier New', 'DotGothic16', sans-serif";
        ctx.fillStyle = "#fff";

        var current = messages[msgIndex];
        var lines = current.text.substr(0, charIndex).split("\n");
        var startX = 40;
        var startY = 60;
        var lineHeight = 36;

        for (i in 0...lines.length) {
            var line = lines[i];
            if (current.isShake) {
                for (j in 0...line.length) {
                    var ox = Math.random() * 2 - 1;
                    var oy = Math.random() * 2 - 1;
                    ctx.fillText(line.charAt(j), startX + j * 22 + ox, startY + i * lineHeight + oy);
                }
            } else {
                ctx.fillText(line, startX, startY + i * lineHeight);
            }
        }

        // 送り待機アイコン（点滅）
        if (isFinished && (Math.floor(Date.now().getTime() / 500) % 2 == 0)) {
            ctx.fillText("▼", 585, 205);
        }
    }
}
