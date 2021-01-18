
module gadget(length, width, height, border_radius, clearance=0) {
    height = height + clearance;
    length = length + clearance;
    thickness = width / 3;
    translate([0, 0, height / 2]) {
        cube(size=[width, length, height], center=true);
        cube(size=[thickness + clearance, length + 5, height], center=true);
    }
    translate([-thickness, 0, height + border_radius / 2 - 0.01]) {
        cube(size=[thickness, length, border_radius], center=true);
    }
}

module button(length, height, depth, clearance=0) {
    module oblong(width, height, depth) {
        hull() {
            translate([0, width / 2, 0]) {
                cylinder(d=height - clearance, h=depth);
            }
            translate([0, -width / 2, 0]) {
                cylinder(d=height - clearance, h=depth);
            }
        }
    }

    oblong(length, height, depth);

    base_thickness = 1;
    translate([0, 0, -base_thickness / 2]) {
        oblong(length, height + 1, base_thickness);
    }
}

module gadget_button(length, width, height, border_radius, debug=false) {

    module switch() {
        length = 12.8;
        thickness = 5.8;
        height = 6.5;
        diameter = 2.2;
        difference() {
            cube(size=[length, thickness, height], center=true);
            rotate([90, 0, 0]) {
                for (pos = [
                    [-length / 2 + 3.15, -height / 2 + 1.5, -thickness],
                    [length / 2 - 3.15, -height / 2 + 1.5, -thickness],
                ]) {
                    translate(pos) {
                        cylinder(d=diameter, h=thickness * 2);
                    }
                }
            }
        }
    }

    module button_position() {
        for (i = [0 : $children - 1]) {
            for (pos = [
                [-(width + 2) / 2, -length / 4.5, height / 2],
                [-(width + 2) / 2, length / 4.5, height / 2],
            ]) {
                translate(pos) {
                    rotate([0, 90, 0]) {
                        children(i);
                    }
                }
            }
        }
    }

    rotate([0, 0, 180]) {
        difference() {
            gadget(length, width, height, border_radius);
            button_position() {
                button(length / 5, height / 1.5, width + 2);
            }
        }

        if (debug) {
            %button_position() {
                button(length / 5, height / 1.5, width + 2);

                translate([0, 0, -4]) {
                    rotate([0, 0, 90]) {
                        switch();
                    }
                }
            }
        }
    }

    // Create base
    base_thickness = 1.5;
    base_width = 10.5;
    translate([width / 2 + base_width / 2, 0, height + border_radius / 2 + base_thickness / 2 - 0.01]) {
        cube(size=[base_width, length, base_thickness], center=true);
        translate([base_width / 2 - 0.5, 0, -1]) {
            cube(size=[1, length, base_thickness], center=true);
        }
    }
}
