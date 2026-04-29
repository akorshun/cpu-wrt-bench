# CPU Benchmark for OpenWrt Devices
This script benchmarks CPU performance on OpenWrt devices using stress-ng.

It measures **Bogo Ops/s** for **int64** and **matrixprod** methods on both single-thread and multi-thread execution.

The results are printed as a Markdown-formatted table row, ready to be copied into the table below.  
Feel free to submit a pull request with benchmark results from your device.

## Run
> [!NOTE]
> Tested only OpenWrt

```
sh <(wget -O - https://raw.githubusercontent.com/itdoginfo/cpu-wrt-bench/refs/heads/main/cpu-wrt-bench.sh)
```

## Device Results
| Device                     | CPU                     | OpenWrt Version                  | CPU Threads  | int64 (1 Thread) | matrixprod (1 Thread)| int64 (ALL Threads) | matrixprod (ALL Threads) |
|----------------------------|-------------------------|----------------------------------|--------------|------------------|----------------------|---------------------|--------------------------|
| Xiaomi MiWiFi Nano         | MediaTek MT7628N        | OpenWrt 24.10.4                  | 1            | 21.97            | 4.58                 | 21.90               | 4.59                     |
| TP-Link TL-WR842N v3       | Atheros QCA9531         | OpenWrt 24.10.2                  | 1            | 24.27            | 4.37                 | 26.30               | 4.54                     |
| Beeline SmartBox TURBO+    | MediaTek MT7621A        | OpenWrt 24.10.1                  | 4            | 35.77            | 7.88                 | 92.83               | 17.94                    |
| Xunlong Orange Pi PC Plus  | H3 Quad-core Cortex-A7  | OpenWrt 24.10.0                  | 4            | 112.43           | 132.54               | 450.46              | 349.75                   |
| Depo Sky A60 / AK1100      | Marvell 88F6282         | OpenWrt 25.12.0                  | 1            | 115.87           | 18.00                | 116.20              | 18.15                    |
| FriendlyElec NanoPi R2S    | Rockchip RK3328         | OpenWrt 24.10.1                  | 4            | 286.60           | 10.80                | 1144.74             | 35.30                    |
| netis NX31                 | MediaTek MT7981B        | OpenWrt 24.10.1                  | 2            | 292.93           | 10.81                | 579.10              | 20.03                    |
| Xiaomi Mi Router AX3000T   | MediaTek MT7981BA       | OpenWrt 24.10.1                  | 2            | 291.67           | 10.89                | 581.33              | 19.86                    |
| Cudy TR3000                | MediaTek MT7981BA       | OpenWrt 24.10.4                  | 2            | 292.57           | 11.03                | 581.96              | 20.43                    |
| Cudy TR3000 256MB v1       | MediaTek MT7981BA       | OpenWrt 25.12.2                  | 2            | 313.70           | 11.01                | 602.27              | 19.97                    |
| Xiaomi Redmi Router AX6S   | MediaTek MT7622BV       | OpenWrt 24.10.2                  | 2            | 304.43           | 12.68                | 607.37              | 23.88                    |
| OrangePi Zero3             | Allwinner H618          | OpenWrt 24.10.2                  | 4            | 317.60           | 11.14                | 1078.89             | 37.04                    |
| FriendlyElec NanoPi R3S    | Rockchip RK3566         | OpenWrt 24.10.2                  | 4            | 419.93           | 17.65                | 1652.03             | 51.48                    |
| ASUS TUF-AX4200            | MediaTek MT7986A        | OpenWrt 24.10.2                  | 4            | 451.10           | 18.70                | 1799.76             | 56.75                    |
| Xiaomi Redmi Router AX6000 | MediaTek MT7986A        | OpenWrt 24.10.1                  | 4            | 451.73           | 18.78                | 1805.96             | 55.30                    |
| GL.iNet GL-MT6000          | MediaTek MT7986A        | OpenWrt 24.10.5                  | 4            | 447.03           | 18.48                | 1793.36             | 54.51                    |
| Bananapi BPI-R4            | MediaTek MT7988AV       | OpenWrt 24.10.4                  | 4            | 463.17           | 24.18                | 1845.56             | 94.76                    |
| ASUSTeK Z62FP              | Intel Core2 T7200       | OpenWrt 24.10.4                  | 2            | 840.77           | 706.54               | 1680.67             | 1289.96                  |
| Bananapi BPI-R4            | MediaTek MT7988AV       | OpenWrt 24.10-SNAPSHOT mtk-feed  | 4            | 896.83           | 24.15                | 3560.60             | 94.02                    |
| Radxa ROCK Pi 4B+          | Rockchip OP1 64-bit SoC | OpenWrt 24.10.2                  | 6            | 512.30           | 21.98                | 2146.80             | 80.34                    |
| LENOVO HuronRiver Platform | Intel Pentium B950      | OpenWrt 24.10.4                  | 2            | 1010.74          | 890.66               | 2020.07             | 1782.24                  |
| Radxa ROCK 5T              | Rockchip RK3588 (Perf)  | OpenWrt 25.12.1                  | 8            | 1058.36          | 43.34                | 5848.28             | 251.09                   |
| FriendlyElec NanoPi R6S    | Rockchip RK3588S        | OpenWrt 24.10.2                  | 8            | 1121.20          | 40.65                | 6178.90             | 237.73                   |
| Beelink EQ12               | Intel N100              | OpenWrt SNAPSHOT                 | 4            | 1415.47          | 2721.25              | 4909.74             | 4500.39                  |
| Beelink EQ14               | Intel N150              | OpenWrt SNAPSHOT                 | 4            | 1449.17          | 2440.35              | 4859.34             | 5417.66                  |


