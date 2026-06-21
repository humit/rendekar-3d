# rendekar-3d build workflow

## 1. Create an artifact ID

```bash
make artifact
```

Example output:

```text
artifact_id=DS-V3B-0001
physical_mark=D3B001
```

## 2. Generate an underside-engraved model

Generate SCAD only:

```bash
make mark ARTIFACT=DS-V3B-0001 MARK=D3B001
```

Generate marked STL using OpenSCAD:

```bash
make mark-render ARTIFACT=DS-V3B-0001 MARK=D3B001
```

## 3. Slice the marked STL

Open the generated marked STL in OrcaSlicer or Bambu Studio.
Later this step can be automated through slicer CLI.

## 4. Print and QA

After printing:

```bash
make finish-pass ARTIFACT=DS-V3B-0001 NOTES="Serial readable; top surface acceptable."
```

or:

```bash
make finish-revise ARTIFACT=DS-V3B-0001 NOTES="Serial too shallow; increase depth to 0.5mm."
```
