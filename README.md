![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/DebugLogAnalyzer)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/DebugLogAnalyzer/total)

# DebugLogAnalyzer
based on original work by [Josh Fletcher](https://kb.4d.com/assetid=75926) (2009)

## Features

only the classic "human readable" debug log file can be analysed.

there are evidently 2 versions of this format:

### header

* v1
```
-- Startup on Tuesday, April 01, 2025 06:27:12 (50712416) --
```

* v2
```
-- Startup on: Tuesday, April 01, 2025 06:27:12 PM --
```

### cmd

* v1

```
1 p=1 puid=1 	(1) cmd: SET TIMER.
```

* v2

```
1	2025-04-01T18:27:13.284 p=1 puid=1	(1)  cmd: SET TIMER
2	2025-04-01T18:27:13.284 p=1 puid=1	(1)  end_cmd: SET TIMER. < ms
```

### meth, mbr

* v1

```
1571 p=6 puid=8 meth: DBL_P_Import
1571 p=6 puid=8 end_meth: DBL_P_Import
```

* v2

```
19	2025-04-01T18:27:13.285 p=6 puid=8	(2)  meth: DBL_P_Import
50	2025-04-01T18:27:13.286 p=6 puid=8	(2)  end_meth: DBL_P_Import. < ms
```

### form, obj

* v1

```
31 p=6 puid=8 form: IAS_CustomAlert; event: OnLoad
33 p=6 puid=8 end_form
```

* v2

```
11	2025-04-01T18:27:13.281 p=6 puid=10	(0)  form: IAS_CustomAlert during OnLoad
64	2025-04-01T18:27:13.286 p=6 puid=10	(0)  end_form: IAS_CustomAlert during OnLoad. 2 ms
``` 
