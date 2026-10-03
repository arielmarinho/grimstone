#!/usr/bin/env python3
"""Process user-provided 4x7 character reference sheets into Godot 4-frame PNGs.

Requires FFmpeg. Original references are never modified. Missing poses are mapped
from the closest supplied source row; see docs/pipeline_paladin.md.
Run with no arguments for all referenced classes, or pass paladin, mage, druid.
"""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUT_ROOT = ROOT / "game/assets/sprites/animation/player"
FFMPEG = shutil.which("ffmpeg")
XS = [244, 422, 600, 778]
YS = [86, 220, 360, 500, 650, 790, 936]
SOURCES = {
    "paladin": "spritesheet_player_paladin_reference.png",
    "mage": "spritesheet_player_mage.png",
    "druid": "spritesheet_player_druid.png",
}
POSES = {
    ("idle", "up"): [(0, i) for i in range(4)],
    ("idle", "down"): [(1, i) for i in range(4)],
    ("idle", "side"): [(2, i) for i in range(4)],
    # Only side has alternate stride-ish source poses; front/back use the nearest
    # existing poses until dedicated walk rows are supplied or drawn.
    ("walk", "up"): [(0, i) for i in range(4)],
    ("walk", "down"): [(1, i) for i in range(4)],
    ("walk", "side"): [(2, 0), (3, 1), (2, 2), (3, 3)],
    ("attack", "up"): [(4, i) for i in range(4)],
    ("attack", "down"): [(4, i) for i in range(4)],
    ("attack", "side"): [(4, i) for i in range(4)],
    ("hurt", "down"): [(5, i) for i in range(4)],
    ("death", "down"): [(6, i) for i in range(4)],
}

# A referência do Druida mistura perfis com orientações opostas nas linhas 3 e
# 4. Para caminhar, use apenas os quatro quadros da linha 3 e deixe o flip do
# jogador resolver esquerda/direita. Isso evita inversões a cada quadro.
CLASS_POSE_OVERRIDES = {
    # O último perfil da linha muda para o sentido contrário; repita o segundo
    # perfil para fechar o ciclo sem um frame que olhe na direção errada.
    # A pose frontal troca o cajado de lado entre células e não é uma caminhada
    # consistente; segure o primeiro quadro até haver arte própria de passos.
    "druid": {
        ("walk", "side"): [(2, 0), (2, 1), (2, 2), (2, 1)],
        ("walk", "down"): [(1, 0)] * 4,
    },
}

# Alinha o corpo e os pés do ciclo lateral da Druida. A composição gerada da
# referência desloca os quadros 1 e 3 dentro de suas células; sem esta correção
# o sprite salta horizontalmente durante a caminhada.
CELL_CENTER_OVERRIDES = {
    ("druid", "walk", "side", 2, 0): (279, 360),
    ("druid", "walk", "side", 2, 2): (573, 358),
}
for direction, row, centers in (
    ("up", 0, [289, 436, 592, 742]),
    ("down", 1, [280, 432, 601, 773]),
):
    for col, center_x in enumerate(centers):
        CELL_CENTER_OVERRIDES[("druid", "walk", direction, row, col)] = (center_x, YS[row])


def process_class(class_name: str) -> None:
    if class_name not in SOURCES:
        raise SystemExit(f"Unknown class {class_name!r}; choose from {', '.join(SOURCES)}")
    source = ROOT / "references" / SOURCES[class_name]
    if not source.is_file():
        raise SystemExit(f"Reference image not found: {source}")
    if not FFMPEG:
        raise SystemExit("FFmpeg is required to process the character references.")
    out_root = OUT_ROOT / class_name
    out_root.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=f"grimstone-{class_name}-") as tmp_name:
        tmp = Path(tmp_name)
        cell_cache = {}
        class_poses = dict(POSES)
        class_poses.update(CLASS_POSE_OVERRIDES.get(class_name, {}))
        for (action, direction), poses in class_poses.items():
            frame_paths = []
            for row, col in poses:
                center_x, center_y = CELL_CENTER_OVERRIDES.get(
                    (class_name, action, direction, row, col), (XS[col], YS[row]))
                cache_key = (row, col, center_x, center_y)
                if cache_key not in cell_cache:
                    x, y = center_x - 64, center_y - 68
                    cell = tmp / f"r{row}_c{col}_x{center_x}_y{center_y}.png"
                    vf = (f"crop=128:136:{x}:{y},"
                          "colorkey=0x10131e:0.075:0.03,format=rgba,"
                          "scale=-1:76:flags=neighbor,"
                          "pad=96:96:(ow-iw)/2:20:color=black@0,format=rgba")
                    subprocess.run([
                        FFMPEG, "-loglevel", "error", "-y", "-i", str(source),
                        "-vf", vf, "-frames:v", "1", "-update", "1", str(cell),
                    ], check=True)
                    cell_cache[cache_key] = cell
                frame_paths.append(cell_cache[cache_key])
            target_dir = out_root / action / direction
            target_dir.mkdir(parents=True, exist_ok=True)
            target = target_dir / f"{class_name}_{action}_{direction}.png"
            cmd = [FFMPEG, "-loglevel", "error", "-y"]
            for frame_path in frame_paths:
                cmd += ["-i", str(frame_path)]
            inputs = "".join(f"[{i}:v]" for i in range(4))
            cmd += ["-filter_complex", f"{inputs}hstack=inputs=4,format=rgba[out]",
                    "-map", "[out]", "-frames:v", "1", "-update", "1", str(target)]
            subprocess.run(cmd, check=True)
            print(target.relative_to(ROOT))


def main(args=None):
    requested = list(sys.argv[1:] if args is None else args)
    for class_name in requested or SOURCES.keys():
        process_class(class_name)


if __name__ == "__main__":
    main()
