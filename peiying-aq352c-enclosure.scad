// Enclosure for PEIYING PY-AQ352C 3.5" 30W Car Speaker
// Speaker specs: 3.5" (89mm), 37mm depth, 30W

/* [Speaker Parameters] */
speaker_diameter = 89;        // mm - 3.5 inch
speaker_depth = 37;           // mm - mounting depth
speaker_cutout = 75;          // mm - cutout diameter for cone
mounting_holes_pcd = 80;      // mm - mounting holes pitch circle diameter
mounting_hole_dia = 4;        // mm - mounting screw hole diameter
num_mounting_holes = 4;       // number of mounting holes

/* [Enclosure Parameters] */
wall_thickness = 4;           // mm - wall thickness
front_baffle_thickness = 6;   // mm - thicker front for mounting
internal_clearance = 10;      // mm - extra space behind speaker
enclosure_shape = "square";   // [round, square]

/* [Print Settings] */
part = "assembled";           // [assembled, body, baffle]
baffle_lip = 2;               // mm - lip for baffle to sit on
screw_hole_dia = 3;           // mm - M3 screws to join parts
num_corner_screws = 4;        // screws to hold baffle

/* [Port Parameters] */
add_port = true;              // add bass reflex port
port_diameter = 20;           // mm
port_length = 25;             // mm

/* [Cable Routing] */
cable_hole_dia = 10;          // mm - main cable entry hole
cable_slot_width = 6;         // mm - slot width for wire routing
cable_slot_depth = 3;         // mm - depth of routing channel

/* [Mounting Options] */
add_mounting_tabs = true;     // add external mounting tabs
mounting_tab_width = 15;      // mm
mounting_tab_hole = 5;        // mm - hole for M5 screw

/* [Calculated Values] */
internal_depth = speaker_depth + internal_clearance;
internal_diameter = speaker_diameter + 10;  // some clearance around speaker
external_diameter = internal_diameter + 2 * wall_thickness;
total_depth = internal_depth + front_baffle_thickness + wall_thickness;

// Calculate internal volume (approximate)
internal_volume_mm3 = (enclosure_shape == "round")
    ? PI * pow(internal_diameter/2, 2) * internal_depth
    : pow(internal_diameter, 2) * internal_depth;
internal_volume_liters = internal_volume_mm3 / 1000000;

echo(str("Internal volume: ", internal_volume_liters, " liters"));
echo(str("External dimensions: ", external_diameter, "mm dia x ", total_depth, "mm depth"));

$fn = 100;

module speaker_cutout() {
    // Main cone cutout
    cylinder(h = front_baffle_thickness + 1, d = speaker_cutout);

    // Mounting holes
    for (i = [0:num_mounting_holes-1]) {
        angle = i * 360 / num_mounting_holes;
        translate([
            cos(angle) * mounting_holes_pcd / 2,
            sin(angle) * mounting_holes_pcd / 2,
            0
        ])
        cylinder(h = front_baffle_thickness + 1, d = mounting_hole_dia);
    }
}

module round_enclosure() {
    difference() {
        union() {
            // Main body
            cylinder(h = total_depth, d = external_diameter);

            // Mounting tabs
            if (add_mounting_tabs) {
                for (angle = [0, 180]) {
                    rotate([0, 0, angle])
                    translate([external_diameter/2 + mounting_tab_width/2 - 5, 0, 0])
                    hull() {
                        cylinder(h = wall_thickness, d = mounting_tab_width);
                        translate([-mounting_tab_width/2, 0, 0])
                        cylinder(h = wall_thickness, d = mounting_tab_width);
                    }
                }
            }
        }

        // Internal cavity
        translate([0, 0, wall_thickness])
        cylinder(h = internal_depth + 1, d = internal_diameter);

        // Speaker cutout in front baffle
        translate([0, 0, total_depth - front_baffle_thickness])
        speaker_cutout();

        // Port hole
        if (add_port) {
            translate([internal_diameter/2 - port_diameter/2 - 5, 0, wall_thickness])
            rotate([0, 0, 0])
            cylinder(h = wall_thickness + 1, d = port_diameter);
        }

        // Mounting tab holes
        if (add_mounting_tabs) {
            for (angle = [0, 180]) {
                rotate([0, 0, angle])
                translate([external_diameter/2 + mounting_tab_width/2, 0, -0.5])
                cylinder(h = wall_thickness + 1, d = mounting_tab_hole);
            }
        }
    }

    // Port tube (if enabled)
    if (add_port) {
        translate([internal_diameter/2 - port_diameter/2 - 5, 0, wall_thickness])
        difference() {
            cylinder(h = port_length, d = port_diameter + 3);
            translate([0, 0, -0.5])
            cylinder(h = port_length + 1, d = port_diameter);
        }
    }
}

