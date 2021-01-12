
use <libs/cubeX.scad>
use <gadgets.scad>

$fn = 60;

DEBUG = false;

/* BEGIN e-Paper defintion
 *
 * Screen information https://www.waveshare.com/product/displays/e-paper/7.5inch-e-paper.htm
 * https://www.waveshare.com/product/displays/e-paper/7.5inch-e-paper.htm
 * https://www.waveshare.com/wiki/File:7.5inch-e-paper-specification.pdf
 * https://www.waveshare.com/w/upload/6/60/7.5inch_e-Paper_V2_Specification.pdf
 */
OUTLINE_LENGTH = 170.2;
OUTLINE_WIDTH = 111.2;
OUTLINE_THICKNESS = 1.18;

// Display Active Area
AA_LENGTH = 163.2;
AA_WIDTH = 97.92;

// Active Area is not centered
// 1.2 + 1.5 + 0.8: see specification "1.4 Mechanical Drawing of EPD module"
AA_BORDER_OFFSET = 1.2 + 1.5 + 0.8;
/*  END e-Paper defintion
 */

BORDER_HORIZONTAL = 10;
BORDER_VERTICAL = 14;

LENGTH = AA_LENGTH + BORDER_HORIZONTAL * 2;
WIDTH = AA_WIDTH + BORDER_VERTICAL * 2;

FRONT_THICKNESS = 3.5;

CASE_HEIGHT = 9.6;
CASE_THICKNESS = 1.;
CASE_WALL_THICKNESS = 9;

// Must be less than or equal to front thickness
BORDER_RADIUS = 3;

// Dept
DISPLAY_DEPTH = 2;

SCREEN_OFFSET = 3;

GADGET_HEIGHT = CASE_HEIGHT - BORDER_RADIUS - CASE_THICKNESS;
GADGET_WIDTH = CASE_WALL_THICKNESS;
GADGET_LENGTH = 40;

/*  Inserts definition
 */
INSERT_THREAD_DIAMETER = 2;
INSERT_DIAMETER = 3.45;
INSERT_HEIGHT = 4;


module dummy_screen(length, width, thickness, active_area_length, active_area_width, border_offset) {
    color("RED")
    cube(size=[length, width, thickness], center=true);

    color("BLACK")
    translate([0, (length - active_area_length) - border_offset, .1]) {
        cube(size=[length, width, 1], center=true);
    }

    // Display connector
    color("BLUE")
    translate([0, -width / 2, 0]) {
        cube(size=[22.04, 5, 1], center=true);
    }
}

module frame(active_area_length, active_area_width, front_thickness, display_depth) {
    // Frame opening
    opening = 6;

    // Height of the closest part of the active area
    base = 1;

    // Clearance between frame border and active area
    clearance = 0.3;

    cube(size=[AA_LENGTH + clearance, AA_WIDTH + clearance, FRONT_THICKNESS * 2], center=true);
    hull() {
        translate([0, 0, base]) {
            cube(size=[AA_LENGTH + clearance, AA_WIDTH + clearance, .01], center=true);
        }
        translate([0, 0, DISPLAY_DEPTH]) {
            cube(size=[AA_LENGTH + opening, AA_WIDTH + opening, .01], center=true);
        }
    }
}

module holes_position() {
    // Holes
    for (pos = [
        [LENGTH / 2 - BORDER_HORIZONTAL / 2 + INSERT_DIAMETER / 2, WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER, 0],
        [LENGTH / 2 - BORDER_HORIZONTAL / 2 + INSERT_DIAMETER / 2, -(WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER), 0],
        [-(LENGTH / 2 - BORDER_HORIZONTAL / 2 + INSERT_DIAMETER / 2), WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER, 0],
        [-(LENGTH / 2 - BORDER_HORIZONTAL / 2 + INSERT_DIAMETER / 2), -(WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER), 0],

        [(LENGTH / 2 - BORDER_HORIZONTAL / 2 + INSERT_DIAMETER / 2), 0, 1],
        [-(LENGTH / 2 - BORDER_HORIZONTAL / 2 + INSERT_DIAMETER / 2), 0, 1],

        [0, WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER, 1],
        [LENGTH / 4, WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER, 1],
        [-LENGTH / 4, WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER, 1],

        [LENGTH / 4, -(WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER), 1],
        [-LENGTH / 4, -(WIDTH / 2 - BORDER_VERTICAL / 2 + INSERT_DIAMETER), 1],
    ]) {
        translate([pos[0], pos[1], 0]) {
            if ($children > 1) {
                children(pos[2]);
            } else {
                children(0);
            }
        }
    }
}

