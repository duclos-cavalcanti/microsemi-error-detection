<h1 align="center">Microsemi SmartFusion2 Error Detection</h1>
<p align="center">
  Installation, Setup, Development and Programming Device
</p>
<br>

# 1. Instructions
## 1.1. Setup
<details closed>
<summary>
1. Open Libero
</summary>
<p>
</p>
</details>
<details closed>
<summary>
1. Create Project
</summary>
<p>

- Click **Project => New Project**
    - Language: VHDL
    - Family: SmartFusion2
    - Part: M2S010-TQ144

</p>
</details>

<details closed>
<summary>
2. Configure System
</summary>
<p>

- Click **Configure MSS**
    - `Clock - MSS_CCC`
        - *Configure*
        - *CLK_BASE=100MHZ*
        - *M3_CLK=100MHZ*
    - `RESET Controller`
        - *Configure*
        - `Enable "MSS_RESET_N_F2M"`
    - `FIC_0 and FIC_1`
        - *Disable*
    - `SPI_0 and SPI_1`
        - *Disable*
    - `I2C_0 and I2C_1`
        - *Disable*
    - `MMUART_0`
        - *Configure*
        - Full Duplex, Aynchronous, Fabric Connection
    - `MMUART_1`
        - *Disable*
    - `USB`
        - *Disable*
    - `Ethernet`
        - *Disable*
    - `Watchdog`
        - *Disable*
    - `DMA`
        - *Disable*
    - `ENVM`
        - *Configure*
        - Give path to *.hex* file
    - `GPIO`
        - *Configure*
        - GPIOs 0 to 7, output, connectivity to FABRIC_A
        - GPIOs 8 to 9, input, connectivity to FABRIC_A
- Click **Generate Component** *(yellow barrel icon)*
- instantiate MSS component in the design
- arrange necessary pins (top levels, etc)

</p>
</details>

<details closed>
<summary>
4. Add Modules from Catalog
</summary>
<p>

- Chip Oscillator
    - select `On-Chip 25-50 Mhz`
    - select `drives fabric logic`
- Clock Conditioning Circuitry
    - change "Dedicated Input Pad 0" to "Oscillators => On-Chip 25-50 Mhz"
- Sysreset
- AND2
- Arrange project
    - image is in `assets/project.png`: [project](assets/project.pdf)
- Check if the project is correctly set as root
- Click **Build Hierarchy** *(Design hierarchy Panel)*

</p>
</details>

## 1.2. Development
### 1.2.1 Hardware

<details closed>
<summary>
1. HDL Files
</summary>
<p>

- Click **File => New => HDL**
- Edit file
- Click **Build Hierarchy** *(Design hierarchy Panel)*
- Drag the now created module to the smart design
- Arrange pins
- Click **Generate Component** *(yellow barrel icon)*
- Click **Build Hierarchy** *(Design hierarchy Panel)*

</p>
</details>

### 1.2.2 Software
<details closed>
<summary>
0. Setup
</summary>
<p>

- Assuming the firmware step has been performed from **Workflow**
- Create Project
    - Click **File => New C/C++ Project**
    - C Managed Build
    - Toolchain: ARM Cross GCC
- Import Firmware
    - Right Click **'Project Name'** => Import
    - File System => Choose exported firmware directory from Libero
    - Select all folders
- Debug Configuration
    - Right Click **'Project Name'** => Properties
    - C/C++ Build => Settings => GNU ARM Cross C Linker => Misc.
        - activate 'use newlib-nano (--specs=nano.specs)'
    - C/C++ Build => Settings => GNU ARM Cross C Compiler => Misc.
        - write into textbox '--specs=cmsis.specs'
    - C/C++ Build => Settings => GNU ARM Cross C Linker => General.
        - Add Script Files
        - Select in workspace 'CMSIS->startup_gcc/debug-in-microsemi-smartfusion2-esram.ld'
    - Apply and Close
    - Project => Build all
    - Debug => Debug Configurations
        - Create new Launch Configuration (Right Click GDB OpenOCD Debugging)
        - Click on Debugger panel
        - Write in "Config Options": `--command "set DEVICE M2S010" --file board/microsemi-cortex-m3.cfg`
        - Click on Startup panel
        - Deactivate "Pre-Run/Restart reset"
- Release Configuration
    - Right Click **'Project Name'** => Build Configuration => Set Active => Release
    - Repeat Debug Configurations
        - Small adjustment:
            - Linker Sript Files:
            - Select in workspace 'production-smartfusion2-execute-in-place.ld'
    - Apply and Close
    - Project => Build all

</p>
</details>
<details closed>
<summary>
1. C/C++ Files
</summary>
<p>

- Click **File => New => Source File**
- Edit
- Click **Project => Build All**
- After every build, remember to `UPDATE eNVM Memory Content` on the Libero side!

</p>
</details>

### 1.2.3 Workflow
<details closed> <summary> 1. Simulate </summary><p>
</p>
</details>

<details closed> <summary> 2. Synthesize </summary><p>
</p>
</details>

<details closed> <summary> 3. Constraints </summary><p>

- Select I/O Panels
- Edit with I/O Editor
- select the correct pin numbers for the LEDs
</p>
</details>

<details closed> <summary> 4. Place and Route </summary><p>
</p>
</details>

<details closed> <summary> 5. Update eNVM MC </summary><p>
</p>
</details>

<details closed> <summary> 6. Generate FPGA Array Data </summary><p>
</p>
</details>

<details closed> <summary> 7. Generate Bitstream </summary><p>
</p>
</details>

<details closed> <summary> 7. Program Device </summary><p>
</p>
</details>

<details closed> <summary> 8. Firmware </summary><p>

- Click on **Configure Firmware Cores**
- Select all cores and click on the download symbol
- Finally click on **Export Firmware** (Needed for SoftConsole)
</p>
</details>

## 1.3 System
<details closed>
<summary>
1. Virtualbox
</summary>
<p>

1. Install Ubuntu on vbox
2. Add Guest additions to the virtual image
3. Enable Shared Folder
4. Enable Shared Clipboard
5. Add User in guest machine to the vboxsf group
6. Add User in host machine to vboxusers group and install `virtualbox-ext-oracle` from the AuR
7. Install libero software on ubuntu vbox following [this](https://pcotret.github.io/microsemi_ubuntu/)
8. Download Softconsole from microsemi's website on ubuntu vbox

</p>
</details>

<details closed>
<summary>
2. Udev Rules
</summary>
<p>

- An example rule file can be found in `assets/udev/70-microsemi.rules`
- Switch the given group name to your respective choice for a group name.
- This group name has to be created on the ubuntu vbox/machine

</p>
</details>
