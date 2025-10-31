{ lib, ... }:

{
  # enable zswap by configuring it at boot by writing tmpfiles to the sysfs interface
  # we can't just enable zswap using the kernel params because those only work if zswap is built into the kernel
  # if you really want to use the kernel params, you could rebuild the kernel to include zswap
  # https://www.kernel.org/doc/html/latest/admin-guide/mm/zswap.html
  systemd.tmpfiles.rules = (
    lib.mapAttrsToList (n: v: "w /sys/module/zswap/parameters/${n}  - - - - ${toString v}") {
      enabled = true;

      # zstd is very fast, while still providing good compression ratios
      compressor = "zstd";

      # maximum percentage of RAM that zswap is allowed to use
      # 20% is the default, which seems reasonable
      max_pool_percent = "20";

      # whether to shrink the zswap pool proactively by moving pages to swap
      # enabling the shrinker seems to be better at punting cold pages to persistent storage according to https://github.com/torvalds/linux/commit/b5ba474f3f518701249598b35c581b92a3c95b48
      shrinker_enabled = "Y";
    }
  );

  # configure the swapfile for zswap to use
  # swapfile is stored on the rootfs, so it is trivially encrypted
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024; # 16GiB, in MiB
  } ];

}