> [!NOTE]
> n/s - CPU not supported int128 method.

## RouterOS Device Results
| Device                  | CPU             | RouterOS Version |  CPU Threads | int64 (1 Thread) | matrixprod (1 Thread) | int64 (ALL Threads) | matrixprod (ALL Threads) |
|-------------------------|-----------------|-----------------|--------------|----------------|---------------------|-------------------|------------------------|
| aliexpress x86 router | intel N100 | RouterOS x86 | 4                      | 1587.47        | 2442.24             | 4134.63           | 4317.04                |
| Mikrotik RB5009UG+S | 88F7040 | RouterOS arm64 | 4                         | 640.61         | 22.09               | 2562.37           | 86.60                  |
| Mikrotik H53UiG-5HaxQ2HaxQ (Chateau PRO ax) | IPQ-8072A | RouterOS arm64 |4| 560.27         | 22.38               | 2214.59           | 64.17                  |
| Mikrotik C53UiG+5HPaxD2HPaxD (hAP ax³)| IPQ-6010 | RouterOS arm64 | 4      | 455.11         | 18.84               | 1815.39           | 57.21                  |
| Mikrotik C52iG-5HaxD2HaxD-TC (hAP ax²)| IPQ-6010 | RouterOS arm64 | 4      | 218.51         | 9.24                | 871.49            | 31.66                  |
| Mikrotik RBD53iG-5HacD2HnD (hAP ac³) | IPQ-4019 | RouterOS arm32  | 4      | 103.20         | 107.72              | 395.64            | 193.26                 |
| Mikrotik L41G (hAP ax lite) | IPQ-5010 | RouterOS arm32 | 2                | 137.87         | 33.56               | 272.74            | 33.88                  |
| Mikrotik E60iUGS (hEX S 2025) | EN7562CT | RouterOS armv5 | 2              | 113.14         | 21.39               | 225.71            | 37.92                  |

> [!NOTE]
> RouterOS devices tested with [wiktorbgu/tools:cpu-bench](https://hub.docker.com/r/wiktorbgu/tools/tags) docker container based on alpine-minirootfs-3.22.1, stress-ng 0.18.0
