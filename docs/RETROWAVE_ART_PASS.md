# Mansion retro-wave foundation — 10 October 2026

Whole-map art pass based on the supplied comic mansion, repeating tunnel frames, cyan/magenta corridor and control-room references. Preserve the authored map, 43 spaces, 41 doors, sockets, collision and player behavior. Individual rooms will be refined next.

Shared runtime material treatment: violet/indigo surfaces, bold dark structure, cyan/magenta accents, animated floor/wall grids and restrained print grain. Existing material resources and pending user edits remain intact beneath the override. `retrowave_style.gd` maps shared materials and can later accept room-specific palettes. Unlit matte colour: reflections, bloom and fog remain off; lighting deferred. Modern bars and flush strips replace vintage fixtures. Existing artwork panels remain artwork.

No new enemies, UI, furniture layouts or room connections are inferred from the reference images. The separate C:\GitHub\subway sandbox is unchanged. This pass does not claim to recreate every detailed reference prop.

Source scripts/resources were backed up before editing in the chat workspace work/mansion-retrowave/before.zip. Existing local material/long-gallery edits were preserved. Remove the STYLE.apply calls to bypass the shared material treatment; fixture shape changes are separate.

## Subway graphics parity
The generic first-pass shader is replaced by an exact copy of the approved standalone Subway shader and benchmark texture. Same small ceramic tile/grout, face-value shading, artwork detail, filtered halftone, animated grid (speed 0.070, opacity 0.96, width 0.011), matte floor and cyan/magenta trim palette. Surface roles are assigned from mesh bounds so furniture and ceilings avoid the grid. Local copies keep both projects independent. No room layout or collision changes.
