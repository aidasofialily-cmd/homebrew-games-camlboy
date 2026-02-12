#include <iostream>
#include <vector>
#include "CamlBridge.h" // Your OCaml FFI header

struct Ball {
    float x, y, dx, dy;
};

class StressTest {
public:
    Ball ball = {80, 72, 1.5, 1.5}; // Start in the middle of 160x144 screen
    
    void update() {
        // Simple physics logic
        ball.x += ball.dx;
        ball.y += ball.dy;

        // Bounce off edges
        if (ball.x <= 0 || ball.x >= 152) ball.dx *= -1;
        if (ball.y <= 0 || ball.y >= 136) ball.dy *= -1;

        // Update the OCaml PPU state via bridge
        // We write directly to the OAM (Object Attribute Memory) for sprites
        caml_write_oam(0, (int)ball.y, (int)ball.x, 0x01, 0x00); 
    }

    void render() {
        // Trigger the OCaml-side SDL2 renderer
        caml_render_frame();
    }
};

extern "C" {
    void run_cpp_test_loop() {
        StressTest game;
        while (true) {
            game.update();
            game.render();
            // Handle timing to match Game Boy 60FPS (approx 16.6ms)
            limit_fps(60); 
        }
    }
}
