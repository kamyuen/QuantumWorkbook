# QuantumWorkbook

A compilation of the Mathematica(R) Notebook files that have been used to generate the demonstrations in the Quantum Workbook.

## Installation

Copy the following code, and just evaluate it in your Mathematica(R) Notebook:

```Mathematica
Module[
  { ps },
  ps = PacletSiteRegister[
    "https://github.com/quantum-mob/PacletServer/raw/main",
    "Quantum Mob Paclet Server"
   ];
  PacletSiteUpdate[ps];
  PacletInstall["WorkbookTools"];
  PacletInstall["QuantumWorkbook"]
 ]
```

Note that along with QuantumWorkbook, it also installs the unitility package WorkbookTools.


## Update

At the momoment, the contents of this package are being actively generated and modified, and you may want to check for updates from time to time:

```Mathematica
QuantumWorkbookCheckUpdate[]
```

In case there is an update, you can install it by using the following function:

```Mathematica
QuantumWorkbookUpdate[]
```

## How to use

Once QuantumWorkbook is installed, put `QuantumWorkbook` in the search field of the Wolfram Documentation Center (Mathematica Help window). You will see the table of contents of the workbook.

## Uninstall

If you do not want to use QuantumWorkbook any longer, just evaluate the following code:

```Mathematica
PacletUninstall["WorkbookTools"];
PacletUninstall["QuantumWorkbook"]
```
