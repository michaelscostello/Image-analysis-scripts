// ============================================================
//  CILIARY BASE DISTANCE ANALYZER  v2
//  Fiji / ImageJ Macro  |  IJ1 Macro Language
// ============================================================
//
//  WHAT IT DOES
//    1. Reads the Straight Line ROI you drew over the ciliary base
//    2. Preprocesses a duplicate (background subtract, fill holes, watershed)
//    3. Locates bacterial centroids via Analyze Particles
//    4. Computes the shortest distance from each centroid to the
//       ciliary-base SEGMENT (finite, not the infinite line)
//    5. Saves a CSV file alongside the image
//
//  HOW TO RUN
//    1. Open your fluorescence micrograph in Fiji
//    2. If multichannel: activate the bacteria channel first
//       (Image > Color > Split Channels, or use the channel slider)
//    3. Select the Straight Line tool (keyboard shortcut: 5)
//    4. Draw a line along the entire ciliary base
//    5. Plugins > Macros > Run...  →  select this .ijm file
//    6. Results appear in the Log window; CSV saved next to the image
//
//  DISTANCE GEOMETRY
//    Given segment endpoints P1=(x1,y1) and P2=(x2,y2) and
//    a bacterial centroid C=(cx,cy):
//
//      t* = dot(C - P1, P2 - P1) / |P2 - P1|²   (unclamped projection)
//      t  = clamp(t*, 0, 1)                        (enforce finite segment)
//      nearest point N = P1 + t*(P2 - P1)
//      distance = |C - N|
//
//    t < 0  → nearest point is P1 (bacterium is "behind" the start)
//    t > 1  → nearest point is P2 (bacterium is "past" the end)
//    0≤t≤1  → perpendicular foot lies on the segment
//
//  OUTPUT COLUMNS
//    BacteriumID       – sequential index (1-based)
//    CentroidX / Y     – centroid coordinates in calibrated units
//    Distance          – shortest distance to segment (same units)
//    ProjectionT       – clamped t value (0 or 1 means an endpoint was used)
//
//  VALIDATION
//    Run  python validate_geometry.py  (in the Pipeline folder) to verify
//    the distance formula against known exact answers before use.
// ============================================================


// ======== USER SETTINGS — adjust these for each experiment ========

// --- Bacterial detection ---
// MANUAL_THRESHOLD = true uses the fixed THRESHOLD_LOW value (matches original
// Centroid.ijm which used 86). Set to false to let Fiji pick automatically.
MANUAL_THRESHOLD = true;
THRESHOLD_LOW    = 86;       // used only when MANUAL_THRESHOLD = true
THRESHOLD_HIGH   = 255;      // used only when MANUAL_THRESHOLD = true
THRESHOLD_METHOD = "Otsu";   // used only when MANUAL_THRESHOLD = false
                             // Options: "Otsu" "Default" "Triangle" "Li" "Yen"

// --- Background subtraction (rolling-ball) ---
// Set ROLLING_BALL_RADIUS = 0 to skip background subtraction entirely.
ROLLING_BALL_RADIUS = 50;    // pixels; 50 matches original Centroid.ijm

// --- Particle (bacterium) size filter ---
// 0-Infinity = no filter (matches original Centroid.ijm which had no size limit).
// Raise MIN_AREA only to exclude obvious noise after inspecting results.
MIN_AREA = 0;
MAX_AREA = 999999;

// Set true to discard bacteria whose mask touches the image border.
// Original Centroid.ijm did NOT exclude edge particles — keep false to match.
EXCLUDE_EDGES = false;

// ==================================================================


// --- 1. Require a Straight Line ROI --------------------------------
if (selectionType() != 5)
    exit("ERROR: No straight line found.\n\n" +
         "Use the Straight Line tool (press '5'), draw a line along\n" +
         "the ciliary base, then re-run this macro.");

getLine(lx1_px, ly1_px, lx2_px, ly2_px, lw);  // always returns pixels


// --- 2. Build output path ------------------------------------------
title  = getTitle();
dir    = getDirectory("image");
if (dir == "") dir = getDirectory("home");   // fallback if image not yet saved

dotIdx = lastIndexOf(title, ".");
if (dotIdx > 0)
    base = substring(title, 0, dotIdx);
else
    base = title;

// Z-plane: use the hyperstack z-position if available, else slice number.
// This records which focal plane was analyzed when re-running on the same image.
if (isHyperstack()) {
    Stack.getPosition(stackC, zPos, stackF);
} else {
    zPos = getSliceNumber();
}
zTag = "Z" + pad2(zPos);

// Timestamp (YYYYMMDD_HHmmss) makes the filename unique even when the same
// image and Z plane are analyzed multiple times.
getDateAndTime(yr, mo, dow, dom, hr, mn, sc, ms);
mo = mo + 1;   // getDateAndTime months are 0-based (Jan = 0)
tsTag = "" + yr + pad2(mo) + pad2(dom) + "_" + pad2(hr) + pad2(mn) + pad2(sc);

// Final filename:  imagename_Z02_20260306_143022_ciliary_distances.csv
outPath = dir + base + "_" + zTag + "_" + tsTag + "_ciliary_distances.csv";


