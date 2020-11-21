{
  description = ''
    DKMS module for controlling System76 Io board
  '';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/30d7b9341291dbe1e3361a5cca9052ee1437bc97;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux = 
      with import nixpkgs {
        system = "x86_64-linux";
      };
      stdenv.mkDerivation {
        name = "system76-io-dkms";
        #version = 1.0.1;
        src = fetchFromGitHub {
          owner = "pop-os";
          repo = "system76-io-dkms";
          rev = "1.0.1";
          sha256 = "0qkgkkjy1isv6ws6hrcal75dxjz98rpnvqbm7agdcc6yv0c17wwh";
        };

        hardeningDisable = [ "pic" ];
        dontStrip = true;
        dontPatchELF = true;

        kernel = linuxPackages_5_8.kernel.dev;
        nativeBuildInputs = linuxPackages_5_8.kernel.moduleBuildDependencies;

        preBuild = ''
          sed -e "s@/lib/modules/\$(.*)@${linuxPackages_5_8.kernel.dev}/lib/modules/${linuxPackages_5_8.kernel.modDirVersion}@" -i Makefile
        '';
        
        installPhase = ''
           mkdir -p $out/lib/modules/${linuxPackages_5_8.kernel.modDirVersion}/misc
           cp system76-io.ko $out/lib/modules/${linuxPackages_5_8.kernel.modDirVersion}/misc

           # not sure if these are working
           mkdir -p $out/usr/share/initramfs-tools/hooks
           cp {$src,$out}/usr/share/initramfs-tools/hooks/system76-io-dkms

           mkdir -p $out/usr/share/initramfs-tools/modules.d
           cp {$src,$out}/usr/share/initramfs-tools/modules.d/system76-io-dkms.conf
        '';
      };
  };
}