module square_enclosure() {
    box_size = internal_diameter + 2 * wall_thickness;
    corner_radius = 5;
    body_depth = total_depth - front_baffle_thickness;

    module rounded_box(size, height, radius) {
        hull() {
            for (x = [-1, 1], y = [-1, 1]) {
                translate([x * (size/2 - radius), y * (size/2 - radius), 0])
                cylinder(h = height, r = radius);
            }
        }
    }

    // Position bosses in corners, connecting wall to wall
    screw_boss_dia = 10;  // larger boss for strength
    screw_boss_height = body_depth - baffle_lip;
    boss_offset = internal_diameter/2 - screw_boss_dia/2 + 2;  // inside corners

    module corner_screw_positions() {
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * boss_offset, y * boss_offset, 0])
            children();
        }
    }

    module body() {
        union() {
            difference() {
                union() {
                    // Main body
                    rounded_box(box_size, body_depth, corner_radius);

                    // Mounting tabs
                    if (add_mounting_tabs) {
                        for (angle = [0, 180]) {
                            rotate([0, 0, angle])
                            translate([box_size/2 + mounting_tab_width/2 - 5, 0, 0])
                            hull() {
                                cylinder(h = wall_thickness, d = mounting_tab_width);
                                translate([-mounting_tab_width/2, 0, 0])
                                cylinder(h = wall_thickness, d = mounting_tab_width);
                            }
                        }
                    }
                }

                // Internal cavity (leave lip for baffle)
                translate([0, 0, wall_thickness])
                rounded_box(internal_diameter, body_depth, corner_radius - wall_thickness);

                // Baffle recess
                translate([0, 0, body_depth - baffle_lip])
                rounded_box(internal_diameter + 0.4, baffle_lip + 1, corner_radius - wall_thickness);

                // Mounting tab holes
                if (add_mounting_tabs) {
                    for (angle = [0, 180]) {
                        rotate([0, 0, angle])
                        translate([box_size/2 + mounting_tab_width/2, 0, -0.5])
                        cylinder(h = wall_thickness + 1, d = mounting_tab_hole);
                    }
                }

                // Cable entry hole
                translate([0, -box_size/2 + wall_thickness/2, wall_thickness + 12])
                rotate([90, 0, 0])
                cylinder(h = wall_thickness + 1, d = cable_hole_dia, center = true);

                // Cable routing channel on bottom interior
                translate([-cable_slot_width/2, -internal_diameter/2 + 2, wall_thickness - cable_slot_depth])
                cube([cable_slot_width, internal_diameter/2, cable_slot_depth + 0.1]);

                // Bass port hole through side wall
                if (add_port) {
                    translate([box_size/2 - wall_thickness/2, 0, wall_thickness + port_diameter/2 + 5])
                    rotate([0, 90, 0])
                    cylinder(h = wall_thickness + 1, d = port_diameter, center = true);
                }
            }  // end main difference

            // Screw bosses - added after cavity cut so they remain solid
            difference() {
                corner_screw_positions()
                    cylinder(h = screw_boss_height, d = screw_boss_dia);
                // Pilot holes for M3 self-tapping
                corner_screw_positions()
                    translate([0, 0, -0.5])
                    cylinder(h = screw_boss_height + 1, d = screw_hole_dia - 0.5);
            }

            // Bass port tube (inside enclosure, extending inward from side)
            if (add_port) {
                translate([box_size/2 - wall_thickness, 0, wall_thickness + port_diameter/2 + 5])
                rotate([0, -90, 0])
                difference() {
                    cylinder(h = port_length, d = port_diameter + 4);
                    translate([0, 0, -0.5])
                    cylinder(h = port_length + 1, d = port_diameter);
                }
            }
        }  // end union
    }

    module baffle() {
        baffle_size = internal_diameter + 0.2;  // slight clearance
        difference() {
            rounded_box(baffle_size, front_baffle_thickness, corner_radius - wall_thickness - 0.1);

            // Speaker cutout
            translate([0, 0, -0.5])
            speaker_cutout();

            // Screw holes (countersunk)
            corner_screw_positions() {
                cylinder(h = front_baffle_thickness + 1, d = screw_hole_dia);
                translate([0, 0, front_baffle_thickness - 2])
                cylinder(h = 3, d1 = screw_hole_dia, d2 = screw_hole_dia * 2);
            }
        }
    }

    if (part == "body") {
        body();
    } else if (part == "baffle") {
        baffle();
    } else {
        // Assembled view
        body();
        translate([0, 0, body_depth - baffle_lip])
        color("SteelBlue") baffle();
    }
}

// Render the enclosure
if (enclosure_shape == "round") {
    round_enclosure();
} else {
    square_enclosure();
}

echo(str("Part: ", part));
echo(str("Box size: ", internal_diameter + 2 * wall_thickness, "mm x ", internal_diameter + 2 * wall_thickness, "mm x ", total_depth, "mm"));
