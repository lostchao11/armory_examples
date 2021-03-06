package arm;

import armory.object.Object;
import armory.system.Input;
import zui.*;

class UITrait extends armory.Trait {
    
    var ui:Zui;
    var rt:kha.Image; // Render target for UI
    var uiWidth = 512;
    var uiHeight = 512;
    var gate:Object;
    var opened = false;

    public function new() {
        super();

        // Load font for UI labels
        kha.Assets.loadFont("droid_sans", function(f:kha.Font) {
            ui = new Zui({font: f, autoNotifyInput: false, scaleFactor: 4});
            armory.Scene.active.notifyOnInit(sceneInit);
        });
    }

    function sceneInit() {
        // Reference to gate object
        gate = armory.Scene.active.getChild('Gate');

        rt = kha.Image.createRenderTarget(uiWidth, uiHeight);

        // We will use empty texture slot in attached material to render UI
        var mat:armory.data.MaterialData = cast(object, armory.object.MeshObject).materials[0];
        mat.contexts[0].textures[0] = rt; // Override diffuse texture

        notifyOnRender(render);
        notifyOnUpdate(update);
    }

    function render(g:kha.graphics4.Graphics) {
        // Begin drawing UI
        ui.begin(rt.g2);
        // Make new window
        if (ui.window(Id.handle(), 0, 0, uiWidth, uiHeight, true)) {
            // Gate controll buttons
            if (ui.button("Open") && !opened) {
                // Gate object is animated in Blender
                // Play gate 'open' animation
                gate.animation.player.play('open');
                opened = true;
            }
            if (ui.button("Close") && opened) {
                // And close..
                gate.animation.player.play('close');
                opened = false;
            }
        }
        ui.end();
    }

    function update() {

        // We need to figure out if user clicked on the UI plane
        // Get plane UV
        var mouse = Input.getMouse();
        var uv = iron.math.RayCaster.getPlaneUV(cast object, mouse.x, mouse.y, iron.Scene.active.camera);
        if (uv == null) return;

        // Pixel coords
        var px = Std.int(uv.x * uiWidth);
        var py = Std.int(uv.y * uiHeight);

        // Send input events
        if (mouse.started()) ui.onMouseDown(0, px, py);
        else if (mouse.released()) ui.onMouseUp(0, px, py);
        if (mouse.movementX != 0 || mouse.movementY != 0) ui.onMouseMove(px, py, 0, 0);
    }
}