// --- 3. Pixel-to-unit calibration ----------------------------------
// getLine() always returns pixel coordinates.
// Analyze Particles returns centroids in calibrated units (or pixels
// if the image is uncalibrated).  Convert line endpoints to match,
// assuming square pixels (standard for fluorescence microscopy).
getPixelSize(unit, pw, ph);
if (unit == "pixels" || unit == "") unit = "px";

lx1 = lx1_px * pw;
ly1 = ly1_px * ph;
lx2 = lx2_px * pw;
ly2 = ly2_px * ph;

// Segment vector and squared length (precomputed once for speed)
sdx      = lx2 - lx1;
sdy      = ly2 - ly1;
segLenSq = sdx*sdx + sdy*sdy;
segLen   = sqrt(segLenSq);


// --- 4. Preprocess and detect bacteria on a duplicate image --------
setBatchMode(true);   // suppress intermediate windows

run("Duplicate...", "title=_bac_mask_");
run("8-bit");

// Background subtraction — matches Centroid.ijm (rolling=50 sliding)
if (ROLLING_BALL_RADIUS > 0)
    run("Subtract Background...", "rolling=" + ROLLING_BALL_RADIUS + " sliding");

// Thresholding
if (MANUAL_THRESHOLD) {
    setThreshold(THRESHOLD_LOW, THRESHOLD_HIGH);
} else {
    setAutoThreshold(THRESHOLD_METHOD + " dark no-reset");
}

setOption("BlackBackground", true);
run("Convert to Mask");

// Morphological cleanup — matches Centroid.ijm
run("Fill Holes");
run("Watershed");

// Measure centroids (calibrated units)
if (EXCLUDE_EDGES)
    edgeFlag = "exclude ";
else
    edgeFlag = "";
run("Set Measurements...",
    "centroid display redirect=None decimal=6");
run("Analyze Particles...",
    "size=" + MIN_AREA + "-" + MAX_AREA + " " +
    "circularity=0.00-1.00 " + edgeFlag +
    "display clear show=Nothing");

close("_bac_mask_");
setBatchMode(false);

selectWindow(title);   // return focus to original image

n = nResults();
if (n == 0)
    exit("No bacteria detected.\n\n" +
         "Try:\n" +
         "  - Enable MANUAL_THRESHOLD and lower THRESHOLD_LOW\n" +
         "  - Change THRESHOLD_METHOD (Otsu, Triangle, Li, Yen)\n" +
         "  - Widen MIN_AREA / MAX_AREA\n" +
         "  - Set ROLLING_BALL_RADIUS = 0 to skip background subtraction");


// --- 5. Compute point-to-segment distances and write CSV -----------
f = File.open(outPath);
print(f, "BacteriumID," +
         "CentroidX_" + unit + "," +
         "CentroidY_" + unit + "," +
         "Distance_"  + unit + "," +
         "ProjectionT");

for (i = 0; i < n; i++) {
    cx = getResult("X", i);
    cy = getResult("Y", i);

    if (segLenSq == 0) {
        // Degenerate case: user clicked instead of drawing a line
        dist = sqrt((cx - lx1)*(cx - lx1) + (cy - ly1)*(cy - ly1));
        t    = 0;
    } else {
        // Project centroid onto segment, clamp to [0, 1]
        t  = ((cx - lx1)*sdx + (cy - ly1)*sdy) / segLenSq;
        t  = maxOf(0, minOf(1, t));

        // Nearest point on the finite segment
        nx = lx1 + t * sdx;
        ny = ly1 + t * sdy;

        dist = sqrt((cx - nx)*(cx - nx) + (cy - ny)*(cy - ny));
    }

    print(f, (i+1) + "," +
             d2s(cx,   6) + "," +
             d2s(cy,   6) + "," +
             d2s(dist, 6) + "," +
             d2s(t,    4));
}

File.close(f);


// --- 6. Print summary to Log window --------------------------------
if (MANUAL_THRESHOLD)
    threshDesc = "manual (" + THRESHOLD_LOW + "-" + THRESHOLD_HIGH + ")";
else
    threshDesc = "auto: " + THRESHOLD_METHOD;

print("\\Clear");
print("=== Ciliary Base Distance Analysis ===");
print("Image      : " + title + "  [" + zTag + "]");
print("Line       : (" + d2s(lx1,3) + ", " + d2s(ly1,3) + ")" +
              " -> (" + d2s(lx2,3) + ", " + d2s(ly2,3) + ")  [" + unit + "]");
print("Seg length : " + d2s(segLen, 3) + " " + unit);
print("Threshold  : " + threshDesc);
if (ROLLING_BALL_RADIUS == 0)
    print("Rolling r  : 0 px (disabled)");
else
    print("Rolling r  : " + ROLLING_BALL_RADIUS + " px");
print("Bacteria   : " + n);
print("CSV        : " + outPath);
print("");
print("Tips:");
print("  - To re-run: redraw the line and run macro again.");
print("  - ProjectionT = 0 or 1 means the nearest point was an endpoint,");
print("    not a perpendicular foot — inspect those bacteria visually.");
print("  - Run  python validate_geometry.py  to verify distance math.");


// ======== HELPER FUNCTIONS ========

// Zero-pad a single integer to 2 digits ("3" -> "03", "12" -> "12").
function pad2(n) {
    if (n < 10) return "0" + n;
    return "" + n;
}