/**
 *  Create the front of the case 
 *
 *  Arguments:
 *  - length            Length of the front
 *  - width             Width of the front
 *  - outline_length    Screen outline length
 *  - outline_width     Screen outline width
 *  - aa_length         Screen active area length
 *  - aa_width          Screen active area width
 *  - front_thickness   The front thickness
 *  - display_depth     TODO
 *  - border_offset     Active area is not centered
 *  - screen_offset     Screen is not vertically centered
 *  - border_radius     Border radius of the corner
 */
module front(length, width, outline_length, outline_width, aa_length, aa_width, front_thickness, display_depth, border_offset, screen_offset, border_radius) {
    clearance = 0.6;

    assert(border_radius <= front_thickness);

    difference() {
        union() {
            difference() {
                cubeX([length, width, front_thickness * 2], radius=border_radius, center=true);
                translate([0, 0, - front_thickness / 2]) {
                    cube([length, width, front_thickness], center=true);
                }
            }
        }

        translate([0, screen_offset, 0]) {
            // Screen opening
            translate([0, - border_offset, front_thickness / 2 - display_depth]) {
                cube([outline_length + clearance, outline_width + clearance, front_thickness], center=true);

                // Display connector
                translate([0, -outline_width / 2, 0]) {
                    cube([40, 6, front_thickness], center=true);
                }
            }

            // Display opening
            translate([0, 0, front_thickness - display_depth]) {
                frame(aa_length, aa_width, front_thickness, display_depth);
            }
        }

        holes_position() {
            translate([0, 0, front_thickness - 1 - INSERT_HEIGHT]) {
                cylinder(d=INSERT_DIAMETER, h=INSERT_HEIGHT);
            }
        }
    }
}

module fixation(height=CASE_HEIGHT) {
    large_diameter = 6;
    small_diameter = 2.8;
    translate([0, 0, 0]) {
        cylinder(d=large_diameter, h=height);
    }
    translate([0, 3, height / 2]) {
        cube(size=[small_diameter, 7, height], center=true);
    }
    translate([0, 6, 0]) {
        cylinder(d=small_diameter, h=height);
    }
}

module case() {

    module fixation_position() {
        translate([0, WIDTH / 2 - 25, CASE_HEIGHT]) {
            for (i = [0 : $children - 1]) {
                children(i);
            }
        }
    }

    difference() {
        cubeX([LENGTH, WIDTH, CASE_HEIGHT * 2], radius=BORDER_RADIUS, center=true);
        translate([0, 0, - CASE_HEIGHT / 2]) {
            cube([LENGTH, WIDTH, CASE_HEIGHT], center=true);
        }

        translate([0, 0, CASE_HEIGHT / 2 - CASE_THICKNESS / 2 - .01]) {
            cube([LENGTH - CASE_WALL_THICKNESS * 2, WIDTH - CASE_WALL_THICKNESS * 2, CASE_HEIGHT - CASE_THICKNESS], center=true);
        }

        holes_position() {
            union() {
                translate([0, 0, -CASE_HEIGHT / 2]) {
                    cylinder(d=INSERT_THREAD_DIAMETER, h=CASE_HEIGHT * 2);
                }
                translate([0, 0, CASE_HEIGHT / 2]) {
                    cylinder(d=4.6, h=CASE_HEIGHT * 2);
                }
                translate([0, 0, -0.01]) {
                    cylinder(d=INSERT_DIAMETER * 1.3, h=2.25);
                }
            }
            cylinder(d=0, h=0); // Dummy one
        }

        fixation_position() {
            translate([0, 0, -CASE_THICKNESS * 2 - 1]) {
                fixation(); 
            }
        }

        for (pos = [
            [[LENGTH / 2 - CASE_WALL_THICKNESS / 2, WIDTH / 4 - 3, -0.001], 0],
            [[-LENGTH / 2 + CASE_WALL_THICKNESS / 2, WIDTH / 4 - 3, -0.001], 180],
            [[LENGTH / 2 - CASE_WALL_THICKNESS / 2, -WIDTH / 4 + 3, -0.001], 0],
            [[-LENGTH / 2 + CASE_WALL_THICKNESS / 2, -WIDTH / 4 + 3, -0.001], 180],
        ]) {
            translate(pos[0]) {
                scale([1.01, 1, 1.01]) {
                    rotate([0, 0, pos[1]]) {
                        gadget(GADGET_LENGTH, GADGET_WIDTH, GADGET_HEIGHT, BORDER_RADIUS, 0.3);
                    }
                }
            }
        }

        // Display connector
        translate([0, -OUTLINE_WIDTH / 2, 0]) {
            cube([40, 6, CASE_HEIGHT], center=true);
        }
    }

