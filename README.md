# Kria KD240

[![Hex version](https://img.shields.io/hexpm/v/nerves_system_kd240.svg "Hex version")](https://hex.pm/packages/nerves_system_kd240)

This is the base Nerves System configuration for the [Kria KD240](https://www.amd.com/ja/products/system-on-modules/kria/k24/kd240-drives-starter-kit.html).

The above image is obtained from AMD's official website
under the [Media Library Terms and Conditions](https://www.amd.com/en/corporate/newsroom-media-terms-conditions).

| Feature        | Description                                                                  |
| -------------- | ---------------------------------------------------------------------------- |
| CPU            | 1.333 GHz quad-core Cortex-A53                                               |
| Memory         | 2 GB DDR4                                                                    |
| Storage        | MicroSD, 512 Mb QSPI                                                         |
| Linux kernel   | [linux-xlnx](https://github.com/Xilinx/linux-xlnx)                           |
| IEx terminal   | UART (micro USB)                                                             |
| I2C            | [Elixir Circuits](https://github.com/elixir-circuits)                        |
| ADC            | No                                                                           |
| PWM            | No                                                                           |
| RS485          | 1 available - `ttyPS0`                                                       |
| Display        | No                                                                           |
| Camera         | No                                                                           |
| Ethernet       | 1 avaiable PS ethernet and 2 PL                                              |
| WiFi           | No                                                                           |
| Bluetooth      | No                                                                           |
| Audio          | No                                                                           |
| Pmod           | 1 available - 12-pin, Untested                                               |
| USB            | 2 available                                                                  |

## Using

The most common way of using this Nerves System is create a project with `mix
nerves.new` and to export `MIX_TARGET=kd240`. See the [Getting started guide](https://hexdocs.pm/nerves/getting-started.html#creating-a-new-nerves-app)
for more information.

If you need custom modifications to this system for your device, clone this
repository and update as described in [Making custom systems](https://hexdocs.pm/nerves/customizing-systems.html).

## Provisioning devices

This system supports storing provisioning information in a small key-value store
outside of any filesystem. Provisioning is an optional step and reasonable
defaults are provided if this is missing.

Provisioning information can be queried using the Nerves.Runtime KV store's
[`Nerves.Runtime.KV.get/1`](https://hexdocs.pm/nerves_runtime/Nerves.Runtime.KV.html#get/1) function.

Keys used by this system are:

| Key                    | Example Value | Description                                                                                                                               |
| :--------------------- | :------------ | :---------------------------------------------------------------------------------------------------------------------------------------- |
| `nerves_serial_number` | `"12345678"`  | By default, this string is used to create unique hostnames and Erlang node names. If unset, it defaults to 4-digits, part of MAC address. |

The normal procedure would be to set these keys once in manufacturing or before
deployment and then leave them alone.

For example, to provision a serial number on a running device, run the following
and reboot:

```elixir
iex> cmd("fw_setenv nerves_serial_number 12345678")
```

This system supports setting the serial number offline. To do this, set the
`NERVES_SERIAL_NUMBER` environment variable when burning the firmware. If you're
programming MicroSD cards using `fwup`, the commandline is:

```sh
sudo NERVES_SERIAL_NUMBER=12345678 fwup path_to_firmware.fw
```

Serial numbers are stored on the MicroSD card so if the MicroSD card is
replaced, the serial number will need to be reprogrammed. The numbers are stored
in a U-boot environment block. This is a special region that is separate from
the application partition so reformatting the application partition will not
lose the serial number or any other data stored in this block.

Additional key value pairs can be provisioned by overriding the default
provisioning.conf file location by setting the environment variable
`NERVES_PROVISIONING=/path/to/provisioning.conf`. The default provisioning.conf
will set the `nerves_serial_number`, if you override the location to this file,
you will be responsible for setting this yourself.

## FPGA

This system provides [dfx-mgr](https://github.com/Xilinx/dfx-mgr), so we can load/unload accelerators
by following steps.

- Add `dfx-mgrd` under the application supervisor, `lib/[project name]/application.ex`.  
   It's recommended to use [MuonTrap.Daemon](https://hexdocs.pm/muontrap/MuonTrap.Daemon.html).  
   **IMPORTANT**: `dfx-mgrd` must be to run on RW partition. (It writes state.txt on it...

```elixir
  def children(_target) do
    dfx_mgrd() ++
      [
        # Children for all targets except host
        # Starts a worker by calling: Kd240Demo.Worker.start_link(arg)
        # {Kd240Demo.Worker, arg},
      ]
  end

  defp dfx_mgrd() do
    dfx_mgrd = "/usr/bin/dfx-mgrd"

    if File.exists?(dfx_mgrd) do
      # nerves_system_kd240 provides `/lib/firmware` as tmpfs
      [{MuonTrap.Daemon, [dfx_mgrd, [], [cd: "/lib/firmware"]]}]
    else
      []
    end
  end
```

- load/unload accelerators by `dfx-mgr-client`.  
  It's recommended to create wrapper but following example use client directly :).

```
# list packages
iex()> cmd "dfx-mgr-client -listPackage"
                     Accelerator          Accel_type                            Base           Base_type      #slots(PL+AIE)         Active_slot

                k24-starter-kits            XRT_FLAT                k24-starter-kits            XRT_FLAT               (0+0)                  0
```

```
# unload
iex()> cmd "dfx-mgr-client -remove"
remove from slot 0 returns: 0 (Ok)
```

```
# load
iex()> cmd "dfx-mgr-client -load k24-starter-kits"
Loaded to slot 0
```

### About the default firmware

The default firmware can be specified by `rootfs_overlay/etc/dfx-mgrd/default_firmware`.

User can change it by your Nerves project's `rootfs_overlay/etc/dfx-mgrd/default_firmware`.

Would like to know more details? Let's read https://github.com/Xilinx/dfx-mgr/tree/xilinx_v2024.1#daemonconf.

**NOTE:This system specified `k24-starter-kits` for default, but doesn't include the firmware.**

### FAQ

Q: Where should accelerators be located?

A: Put them under your Nerves project's `rootfs_overlay/usr/lib/firmware/xilinx`.

### dfx-mgr details for DEV

1. `dfx-mgrd` needs some RW area.
   1. `/configfs`, literally [configfs](https://www.kernel.org/doc/Documentation/filesystems/configfs/configfs.txt)  
      We prepared it as configfs by erlinit, see. `rootfs_overlay/etc/erlinit.config`
   1. `/lib/firmware`, accelerator's `*.dtbo` is copied to here by `dfx-mgrd`  
      We prepared it as tmpfs by erlinit, see. `rootfs_overlay/etc/erlinit.config`
   1. `dfx-mgrd` must run on RW area, 'cause it writes some files to run.  
      We recommended to use tmpfs(RAM) for it.