    holes_position() {
        cylinder(d=0, h=0); // Dummy one
        sphere(d=INSERT_DIAMETER - 0.1);
    }

    fixation_position() {
        difference() {
            translate([0, 2, -CASE_THICKNESS * 2]) {
                cylinder(d=15, h=CASE_THICKNESS);
            }
            translate([0, 0, -2.1]) {
                fixation();
            }
        }

        translate([0, 2, -CASE_THICKNESS * 2 - 4]) {
            difference() {
                cylinder(d=15, h=5);
                translate([0, 0, 1]) {
                    cylinder(d=12, h=5);
                }
            }
        }
    }

    if (DEBUG) {
        translate([-LENGTH / 2 + CASE_WALL_THICKNESS / 2, WIDTH / 4 - 3, -0.001]) {
            gadget_button(GADGET_LENGTH, GADGET_WIDTH, GADGET_HEIGHT, BORDER_RADIUS, DEBUG);
        }

        for (pos = [
            [[LENGTH / 2 - CASE_WALL_THICKNESS / 2, WIDTH / 4 - 3, -0.001], 0],
            [[LENGTH / 2 - CASE_WALL_THICKNESS / 2, -WIDTH / 4 + 3, -0.001], 0],
            [[-LENGTH / 2 + CASE_WALL_THICKNESS / 2, -WIDTH / 4 + 3, -0.001], 180],
        ]) {
            translate(pos[0]) {
                rotate([0, 0, pos[1]]) {
                    gadget(GADGET_LENGTH, GADGET_WIDTH, GADGET_HEIGHT, BORDER_RADIUS);
                }
            }
        }
    }
}

module demo() {
    front(LENGTH, WIDTH, OUTLINE_LENGTH, OUTLINE_WIDTH, AA_LENGTH, AA_WIDTH, FRONT_THICKNESS, DISPLAY_DEPTH, AA_BORDER_OFFSET, SCREEN_OFFSET, BORDER_RADIUS);
    %translate([0, SCREEN_OFFSET - AA_BORDER_OFFSET, FRONT_THICKNESS - DISPLAY_DEPTH]) {
        dummy_screen(OUTLINE_LENGTH, OUTLINE_WIDTH, OUTLINE_THICKNESS, AA_LENGTH, AA_WIDTH, AA_BORDER_OFFSET);
    }

    translate([0, 0, -5]) {
        rotate([0, 180, 0]) {
            case();
        }
    }
}

front(LENGTH, WIDTH, OUTLINE_LENGTH, OUTLINE_WIDTH, AA_LENGTH, AA_WIDTH, FRONT_THICKNESS, DISPLAY_DEPTH, AA_BORDER_OFFSET, SCREEN_OFFSET, BORDER_RADIUS);
demo();
//frame(AA_LENGTH, AA_WIDTH, FRONT_THICKNESS, DISPLAY_DEPTH);
case();
gadget(GADGET_LENGTH, GADGET_WIDTH, GADGET_HEIGHT, BORDER_RADIUS);
!gadget_button(GADGET_LENGTH, GADGET_WIDTH, GADGET_HEIGHT, BORDER_RADIUS, true);
button(GADGET_LENGTH / 5, GADGET_HEIGHT / 1.5, GADGET_WIDTH + 2, 0.25);

intersection() {
    case();
    translate([-LENGTH / 2, WIDTH / 4, 10]) {
        cube(size=[30, 55, 23], center=true);
    }
}
